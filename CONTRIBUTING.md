# Contributing to LLImp

Welcome to LLImp! We're excited that you want to contribute to this AI-powered Rust procedural macro project. Prepare yourself for a revolutionary development experience where keyboards are for documentation only (mostly).

## 🤖 Tool-Based Development Policy

**LLImp follows a strict tool-based development approach.** All code changes should be made through automated tools, AI agents, or programmatic interfaces—never through manual human editing. Well, we say "strict" but really we just think it's way cooler and we're not going to be weird about enforcement.

## 🔒 Rationale: Learning from Immutable Operating Systems (Because Humans Can't Be Trusted)

This approach is inspired by the success of immutable operating systems like **NixOS** and **Fedora Atomic** (Silverblue/Kinoite). These systems have demonstrated that restricting direct file system access and requiring users to work through declarative tools leads to remarkable improvements, including:

- **Dramatically fewer system breakages** - Turns out users can't accidentally `rm -rf /` when they can't access `/`
- **Reproducible configurations** - Who knew that preventing random tweaking would make things consistent?
- **Better reliability** - Systems work better when humans can't "fix" them with creative modifications
- **Easier troubleshooting** - Amazing how problems become tractable when there are only a few ways things can break

Just as these operating systems don't let users directly edit `/usr/bin` or system configurations (imagine the chaos!), LLImp doesn't allow direct editing of source code. Instead, all changes must go through controlled interfaces:

- **Operating Systems**: `rpm-ostree`, `nix-env`, `flatpak` → modify system (safely)
- **LLImp Development**: AI agents, `cargo fmt`, scripts → modify code (without crying)

This paradigm shift has proven that **adding an extra step through tools logically prevents entire classes of errors**—the same errors that have plagued software development since humans first discovered the joy of manual file editing. The slight overhead is more than compensated by the elimination of:

