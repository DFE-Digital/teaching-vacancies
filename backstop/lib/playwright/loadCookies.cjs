const fs = require('fs');

module.exports = async (browserContext, scenario, consent = true) => {
  let cookies = [];
  const cookiePath = scenario.cookiePath;

  // Read Cookies from File, if exists
  if (fs.existsSync(cookiePath)) {
    cookies = JSON.parse(fs.readFileSync(cookiePath));
  }

  const url = new URL(scenario.url);

  if (consent) {
    cookies.push({
      "name": "consented-to-additional-cookies",
      "value": "yes",
      "domain": url.host,
      "path": "/",
      "expires": -1,
      "httpOnly": false,
      "secure": url.protocol === 'https:' ? true : false,
      "sameSite": "Lax"
    })
  }

  // Add cookies to browser
  await browserContext.addCookies(cookies);

  console.log('Cookie state restored with:', cookies.map((cookie) => `${cookie.name}`));
};
