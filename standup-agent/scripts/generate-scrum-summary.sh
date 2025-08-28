#!/bin/bash

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"

# Input and output files
PROMPT_FILE="$BUILD_DIR/summary-prompt.md"
OUTPUT_FILE="$BUILD_DIR/summary.txt"

echo "Generating scrum summary using Claude..."

# Check if Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo "Error: Claude CLI not found. Please make sure it's installed and in your PATH."
    exit 1
fi

# Check if the prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: Summary prompt file not found at $PROMPT_FILE"
    echo "Please run generate-summary-prompt.sh first to create the prompt file."
    exit 1
fi

# Create build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

# Change to the script directory to ensure relative paths work correctly
cd "$SCRIPT_DIR"

echo "Using prompt file: $PROMPT_FILE"
echo "Output will be saved to: $OUTPUT_FILE"

# Run Claude with the prompt
if cat "../build/summary-prompt.md" | claude -p > "../build/summary.txt"; then
    echo "✅ Scrum summary generated successfully!"
    echo "Summary saved to: $OUTPUT_FILE"
    
    # Show a preview of the generated content
    echo ""
    echo "--- Preview (first 10 lines) ---"
    head -10 "$OUTPUT_FILE"
    echo "..."
    echo "--- End Preview ---"
    echo ""
    echo "Full summary available at: $OUTPUT_FILE"
else
    echo "❌ Error: Failed to generate scrum summary"
    echo "Please check that:"
    echo "- Claude CLI is properly configured"
    echo "- The prompt file is valid"
    echo "- You have proper permissions"
    exit 1
fi
