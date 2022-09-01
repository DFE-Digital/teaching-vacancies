import fs from 'fs-extra';

if (!process.env.CI) {
  fs.remove('app/assets/builds', err => {
    if (err) return console.error(err);
    console.log('Build folder removed!');
  });
}
