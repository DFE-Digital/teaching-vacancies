const YAML = require('yaml');
const fs = require('fs');

const file = fs.readFileSync('./config/ab_tests.yml', 'utf8');

const scenarios = [];

const abTests = YAML.parse(file).visual;

//purely demo code atm
Object.values(abTests).forEach((test, i) => {
  Object.keys(test).forEach((key) => {
    scenarios.push(
      {
        "label": `Home page ${key}`,
        "url": `?ab_test_override[${Object.keys(abTests)[i]}]=${key}`,
        "readySelector": ".govuk-main-wrapper",
        "removeSelectors": [".govuk-footer", ".environment-banner-component"],
        "selectors": [
          ".govuk-main-wrapper"
        ]
      }
    )
  });
});

scenarios.push(...[
  {
    "label": "Search results",
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
  // {
  //   "label": "Sign in",
  //   "url": "/pages/sign-in",
  //   "readySelector": ".govuk-main-wrapper",
  //   "removeSelectors": [".govuk-footer", ".environment-banner-component"],
  //   "selectors": [
  //     ".govuk-main-wrapper"
  //   ]
  // },
  // {
  //   "label": "Cookie preferences",
  //   "url": "/cookies-preferences",
  //   "readySelector": ".govuk-main-wrapper",
  //   "removeSelectors": [".govuk-footer", ".environment-banner-component"],
  //   "selectors": [
  //     ".govuk-main-wrapper"
  //   ]
  // },
  // {
  //   "label": "Accessibility",
  //   "url": "/pages/accessibility",
  //   "readySelector": ".govuk-main-wrapper",
  //   "removeSelectors": [".govuk-footer", ".environment-banner-component"],
  //   "selectors": [
  //     ".govuk-main-wrapper"
  //   ]
  // },
  // {
  //   "label": "Support request",
  //   "url": "/support_request/new",
  //   "readySelector": ".govuk-main-wrapper",
  //   "removeSelectors": [".govuk-footer", ".environment-banner-component"],
  //   "selectors": [
  //     ".govuk-main-wrapper"
  //   ]
  // },
  // {
  //   "label": "Submit feedback",
  //   "url": "/feedback/new",
  //   "readySelector": ".govuk-main-wrapper",
  //   "removeSelectors": [".govuk-footer", ".environment-banner-component"],
  //   "selectors": [
  //     ".govuk-main-wrapper"
  //   ]
  // },
  // {
  //   "label": "Vacancy",
  //   "url": "/jobs",
  //   "readySelector": ".govuk-main-wrapper",
  //   "clickSelector": ".vacancies .govuk-link",
  //   "removeSelectors": [".govuk-footer", ".environment-banner-component", "#school-location"],
  //   "selectors": [
  //     ".govuk-main-wrapper"
  //   ]
  // }
]);

module.exports = scenarios;
