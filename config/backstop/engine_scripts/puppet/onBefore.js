const fs = require('fs');

module.exports = async (page, scenario, vp) => {
  console.log('OOONNN BBBEEEFFFOORRRE');
  
  await require('./loadCookies')(page, scenario);
};
