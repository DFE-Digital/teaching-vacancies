const publicScenarios = require('./scenarios/public');
const commonScenarios = require('./scenarios/common');
const userScenarios = require(`./scenarios/${process.argv[4]}`);

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
  "scenarios": [
    ...commonScenarios,
    ...publicScenarios,
    ...userScenarios,
  ],
  "paths": {
    "bitmaps_reference": "visual_snapshots",
    "bitmaps_test": "visual_regression/bitmaps_test",
    "engine_scripts": "config/backstop/engine_scripts",
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
