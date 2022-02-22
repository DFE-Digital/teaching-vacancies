const { chromium } = require('playwright');
const fs = require('fs');
const PR_ID = process.env.PR_ID;

console.log(`This is the PR_ID: ${PR_ID}`);
const URL = `https://teaching-vacancies-review-pr-${PR_ID}.london.cloudapps.digital/jobseekers/sign-in`;
console.log(URL);

(async () => {
  const browser = await chromium.launch();
  const context = await browser.newContext();
  const page = await context.newPage();
  await page.goto(URL);

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
