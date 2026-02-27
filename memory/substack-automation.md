# Substack Automation — Debugging History & Lessons

## What Was Built
A headless Playwright script that posts newsletter drafts to Substack with markdown formatting preserved.

## Bugs Fixed (in order encountered)

### 1. Wrong Base URL
- **Problem**: `https://substack.com/publish/post/new` lands on public homepage
- **Fix**: Use `https://[publication].substack.com/publish/post/new`

### 2. Editor Hydration Timing
- **Problem**: `networkidle` fires before React hydrates the Tiptap editor
- **Fix**: `waitForSelector('.tiptap.ProseMirror', { timeout: 20000 })` + 1500ms settle

### 3. Title Selector Wrong
- **Problem**: Title is a `<textarea>`, not a ProseMirror contenteditable element
- **Fix**: `page.locator('textarea[placeholder="Title"]').fill(title)`

### 4. Body Editor Selector Timeout
- **Problem**: `.tiptap.ProseMirror[placeholder="Start writing..."]` timed out
- **Fix**: `.tiptap.ProseMirror` → `.first()` (index 0 is the body at top)

### 5. Clipboard Permission Denied (headless)
- **Problem**: `navigator.clipboard.write()` blocked in headless Chromium
- **Fix**: Use `document.execCommand('insertText', false, text)` — no permissions needed

### 6. Content Injected as One Block
- **Problem**: Using clipboard for full content lost paragraph separation
- **Fix**: Paragraph-by-paragraph typing with `Enter+Enter` between paragraphs

### 7. Shell Escaping Syntax Error
- **Problem**: Inline `node -e` with `!` in filter caused SyntaxError
- **Fix**: Write extraction logic to `/tmp/extract-newsletter.js`, run as file

## Architecture Decisions

### Why execCommand for plain text?
- Clipboard requires permissions even with `permissions: ['clipboard-read','clipboard-write']` in headless
- `execCommand('insertText')` fires as native input events that Tiptap/ProseMirror respects
- Much faster than `keyboard.type()` for long paragraphs

### Why Ctrl+B/Ctrl+I for formatting?
- Tiptap processes keyboard shortcuts reliably
- Alternative (clipboard paste with HTML) is blocked in headless
- Alternative (direct DOM manipulation) risks desync with React state

### Why two .tiptap.ProseMirror elements?
- Index 0 (top ~367px): main body editor
- Index 1 (lower): subtitle/description area
- Always use `.first()` for body

## Running the Script
```bash
# Extract newsletter body
cd /home/rvignesh/Claude-Writer
node /tmp/extract-newsletter.js  # writes /tmp/substack-body.txt

# Publish to Substack
node .claude/skills/substack-publisher.js \
  --title "Your Title Here" \
  --content-file /tmp/substack-body.txt
```

## Cookie Refresh
- `substack.sid` lasts ~3 months
- Extract from Chrome: DevTools → Application → Cookies → substack.com → copy `substack.sid` value
- Update `/home/rvignesh/.playwright-profiles/substack-auth.json` (set on both cookie domains)
