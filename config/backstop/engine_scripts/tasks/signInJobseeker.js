const fs = require('fs');

module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  console.log('JOBSEEKER SIGN IN > ', scenario.label, viewport.label);

  await require('../playwright/clickAndHoverHelper')(page, scenario);

  // const cookies = await browserContext.cookies();

  // console.log('cooookkkkiiies', c)


  if (!fs.existsSync('config/backstop/cookies.json')) {

  await page.waitForSelector('button[type="submit"]');

  await page.evaluate(() => {
    document.querySelector('#jobseeker-email-field').value = 'jobseeker@example.com';
    document.querySelector('#jobseeker-password-field').value = 'password';
  });

  await page.click('button[type="submit"]');

  await require('./setSessionCookie')(page, scenario, viewport, isReference, browserContext);
} else {
  await page.evaluate(() => {
    document.cookie = "consented-to-cookies=yes path=/";
  });
}
};
