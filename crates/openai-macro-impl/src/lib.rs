use proc_macro::TokenStream;
use quote::{quote, ToTokens};
use sha2::{Digest, Sha256};
use std::{env, fs, path::PathBuf};
use syn::{parse_macro_input, punctuated::Punctuated, ItemImpl, Lit, Meta, MetaNameValue, Token};

#[proc_macro_attribute]
pub fn openai_impl(args: TokenStream, input: TokenStream) -> TokenStream {
    let args = parse_macro_input!(args with Punctuated::<Meta, Token![,]>::parse_terminated);
    let mut model: Option<String> = None;
    let mut prompt_hint: Option<String> = None;

    for arg in args {
        match arg {
            Meta::NameValue(MetaNameValue {
                path,
                value:
                    syn::Expr::Lit(syn::ExprLit {
                        lit: Lit::Str(val), ..
                    }),
                ..
            }) => {
                let key = path.to_token_stream().to_string();
                match key.as_str() {
                    "model" => model = Some(val.value()),
                    "prompt" => prompt_hint = Some(val.value()),
                    _ => {}
                }
            }
            _ => {}
        }
    }

    let item_impl = parse_macro_input!(input as ItemImpl);
    // We render the original impl header but replace fn bodies.
    let trait_path = item_impl
        .trait_
        .as_ref()
        .map(|(_, p, _)| p.to_token_stream().to_string());
    let self_ty = item_impl.self_ty.to_token_stream().to_string();

    // Collect method signatures for the prompt.
    let mut sigs = Vec::new();
    for item in &item_impl.items {
        if let syn::ImplItem::Fn(f) = item {
            sigs.push(f.sig.to_token_stream().to_string());
        }
    }

    // Build a deterministic cache key.
    let prompt_seed = format!(
        "trait={:?}\nself_ty={}\nmethods={:#?}\nprompt_hint={:?}",
        trait_path, self_ty, sigs, prompt_hint
    );
    let mut hasher = Sha256::new();
    hasher.update(prompt_seed.as_bytes());
    let key_hex = hex::encode(hasher.finalize());

    // Prepare OUT_DIR cache path
    let out_dir = env::var("OUT_DIR")
        .ok()
        .map(PathBuf::from)
        .unwrap_or_else(|| PathBuf::from("./target/openai-macro"));
    let cache_dir = out_dir.join("openai_impl_cache");
    let _ = fs::create_dir_all(&cache_dir);
    let cache_file = cache_dir.join(format!("{key_hex}.rs"));

    // Decide generation strategy.
    let offline =
        env::var("OPENAI_OFFLINE").ok().as_deref() == Some("1") || cfg!(feature = "no-network");

    let generated_impl = if offline && cache_file.exists() {
        fs::read_to_string(&cache_file).expect("read cache")
    } else {
        let mdl = model.unwrap_or_else(|| "gpt-4o-mini".to_string());
        let sys = r#"You are a Rust code generator. Return ONLY valid Rust code for method bodies.
Do not include backticks. Follow the provided signatures exactly.
If something is unspecified, make reasonable, deterministic choices.
Avoid external crates unless explicitly requested."#;

        let human = format!(
            r#"Implement the following Rust impl methods.
Do not change signatures. Provide only the method bodies (without 'fn' lines).
Context:
- Trait: {trait_path:?}
- Self type: {self_ty}
- Methods:
{methods}
Additional hint: {hint}"#,
            methods = sigs.join("\n"),
            hint = prompt_hint.unwrap_or_default(),
        );

        let code =
            call_openai(&mdl, &sys, &human).unwrap_or_else(|e| panic!("openai_impl error: {e:?}"));

        // Basic sanity: we expect one body per method, delimited.
        // Easiest contract: the model returns a JSON array of strings,
        // each string is the body for the corresponding method in order.
        // (We instruct this contract in `call_openai`.)
        let bodies: Vec<String> = serde_json::from_str(&code).unwrap_or_else(|_| vec![code]); // fallback: single blob

        // Stitch methods back into an impl block.
        synthesize_impl(&item_impl, &bodies)
            .unwrap_or_else(|e| panic!("synthesis error: {e}"))
            .to_string()
    };

    // Cache
    let _ = fs::write(&cache_file, &generated_impl);

    // Return tokens from the generated string.
    generated_impl.parse().unwrap()
}

