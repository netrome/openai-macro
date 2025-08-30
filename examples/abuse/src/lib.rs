use openai_macro::openai_impl;

pub trait Greeter {
    fn greet(&self, name: &str) -> String;
    fn exclaim(&self, text: &str) -> String;
}

pub struct Simple;

#[openai_impl(
    model = "gpt-4o-mini",
    prompt = "Be terse and deterministic. Use only std."
)]
impl Greeter for Simple {
    fn greet(&self, name: &str) -> String {
        /* filled by macro */
    }

    fn exclaim(&self, text: &str) -> String {
        /* filled by macro */
    }
}
