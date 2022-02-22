const fs = require('fs');

module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  console.log('JOBSEEKER VIEW APPLICATION > ', scenario.label, viewport.label);

  await page.waitForSelector('.card-component .govuk-link');

  await page.click('.card-component .govuk-link');
};
