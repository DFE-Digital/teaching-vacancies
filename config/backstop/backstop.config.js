let TEST_ENV_URL = 'http://localhost:3000';

if (process.env.PR_ID) {
  TEST_ENV_URL = `https://teaching-vacancies-review-pr-${process.env.PR_ID}.london.cloudapps.digital`;
}

let scenarios = [
  ...require('./scenarios/public'),
  ...require('./scenarios/common')
];

if (process.argv[4]) {
  scenarios.push(...require(`./scenarios/${process.argv[4]}`));
}

scenarios = scenarios.map((scenario) => {
  return {...scenario, url: `${TEST_ENV_URL}${scenario.url}`}
})

module.exports = {
  "id": "teacher_vacancies",
  "viewports": [
    {
      "label": "phone",
      "width": 320,
      "height": 1000
    },
    {
      "label": "tablet",
      "width": 768,
      "height": 1024
    },
    {
      "label": "desktop",
      "width": 1300,
      "height": 1024
    }
  ],
  "onBeforeScript": "playwright/onBefore.js",
  "onReadyScript": "playwright/onReady.js",
  "scenarios": scenarios,
  "paths": {
    "bitmaps_reference": "visual_snapshots",
    "bitmaps_test": "visual_regression/bitmaps_test",
    "engine_scripts": "config/backstop/engine_scripts",
    "html_report": "visual_regression/html_report",
    "ci_report": "visual_regression/ci_report"
  },
  "report": ["CI"],
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
