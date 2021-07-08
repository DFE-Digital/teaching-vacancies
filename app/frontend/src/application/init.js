/* eslint-disable */
import './jobseekers/init';
import './publishers/init';
import '../components/form/form';

document.addEventListener('DOMContentLoaded', () => {
  const writeText = (copytext) => {
    return new Promise((resolve, reject) => {
      let success = false;
      const listener = (e) => {
        // e.clipboardData.setData('text/plain', str);
        e.clipboardData.setData('Text', copytext);
        console.log('listener str', copytext);
        e.preventDefault();
        success = true;
      };
      document.addEventListener('copy', listener);
      document.execCommand('copy');
      document.removeEventListener('copy', listener);
      console.log('success', success);
      success ? resolve() : reject();
    });
  };

  Array.from(document.getElementsByClassName('copy-to-clipboard')).forEach((el) => {
    el.addEventListener('click', (e) => {
      const copyEl = e.target.dataset.targetId;
      const copyText = document.getElementById(copyEl).innerHTML;
      console.log('click', copyText);
      writeText(copyText).then(() => {
        console.log('copied');
        e.target.innerHTML = 'Copied';
      });
    });
  });
});
/* eslint-enable */
