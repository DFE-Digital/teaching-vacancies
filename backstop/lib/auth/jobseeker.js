module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  await page.goto(`${scenario.BASE_URL}/jobseekers/sign-in`);

  await page.waitForSelector('button[type="submit"]');

  await page.fill('#jobseeker-email-field', process.env.VISUAL_TEST_JOBSEEKER_USERNAME);
  await page.fill('#jobseeker-password-field', process.env.VISUAL_TEST_JOBSEEKER_PASSWORD);

  await page.click('button[type="submit"]');

  await require('../setSessionCookie')(browserContext, scenario.cookiePath);
};
