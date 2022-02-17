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
  "onBeforeScript": "playwright/onBefore.js",
  "onReadyScript": "playwright/onReady.js",
  "scenarios": [
    ...publicScenarios,
    {
      "label": "Jobseeker sign in",
      "url": "http://localhost:3000/jobseekers/sign-in",
      "readySelector": ".govuk-footer",
      "delay": 100,
      "hideSelectors": [".profiler-results"],
      
      "selectors": [
        "viewport"
      ]
    },
    {
      "cookiePath": "config/backstop/cookies.json",
      "label": "Jobseeker my applications page",
      "url": "http://localhost:3000/jobseekers/job_applications",
      "readySelector": ".govuk-footer",
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
      "url": "http://localhost:3000/jobseekers/job_applications",
      "readySelector": ".govuk-footer",
      
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
      "url": "http://localhost:3000/jobseekers/saved_jobs",
      "readySelector": ".govuk-footer",
      
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
      "url": "http://localhost:3000/jobseekers/account",
      "readySelector": ".govuk-footer",
      
      "delay": 100,
      "hideSelectors": [".profiler-results"],
      "onReadyScript": "tasks/signInJobseeker.js",
      "selectors": [
        "viewport"
      ]
    },
    // {
    //   "label": "Jobseeker sign out",
    //   "url": "http://localhost:3000",
    //   "readySelector": ".govuk-footer",
    //   "onReadyScript": "tasks/signOutJobseeker.js",
    //   "delay": 2000,
    //   "hideSelectors": [".profiler-results"],
      
    //   "selectors": [
    //     ".govuk-header__navigation-list"
    //   ],
    //   "viewports": [
    //     {
    //       "label": "desktop",
    //       "width": 1300,
    //       "height": 1024
    //     }
    //   ]
    // },
    // {
    //   "label": "Publisher sign in",
    //   "url": "http://localhost:3000/publishers/sign-in",
    //   "hideSelectors": [".profiler-results"],
    //   "onReadyScript": "tasks/signInPublisher.js",
    //   "delay": 100,
    //   "selectors": [
    //     "document"
    //   ]
    // },
    // {
    //   "cookiePath": "config/backstop/cookies.json",
    //   "label": "Jobseeker my applications page",
    //   "url": "http://localhost:3000/jobseekers/job_applications",
    //   "hideSelectors": [".profiler-results"],
    //   "delay": 100,
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
  "report": ["browser"],
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
