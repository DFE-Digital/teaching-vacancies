const publicScenarios = require('./engine_scripts/scenarios/public');

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
  "onBeforeScript": null,
  "onReadyScript": "playwright/onReady.js",
  "scenarios": [

    {
      "label": "Jobseeker sign in",
      "url": "https://qa.teaching-vacancies.service.gov.uk/jobseekers/sign-in",
      "delay": 100,
      "hideSelectors": [".profiler-results"],
      "selectors": [
        "viewport"
      ]
    },
    {
      "cookiePath": "config/backstop/cookies.json",
      "label": "Jobseeker my applications page",
      "url": "https://qa.teaching-vacancies.service.gov.uk/jobseekers/job_applications",
      "hideSelectors": [".profiler-results"],
      "delay": 100,
      "onReadyScript": "tasks/signInJobseeker.js",
      "selectors": [
        "viewport"
      ]
    },
    {
      "cookiePath": "config/backstop/cookies.json",
      "label": "Jobseeker view application page",
      "url": "https://qa.teaching-vacancies.service.gov.uk/jobseekers/job_applications",
      "delay": 100,
      "hideSelectors": [".profiler-results"],
      "onReadyScript": "tasks/viewApplication.js",
      "selectors": [
        "viewport"
      ]
    },
    {
      "cookiePath": "config/backstop/cookies.json",
      "label": "Jobseeker saved jobs page",
      "url": "https://qa.teaching-vacancies.service.gov.uk/jobseekers/saved_jobs",
      "delay": 100,
      "hideSelectors": [".profiler-results"],
      "onReadyScript": "tasks/signInJobseeker.js",
      "selectors": [
        "viewport"
      ]
    },
    {
      "cookiePath": "config/backstop/cookies.json",
      "label": "Jobseeker view account page",
      "url": "https://qa.teaching-vacancies.service.gov.uk/jobseekers/account",
      "delay": 100,
      "hideSelectors": [".profiler-results"],
      "onReadyScript": "tasks/signInJobseeker.js",
      "selectors": [
        "viewport"
      ]
    },
    {
      "label": "Jobseeker sign out",
      "url": "https://qa.teaching-vacancies.service.gov.uk",
      "onReadyScript": "tasks/signOutJobseeker.js",
      "delay": 2000,
      "hideSelectors": [".profiler-results"],
      "selectors": [
        ".govuk-header__navigation-list"
      ],
      "viewports": [
        {
          "label": "desktop",
          "width": 1300,
          "height": 1024
        }
      ]
    },
    // {
    //   "label": "Publisher sign in",
    //   "url": "https://qa.teaching-vacancies.service.gov.uk/publishers/sign-in",
    //   "hideSelectors": [".profiler-results"],
    //   "onReadyScript": "tasks/signInPublisher.js",
    //   "delay": 1000,
    //   "selectors": [
    //     "document"
    //   ]
    // },
    // {
    //   "cookiePath": "config/backstop/cookies.json",
    //   "label": "Jobseeker my applications page",
    //   "url": "https://qa.teaching-vacancies.service.gov.uk/jobseekers/job_applications",
    //   "hideSelectors": [".profiler-results"],
    //   "delay": 200,
    //   "onReadyScript": "tasks/signInJobseeker.js",
    //   "selectors": [
    //     "viewport"
    //   ]
    // },
  ],
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
  "debug": false,
  "debugWindow": false
}
