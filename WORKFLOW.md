# Content Creation Workflow

Complete guide to the content lifecycle from raw notes to published articles.

---

## Quick Reference

```bash
/extract-themes          # Analyze raw notes → identify content ideas
/research [topic]        # Deep research → create brief
/write [topic]           # Write article → auto-generate all platforms
/publish [topic-slug]    # Move to published → archive research
/unpublish [topic-slug]  # Reverse publication (if needed)
```

---

## The Complete Workflow

### Phase 1: Capture Ideas
**Tool**: Raw notes in `/rawnotes/`

1. Dump thoughts, observations, links into text files
2. No formatting required - just capture
3. Name files descriptively: `day0.txt`, `ideas-jan-2026.txt`, etc.

### Phase 2: Extract Themes
**Command**: `/extract-themes`

What it does:
- Analyzes all files in `/rawnotes/`
- Identifies recurring patterns and content opportunities
- Creates `research/theme-analysis-[date].md`
- Suggests which themes are worth developing

**Output**: List of potential topics with supporting evidence

### Phase 3: Research
**Command**: `/research [topic]`

**IMPORTANT**: Research now checks archived topics first!

The research process:
1. ✓ **Archive Check**: Reads `research/archive/INDEX.md`
   - If topic already published → suggests fresh angle or confirms re-research
   - If related topic exists → notes what was covered before
   - Ensures you don't duplicate past work

2. ✓ **Priority Sources**: Checks @context/research-sources.md first
   - Independent newsletters
   - Emerging voices
   - Building-in-public creators

3. ✓ **Gap Analysis**: What's NOT being covered?

4. ✓ **Unique Angle**: Your differentiated perspective

5. ✓ **Supporting Evidence**: Data, studies, examples

**Output**: `research/research-brief-[topic]-[date].md` with metadata:
```yaml
---
status: draft
created_date: 2026-01-14
topic: Happiness and Self-Control
archived: false
---
```

### Phase 4: Write
**Command**: `/write [topic or research brief]`

What happens automatically:
1. ✓ Creates long-form article from research
2. ✓ Adds publication metadata
3. ✓ Saves to `drafts/article-[topic]-[date].md`
4. ✓ **Auto-launches 3 repurposing agents**:
   - `linkedin-repurposer` → Professional post
   - `newsletter-repurposer` → Email version
   - `conversational-repurposer` → Social & podcast Q&A

**Output**: 4 files in `/drafts/`:
- `article-[topic]-[date].md` (main content)
- `linkedin-[topic]-[date].md`
- `newsletter-[topic]-[date].md`
- `social-[topic]-[date].md`

All files include metadata:
```yaml
---
status: draft
created_date: 2026-01-14
topic: [Topic Name]
platforms: [article, linkedin, newsletter, social]
published: false
research_source: research-brief-[topic]-[date].md
---
```

### Phase 5: Review & Edit
**Manual step**

1. Review all draft files
2. Make edits as needed
3. Test content if desired
4. When satisfied → proceed to publish

### Phase 6: Publish
**Command**: `/publish [topic-slug]`

Example: `/publish happiness-self-control`

What happens:
1. ✓ Finds all files matching topic slug
2. ✓ Updates metadata: `status: draft` → `status: published`
3. ✓ Adds `published_date: [today]`
4. ✓ Moves all drafts → `published/`
5. ✓ Moves research brief → `research/archive/`
6. ✓ Moves theme analysis → `research/archive/` (if exists for same date)
7. ✓ Moves raw notes → `rawnotes/archive/` (all .txt files)
8. ✓ Updates `research/archive/INDEX.md`

**Result**:
- Clean `/drafts/` folder
- Clean `/rawnotes/` folder (ready for new ideas)
- Organized `/published/` folder
- Archived research won't be re-used
- INDEX tracks what you've covered
- Complete audit trail of your content creation process

### Phase 7: Unpublish (if needed)
**Command**: `/unpublish [topic-slug]`

Reverses the publication:
- Moves files back to `/drafts/`
- Restores research brief from archive
- Restores theme analysis from archive (if exists)
- Updates metadata back to `status: draft`
- Topic becomes researchable again

