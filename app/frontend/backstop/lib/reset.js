const fs = require('fs');

fs.rmdir('app/frontend/backstop/lib/.tmp', { recursive: true, force: true }, (error) => {
  if (!error) {
    console.log('\nExisting cookies removed\n');

    fs.mkdirSync('app/frontend/backstop/lib/.tmp');
  }
});
