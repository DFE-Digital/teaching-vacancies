const fs = require('fs');

module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  console.log('JOBSEEKER VIEW APPLICATION > ', scenario.label, viewport.label);

  await require('./signInJobseeker')(page, scenario, viewport, isReference, browserContext);

  await page.waitForSelector('.card-component a');

  await page.click('.card-component a');
};