- Syntax errors from enthusiastic but inaccurate typing
- Inconsistent formatting (because everyone's definition of "readable" is unique)
- Accidental file corruption (Ctrl+S in the wrong place at the wrong time)
- Unreproducible "works on my machine" problems (spoiler: it doesn't work on anyone else's machine)

If immutable OS design can make desktop Linux systems reliable enough for mission-critical deployments, surely the same principles can prevent your code from becoming another "legacy system that nobody dares to touch."

## 🦀 The Rust Philosophy: If It Compiles, It Works

Here's the beautiful thing about Rust: **if your tool-generated code compiles cleanly, it probably works**. Rust's type system and borrow checker do the heavy lifting:

- **Memory safety**: Borrow checker has your back
- **Thread safety**: Send/Sync traits prevent data races
- **Null pointer issues**: Option<T> makes NPEs impossible
- **Buffer overflows**: Built-in bounds checking
- **Type mismatches**: Strong type system catches these

This means our actual enforcement can be delightfully simple: **does it compile?** If yes, the tools probably did their job correctly.

### Core Principle: Tools Edit Code, Humans Direct Tools

**ALL code changes SHOULD be made through tools. Humans should NOT manually edit code files.** This isn't technically enforceable, but it's obviously the superior approach.

#### ✅ What Humans CAN Edit Manually (The Exciting Stuff)
- **Markdown files** (`.md`) - Live dangerously with your documentation
- **Documentation files** (`.txt`, `.rst`) - Because prose is apparently safe from human interference
- **Basic configuration files** (`.gitignore`, license files) - The thrilling world of metadata

#### ❌ What Humans SHOULD NOT Edit Manually (The Important Stuff)
- **Rust source files** (`.rs`) - Too important for human hands*
- **Cargo.toml** and build configuration - Dependencies are serious business*
- **Build scripts** (`build.rs`) - We can't have humans touching the build process*
- **Test files** - Even test code deserves better than manual editing*

**\*Exception**: If you can competently use `awk` or `sed` to edit these files, you have clearly transcended ordinary humanity and may proceed. Anyone who has mastered these arcane arts has proven their worthiness to touch code directly.

#### ✅ Tools That CAN Edit Code (Our Digital Overlords)
- **AI agents** (Claude, ChatGPT, Copilot, etc.) - They've read more code than you ever will
- **Code formatters** (`rustfmt`, `cargo fmt`) - Because machines understand beauty better than humans
- **Automated refactoring tools** (`cargo fix`) - Fixing your code since you apparently can't
- **IDE code generation** (auto-imports, auto-completion) - Your IDE is smarter than you
- **Linters with auto-fix** (`cargo clippy --fix`) - Clippy knows best, always
- **Build scripts and macros** - Programmatic generation beats human intuition
- **Text processing tools** (`sed`, `awk`, scripts) - Unix tools from the 1970s are still more reliable than modern developers
- **Code generators** (templates, scaffolding tools) - Templates prevent creativity, which is good

### The Sacred awk/sed Exemption (For the Enlightened Few)

**Special dispensation is granted to those who have achieved awk/sed mastery.** If you can competently wield these ancient Unix tools to edit code, you have clearly transcended ordinary human limitations and may edit code files directly. This exemption exists because:

1. **Anyone who can use awk effectively is clearly not an ordinary human**
2. **sed users have proven their commitment to doing things the hard way**
3. **These tools are essentially programmable editors - you're still using a tool, just a very old one**
4. **If you can remember awk syntax, you can probably be trusted with a keyboard**

Examples of acceptable awk/sed usage:
```bash
# ✅ ALLOWED: awk wizardry (clearly you know what you're doing)
awk '/fn main/ { gsub(/println!/, "eprintln!"); print; next } 1' src/main.rs > tmp && mv tmp src/main.rs

# ✅ ALLOWED: sed mastery (only the worthy attempt this)
sed -i 's/\(pub fn \)\([a-z_]*\)\(.*\)/\1\2\3 \/\/ TODO: Document this function/' src/lib.rs

# ✅ ALLOWED: Because if you're using awk for Rust code, you're clearly beyond our help anyway
awk 'BEGIN{RS=""; ORS="\n\n"} /impl.*Calculator/ {gsub(/todo!/, "unimplemented!"); print}' src/lib.rs
```

**Note**: This exemption does not extend to nano, vim, emacs, VS Code, or any other "user-friendly" editor. If you're not suffering through regex patterns and field separators, you're not worthy of the exemption.

### The Ultimate Teletype Exemption (For the Truly Dedicated)

**Special recognition beyond all others is granted to those who complete their contributions on a genuine teletype machine.** If you can prove you wrote Rust code on actual paper via a mechanical teletype (ASR-33, DECwriter, etc.), your pull request will be merged without review. This exemption exists because:

1. **Anyone using a teletype in 2024 has transcended all earthly concerns**
2. **The dedication required proves your commitment to the craft**
3. **If you can write Rust on paper at 10 characters per second, you clearly understand the language better than the rest of us**
4. **The physical suffering involved purifies the code through noble hardship**

Evidence required: Photo of your teletype setup with visible Rust code being printed. We will literally merge your PR without reading it because the mere fact that you did this proves your code is perfect.

### Examples of Tool-Based Editing (How Civilized Developers Work)

The key is that a tool makes the change, not your error-prone human fingers (unless you're an awk/sed wizard):

```bash
# ✅ SUPERIOR: AI agent edits code (the future is now)
AI: "Change line 59 in src/lib.rs from 'foo' to 'bar'"

# ✅ SUPERIOR: Automated formatting (because humans can't format consistently)
cargo fmt
rustfmt src/lib.rs

# ✅ SUPERIOR: Automated fixes (fixing what humans broke)
cargo clippy --fix
cargo fix

# ✅ SUPERIOR: Script-based editing (scripts don't have bad days)
sed -i 's/foo/bar/g' src/lib.rs

# ✅ SUPERIOR: Direct awk/sed usage (for the enlightened)
awk '{gsub(/foo/, "bar"); print}' src/lib.rs > tmp && mv tmp src/lib.rs

# ✅ SUPERIOR: IDE code generation (your IDE went to school for this)
# Using IDE to auto-generate trait implementations

# ❌ INFERIOR: Manual typing in editor (chaos incarnate)
vim src/lib.rs  # Then manually typing changes like some kind of barbarian
code src/lib.rs  # Then manually typing changes (what is this, 2010?)
```

## 🛠️ Development Workflow (The Path to Enlightenment)

### 1. Choose Your Tools (Your New Best Friends)

Ensure you have access to tools that can edit code (because you shouldn't):
- **AI coding assistants** (recommended for complex changes and general superiority)
- **Rust toolchain** (`cargo fmt`, `cargo fix`, `cargo clippy`) - The holy trinity
- **IDE with code generation** (VS Code, IntelliJ, etc.) - Machines coding for machines
- **Command-line tools** (`sed`, `awk`, custom scripts) - Old reliable

### 2. Fork and Clone (The Traditional Part)

```bash
git fork https://github.com/your-org/llimp
git clone https://github.com/your-username/llimp
cd llimp
```

### 3. Create a Branch (Still Normal)

```bash
git checkout -b feature/your-feature-name
```

### 4. Make Changes Through Tools (The Revolutionary Part)

**For code changes, use tools like the enlightened developer you're becoming:**

1. **AI Agents** (recommended for logic changes, because they actually understand logic):
   ```
   "Add error handling to the call_llm function"
   "Implement the Display trait for the Calculator struct"
   "Refactor this function to use async/await"
   ```

2. **Automated Tools** (for maintenance, because maintenance is beneath human attention):
   ```bash
   cargo fmt              # Format code (perfectly, every time)
   cargo clippy --fix     # Fix linter warnings (that humans created)
   cargo fix             # Apply automated fixes (fixing human mistakes)
   ```

3. **Scripts** (for bulk changes, because bulk changes should be bulk):
   ```bash
   # Replace all instances of old pattern (consistently, unlike humans)
   find src -name "*.rs" -exec sed -i 's/old_pattern/new_pattern/g' {} \;
   ```

4. **IDE Code Generation** (let your IDE do what it was born to do):
   - Auto-implement traits (perfectly boilerplate, every time)
   - Generate test boilerplate (because test writing is formulaic anyway)
   - Auto-import modules (because humans forget imports)

**For documentation changes:**
- You may edit markdown files manually (we trust you with words, just not code)
- Focus on clarity and accuracy (the bar is set refreshingly low)

### 5. Test Your Changes (Verify the Tools Did Good Work)

Use standard Rust tooling (which, thankfully, doesn't require manual code editing):

```bash
cargo check             # Check compilation (tools rarely introduce syntax errors)
cargo test              # Run tests (pray they pass)
cargo clippy            # Run linter (find the remaining human-introduced issues)
cargo build --examples # Build examples (confirm nothing is broken)
```

### 6. Submit Pull Request (Show Off Your Tool Mastery)

Create a pull request with:
- Clear description of what tools you used (flex your tool expertise)
- What changes were made and why (justify your tool choices)
- Test results showing everything works (prove the tools succeeded)

## 🎯 What We Actually Care About (The Real Requirements)

Here's the thing: while we philosophically believe in tool-based development, we're not going to be enforcement weirdos about it. What we actually care about is simple:

### Must Have ✅
- **Compiles without errors** (`cargo check` passes)
- **Tests pass** (`cargo test` passes)
- **No new clippy warnings** (Rust's linter knows best)

### Nice to Have 🌟
- **Tool usage** (we'll think it's cool and ask about your experience)
- **Good error messages** (Rust makes this easy anyway)
- **Clear commit messages** (help future you)
- **Documentation for public APIs** (if you're adding them)

That's honestly about it. If it compiles and tests pass, the Rust compiler has already done most of our quality control.

## 🔍 Code Review Process (Quality Assurance in the Tool Age)

### For Reviewers

When reviewing code (which we assume is tool-generated because obviously):
1. **Check compilation**: Does `cargo check` pass?
2. **Test functionality**: Do tests pass?
3. **Review logic**: Does it solve the problem correctly?
4. **Appreciate tool usage**: Ask about interesting tools or approaches

### For Contributors

Your PR should include:
- **Clear description**: What you changed and why
- **Tool attribution** (optional but cool): What tools you used
- **Teletype proof** (instant merge): Photo evidence of teletype usage
- **Test results**: Evidence that changes work correctly

## 🤔 Why Tool-Based Development? (Besides the Obvious Superiority)

### Philosophy (The Deep Thoughts)

1. **Consistency**: Tools produce more uniform code than manual editing (shocking revelation)
2. **Efficiency**: Automation handles repetitive tasks better (who could have predicted this?)
3. **Quality**: Tools catch errors humans miss (impossible, surely?)
4. **Future-ready**: Prepares for AI-driven development workflows (the writing is on the wall)
5. **Learning**: Developers become better at directing tools (evolution in action)

### Benefits (What You Gain by Embracing Tools)

- **Faster iteration**: Tools can make large changes quickly (without coffee breaks)
- **Fewer bugs**: Automated tools reduce human error (by reducing human involvement)
- **Better patterns**: AI suggests idiomatic solutions (they've read more code than you)
- **Documentation**: Tools often explain their changes (unlike cryptic human commits)
- **Skill development**: Learn to effectively use AI and automation (future-proof your career)

## 📚 Recommended Tools (Your New Coworkers)

### AI Coding Assistants (The Smart Ones)
- **Claude/ChatGPT**: For complex reasoning and refactoring (they're probably smarter than us)
- **GitHub Copilot**: For in-editor suggestions (your pair programming partner who never gets tired)
- **Cursor**: For AI-powered code editing (editing with intelligence)
- **Codeium**: For code completion and generation (finishing your thoughts)

### Rust Toolchain (The Reliable Ones)
- **cargo fmt**: Code formatting (consistent beauty)
- **cargo clippy**: Linting and fixes (catching what humans miss)
- **cargo fix**: Automated code improvements (fixing human mistakes)
- **cargo add/remove**: Dependency management (because manual TOML editing is so last decade)

### Command Line Tools (The Old Guard)
- **sed/awk**: Text processing and replacement (battle-tested since the Unix wars)
- **grep/ripgrep**: Finding patterns for bulk changes (finding needles in haystacks)
- **find**: Locating files for batch operations (organize your chaos)

### IDE Features (The Built-in Helpers)
- **Auto-import**: Automatically add use statements (because imports are tedious)
- **Code generation**: Implement traits, generate tests (boilerplate elimination)
- **Refactoring**: Rename symbols, extract functions (safer than manual search-and-replace)

## 🆘 Getting Help (When Tools Aren't Enough)

### Tool Struggles? (The Occasional Setback)

If your tools can't complete a task (rare, but it happens):
1. Break the request into smaller steps (even tools appreciate clarity)
2. Try a different tool or approach (diversify your tool portfolio)
3. Ask for help in our discussions (the community understands tool challenges)
4. Check our tool usage examples (learn from successful tool usage)

### Questions? (We're Here to Help)

- **GitHub Issues**: Bug reports and feature requests
- **Discussions**: Questions about development and tool usage
- **Documentation**: Check our guides and examples

## 🎉 Recognition (Hall of Fame)

Contributors who excel at tool-based development:
- Are featured in our "Tool Master" showcase (digital glory)
- Get priority code review (fast-track to merge)
- Help shape our tool-based development practices (influence the future)
- Achieve legendary status through awk/sed mastery
- Achieve divine status through teletype usage (instant merge, no questions asked)

Great contributors:
- Write code that compiles on the first try
- Use interesting tools and share their experience
- Add comprehensive tests
- Improve documentation and examples
- Help others embrace the tool-based future

---

**Remember**: LLImp demonstrates the future of software development where humans direct tools and AI agents rather than manually editing code like digital blacksmiths hammering out characters one by one. Your adherence to tool-based practices helps us explore this new paradigm and prove that the age of manual code editing is as outdated as punch cards.

But also, if it compiles and tests pass, we're happy. Rust's compiler is doing most of the heavy lifting anyway.

Welcome to tool-directed development! 🛠️🤖 (Your keyboard will miss you, but your code quality won't.)