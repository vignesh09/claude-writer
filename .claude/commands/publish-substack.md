# Publish to Substack Command

Use this command to push a newsletter draft to Substack as a saved draft.

## Usage
`/publish-substack`

---

## What This Command Does
1. Lists all available newsletter drafts and asks which one to publish
2. Extracts the title (primary subject line) and email body content
3. Strips metadata headers, subject line options, preview text, and notes sections
4. Opens Substack's new post editor via Playwright (headless Chromium)
5. Sets the post title and injects the clean body content
6. Saves as a draft in Substack
7. Reports the draft URL back to you

---

## Process

### Step 1: List Available Drafts and Ask
ALWAYS do this first — even if a topic slug was passed as an argument.

1. Glob for all files matching `drafts/newsletter-*.md`
2. For each file, extract the **Primary subject line** (under `**Primary:**`) to use as the display title
3. Present the options to the user using AskUserQuestion with:
   - The subject line as the label
   - The filename (without path) as the description
4. Wait for the user to select one before proceeding

Example question format:
> "Which newsletter draft would you like to publish to Substack?"
> - "The friction that was actually protecting you" — newsletter-ai-hyperachievers-burnout-no-limits-2026-02-27.md
> - "Why the AI productivity gap is wider than you think" — newsletter-ai-infrastructure-productivity-gap-2026-02-23.md

### Step 2: Extract Clean Content
From the selected newsletter file, extract:
- **Title**: The primary subject line (under `**Primary:**` heading)
- **Body**: Everything between `## EMAIL BODY` and `## TECHNICAL SPECS` (or end of file if no specs section)
- Strip any lines starting with `Notes:` — these are internal instructions, not content
- Strip the `---` dividers used as section separators inside the email body
- Strip any lines matching `[placeholder text]` pattern (e.g. `[Your sign-off]`, `[Read the full article]`)
- Strip the `## SUBJECT LINE OPTIONS`, `## PREVIEW TEXT`, `## TECHNICAL SPECS`, `## ENGAGEMENT STRATEGY`, `## A/B TEST VARIANTS`, `## SELF-VERIFICATION CHECKLIST`, `## NOTES` sections entirely

Write the clean body to `/tmp/substack-body.txt`.

### Step 3: Run the Substack Automation Script
Execute the Node.js Playwright script:
```bash
node /home/rvignesh/Claude-Writer/.claude/skills/substack-publisher.js \
  --title "EXTRACTED_TITLE" \
  --content-file /tmp/substack-body.txt
```

The script will:
- Launch headless Chromium with the saved Substack session
- Navigate to `https://vigneshrajendran581748.substack.com/publish/post/new`
- Wait for the Tiptap editor to load
- Set the title
- Inject the body content paragraph by paragraph with formatting
- Trigger autosave and wait for "Saved" confirmation

### Step 4: Report Result
- Show the Substack draft URL
- Confirm content was saved successfully
- Note: content is saved as DRAFT only — you still publish manually from Substack

---

## Content Extraction Rules

**KEEP** (goes into Substack):
- Opening paragraphs (the actual email text)
- Section headings (### headings become H3 in Substack)
- The closing question/CTA
- The sign-off line
- P.S. line if present

**STRIP** (internal metadata, never goes to Substack):
- The YAML frontmatter block (`---` ... `---`)
- `## SUBJECT LINE OPTIONS` section and all its content
- `## PREVIEW TEXT` section and all its content
- `## TECHNICAL SPECS` section and everything after it
- Any line starting with `Notes:`
- The `# Newsletter:` title line at top of file
- Standalone `---` divider lines used as section breaks
- Lines that are only a `[placeholder]` (square brackets wrapping text, e.g. `[Your sign-off]`)

---

## Auth & Session
- Session stored at: `/home/rvignesh/.playwright-profiles/substack-auth.json`
- Cookie expires: ~3 months from extraction date
- If session expired: "Navigate to substack.com in Chrome, open DevTools → Application → Cookies, copy `substack.sid` value, update the auth file"

---

## Error Handling
- **Session expired**: Script detects redirect to login page and reports clearly
- **Editor not loading**: Script waits up to 30 seconds for editor, then reports timeout
- **No drafts found**: Inform user no newsletter drafts exist in the `drafts/` folder yet

---

## Example Output
```
Available newsletter drafts:
1. "The friction that was actually protecting you"
2. "Why the AI productivity gap is wider than you think"

[User selects #1]

✓ Selected: newsletter-ai-hyperachievers-burnout-no-limits-2026-02-27.md
✓ Extracted title: "The friction that was actually protecting you"
✓ Extracted body: 861 words
✓ Launched headless Chromium
✓ Session authenticated
✓ Editor loaded
✓ Title set
✓ Content injected (39 paragraphs with formatting)
✓ Draft saved to Substack!

Open your Substack drafts to review and publish:
https://vigneshrajendran581748.substack.com/publish/drafts
```
