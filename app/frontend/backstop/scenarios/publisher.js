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
];
