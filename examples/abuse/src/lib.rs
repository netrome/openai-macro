use llimp::llimp;

pub trait Greeter {
    fn greet(&self, name: &str) -> String;
    fn exclaim(&self, text: &str) -> String;
}

pub struct Simple;

#[llimp(prompt = "Be terse and deterministic. Use only std.")]
impl Greeter for Simple {
    fn greet(&self, name: &str) -> String {
        /* filled by macro */
    }

    fn exclaim(&self, text: &str) -> String {
        /* filled by macro */
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_generated_implementations() {
        let greeter = Simple;

        // Test that the AI-generated methods work
        let greeting = greeter.greet("World");
        let exclamation = greeter.exclaim("Hello");

        // Basic checks that something reasonable was generated
        assert!(!greeting.is_empty(), "greet should return non-empty string");
        assert!(
            !exclamation.is_empty(),
            "exclaim should return non-empty string"
        );

        println!("✅ Generated greeting: {}", greeting);
        println!("✅ Generated exclamation: {}", exclamation);
    }
}
