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
        "url": `http://localhost:3000/?ab_test_override[${Object.keys(abTests)[i]}]=${key}`,
        "readySelector": ".govuk-main-wrapper",
        "removeSelectors": [".govuk-footer"],
        "selectors": [
          ".govuk-main-wrapper"
        ]
      }
    )
  });
});

scenarios.push(...[
  // {
  //   "label": "Search results",
  //   "url": "http://localhost:3000/jobs",
  //   "readySelector": ".govuk-main-wrapper",
  //   "selectors": [
  //     "viewport"
  //   ]
  // },
  {
    "label": "Sign in",
    "url": "http://localhost:3000/pages/sign-in",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Cookie preferences",
    "url": "http://localhost:3000/cookies-preferences",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Accessibility",
    "url": "http://localhost:3000/pages/accessibility",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Support request",
    "url": "http://localhost:3000/support_request/new",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Submit feedback",
    "url": "http://localhost:3000/feedback/new",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  // {
  //   "label": "Vacancy",
  //   "url": "http://localhost:3000/jobs",
  //   "readySelector": ".govuk-main-wrapper",
  //   "clickSelector": ".vacancies .govuk-link",
  //   "selectors": [
  //     "viewport"
  //   ]
  // }
]);

module.exports = scenarios;