**Note**: Raw notes remain in `rawnotes/archive/` and need manual restoration if needed (since they're not tied to specific articles)

---

## Folder Structure

```
Claude-Writer/
├── rawnotes/                    # Raw captures
│   ├── *.txt                    # Any format, no structure needed
│   └── archive/                 # Processed raw notes
│       └── *.txt                # Archived after publication
│
├── research/                    # Active research
│   ├── theme-analysis-*.md      # From /extract-themes (active)
│   ├── research-brief-*.md      # From /research (active)
│   └── archive/                 # Published research
│       ├── INDEX.md             # Published topics list
│       ├── theme-analysis-*.md  # Archived theme analyses
│       └── research-brief-*.md  # Archived briefs
│
├── drafts/                      # Work in progress
│   ├── article-*.md             # Main articles
│   ├── linkedin-*.md            # LinkedIn versions
│   ├── newsletter-*.md          # Email versions
│   └── social-*.md              # Social/podcast versions
│
├── published/                   # Published content
│   ├── article-*.md
│   ├── linkedin-*.md
│   ├── newsletter-*.md
│   └── social-*.md
│
└── context/                     # System context
    ├── writing-examples.md      # Voice & style guide
    └── research-sources.md      # Priority sources
```

---

## Research Archive System

### How It Works

**Problem**: Without tracking, you might research the same topics repeatedly.

**Solution**: Archive system automatically tracks published topics.

### The INDEX File

Location: `research/archive/INDEX.md`

Format:
```markdown
### 2026-01-14 - Happiness and Self-Control

- **Research**: `research-brief-happiness-self-control-2026-01-14.md`
- **Article**: `article-happiness-self-control-2026-01-14.md`
- **LinkedIn**: `linkedin-happiness-self-control-2026-01-14.md`
- **Newsletter**: `newsletter-happiness-self-control-2026-01-14.md`
- **Social**: `social-happiness-self-control-2026-01-14.md`
```

### Research Command Behavior

When you run `/research [topic]`:

1. **Checks INDEX.md first**
2. If exact match found:
   ```
   ⚠️  This topic was already published on 2026-01-14

   Options:
   a) Research a different angle: [suggestions]
   b) Research new developments since publication
   c) Proceed anyway (will re-research same topic)
   ```

3. If related topic found:
   ```
   ℹ️  Related topic covered: "Happiness and Self-Control" (2026-01-14)

   Previous angle: Happiness as fuel for self-control
   Suggested new angles: [list]
   ```

4. If no match:
   ```
   ✓ Fresh topic - proceeding with research
   ```

---

## Publication Metadata

### Why Metadata Matters

Metadata enables:
- Track publication status
- Link articles to research sources
- Identify platform versions
- Maintain publication history

### Metadata Fields

**Research Brief**:
```yaml
---
status: draft | archived
created_date: YYYY-MM-DD
topic: Human-readable topic name
archived: false | true
---
```

**Articles** (all platforms):
```yaml
---
status: draft | published
created_date: YYYY-MM-DD
published_date: YYYY-MM-DD  # Added on publish
original_draft_date: YYYY-MM-DD  # Added on publish
topic: Human-readable topic name
platform: article | linkedin | newsletter | social
published: false | true
research_source: research-brief-[topic]-[date].md
---
```

---

## Common Workflows

### Workflow 1: Idea → Published Article
```bash
# 1. Capture ideas
echo "Noticed people struggle with..." > rawnotes/observation.txt

# 2. Extract themes
/extract-themes

# 3. Research chosen theme
/research [theme from analysis]

# 4. Write content (auto-generates all platforms)
/write [topic]

# 5. Review drafts, edit as needed
# (manual review)

# 6. Publish everything
/publish [topic-slug]
```

### Workflow 2: Direct Research → Publish
```bash
# Skip theme extraction if you know what you want
/research [specific topic]
/write [topic]
/publish [topic-slug]
```

### Workflow 3: Avoiding Duplicate Research
```bash
/research productivity hacks

# System responds:
⚠️  Similar topic published on 2025-12-15: "Productivity Systems"
Covered angle: System optimization
Suggested fresh angles:
- Psychological barriers to productivity
- Cultural aspects of productivity
- Anti-productivity (doing less better)

Proceed with "productivity hacks" anyway? (y/n)
```

### Workflow 4: Unpublish & Re-edit
```bash
# Realize you want to make changes after publishing
/unpublish [topic-slug]

# Make edits to files now in drafts/

# Republish
/publish [topic-slug]
```

---

## File Naming Convention

**Format**: `[type]-[topic-slug]-[YYYY-MM-DD].md`

**Rules**:
- **type**: `article`, `linkedin`, `newsletter`, `social`, `research-brief`, `theme-analysis`
- **topic-slug**: lowercase, hyphenated, no special chars
- **date**: ISO format (YYYY-MM-DD)

**Examples**:
- ✓ `article-happiness-self-control-2026-01-14.md`
- ✓ `linkedin-remote-work-myths-2026-01-15.md`
- ✗ `Article_HappinessSelfControl_01-14-2026.md` (wrong format)
- ✗ `happiness-article.md` (missing date)

**Why**:
- Enables `/publish` to find related files
- Keeps chronological order
- Makes searching easy
- Prevents filename conflicts

---

## Best Practices

### Research
1. ✓ Always check archive before researching
2. ✓ Focus on fresh angles for covered topics
3. ✓ Document sources in research brief
4. ✓ Note what's NOT being covered by others

### Writing
1. ✓ Reference @context/writing-examples.md for voice
2. ✓ Let agents handle platform optimization
3. ✓ Review all generated versions before publishing
4. ✓ Edit the article first, regenerate platforms if needed

### Publishing
1. ✓ Review all 4 platform versions
2. ✓ Confirm metadata is correct
3. ✓ Use consistent topic slugs
4. ✓ Archive promptly after publication

### Organization
1. ✓ Keep `/drafts/` clean - publish or delete
2. ✓ Don't edit archived research (it's historical record)
3. ✓ Use descriptive topic slugs
4. ✓ Regular raw notes cleanup

