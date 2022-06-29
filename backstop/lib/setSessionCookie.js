const fsPromises = require('fs').promises;

module.exports = async (context, filepath) => {
  const writeCookies = async (cookies) => {
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

    await fsPromises.writeFile(filepath, JSON.stringify(cookieData), (err) => {
      if (err) throw err;
    });
  }

  const cookies = await context.cookies()

  await writeCookies(cookies);
}
