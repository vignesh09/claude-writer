#!/bin/bash
# Unpublish Command - Move published content back to drafts
# Usage: This is called by Claude when user runs /unpublish

set -e

TOPIC_SLUG="$1"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Unpublishing content for: ${TOPIC_SLUG}${NC}"

# Find all published files matching the topic
ARTICLE=$(find published/ -name "article-${TOPIC_SLUG}-*.md" 2>/dev/null | head -1)
LINKEDIN=$(find published/ -name "linkedin-${TOPIC_SLUG}-*.md" 2>/dev/null | head -1)
NEWSLETTER=$(find published/ -name "newsletter-${TOPIC_SLUG}-*.md" 2>/dev/null | head -1)
SOCIAL=$(find published/ -name "social-${TOPIC_SLUG}-*.md" 2>/dev/null | head -1)
RESEARCH=$(find research/archive/ -name "research-brief-${TOPIC_SLUG}-*.md" 2>/dev/null | head -1)

# Check if files exist
if [ -z "$ARTICLE" ]; then
    echo -e "${RED}Error: No published article found for topic '${TOPIC_SLUG}'${NC}"
    echo "Available published articles:"
    ls -1 published/article-*.md 2>/dev/null || echo "  (no articles found)"
    exit 1
fi

# Count files to unpublish
COUNT=0
[ -n "$ARTICLE" ] && ((COUNT++)) || true
[ -n "$LINKEDIN" ] && ((COUNT++)) || true
[ -n "$NEWSLETTER" ] && ((COUNT++)) || true
[ -n "$SOCIAL" ] && ((COUNT++)) || true

echo -e "${GREEN}✓ Found ${COUNT} published files${NC}"
[ -n "$RESEARCH" ] && echo -e "${GREEN}✓ Found archived research${NC}"

# Function to update metadata
update_metadata() {
    local file=$1
    local temp_file="${file}.tmp"

    # Update status in frontmatter
    if grep -q "^status: published$" "$file"; then
        sed 's/^status: published$/status: draft/' "$file" > "$temp_file"
        mv "$temp_file" "$file"
    fi
}

# Update metadata for each file
echo ""
echo "Updating metadata to draft status..."
[ -n "$ARTICLE" ] && update_metadata "$ARTICLE" && echo "  ✓ Article"
[ -n "$LINKEDIN" ] && update_metadata "$LINKEDIN" && echo "  ✓ LinkedIn"
[ -n "$NEWSLETTER" ] && update_metadata "$NEWSLETTER" && echo "  ✓ Newsletter"
[ -n "$SOCIAL" ] && update_metadata "$SOCIAL" && echo "  ✓ Social"

# Move files back to drafts
echo ""
echo "Moving to drafts folder..."
[ -n "$ARTICLE" ] && mv "$ARTICLE" "drafts/" && echo "  ✓ $(basename "$ARTICLE")"
[ -n "$LINKEDIN" ] && mv "$LINKEDIN" "drafts/" && echo "  ✓ $(basename "$LINKEDIN")"
[ -n "$NEWSLETTER" ] && mv "$NEWSLETTER" "drafts/" && echo "  ✓ $(basename "$NEWSLETTER")"
[ -n "$SOCIAL" ] && mv "$SOCIAL" "drafts/" && echo "  ✓ $(basename "$SOCIAL")"

# Restore research from archive
if [ -n "$RESEARCH" ]; then
    echo ""
    echo "Restoring research from archive..."
    mv "$RESEARCH" "research/"
    echo "  ✓ $(basename "$RESEARCH")"
fi

# Extract original date from published article
ORIGINAL_DATE=$(echo "$ARTICLE" | grep -oP '\d{4}-\d{2}-\d{2}')

# Restore theme analysis from archive (matches same date as article)
THEME_ANALYSIS=$(find research/archive/ -type f -name "theme-analysis-${ORIGINAL_DATE}.md" 2>/dev/null | head -1)
if [ -n "$THEME_ANALYSIS" ]; then
    echo ""
    echo "Restoring theme analysis from archive..."
    mv "$THEME_ANALYSIS" "research/"
    echo "  ✓ $(basename "$THEME_ANALYSIS")"
fi

# Note: Raw notes are NOT restored automatically as they're generic
# If you need them, manually move from rawnotes/archive/

# Remove entry from INDEX.md
echo ""
echo "Updating archive index..."
# This is a simplified removal - in production you might want more sophisticated removal
RESEARCH_NAME=$(basename "$RESEARCH")
sed -i "/$(basename "$ARTICLE")/,+5d" research/archive/INDEX.md 2>/dev/null || true
echo -e "${GREEN}✓ Updated INDEX.md${NC}"

# Summary
echo ""
echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}Unpublication complete!${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""
echo "Restored to drafts:"
[ -n "$ARTICLE" ] && echo "  • $(basename "$ARTICLE")"
[ -n "$LINKEDIN" ] && echo "  • $(basename "$LINKEDIN")"
[ -n "$NEWSLETTER" ] && echo "  • $(basename "$NEWSLETTER")"
[ -n "$SOCIAL" ] && echo "  • $(basename "$SOCIAL")"
echo ""
echo "Files moved to: drafts/"
[ -n "$RESEARCH" ] && echo "Research restored to: research/"
[ -n "$THEME_ANALYSIS" ] && echo "Theme analysis restored to: research/"
echo ""
echo -e "${YELLOW}Note: This topic can now be re-researched if needed.${NC}"
echo -e "${YELLOW}Note: Raw notes remain in rawnotes/archive/ (restore manually if needed).${NC}"
