module.exports = [
  {
    "label": "search",
    "url": "/jobs",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [
      ".govuk-footer",
      ".environment-banner-component",
      ".vacancies .vacancy:not(:first-child)"
    ],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "home",
    "url": `/`,
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Sign in",
    "url": "/pages/sign-in",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Cookie preferences",
    "url": "/cookies-preferences",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Accessibility",
    "url": "/pages/accessibility",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Support request",
    "url": "/support_request/new",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Submit feedback",
    "url": "/feedback/new",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer", ".environment-banner-component"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Vacancy",
    "url": "/jobs",
    "delay": 1000,
    "readySelector": ".govuk-main-wrapper",
    "clickSelector": ".search-results .govuk-link",
    "removeSelectors": [".govuk-footer", ".environment-banner-component", "#school-location"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  }
];
