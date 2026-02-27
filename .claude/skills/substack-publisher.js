#!/usr/bin/env node
/**
 * Substack Draft Publisher
 * Publishes newsletter content to Substack as a draft using Playwright.
 * Supports markdown bold (**text**), italic (*text*), and headings (### heading).
 *
 * Usage:
 *   node substack-publisher.js --title "Your Title" --content-file /path/to/body.txt
 */

const { chromium } = require('playwright');
const fs = require('fs');

// ─── Configuration ────────────────────────────────────────────────────────────

const AUTH_FILE = '/home/rvignesh/.playwright-profiles/substack-auth.json';
const PUBLICATION_URL = 'https://vigneshrajendran581748.substack.com';
const NEW_POST_URL = `${PUBLICATION_URL}/publish/post/new`;

// ─── Argument Parsing ─────────────────────────────────────────────────────────

function parseArgs() {
  const args = process.argv.slice(2);
  const result = {};
  for (let i = 0; i < args.length; i++) {
    if (args[i] === '--title' && args[i + 1]) result.title = args[++i];
    if (args[i] === '--content-file' && args[i + 1]) result.contentFile = args[++i];
  }
  return result;
}

function log(msg) { process.stdout.write(msg + '\n'); }
function fail(msg) { process.stderr.write('ERROR: ' + msg + '\n'); process.exit(1); }

// ─── Markdown Parser ──────────────────────────────────────────────────────────
// Parses a single line into segments with formatting tokens.
// Returns array of: { text, bold, italic, heading (1-3 or 0) }

