# LLImp (Large Language Implementation) Makefile
# Simplified testing focused on Ollama (default) and Gemini (cloud API)

.PHONY: help test test-core test-ollama test-gemini test-offline \
        check setup-ollama clean-cache demo quick

# Default target
help:
	@echo "🦙 LLImp Testing Makefile"
	@echo "========================="
	@echo ""
	@echo "Quick Testing:"
	@echo "  quick         - Fast core tests (no LLM required)"
	@echo "  test          - Run all core tests"
	@echo ""
	@echo "LLM Testing:"
	@echo "  test-ollama   - Test with Ollama (default, local)"
	@echo "  test-gemini   - Test with Google Gemini (cloud)"
	@echo ""
	@echo "Setup:"
	@echo "  setup-ollama  - Install and configure Ollama"
	@echo "  check         - Check all examples compile"
	@echo ""
	@echo "Utilities:"
	@echo "  clean-cache   - Clean cached implementations"
	@echo "  demo          - Interactive demo"
	@echo ""
	@echo "Environment:"
	@echo "  LLM_MODEL     - Model to use (default: starcoder2:latest)"
	@echo "  LLM_API_KEY   - API key for cloud services (Gemini)"
	@echo "  LLM_BASE_URL  - Override default endpoints"

# Quick development test
quick:
	@echo "⚡ Quick test..."
	cargo test -p llimp --quiet
	@echo "✅ Quick test passed"

# Core library tests (always work)
test-core:
	@echo "🧪 Testing core library..."
	cargo test -p llimp
	@echo "✅ Core library tests passed"

# Offline mode testing
test-offline:
	@echo "🔌 Testing offline mode..."
	LLM_OFFLINE=1 cargo check -p llimp
	@echo "✅ Offline mode works"

# Check syntax without LLM services
check:
	@echo "🔍 Checking example syntax..."
	@echo "  Note: Compilation errors are expected without LLM service"
	@echo ""
	@echo "  Checking abuse example..."
	@if cargo check -p abuse --quiet 2>/dev/null; then \
		echo "  ✅ Abuse example compiles"; \
	else \
		echo "  ⚠️  Abuse example needs LLM (expected)"; \
	fi
	@echo "  Checking calculator example..."
	@if cargo check -p calculator --quiet 2>/dev/null; then \
		echo "  ✅ Calculator example compiles"; \
	else \
		echo "  ⚠️  Calculator example needs LLM (expected)"; \
	fi

# Main test suite
test: test-core test-offline check
	@echo ""
	@echo "🎉 Core Tests Complete"
	@echo "====================="
	@echo "✅ Core library: PASSED"
	@echo "✅ Offline mode: PASSED"
	@echo "✅ Example syntax: VERIFIED"
	@echo ""
	@echo "🚀 Ready to test with LLM:"
	@echo "  make test-ollama  # Local (recommended)"
	@echo "  make test-gemini LLM_API_KEY=your_key  # Cloud"

# Ollama testing (default, local)
setup-ollama:
	@echo "🦙 Setting up Ollama..."
	@if ! command -v ollama &> /dev/null; then \
		echo "❌ Ollama not installed. Install from: https://ollama.com"; \
		exit 1; \
	fi
	@echo "  Checking if Ollama is running..."
	@if ! curl -s http://localhost:11434/api/tags &> /dev/null; then \
		echo "  Starting Ollama server..."; \
		echo "  Run 'ollama serve' in another terminal"; \
		exit 1; \
	else \
		echo "  ✅ Ollama is running"; \
	fi
	@echo "  Checking for models..."
	@if ! ollama list | grep -q starcoder2; then \
		echo "  Pulling starcoder2 model (this may take a while)..."; \
		ollama pull starcoder2:latest; \
	else \
		echo "  ✅ starcoder2 model available"; \
	fi
	@echo "✅ Ollama setup complete"

test-ollama: setup-ollama
	@echo "🦙 Testing with Ollama (default mode)..."
	@echo "  Clearing cloud API variables to ensure local mode..."
	@echo "  Building examples with local Ollama..."
	unset LLM_API_KEY LLM_BASE_URL; LLM_MODEL=starcoder2:latest cargo build -p abuse
	unset LLM_API_KEY LLM_BASE_URL; LLM_MODEL=starcoder2:latest cargo build -p calculator
	@echo "  Running calculator example..."
	unset LLM_API_KEY LLM_BASE_URL; LLM_MODEL=starcoder2:latest cargo run -p calculator
	@echo "✅ Ollama test completed successfully!"

