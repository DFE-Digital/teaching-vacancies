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
        "url": `http://localhost:3000?ab_test_override[${[Object.keys(abTests)]}]=${key}`,
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
    "url": "http://localhost:3000/jobs",
    "delay": 100,
    "hideSelectors": [".profiler-results"],
    "selectors": [
      "viewport"
    ]
  },
  {
    "label": "Vacancy",
    "url": "http://localhost:3000/jobs",
    "delay": 100,
    "hideSelectors": [".profiler-results"],
    "clickSelector": ".vacancies .govuk-link",
    "selectors": [
      "viewport"
    ]
  }
]);

module.exports = scenarios;