fn synthesize_impl(
    item_impl: &ItemImpl,
    bodies: &[String],
) -> anyhow::Result<proc_macro2::TokenStream> {
    use anyhow::{bail, Context};

    // Rebuild the impl header
    let unsafety = &item_impl.unsafety;
    let impl_token = &item_impl.impl_token;
    let generics = &item_impl.generics;
    let self_ty = &item_impl.self_ty;

    // Handle trait implementation properly
    let trait_impl = if let Some((_, trait_path, _)) = &item_impl.trait_ {
        quote! { #trait_path for }
    } else {
        quote! {}
    };

    // Replace each fn body with a parsed body from `bodies` in order.
    let mut items = Vec::new();
    let mut body_iter = bodies.iter();
    for item in &item_impl.items {
        match item {
            syn::ImplItem::Fn(f) => {
                let mut f = f.clone();
                let body_src = body_iter
                    .next()
                    .with_context(|| "not enough bodies returned")?;

                // Parse `{ ... }` from the returned string; if the string didn't include braces, wrap it.
                let wrapped = if body_src.trim_start().starts_with('{') {
                    body_src.clone()
                } else {
                    format!("{{ {body_src} }}")
                };
                f.block = syn::parse_str::<syn::Block>(&wrapped)
                    .with_context(|| "failed to parse generated body into a block")?;
                items.push(syn::ImplItem::Fn(f));
            }
            other => items.push(other.clone()),
        }
    }
    if body_iter.next().is_some() {
        // Too many bodies
        bail!("too many bodies returned compared to fn methods");
    }

    let tokens = quote! {
        #unsafety #impl_token #generics #trait_impl #self_ty #generics {
            #(#items)*
        }
    };
    Ok(tokens)
}

#[derive(serde::Serialize)]
struct ChatReq<'a> {
    model: &'a str,
    messages: Vec<Msg<'a>>,
    response_format: Option<RespFormat>,
}

#[derive(serde::Serialize)]
struct Msg<'a> {
    role: &'a str,
    content: &'a str,
}

#[derive(serde::Serialize)]
#[serde(tag = "type", rename_all = "snake_case")]
enum RespFormat {
    JsonObject { schema: serde_json::Value },
}

// Returns a JSON string array of method bodies.
fn call_openai(model: &str, system: &str, user: &str) -> anyhow::Result<String> {
    use anyhow::{bail, Context};
    if cfg!(feature = "no-network") || env::var("OPENAI_OFFLINE").ok().as_deref() == Some("1") {
        bail!("network disabled (OPENAI_OFFLINE=1 or feature=no-network)");
    }

    let key = env::var("OPENAI_API_KEY").context("missing OPENAI_API_KEY")?;
    let base =
        env::var("OPENAI_BASE_URL").unwrap_or_else(|_| "https://api.openai.com/v1".to_string());

    // Ask the model to return JSON array of strings (bodies).
    let schema = serde_json::json!({
      "name":"impl_bodies",
      "schema":{
        "type":"object",
        "properties":{
          "bodies":{"type":"array","items":{"type":"string"}}
        },
        "required":["bodies"],
        "additionalProperties":false
      },
      "strict": true
    });

    let req = ChatReq {
        model,
        messages: vec![
            Msg {
                role: "system",
                content: system,
            },
            Msg {
                role: "user",
                content: user,
            },
            Msg {
                role: "user",
                content: "Return ONLY a strict JSON object like {\"bodies\":[\"{ /* body 1 */ }\", \"{ /* body 2 */ }\"]} \
                 where each string parses as a Rust block for the corresponding method, in order.",
            },
        ],
        response_format: Some(RespFormat::JsonObject { schema }),
    };

    let client = reqwest::blocking::Client::new();
    let resp = client
        .post(format!("{base}/chat/completions"))
        .bearer_auth(key)
        .json(&req)
        .send()
        .context("request failed")?
        .error_for_status()
        .context("non-200 response")?
        .text()
        .context("read body failed")?;

    // extract JSON content
    let v: serde_json::Value = serde_json::from_str(&resp).context("parse api json")?;
    let content = v["choices"][0]["message"]["content"]
        .as_str()
        .ok_or_else(|| anyhow::anyhow!("missing content"))?;

    // content itself should be a JSON object with "bodies"
    let j: serde_json::Value = serde_json::from_str(content).context("model didn't return JSON")?;
    let arr = &j["bodies"];
    if !arr.is_array() {
        return Ok(content.to_string());
    }
    Ok(arr.to_string())
}