function parseLine(line) {
  // Check for heading: ### / ## / #
  const headingMatch = line.match(/^(#{1,3})\s+(.+)$/);
  if (headingMatch) {
    return [{ text: headingMatch[2], bold: false, italic: false, heading: headingMatch[1].length }];
  }

  // Parse inline bold/italic markers
  const segments = [];
  // Regex: matches **bold**, *italic*, or plain text
  const regex = /(\*\*(.+?)\*\*|\*(.+?)\*|([^*]+))/g;
  let match;
  while ((match = regex.exec(line)) !== null) {
    if (match[2] !== undefined) {
      // **bold**
      segments.push({ text: match[2], bold: true, italic: false, heading: 0 });
    } else if (match[3] !== undefined) {
      // *italic*
      segments.push({ text: match[3], bold: false, italic: true, heading: 0 });
    } else if (match[4] !== undefined) {
      // plain text
      segments.push({ text: match[4], bold: false, italic: false, heading: 0 });
    }
  }
  return segments.length > 0 ? segments : [{ text: line, bold: false, italic: false, heading: 0 }];
}

// Parse full content into paragraphs of segments
function parseContent(content) {
  const paragraphs = content.split(/\n{2,}/).map(p => p.trim()).filter(p => p.length > 0);
  return paragraphs.map(para => {
    // Each paragraph is a single line (newsletters are single-line paragraphs)
    return parseLine(para);
  });
}

// Check if a paragraph has any formatting
function hasFormatting(segments) {
  return segments.some(s => s.bold || s.italic || s.heading > 0);
}

// ─── Main ─────────────────────────────────────────────────────────────────────

(async () => {
  const args = parseArgs();
  if (!args.title) fail('--title is required');
  if (!args.contentFile) fail('--content-file is required');
  if (!fs.existsSync(args.contentFile)) fail('Content file not found: ' + args.contentFile);

  const bodyContent = fs.readFileSync(args.contentFile, 'utf8').trim();
  if (!bodyContent) fail('Content file is empty');

  const paragraphs = parseContent(bodyContent);
  const wordCount = bodyContent.split(/\s+/).length;

  log('✓ Title: "' + args.title + '"');
  log('✓ Content: ' + wordCount + ' words across ' + paragraphs.length + ' paragraphs');

  const formattedCount = paragraphs.filter(p => hasFormatting(p)).length;
  log('✓ Formatted paragraphs: ' + formattedCount + ' (bold/italic/heading)');

  // ─── Launch Browser ──────────────────────────────────────────────────────

  log('\nLaunching headless Chromium...');
  const browser = await chromium.launch({
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--disable-dev-shm-usage']
  });

  const context = await browser.newContext({
    storageState: AUTH_FILE,
    viewport: { width: 1280, height: 900 },
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    permissions: ['clipboard-read', 'clipboard-write']
  });

  const page = await context.newPage();

  try {
    // ─── Navigate ──────────────────────────────────────────────────────────

    log('Navigating to editor...');
    await page.goto(NEW_POST_URL, { waitUntil: 'networkidle', timeout: 30000 });

    if (page.url().includes('login') || page.url().includes('sign-in')) {
      fail('Session expired. Re-extract substack.sid from Chrome DevTools and update:\n' + AUTH_FILE);
    }

    // ─── Wait for Editor ───────────────────────────────────────────────────

    log('Waiting for editor to hydrate...');
    await page.waitForSelector('.tiptap.ProseMirror', { timeout: 20000 });
    await page.waitForTimeout(1500);
    log('✓ Editor ready');

    // ─── Set Title ─────────────────────────────────────────────────────────

    log('\nSetting title...');
    const titleField = page.locator('textarea[placeholder="Title"]');
    await titleField.click();
    await titleField.fill(args.title);
    log('✓ Title set');
    await page.waitForTimeout(500);

    // ─── Click Body Editor ─────────────────────────────────────────────────

    log('\nInjecting body content with formatting...');
    const bodyEditor = page.locator('.tiptap.ProseMirror').first();
    await bodyEditor.click({ timeout: 10000 });
    await page.waitForTimeout(300);

    // ─── Type Content Paragraph by Paragraph with Formatting ───────────────

    for (let pIdx = 0; pIdx < paragraphs.length; pIdx++) {
      const segments = paragraphs[pIdx];

      // Progress log every 10 paragraphs
      if (pIdx > 0 && pIdx % 10 === 0) {
        log('  Progress: ' + pIdx + '/' + paragraphs.length + ' paragraphs...');
      }

      // Handle headings: use Tiptap's markdown shortcut (# + space)
      if (segments.length === 1 && segments[0].heading > 0) {
        const { text, heading } = segments[0];
        const prefix = '#'.repeat(heading) + ' ';
        await page.keyboard.type(prefix, { delay: 0 });
        await page.waitForTimeout(50);
        await page.keyboard.type(text, { delay: 0 });
        await page.keyboard.press('Enter');
        await page.keyboard.press('Enter');
        continue;
      }

      // Handle mixed bold/italic/plain segments
      for (const segment of segments) {
        if (segment.bold) {
          await page.keyboard.down('Control');
          await page.keyboard.press('b');
          await page.keyboard.up('Control');
          await page.keyboard.type(segment.text, { delay: 0 });
          await page.keyboard.down('Control');
          await page.keyboard.press('b');
          await page.keyboard.up('Control');
        } else if (segment.italic) {
          await page.keyboard.down('Control');
          await page.keyboard.press('i');
          await page.keyboard.up('Control');
          await page.keyboard.type(segment.text, { delay: 0 });
          await page.keyboard.down('Control');
          await page.keyboard.press('i');
          await page.keyboard.up('Control');
        } else {
          // Plain text — use execCommand for speed on long segments
          await page.evaluate((text) => {
            document.execCommand('insertText', false, text);
          }, segment.text);
        }
      }

      // End of paragraph: press Enter twice (except last paragraph)
      if (pIdx < paragraphs.length - 1) {
        await page.keyboard.press('Enter');
        await page.keyboard.press('Enter');
      }
    }

    log('✓ Content injected (' + paragraphs.length + ' paragraphs with formatting)');
    await page.waitForTimeout(1000);

    // ─── Trigger Autosave ──────────────────────────────────────────────────

    log('\nTriggering autosave...');
    await page.mouse.click(640, 30);
    await page.waitForTimeout(3000);

    try {
      await page.waitForSelector('text=Saved', { timeout: 8000 });
      log('✓ Substack confirmed save ("Saved" indicator visible)');
    } catch (_) {
      log('⚠ "Saved" indicator not detected — Substack should autosave within a few seconds');
    }

    const finalUrl = page.url();

    // Take confirmation screenshot
    await page.screenshot({ path: '/tmp/substack-saved.png', fullPage: false });

    log('\n══════════════════════════════════════════════');
    log('✓ Draft saved to Substack!');
    log('══════════════════════════════════════════════');
    log('\nDraft URL: ' + finalUrl);
    log('Confirmation screenshot: /tmp/substack-saved.png');
    log('\nOpen your Substack drafts to review and publish:');
    log(PUBLICATION_URL + '/publish/drafts');

  } catch (e) {
    try { await page.screenshot({ path: '/tmp/substack-error.png' }); } catch (_) {}
    await browser.close();
    fail(e.message + '\nDebug screenshot: /tmp/substack-error.png');
  }

  await browser.close();
  process.exit(0);
})();
