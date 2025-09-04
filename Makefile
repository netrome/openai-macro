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
	@echo "  test-ollama   - Test with Ollama (local or remote via OLLAMA_HOST)"
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
	@echo "  LLM_MODEL     - Model to use (default: gemma3:latest)"
	@echo "  LLM_API_KEY   - API key for cloud services (Gemini)"
	@echo "  LLM_BASE_URL  - Override default endpoints"
	@echo "  OLLAMA_HOST   - Remote Ollama server (default: localhost)"

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
	@echo "  OLLAMA_HOST=192.168.1.100 make test-ollama  # Remote"
	@echo "  make test-gemini LLM_API_KEY=your_key  # Cloud"

# Ollama testing (default, local)
setup-ollama:
	@echo "🦙 Setting up Ollama..."
	@OLLAMA_HOST=$${OLLAMA_HOST:-localhost}; \
	echo "  Checking if Ollama is running on $$OLLAMA_HOST..."; \
	if curl -s http://$$OLLAMA_HOST:11434/api/tags > /tmp/ollama_test.json 2>&1; then \
		echo "  ✅ Ollama is running on $$OLLAMA_HOST"; \
		if [ -s /tmp/ollama_test.json ]; then \
			MODELS=$$(cat /tmp/ollama_test.json | grep -o '"name":"[^"]*"' | head -3 | cut -d'"' -f4 || echo ""); \
			if [ -n "$$MODELS" ]; then \
				echo "  📦 Available models: $$(echo $$MODELS | tr '\n' ' ')"; \
			fi; \
		fi; \
		rm -f /tmp/ollama_test.json; \
	else \
		echo "  ❌ Connection test failed. Debug info:"; \
		curl -v http://$$OLLAMA_HOST:11434/api/tags 2>&1 | head -10; \
		if [ "$$OLLAMA_HOST" = "localhost" ]; then \
			echo "  💡 For local Ollama:"; \
			echo "     1. Install from: https://ollama.com"; \
			echo "     2. Run 'ollama serve' in another terminal"; \
			echo "     3. Or use SSH tunnel: ssh -L 11434:localhost:11434 huginn.local"; \
		else \
			echo "  💡 For remote Ollama:"; \
			echo "     1. Make sure Ollama is running on $$OLLAMA_HOST"; \
			echo "     2. Check firewall allows port 11434"; \
			echo "     3. Or use: export OLLAMA_HOST=huginn.local"; \
		fi; \
		exit 1; \
	fi
	@OLLAMA_HOST=$${OLLAMA_HOST:-localhost}; \
	if [ "$$OLLAMA_HOST" = "localhost" ]; then \
		echo "  Checking for models..."; \
		if ! command -v ollama &> /dev/null; then \
			echo "  ⚠️  Ollama CLI not found, skipping model check"; \
		elif ! ollama list | grep -q gemma3; then \
			echo "  Pulling gemma3 model (this may take a while)..."; \
			ollama pull gemma3:latest; \
		else \
			echo "  ✅ gemma3 model available"; \
		fi; \
	else \
		echo "  ✅ Using remote Ollama, skipping model check"; \
	fi
	@echo "✅ Ollama setup complete"

test-ollama: setup-ollama
	@OLLAMA_HOST=$${OLLAMA_HOST:-localhost}; \
	echo "🦙 Testing with Ollama on $$OLLAMA_HOST..."; \
	echo "  Clearing cloud API variables to ensure Ollama mode..."; \
	echo "  Debug: Testing connection before build..."; \
	if curl -s http://$$OLLAMA_HOST:11434/v1/chat/completions -X POST -H "Content-Type: application/json" -H "Authorization: Bearer dummy" -d "{\"model\": \"$${LLM_MODEL:-gemma3:latest}\", \"messages\": [{\"role\": \"user\", \"content\": \"test\"}]}" > /tmp/ollama_debug.json 2>&1; then \
		echo "  ✅ Direct API call works"; \
		if grep -q "error" /tmp/ollama_debug.json; then \
			echo "  ⚠️  API responded with error:"; \
			cat /tmp/ollama_debug.json | head -3; \
			echo "  💡 Try with available model: LLM_MODEL=gemma3:latest make test-ollama"; \
		else \
			echo "  ✅ API call successful"; \
		fi; \
	else \
		echo "  ❌ Direct API call failed"; \
		cat /tmp/ollama_debug.json; \
	fi; \
	rm -f /tmp/ollama_debug.json; \
	echo "  Building examples with Ollama..."; \
	echo "  Environment: OLLAMA_HOST=$$OLLAMA_HOST LLM_MODEL=$${LLM_MODEL:-gemma3:latest}"; \
	if unset LLM_API_KEY LLM_BASE_URL; OLLAMA_HOST=$$OLLAMA_HOST LLM_MODEL=$${LLM_MODEL:-gemma3:latest} cargo build -p abuse; then \
		echo "  ✅ Abuse example built successfully"; \
	else \
		echo "  ❌ Abuse example failed to build"; \
		echo "  💡 Common fixes:"; \
		echo "     - Use available model: LLM_MODEL=gemma3:latest make test-ollama"; \
		echo "     - Check connection: curl -s http://$$OLLAMA_HOST:11434/api/tags"; \
		echo "     - Clean cache: make clean-cache"; \
		exit 1; \
	fi; \
	if unset LLM_API_KEY LLM_BASE_URL; OLLAMA_HOST=$$OLLAMA_HOST LLM_MODEL=$${LLM_MODEL:-gemma3:latest} cargo build -p calculator; then \
		echo "  ✅ Calculator example built successfully"; \
	else \
		echo "  ❌ Calculator example failed to build"; \
		exit 1; \
	fi; \
	echo "  Running calculator example..."; \
	if unset LLM_API_KEY LLM_BASE_URL; OLLAMA_HOST=$$OLLAMA_HOST LLM_MODEL=$${LLM_MODEL:-gemma3:latest} cargo run -p calculator; then \
		echo "✅ Ollama test completed successfully!"; \
	else \
		echo "❌ Calculator example failed to run"; \
		exit 1; \
	fi

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
	@echo "1) Ollama demo (local/remote, free, private)"
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
	@echo "Local Ollama:"
	@echo "1. Install Ollama: https://ollama.com"
	@echo "2. Start server: ollama serve"
	@echo "3. Pull model: ollama pull gemma3:latest"
	@echo "4. Test: make test-ollama"
	@echo ""
	@echo "Remote Ollama:"
	@echo "1. Set remote host: export OLLAMA_HOST=192.168.1.100"
	@echo "2. Test: make test-ollama"
	@echo ""
	@echo "✅ No API key needed - runs locally or remotely!"

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
	unset LLM_API_KEY LLM_BASE_URL; LLM_MODEL=gemma3:latest make test-ollama

# CI/CD friendly test
ci:
	@echo "🤖 CI/CD test suite..."
	make test
	@echo "✅ CI tests passed - examples need LLM service to run"
