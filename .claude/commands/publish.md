# Publish Command

Use this command to mark articles as published and archive the associated research.

## Usage
`/publish [topic-slug]` or `/publish [date]`

## What This Command Does
1. Moves all draft files for a topic to the published folder
2. Archives the associated research brief
3. Archives the theme analysis file (if exists for same date)
4. Archives all raw notes (.txt files) to keep rawnotes folder clean
5. Adds publication metadata to all files
6. Organizes published content by date
7. Updates tracking to exclude this research from future queries

## Process
### Step 1: Identify Content
- Find all files matching the topic slug or date pattern
- Locate: article, LinkedIn, newsletter, social versions
- Locate: associated research brief

### Step 2: Add Publication Metadata
Add to the top of each file (after title):
```markdown
---
status: published
published_date: [YYYY-MM-DD]
original_draft_date: [YYYY-MM-DD]
platforms: [article, linkedin, newsletter, social]
---
```

### Step 3: Move Files
- **Drafts → Published**: Move all draft versions to `published/`
  - `drafts/article-[topic]-[date].md` → `published/article-[topic]-[date].md`
  - `drafts/linkedin-[topic]-[date].md` → `published/linkedin-[topic]-[date].md`
  - `drafts/newsletter-[topic]-[date].md` → `published/newsletter-[topic]-[date].md`
  - `drafts/social-[topic]-[date].md` → `published/social-[topic]-[date].md`

- **Research → Archive**: Move research brief to archive
  - `research/research-brief-[topic]-[date].md` → `research/archive/research-brief-[topic]-[date].md`

### Step 4: Update Index
Create/update `research/archive/INDEX.md` with archived topics:
```markdown
# Archived Research Topics

Topics below have been published and should NOT be included in future research.

## Published Content
- [YYYY-MM-DD] [Topic Name] - [Brief description]
  - Research: research-brief-[topic]-[date].md
  - Article: article-[topic]-[date].md
```

## File Organization
After publication, your structure will look like:
```
/published/
  article-[topic]-[date].md
  linkedin-[topic]-[date].md
  newsletter-[topic]-[date].md
  social-[topic]-[date].md

/research/archive/
  research-brief-[topic]-[date].md
  INDEX.md
```

## Research Exclusion
The `/research` command will:
1. Check `research/archive/INDEX.md` for archived topics
2. Exclude these topics from new research
3. Avoid covering the same ground twice
4. Focus on fresh perspectives and new angles

## Example Workflow
```
# After creating content with /write
/publish happiness-self-control

# System responds:
✓ Found 4 draft files
✓ Found 1 research brief
✓ Added publication metadata
✓ Moved to published folder
✓ Archived research
✓ Updated INDEX.md

Published content:
- article-happiness-self-control-2026-01-14.md
- linkedin-happiness-self-control-2026-01-14.md
- newsletter-happiness-self-control-2026-01-14.md
- social-happiness-self-control-2026-01-14.md
```

## Unpublish (Reversal)
If you need to unpublish content:
```
/unpublish [topic-slug]
```
This moves files back to drafts and restores research from archive.

## Notes
- Publication is reversible - files can be moved back if needed
- Original creation dates are preserved in metadata
- Multiple articles on similar topics are tracked separately
- Archive serves as a record of what's already been covered
