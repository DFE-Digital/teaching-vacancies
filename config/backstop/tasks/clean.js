const fs = require('fs');

fs.rmdir('visual_regression/bitmaps_test', { recursive: true, force: true }, (error) => {
  if (!error) {
    console.log('\nTest comparision files removed\n');
  }
});

