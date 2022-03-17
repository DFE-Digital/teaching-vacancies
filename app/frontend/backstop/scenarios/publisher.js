const AUTH_TYPE = 'publisher';

module.exports = [
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher active jobs",
    "url": "/organisation/jobs",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      "viewport"
    ]
  },
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher draft jobs",
    "url": "/organisation/jobs/draft",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      "viewport"
    ]
  },
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher expired jobs",
    "url": "/organisation/jobs/expired",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      "viewport"
    ]
  },
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher scheduled jobs",
    "url": "/organisation/jobs/pending",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      "viewport"
    ]
  },
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher awaiting feedback jobs",
    "url": "/organisation/jobs/awaiting_feedback",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      "viewport"
    ]
  },
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher manage job listing page",
    "url": "/organisation/jobs",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "clickSelector": ".card-component .govuk-link",
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher job listing applicants page",
    "url": "/organisation/jobs",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "clickSelector": ".card-component__content div:nth-child(2) .govuk-link",
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher manage settings page",
    "url": "/organisation/jobs",
    "viewports": [
      {
        "label": "phone",
        "width": 480,
        "height": 1024
      },
      {
        "label": "tablet",
        "width": 768,
        "height": 1024
      }
    ],
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "clickSelectors": [".govuk-header__menu-button", "#navigation li:nth-child(2) .govuk-header__link"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher manage settings page",
    "url": "/organisation/jobs",
    "viewports": [
      {
        "label": "desktop",
        "width": 1020,
        "height": 1024
      }
    ],
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "clickSelector": "#navigation li:nth-child(2) .govuk-header__link",
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "onBeforeScript": "auth.js",
    "AUTH_TYPE": AUTH_TYPE,
    "cookiePath": `${AUTH_TYPE}.json`,
    "label": "Publisher notifications page",
    "url": "/publishers/notifications",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
];