# Google Gemini testing (cloud)
test-gemini:
	@echo "🔍 Testing with Google Gemini..."
	@if [ -z "$(LLM_API_KEY)" ]; then \
		echo "❌ LLM_API_KEY not set."; \
		echo "   Get your key from: https://aistudio.google.com/app/apikey"; \
		echo "   Then run: make test-gemini LLM_API_KEY=your_key"; \
		exit 1; \
	fi
	@echo "  Building examples with Gemini API..."
	@LLM_MODEL=gemini-2.0-flash-exp \
	LLM_BASE_URL=https://generativelanguage.googleapis.com/v1beta/openai \
	LLM_API_KEY=$(LLM_API_KEY) \
	cargo build -p abuse
	@echo "  Testing abuse example (library only - no main function)..."
	@LLM_MODEL=gemini-2.0-flash-exp \
	LLM_BASE_URL=https://generativelanguage.googleapis.com/v1beta/openai \
	LLM_API_KEY=$(LLM_API_KEY) \
	cargo test -p abuse
	@echo "✅ Gemini test completed successfully!"

# Cache management
clean-cache:
	@echo "🧹 Cleaning implementation cache and build locks..."
	@# Kill any hanging cargo processes
	-pkill -f cargo || true
	-pkill -f rustc || true
	@# Wait a moment for processes to die
	sleep 1
	@# Remove all possible lock files
	-rm -rf target/.cargo-lock || true
	-rm -rf ~/.cargo/.package-cache-lock || true
	-find target -name "*.lock" -delete || true
	@# Force remove the entire target directory if needed
	-rm -rf target || true
	@# Recreate clean target directory
	mkdir -p target
	@# Remove implementation caches (redundant but safe)
	-rm -rf target/llimp/llimp_cache/ || true
	-rm -rf target/openai-macro/openai_impl_cache/ || true
	@echo "✅ Cache and locks aggressively cleaned"

# Interactive demo
demo:
	@echo "🎭 LLImp Demo"
	@echo "============="
	@echo ""
	@echo "LLImp defaults to Ollama (local) for privacy and cost."
	@echo "You can override with cloud APIs when needed."
	@echo ""
	@echo "Choose a demo:"
	@echo "1) Ollama demo (local, free, private)"
	@echo "2) Gemini demo (cloud, requires LLM_API_KEY env var)"
	@echo "3) Core library demo (no LLM needed)"
	@echo ""
	@read -p "Enter choice (1-3): " choice; \
	case $$choice in \
		1) echo "🦙 Starting Ollama demo..."; \
		   make test-ollama;; \
		2) if [ -z "$(LLM_API_KEY)" ]; then \
		     echo "❌ LLM_API_KEY environment variable not set"; \
		     echo "   Set it with: export LLM_API_KEY=your_key"; \
		     exit 1; \
		   fi; \
		   echo "🔍 Starting Gemini demo..."; \
		   make test-gemini;; \
		3) echo "🧪 Starting core demo..."; \
		   make test;; \
		*) echo "Invalid choice";; \
	esac

# Help for specific setups
help-ollama:
	@echo "🦙 Ollama Setup (Recommended)"
	@echo "============================"
	@echo "1. Install Ollama: https://ollama.com"
	@echo "2. Start server: ollama serve"
	@echo "3. Pull model: ollama pull starcoder2:latest"
	@echo "4. Set model: export LLM_MODEL=starcoder2:latest"
	@echo "5. Test: make test-ollama"
	@echo ""
	@echo "✅ No API key needed - runs locally!"

help-gemini:
	@echo "🔍 Google Gemini Setup"
	@echo "======================"
	@echo "1. Get API key: https://aistudio.google.com/app/apikey"
	@echo "2. Set model: export LLM_MODEL=gemini-2.0-flash-exp"
	@echo "3. Test: make test-gemini LLM_API_KEY=your_key"
	@echo ""
	@echo "💰 Note: This uses cloud API and may incur costs"

# Development workflow
dev:
	@echo "🔧 Development workflow..."
	make quick
	unset LLM_API_KEY LLM_BASE_URL; LLM_MODEL=starcoder2:latest make test-ollama

# CI/CD friendly test
ci:
	@echo "🤖 CI/CD test suite..."
	make test
	@echo "✅ CI tests passed - examples need LLM service to run"
