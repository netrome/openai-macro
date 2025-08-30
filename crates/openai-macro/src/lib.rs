//! # OpenAI Macro
//!
//! A procedural macro that generates Rust code using OpenAI's API.
//!
//! ## Usage
//!
//! ```rust,ignore
//! use openai_macro::openai_impl;
//!
//! trait Calculator {
//!     fn add(&self, a: i32, b: i32) -> i32;
//!     fn multiply(&self, a: i32, b: i32) -> i32;
//! }
//!
//! struct MyCalculator;
//!
//! #[openai_impl(model = "gpt-4", prompt = "Implement basic arithmetic operations")]
//! impl Calculator for MyCalculator {}
//! ```
//!
//! ## Features
//!
//! - `no-network`: Disables network requests and uses only cached implementations

pub use openai_macro_impl::openai_impl;
