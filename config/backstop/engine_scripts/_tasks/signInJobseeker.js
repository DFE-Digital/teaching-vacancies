const fs = require('fs');

module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  console.log('JOBSEEKER SIGN IN > ', scenario.label, viewport.label);

  await require('../playwright/clickAndHoverHelper')(page, scenario);

  let checkFileExists = s => new Promise(r=>fs.access(s, fs.constants.F_OK, e => r(!e)))
  const exists = await checkFileExists("config/backstop/cookies.json")

  if (!exists) {
    console.log('OOOONNNNCCCEEEE');
    await page.waitForSelector('button[type="submit"]');

    await page.evaluate(() => {
      document.querySelector('#jobseeker-email-field').value = 'jobseeker@example.com';
      document.querySelector('#jobseeker-password-field').value = 'password';
      document.cookie = "consented-to-cookies=yes path=/";
    });

    await page.click('button[type="submit"]');

    await require('./setSessionCookie')(page, scenario, viewport, isReference, browserContext);
  }
};
