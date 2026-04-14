# Headless Browser Detection via CSS System Colors

#security #scraping #stealth #playwright

Three lines of JavaScript can detect headless Chrome, even with stealth plugins.

## The Detection

```javascript
const div = document.createElement('div');
div.style.backgroundColor = 'ActiveText';
document.body.appendChild(div);
const color = getComputedStyle(div).backgroundColor;
// Real desktop: unique OS-themed color (varies per user)
// Headless/cloud: rgb(255, 0, 0) — Chromium's hardcoded default
```

`ActiveText` is a CSS system color that pulls from the OS theme. Real desktops return unique themed colors. Headless Chromium on cloud machines returns the hardcoded default `rgb(255, 0, 0)` because there's no OS theme to pull from.

## Why Stealth Plugins Don't Fix This

Patchright, puppeteer-extra-plugin-stealth, and similar tools patch:
- `navigator.webdriver`
- `navigator.plugins`
- `chrome.runtime`
- WebGL fingerprint
- Canvas fingerprint

But they don't patch CSS system color resolution because that happens at the rendering engine level, not in JavaScript APIs. The only fix is running on a machine with an actual desktop environment (like our WSL + Windows Chrome CDP setup).

## Impact on Our Stack

Our Chrome CDP setup (debug Chrome on Windows) is NOT affected because it's a real desktop browser with a real OS theme. The detection only catches cloud-hosted headless instances.

If we ever move scraping to a cloud server (Railway, EC2, etc.), this will break Maps scraping and any site that checks for it.

## Other System Colors That Leak

- `Canvas` — background color
- `CanvasText` — text color  
- `LinkText` — unvisited link color
- `VisitedText` — visited link color
- `ButtonFace` — button background
- `Highlight` — selection highlight

All return Chromium defaults on headless. A fingerprinting script could check all of them.

Source: Reddit post analysis, April 2026

## Related

- [[site-builder-overview]] — Maps scraper uses Playwright stealth
- [[leadfinder-overview]] — lead scraper uses anti-detection
