const fs = require('fs');

module.exports = async (context) => {
  const cookies = await context.cookies();

  const [sessionCookie] = cookies.filter((c) => c.name === '_teachingvacancies_session');

  const cookieData = [];

  cookieData.push({
    "name": sessionCookie.name,
    "value": sessionCookie.value,
    "domain": sessionCookie.domain,
    "path": sessionCookie.path,
    "expires": sessionCookie.expires,
    "httpOnly": sessionCookie.httpOnly,
    "secure": sessionCookie.secure,
    "sameSite": sessionCookie.sameSite
  });

  const fsPromises = fs.promises;
  
  const writeCookies = async () => {
    await fsPromises.writeFile('config/backstop/cookies.json', JSON.stringify(cookieData), (err) => {
      if (err) {
          throw err;
      }
      console.log("JSON data is saved.");
    });
  }

  await writeCookies();
}