const fs = require('fs');

module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  console.log('SCENARIO SIGN IN PUBLISER > ' + scenario.label);

  await require('../playwright/clickAndHoverHelper')(page, scenario);

  await page.waitForSelector('input[type="submit"]');

  await page.click('input[type="submit"]');

  await page.waitForSelector('input[name="username"]');
  await page.waitForSelector('input[name="password"]');

  await page.evaluate(() => {
    document.querySelector('input[name="username"]').value = 'alex.bowen@digital.education.gov.uk';
    document.querySelector('input[name="password"]').value = 't2yyw22XK54X8UT';
  });

  // await page.waitForNavigation();

  // const cookies = await browserContext.cookies();

  // // console.log('browserContext.cookies()', cookies)

  // const [sessionCookie] = cookies.filter((c) => c.name === '_teachingvacancies_session');

  // const cookieData = [];

  // cookieData.push({
  //   "name": sessionCookie.name,
  //   "value": sessionCookie.value,
  //   "domain": sessionCookie.domain,
  //   "path": sessionCookie.path,
  //   "expires": sessionCookie.expires,
  //   "httpOnly": sessionCookie.httpOnly,
  //   "secure": sessionCookie.secure,
  //   "sameSite": sessionCookie.sameSite
  // });

  // const fsPromises = fs.promises;
  
  // const writeCookies = async () => {
  //   return fsPromises.writeFile('config/backstop/cookies.json', JSON.stringify(cookieData), (err) => {
  //     if (err) {
  //         throw err;
  //     }
  //     console.log("JSON data is saved.");
  //   });
  // }

  // await writeCookies();
};
