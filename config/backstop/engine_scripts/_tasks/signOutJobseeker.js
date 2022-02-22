const fs = require('fs');

module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  console.log('JOBSEEKER SIGN OUT > ' + scenario.label);

  const fsPromises = fs.promises;

  await fsPromises.unlink('config/backstop/cookies.json');
};
