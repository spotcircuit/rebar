# CON-40: Queue Open & Copy Should Paste Into Comment Editor

## Problem
Clicking "Open & Copy" in the popup queue opens the post URL and copies draft to clipboard, but doesn't paste it into the comment editor. User has to manually Ctrl+V.

## Root Cause
popup.js calls `chrome.tabs.create()` to open the URL but never sends the draft text to the content script running on that page.

## Existing Pattern
LinkedIn content.js already has a `PASTE_COMMENT` handler at line 598:
```js
if (message.type === 'PASTE_COMMENT') {
    // finds editor, focuses, pastes text
}
```

## Plan

### 1. popup.js — Send draft to content script after tab loads
In the "Open & Copy" click handler (~line 54):
- `chrome.tabs.create()` returns a tab object
- Use `chrome.tabs.onUpdated` to wait for the tab to finish loading
- Then `chrome.tabs.sendMessage(tab.id, { type: 'PASTE_COMMENT', text: draftText })`
- Add a small delay (2-3s) to let the page render and content script initialize

### 2. reddit-content.js — Add PASTE_COMMENT handler
At the end of the IIFE (before the closing `})()`), add:
```js
chrome.runtime.onMessage.addListener((message, sender, sendResponse) => {
    if (message.type === 'PASTE_COMMENT') {
        // find visible editor, focus, paste text
    }
});
```
Use the same paste methods from the existing `pasteAndPost()` function (lines 456-556).

### 3. discord-content.js — Add PASTE_COMMENT handler
Same pattern. Discord uses Slate editor with `[role="textbox"]`.

## Files
- `extensions/linkedin-scout/scripts/popup.js` (modify Open & Copy handler)
- `extensions/linkedin-scout/scripts/reddit-content.js` (add message handler)
- `extensions/linkedin-scout/scripts/discord-content.js` (add message handler)

## Test
1. Scout Reddit → drafts appear in queue
2. Click "Open & Copy" on a draft
3. Reddit post opens in new tab
4. Comment editor gets focused and draft text is pasted
5. User reviews and clicks Reply
