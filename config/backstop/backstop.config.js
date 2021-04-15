module.exports = {
  "id": "teacher_vacancies",
  "viewports": [
    {
      "label": "phone",
      "width": 320,
      "height": 830
    },
    {
      "label": "tablet",
      "width": 768,
      "height": 1024
    }
    ,
    {
      "label": "desktop",
      "width": 1300,
      "height": 1024
    }
  ],
  "onBeforeScript": "puppet/onBefore.js",
  "onReadyScript": "puppet/onReady.js",
  "scenarios": [
    {
      "label": "2021_04_cookie_consent_ab_test_bottom_black",
      "url": "http://host.docker.internal/?ab_test_override%5B2021_04_cookie_consent_test%5D=bottom_black",
      "selectors": [
        "viewport"
      ],
      "removeSelectors": [
        ".govuk-main-wrapper",
        ".environment-banner-component"
      ]
    }
  ],
  "paths": {
    "bitmaps_reference": "visual_snapshots",
    "bitmaps_test": "visual_regression/bitmaps_test",
    "engine_scripts": "config/backstop/engine_scripts",
    "html_report": "visual_regression/html_report",
    "ci_report": "visual_regression/ci_report"
  },
  "report": ["CI"],
  "engine": "puppeteer",
  "engineOptions": {
    "args": ["--no-sandbox"]
  },
  "asyncCaptureLimit": 5,
  "asyncCompareLimit": 50,
  "debug": false,
  "debugWindow": false
}
