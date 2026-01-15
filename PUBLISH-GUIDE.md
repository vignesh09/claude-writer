# Quick Publishing Guide

Fast reference for marking articles as published and managing your content library.

---

## TL;DR

```bash
# Publish all drafts for a topic
/publish happiness-self-control

# Undo publication
/unpublish happiness-self-control
```

---

## What `/publish` Does

When you run `/publish [topic-slug]`:

1. ✓ **Adds metadata** - Marks files with publication date and status
2. ✓ **Moves drafts** - All 4 platform versions → `published/` folder
3. ✓ **Archives research** - Research brief → `research/archive/`
4. ✓ **Archives theme analysis** - Theme analysis file → `research/archive/` (if exists for same date)
5. ✓ **Archives raw notes** - All .txt files → `rawnotes/archive/`
6. ✓ **Updates index** - Adds entry to `research/archive/INDEX.md`
7. ✓ **Prevents reuse** - Future `/research` commands skip this topic

**Result**: Clean drafts folder + clean rawnotes folder + organized published content + no duplicate research + complete audit trail

---

## Step-by-Step

### 1. Find Your Topic Slug

The topic slug is the middle part of your filename:

```
article-happiness-self-control-2026-01-14.md
        ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
        This is your topic slug
```

### 2. Run Publish Command

```bash
/publish happiness-self-control
```

### 3. Verify Results

Check what was published:
```bash
ls published/
# Should see your 4 files:
# - article-happiness-self-control-2026-01-14.md
# - linkedin-happiness-self-control-2026-01-14.md
# - newsletter-happiness-self-control-2026-01-14.md
# - social-happiness-self-control-2026-01-14.md
```

Check archive:
```bash
cat research/archive/INDEX.md
# Should see your topic listed
```

---

## After Publishing

### What Changed

**Files moved**:
- `drafts/article-*.md` → `published/article-*.md`
- `drafts/linkedin-*.md` → `published/linkedin-*.md`
- `drafts/newsletter-*.md` → `published/newsletter-*.md`
- `drafts/social-*.md` → `published/social-*.md`
- `research/research-brief-*.md` → `research/archive/research-brief-*.md`
- `research/theme-analysis-*.md` → `research/archive/theme-analysis-*.md` (if exists)
- `rawnotes/*.txt` → `rawnotes/archive/*.txt` (all raw notes)

**Metadata added** (to each file):
```yaml
---
status: published
published_date: 2026-01-15
original_draft_date: 2026-01-14
platform: article
research_source: research-brief-[topic]-[date].md
---
```

**Index updated**:
```markdown
### 2026-01-15 - [Your Article Title]

- **Theme Analysis**: `theme-analysis-[date].md`
- **Research**: `research-brief-[topic]-[date].md`
- **Article**: `article-[topic]-[date].md`
- **LinkedIn**: `linkedin-[topic]-[date].md`
- **Newsletter**: `newsletter-[topic]-[date].md`
- **Social**: `social-[topic]-[date].md`
- **Raw Notes**: `*.txt` (archived to rawnotes/archive/)
```

---

## Research Archive System

### How It Works

Once you publish, the research is archived and **automatically excluded** from future research.

### Example

```bash
# You publish an article about productivity
/publish productivity-myths

# Later, you try to research productivity again
/research productivity systems

# Claude checks the archive and responds:
⚠️  Related topic published on 2026-01-15: "Productivity Myths"
Previous angle: Common misconceptions about productivity
Suggested new angles:
- Productivity systems for creative work
- Cultural differences in productivity
- Anti-productivity movement

Proceed anyway? (y/n)
```

This prevents you from:
- Duplicating research effort
- Covering the same ground twice
- Wasting time on topics you've already explored

---

## Unpublishing

### When to Unpublish

- You want to make significant edits
- You published by mistake
- You want to merge with another article

### How to Unpublish

```bash
/unpublish [topic-slug]
```

**This reverses publication**:
- Moves files back to `drafts/`
- Restores research brief from archive
- Restores theme analysis from archive (if exists)
- Changes metadata from `published` → `draft`
- Makes topic researchable again

