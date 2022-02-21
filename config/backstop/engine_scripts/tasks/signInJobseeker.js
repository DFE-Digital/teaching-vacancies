const fs = require('fs');

const UI_TEST_USERNAME = "foo";
const UI_TEST_PASSWORD = process.env.UI_TEST_PASSWORD;

console.log(`hello world - fake username: ${UI_TEST_USERNAME}`)

module.exports = async (page, scenario, viewport, isReference, browserContext) => {

  const UI_TEST_USERNAME = "foo";
//  const UI_TEST_PASSWORD = process.env.UI_TEST_PASSWORD

  console.log('JOBSEEKER SIGN IN > ', scenario.label, viewport.label);

  await require('../playwright/clickAndHoverHelper')(page, scenario);

  await page.waitForSelector('button[type="submit"]');

  await page.evaluate(() => {
    document.querySelector('#jobseeker-email-field').value = UI_TEST_USERNAME;
    document.querySelector('#jobseeker-password-field').value = UI_TEST_PASSWORD;
    document.cookie = "consented-to-cookies=yes path=/";
  });

  await page.click('button[type="submit"]');

  await require('./setSessionCookie')(page, scenario, viewport, isReference, browserContext);
};
