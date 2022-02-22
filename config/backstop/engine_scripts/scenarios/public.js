const YAML = require('yaml');
const fs = require('fs');

const file = fs.readFileSync('./config/ab_tests.yml', 'utf8');

const scenarios = [];

const abTests = YAML.parse(file).visual;

//purely demo code atm
Object.values(abTests).forEach((test) => {
  Object.keys(test).forEach((key) => {
    scenarios.push(
      {
        "label": `Home page ${key}`,
        "url": `https://teaching-vacancies-review-pr-4666.london.cloudapps.digital?ab_test_override[${[Object.keys(abTests)]}]=${key}`,
        "delay": 100,
        "hideSelectors": [".profiler-results"],
        "selectors": [
          "viewport"
        ]
      }
    )
  });
});

scenarios.push(...[
  {
    "label": "Search results",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/jobs",
    "delay": 100,
    "hideSelectors": [".profiler-results"],
    "selectors": [
      "viewport"
    ]
  },
  {
    "label": "Vacancy",
    "url": "https://teaching-vacancies-review-pr-4666.london.cloudapps.digital/jobs",
    "delay": 100,
    "hideSelectors": [".profiler-results"],
    "clickSelector": ".vacancies .govuk-link",
    "selectors": [
      "viewport"
    ]
  }
]);

module.exports = scenarios;