**Note**: Raw notes stay in `rawnotes/archive/` (restore manually if needed since they're not tied to specific articles)

### After Unpublishing

Edit your drafts, then republish:
```bash
# Make your edits...
/publish [topic-slug]
```

---

## Common Tasks

### View All Published Articles

```bash
ls -lt published/article-*.md
# Shows articles sorted by modification date
```

### Count Your Publications

```bash
ls -1 published/article-*.md | wc -l
# Shows total number of published articles
```

### Find What You've Written About a Topic

```bash
grep -i "productivity" research/archive/INDEX.md
# Shows all productivity-related publications
```

### Check What's Ready to Publish

```bash
ls -1 drafts/article-*.md
# Shows all draft articles waiting for publication
```

### See Full Publication History

```bash
cat research/archive/INDEX.md
# Shows everything you've published, in order
```

---

## Troubleshooting

### "No article found for topic"

**Problem**: Can't find your draft

**Solution**:
```bash
# List your drafts
ls -1 drafts/article-*.md

# Copy the exact topic slug from the filename
# article-THIS-IS-THE-SLUG-2026-01-14.md
#         ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑

# Use that exact slug
/publish THIS-IS-THE-SLUG
```

### Already Published This Topic

**Problem**: Trying to research something you've already published

**Options**:
1. Choose a different angle (recommended)
2. Research new developments since publication
3. Confirm you want to re-research anyway

### Missing Platform Versions

**Problem**: Only 3 files found instead of 4

**What happens**: Publishes whatever exists. If you're missing:
- LinkedIn version: Only that platform skipped
- All platforms exist: Everything published normally

**To fix later**: Generate missing platforms and republish

### Want to Reorganize Published Content

**Solution**: You can manually move/rename files in `published/` folder. The archive INDEX is just for research tracking.

---

## Best Practices

### Before Publishing

- [ ] Review all 4 platform versions
- [ ] Check metadata is correct
- [ ] Test any links or references
- [ ] Run spell check if desired

### After Publishing

- [ ] Keep `drafts/` folder clean
- [ ] Don't edit archived research (it's historical)
- [ ] Update external systems (CMS, schedulers, etc.)

### Maintenance

- **Weekly**: Review drafts, publish or delete old ones
- **Monthly**: Audit published content for patterns
- **Quarterly**: Review archive INDEX for content gaps

---

## Tips

### Batch Publishing

If you have multiple topics ready:
```bash
/publish topic-one
/publish topic-two
/publish topic-three
```

### Test Before Publishing

Create a test copy:
```bash
cp drafts/article-test-2026-01-15.md /tmp/test.md
# Edit and test
# When satisfied, publish the original
/publish test
```

### Track Publication Metrics

Use the metadata to track:
- Time from draft to published (compare dates)
- Publishing velocity (count per week)
- Topic coverage (archive INDEX analysis)

---

## File Locations Quick Reference

```
/rawnotes/                      # Fresh ideas
  *.txt                         # Unprocessed notes
  archive/                      # Processed raw notes
    *.txt

/drafts/                        # Work in progress
  article-*.md
  linkedin-*.md
  newsletter-*.md
  social-*.md

/published/                     # Published content
  article-*.md                  # (Same structure as drafts)
  linkedin-*.md
  newsletter-*.md
  social-*.md

/research/                      # Active research
  research-brief-*.md
  theme-analysis-*.md

/research/archive/              # Published research
  INDEX.md                      # List of published topics
  research-brief-*.md           # Archived research briefs
  theme-analysis-*.md           # Archived theme analyses
```

---

## See Also

- [WORKFLOW.md](WORKFLOW.md) - Complete content creation workflow
- [CLAUDE.md](CLAUDE.md) - System overview and commands
- [/publish command docs](.claude/commands/publish.md) - Detailed command reference

---

## Summary

**Publishing is simple**:
1. Create content with `/write`
2. Review drafts
3. Run `/publish [topic-slug]`
4. Done!

**Benefits**:
- ✓ Clean organization
- ✓ Prevents duplicate research
- ✓ Tracks publication history
- ✓ Makes content discoverable

**Remember**: Publishing is reversible. If you need to make changes, use `/unpublish` and then republish.
