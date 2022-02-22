const { chromium } = require('playwright');
const fs = require('fs');

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto('http://localhost:3000/jobseekers/sign-in');

  const fsPromises = fs.promises;

  try {
    await fsPromises.unlink('config/backstop/cookies.json');
  } catch (e) {}

  await page.waitForSelector('button[type="submit"]');

  // await page.evaluate(() => {
  //   document.querySelector('#jobseeker-email-field').value = 'jobseeker@example.com';
  //   document.querySelector('#jobseeker-password-field').value = 'password';
  // });

  const UI_TEST_USERNAME = process.env.UI_TEST_USERNAME;
  const UI_TEST_PASSWORD = process.env.UI_TEST_PASSWORD;

  await page.fill('#jobseeker-email-field', UI_TEST_USERNAME);
  await page.fill('#jobseeker-password-field', UI_TEST_PASSWORD);

  await page.click('button[type="submit"]');

  await require('./setSessionCookie')(context);

  await browser.close();
})();