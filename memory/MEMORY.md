# Claude-Writer Project Memory

## Project Overview
Content creation system: research → write → repurpose across platforms → publish to Substack.
Working dir: `/home/rvignesh/Claude-Writer`

## Key Infrastructure

### Substack Automation
- **Script**: `.claude/skills/substack-publisher.js`
- **Skill command**: `.claude/commands/publish-substack.md`
- **Auth file**: `/home/rvignesh/.playwright-profiles/substack-auth.json`
- **Publication URL**: `https://vigneshrajendran581748.substack.com`
- **Auth**: `substack.sid` cookie (~3 month lifespan). Extract from Chrome DevTools → Application → Cookies → substack.com
- **Cookie set on both**: `.substack.com` AND `.vigneshrajendran581748.substack.com` domains

### Substack Editor DOM Facts
- Title: `<textarea placeholder="Title">` (NOT contenteditable — unusual)
- Body: `.tiptap.ProseMirror` — use `.first()` (index 0 = body at top)
- Bold: `Ctrl+B` toggle before/after text
- Italic: `Ctrl+I` toggle before/after text
- Headings: type `### ` prefix (Tiptap markdown shortcut)
- Plain text: `document.execCommand('insertText', false, text)` — fastest, no clipboard permission needed
- Must navigate to `[publication].substack.com/publish/post/new`, NOT `substack.com/publish/post/new`
- Wait for `.tiptap.ProseMirror` to appear (editor hydration), then +1500ms settle

### Permissions
- `.claude/settings.json`: `dangerouslyAllowAll: true`
- `.claude/settings.local.json`: same, plus explicit allow patterns

## Workflow
1. `/research [topic]` → saves `research/research-brief-[slug]-[date].md`
2. `/write` → saves article + auto-runs 3 platform agents in parallel
3. `/publish-substack [topic-slug]` → extracts newsletter body → runs substack-publisher.js
4. `/publish [topic-slug]` → moves files to published/, archives research

## Platform Output Files (naming convention)
- `drafts/article-[slug]-[date].md`
- `drafts/newsletter-[slug]-[date].md`
- `drafts/linkedin-[slug]-[date].md`
- `drafts/social-[slug]-[date].md`

## WSL2 Notes
- `--no-sandbox` required for Playwright/Chromium
- `--chrome` flag for Claude Code not supported in WSL2
- Headed browser requires DISPLAY=:0 (WSLg) — skip this, use headless

## Published Content
- See `published/` and `research/archive/` for past topics
- Check `research/archive/INDEX.md` before researching to avoid duplication

## Detailed Notes
- See `memory/substack-automation.md` for full debugging history
