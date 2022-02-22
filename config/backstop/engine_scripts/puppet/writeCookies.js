const fs = require('fs');

module.exports = async (page, scenario) => {
  page.cookies().then((cookies) => {
    console.log(cookies.filter((c) => c.name === '_teachingvacancies_session'));
    
  })
}
