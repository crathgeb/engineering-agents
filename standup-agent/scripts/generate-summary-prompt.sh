#!/bin/bash

# Get today's date in YYYY-MM-DD format
TODAY=$(date +%Y-%m-%d)

# Directory paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BUILD_DIR="$PROJECT_DIR/build"
PROMPTS_DIR="$PROJECT_DIR/prompts"

# Output file
OUTPUT_FILE="$BUILD_DIR/summary-prompt.md"

# Check if prompt template exists
if [ ! -f "$PROMPTS_DIR/generate-summary.md" ]; then
    echo "Error: Prompt template not found at $PROMPTS_DIR/generate-summary.md"
    exit 1
fi

# Create build directory if it doesn't exist
mkdir -p "$BUILD_DIR"

echo "Creating summary prompt for $TODAY..."

# Start with the prompt template
cat "$PROMPTS_DIR/generate-summary.md" > "$OUTPUT_FILE"

# Add separator and header for daily reports
echo "" >> "$OUTPUT_FILE"
echo "---" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "# Daily Activity Reports for $TODAY" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# Find and concatenate all build files with today's date
found_files=false
for file in "$BUILD_DIR"/*_$TODAY.md; do
    if [ -f "$file" ]; then
        found_files=true
        echo "Adding $(basename "$file")..."
        
        # Add section header
        repo_name=$(basename "$file" "_$TODAY.md")
        echo "## $repo_name Daily Report" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        
        # Add file content
        cat "$file" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
        echo "---" >> "$OUTPUT_FILE"
        echo "" >> "$OUTPUT_FILE"
    fi
done

if [ "$found_files" = false ]; then
    echo "Warning: No daily activity files found for $TODAY in $BUILD_DIR"
    echo "Looking for files matching pattern: *_$TODAY.md"
    echo "" >> "$OUTPUT_FILE"
    echo "*No daily activity reports found for $TODAY*" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
fi

echo "Summary prompt created: $OUTPUT_FILE"
echo "Files included:"
echo "- Base prompt: $PROMPTS_DIR/generate-summary.md"
if [ "$found_files" = true ]; then
    for file in "$BUILD_DIR"/*_$TODAY.md; do
        if [ -f "$file" ]; then
            echo "- Daily report: $(basename "$file")"
        fi
    done
fi
