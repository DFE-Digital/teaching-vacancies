const fs = require('fs');

fs.rmdir('backstop/lib/.tmp', { recursive: true, force: true }, (error) => {
  if (!error) {
    console.log('\nExisting cookies removed\n');

    fs.mkdirSync('backstop/lib/.tmp');
  }
});
