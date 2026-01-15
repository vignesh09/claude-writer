#!/bin/bash
# Publish Command - Move drafts to published and archive research
# Usage: This is called by Claude when user runs /publish

set -e

TOPIC_SLUG="$1"
PUBLISH_DATE=$(date +%Y-%m-%d)

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Publishing content for: ${TOPIC_SLUG}${NC}"

# Find all draft files matching the topic
ARTICLE=$(find drafts/ -type f -name "article-${TOPIC_SLUG}-*.md" 2>/dev/null | head -1)
LINKEDIN=$(find drafts/ -type f -name "linkedin-${TOPIC_SLUG}-*.md" 2>/dev/null | head -1)
NEWSLETTER=$(find drafts/ -type f -name "newsletter-${TOPIC_SLUG}-*.md" 2>/dev/null | head -1)
SOCIAL=$(find drafts/ -type f -name "social-${TOPIC_SLUG}-*.md" 2>/dev/null | head -1)
RESEARCH=$(find research/ -type f -name "research-brief-${TOPIC_SLUG}-*.md" -not -path "*/archive/*" 2>/dev/null | head -1)

# Check if files exist
if [ -z "$ARTICLE" ]; then
    echo -e "${RED}Error: No article found for topic '${TOPIC_SLUG}'${NC}"
    echo "Available drafts:"
    ls -1 drafts/article-*.md 2>/dev/null || echo "  (no articles found)"
    exit 1
fi

# Count files to publish
COUNT=0
[ -n "$ARTICLE" ] && ((COUNT++)) || true
[ -n "$LINKEDIN" ] && ((COUNT++)) || true
[ -n "$NEWSLETTER" ] && ((COUNT++)) || true
[ -n "$SOCIAL" ] && ((COUNT++)) || true

echo -e "${GREEN}✓ Found ${COUNT} draft files${NC}"
[ -n "$RESEARCH" ] && echo -e "${GREEN}✓ Found research brief${NC}"

# Extract original date from filename
ORIGINAL_DATE=$(echo "$ARTICLE" | grep -oP '\d{4}-\d{2}-\d{2}')

# Function to add metadata to file
add_metadata() {
    local file=$1
    local platform=$2
    local temp_file="${file}.tmp"

    # Check if file starts with YAML frontmatter (first line is ---)
    if head -1 "$file" | grep -q "^---$"; then
        # Has frontmatter - remove it (everything until second ---)
        awk '/^---$/{if(++count==2){flag=1;next}}flag' "$file" > "$temp_file"
    else
        # No frontmatter - copy entire file
        cp "$file" "$temp_file"
    fi

    # Add new frontmatter
    {
        echo "---"
        echo "status: published"
        echo "published_date: ${PUBLISH_DATE}"
        echo "original_draft_date: ${ORIGINAL_DATE}"
        echo "platform: ${platform}"
        [ -n "$RESEARCH" ] && echo "research_source: $(basename "$RESEARCH")"
        echo "---"
        echo ""
        cat "$temp_file"
    } > "${file}.new"

    mv "${file}.new" "$file"
    rm "$temp_file"
}

# Add metadata to each file
echo ""
echo "Adding publication metadata..."
[ -n "$ARTICLE" ] && add_metadata "$ARTICLE" "article" && echo "  ✓ Article"
[ -n "$LINKEDIN" ] && add_metadata "$LINKEDIN" "linkedin" && echo "  ✓ LinkedIn"
[ -n "$NEWSLETTER" ] && add_metadata "$NEWSLETTER" "newsletter" && echo "  ✓ Newsletter"
[ -n "$SOCIAL" ] && add_metadata "$SOCIAL" "social" && echo "  ✓ Social"

# Move files to published
echo ""
echo "Moving to published folder..."
[ -n "$ARTICLE" ] && mv "$ARTICLE" "published/" && echo "  ✓ $(basename "$ARTICLE")"
[ -n "$LINKEDIN" ] && mv "$LINKEDIN" "published/" && echo "  ✓ $(basename "$LINKEDIN")"
[ -n "$NEWSLETTER" ] && mv "$NEWSLETTER" "published/" && echo "  ✓ $(basename "$NEWSLETTER")"
[ -n "$SOCIAL" ] && mv "$SOCIAL" "published/" && echo "  ✓ $(basename "$SOCIAL")"

# Archive research if found
if [ -n "$RESEARCH" ]; then
    echo ""
    echo "Archiving research..."
    mv "$RESEARCH" "research/archive/"
    echo "  ✓ $(basename "$RESEARCH")"
fi

# Archive theme analysis if found (matches same date as article)
THEME_ANALYSIS=$(find research/ -type f -name "theme-analysis-${ORIGINAL_DATE}.md" -not -path "*/archive/*" 2>/dev/null | head -1)
if [ -n "$THEME_ANALYSIS" ]; then
    echo ""
    echo "Archiving theme analysis..."
    mv "$THEME_ANALYSIS" "research/archive/"
    echo "  ✓ $(basename "$THEME_ANALYSIS")"
fi

# Archive raw notes (move all .txt files to archive)
RAW_NOTES=$(find rawnotes/ -type f -name "*.txt" 2>/dev/null)
if [ -n "$RAW_NOTES" ]; then
    echo ""
    echo "Archiving raw notes..."
    while IFS= read -r note; do
        if [ -f "$note" ]; then
            mv "$note" "rawnotes/archive/"
            echo "  ✓ $(basename "$note")"
        fi
    done <<< "$RAW_NOTES"
fi

# Update INDEX.md
echo ""
echo "Updating archive index..."

# Extract topic name from article title
TOPIC_NAME=$(grep -m1 "^# " "published/$(basename "$ARTICLE")" | sed 's/^# //')

# Add entry to INDEX
{
    echo ""
    echo "### ${PUBLISH_DATE} - ${TOPIC_NAME}"
    echo ""
    [ -n "$THEME_ANALYSIS" ] && echo "- **Theme Analysis**: \`$(basename "$THEME_ANALYSIS")\`"
    [ -n "$RESEARCH" ] && echo "- **Research**: \`$(basename "$RESEARCH")\`"
    echo "- **Article**: \`$(basename "$ARTICLE")\`"
    [ -n "$LINKEDIN" ] && echo "- **LinkedIn**: \`$(basename "$LINKEDIN")\`"
    [ -n "$NEWSLETTER" ] && echo "- **Newsletter**: \`$(basename "$NEWSLETTER")\`"
    [ -n "$SOCIAL" ] && echo "- **Social**: \`$(basename "$SOCIAL")\`"
} >> research/archive/INDEX.md

echo -e "${GREEN}✓ Updated INDEX.md${NC}"

# Summary
echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Publication complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Published content:"
[ -n "$ARTICLE" ] && echo "  • $(basename "$ARTICLE")"
[ -n "$LINKEDIN" ] && echo "  • $(basename "$LINKEDIN")"
[ -n "$NEWSLETTER" ] && echo "  • $(basename "$NEWSLETTER")"
[ -n "$SOCIAL" ] && echo "  • $(basename "$SOCIAL")"
echo ""
echo "Files moved to: published/"
[ -n "$RESEARCH" ] && echo "Research archived to: research/archive/"
[ -n "$THEME_ANALYSIS" ] && echo "Theme analysis archived to: research/archive/"
[ -n "$RAW_NOTES" ] && echo "Raw notes archived to: rawnotes/archive/"
echo ""
echo "Use \`/unpublish ${TOPIC_SLUG}\` to reverse this action."
