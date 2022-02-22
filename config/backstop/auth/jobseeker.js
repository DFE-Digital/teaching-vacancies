const { chromium } = require('playwright');
const fs = require('fs');

let TEST_ENV_URL = 'http://localhost:3000/jobseekers/sign-in';

if (process.env.PR_ID) {
  TEST_ENV_URL = `https://teaching-vacancies-review-pr-${process.env.PR_ID}.london.cloudapps.digital/jobseekers/sign-in`;
}

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto(TEST_ENV_URL);

  const fsPromises = fs.promises;

  try {
    await fsPromises.unlink('config/backstop/cookies.json');
  } catch (e) {}

  await page.waitForSelector('button[type="submit"]');

  const UI_TEST_USERNAME = process.env.UI_TEST_USERNAME || 'jobseeker1@example.com';
  const UI_TEST_PASSWORD = process.env.UI_TEST_PASSWORD || 'password';

  await page.fill('#jobseeker-email-field', UI_TEST_USERNAME);
  await page.fill('#jobseeker-password-field', UI_TEST_PASSWORD);

  await page.click('button[type="submit"]');

  await require('./setSessionCookie')(context);

  await browser.close();
})();
