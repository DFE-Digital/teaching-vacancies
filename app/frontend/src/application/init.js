/* eslint-disable */
import './jobseekers/init';
import './publishers/init';
import '../components/form/form';

document.addEventListener('DOMContentLoaded', () => {
  const writeText = (str) => {
    return new Promise((resolve, reject) => {
      let success = false;
      const listener = (e) => {
        e.clipboardData.setData('text/plain', str);
        e.preventDefault();
        success = true;
      };
      document.addEventListener('copy', listener);
      document.execCommand('copy');
      document.removeEventListener('copy', listener);
      success ? resolve() : reject();
    });
  };

  Array.from(document.getElementsByClassName('copy-to-clipboard')).forEach((el) => {
    el.addEventListener('click', (e) => {
      const copyEl = e.target.dataset.targetId;
      const copyText = document.getElementById(copyEl).innerHTML;

      writeText(copyText).then(() => {
        e.target.innerHTML = 'Copied';
      });
    });
  });
});
/* eslint-enable */
