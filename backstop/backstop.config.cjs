require('dotenv').config();

const TEST_ENV_URL = 'http://localhost:3000';
const TEMP_FOLDER = 'lib/.tmp'

//create flat array of scenarios
let scenarios = [
  ...require('./scenarios/public.cjs'),
  ...require('./scenarios/common.cjs'),
  ...require('./scenarios/components.cjs'),
  ...require('./scenarios/publisher.cjs'),
  ...require('./scenarios/jobseeker.cjs')
];

// map variants on pages that have abtests running
const { hasVariants, mapVariants } = require('./scenarios/abtest.cjs');

scenarios = scenarios.map((scenario) => hasVariants(scenario.label) ? mapVariants(scenario) : scenario).flat();

const Path = require('path');

//map host of server to scenario urls
scenarios = scenarios.map((scenario) => {

  if (scenario.cookiePath) {
    scenario.cookiePath = Path.join(__dirname, TEMP_FOLDER, scenario.cookiePath)
  }

  return {...scenario, url: `${TEST_ENV_URL}${scenario.url}`, BASE_URL: TEST_ENV_URL}
});

module.exports = {
  "id": "teacher_vacancies",
  "viewports": [
    {
      "label": "phone",
      "width": 480,
      "height": 1200
    },
    {
      "label": "tablet",
      "width": 768,
      "height": 1024
    },
    {
      "label": "desktop",
      "width": 1020,
      "height": 1024
    }
  ],
  "onBeforeScript": "playwright/onBefore.cjs",
  "onReadyScript": "playwright/onReady.cjs",
  "scenarios": scenarios,
  "paths": {
    "bitmaps_reference": "visual_snapshots",
    "bitmaps_test": "visual_regression/bitmaps_test",
    "engine_scripts": "backstop/lib",
    "html_report": "visual_regression/html_report",
    "ci_report": "visual_regression/ci_report"
  },
  "report": ["browser"],
  "engine": "playwright",
  "engineOptions": {
    "args": ["--no-sandbox"],
    "browser": "chromium"
  },
  "asyncCaptureLimit": 5,
  "asyncCompareLimit": 50,
  "debug": true,
  "debugWindow": false
}
