const fsPromises = require('fs').promises;

module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  async function exists (path) {  
    try {
      await fsPromises.access(path)
      return true
    } catch {
      return false
    }
  }
  
  const cookies = await exists(scenario.cookiePath)  

  if (!cookies) {
    await require(`./auth/${scenario.AUTH_TYPE}`)(page, scenario, viewport, isReference, browserContext);
  }

  await require('./playwright/loadCookies')(browserContext, scenario, scenario.cookieConsent);
};