---

## Troubleshooting

### "No article found for topic"
**Problem**: `/publish` can't find your draft

**Solution**:
```bash
# List drafts to see exact naming
ls -1 drafts/article-*.md

# Use the exact topic-slug from filename
/publish [exact-slug-from-filename]
```

### "Topic already published"
**Problem**: Trying to research a covered topic

**Options**:
1. Research a different angle (recommended)
2. Confirm you want to re-research
3. Update the existing content instead

### Multiple versions of same topic
**Problem**: Accidentally created duplicate research

**Solution**:
- Archive the older/worse version manually
- Update INDEX.md to reflect which is canonical
- Or delete the duplicate entirely

### Lost connection between article and research
**Problem**: Research file renamed or moved

**Solution**:
- Check `research_source` field in article metadata
- Update to correct filename
- Or manually move research to archive with note

---

## Tips

### Speed Up Your Workflow
- Keep a "topic ideas" running note in `/rawnotes/`
- Batch research multiple topics
- Review and publish daily to keep drafts clean

### Maintain Quality
- Don't skip the archive check during research
- Review all platform versions before publishing
- Keep context files updated with best examples

### Stay Organized
- Regular `/rawnotes/` cleanup
- Publish or delete old drafts
- Archive check prevents redundancy

### Track Your Progress
- `published/` folder shows your output
- INDEX.md shows topic coverage
- Use file dates to track velocity

---

## Advanced Usage

### Batch Publishing
```bash
# Publish multiple topics
for topic in topic1 topic2 topic3; do
  /publish $topic
done
```

### Search Archive
```bash
# Find what you've written about productivity
grep -i "productivity" research/archive/INDEX.md
```

### Content Audit
```bash
# See all published content
ls -lt published/article-*.md

# Count publications
ls -1 published/article-*.md | wc -l
```

### Find Gaps
```bash
# Topics researched but never published
comm -23 <(ls research/*.md | sort) <(ls research/archive/*.md | sort)
```

---

## Summary

**The lifecycle**:
1. Capture → `/rawnotes/`
2. Analyze → `/extract-themes`
3. Research → `/research` (checks archive)
4. Write → `/write` (auto-generates platforms)
5. Review → Manual editing
6. Publish → `/publish` (archives research)

**Key benefits**:
- ✓ Never duplicate research
- ✓ Organized by publication status
- ✓ Clear content lifecycle
- ✓ Easy to track what's covered
- ✓ Automatic platform optimization

**Remember**:
- Archive system prevents redundant work
- Metadata tracks everything
- Scripts automate the tedious parts
- Focus on writing, not file management
