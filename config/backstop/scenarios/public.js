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
        "url": `https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/?ab_test_override[${Object.keys(abTests)[i]}]=${key}`,
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
  //   "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/jobs",
  //   "readySelector": ".govuk-main-wrapper",
  //   "selectors": [
  //     "viewport"
  //   ]
  // },
  {
    "label": "Sign in",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/pages/sign-in",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Cookie preferences",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/cookies-preferences",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Accessibility",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/pages/accessibility",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Support request",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/support_request/new",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  {
    "label": "Submit feedback",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/feedback/new",
    "readySelector": ".govuk-main-wrapper",
    "removeSelectors": [".govuk-footer"],
    "selectors": [
      ".govuk-main-wrapper"
    ]
  },
  // {
  //   "label": "Vacancy",
  //   "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/jobs",
  //   "readySelector": ".govuk-main-wrapper",
  //   "clickSelector": ".vacancies .govuk-link",
  //   "selectors": [
  //     "viewport"
  //   ]
  // }
]);

module.exports = scenarios;
