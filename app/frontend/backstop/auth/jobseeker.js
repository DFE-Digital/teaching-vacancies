const { chromium } = require('playwright');
const fs = require('fs');

const TEST_ENV_URL = process.argv[2] || 'http://localhost:3000';

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto(`${TEST_ENV_URL}/jobseekers/sign-in`);

  const fsPromises = fs.promises;

  try {
    await fsPromises.unlink('app/frontend/backstop/cookies.json');
  } catch (e) {}

  await page.waitForSelector('button[type="submit"]');

  const UI_TEST_USERNAME = 'jobseeker1@example.com';
  const UI_TEST_PASSWORD = 'password';

  await page.fill('#jobseeker-email-field', UI_TEST_USERNAME);
  await page.fill('#jobseeker-password-field', UI_TEST_PASSWORD);

  await page.click('button[type="submit"]');

  await require('./setSessionCookie')(context);

  await browser.close();
})();
