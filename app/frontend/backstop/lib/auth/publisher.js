module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  await page.goto(`${scenario.BASE_URL}/publishers/sign-in`);

  await page.waitForSelector('input[type="submit"]');
  await page.click('input[type="submit"]');

  await page.fill('input[name="username"]', process.env.VISUAL_TEST_PUBLISHER_USERNAME);
  await page.fill('input[name="password"]', process.env.VISUAL_TEST_PUBLISHER_PASSWORD);

  await page.click('button[type="submit"]');

  await page.waitForSelector('.govuk-radios__input:first-child');
  await page.check('.govuk-radios__input:first-child');
  await page.click('input[type="submit"]');

  await page.waitForSelector('.govuk-main-wrapper');

  await require('../setSessionCookie')(browserContext, scenario.cookiePath);
};
