/* eslint-disable */
import './jobseekers/init';
import './publishers/init';
import '../components/form/form';

document.addEventListener('DOMContentLoaded', () => {

  const selectText = (node) => {
    if (document.body.createTextRange) {
      const range = document.body.createTextRange();
      range.moveToElementText(node);
      range.select();
    } else if (window.getSelection) {
      const selection = window.getSelection();
      const range = document.createRange();
      range.selectNodeContents(node);
      selection.removeAllRanges();
      selection.addRange(range);
    }
  };

  const clearSelection = () => {
    if (window.getSelection) {
      window.getSelection().removeAllRanges();
    } else if (document.selection) {
      document.selection.empty();
    }
  };

  const writeText = (copytext) => {
    return new Promise((resolve) => {
      const listener = (e) => {
        e.clipboardData.setData('text/plain', copytext);
        e.preventDefault();
      };
      document.addEventListener('copy', listener);
      document.execCommand('copy');
      document.removeEventListener('copy', listener);
      resolve();
    });
  };

  Array.from(document.getElementsByClassName('copy-to-clipboard')).forEach((el) => {
    el.addEventListener('click', (e) => {
      const copyEl = e.target.dataset.targetId;
      const copyText = document.getElementById(copyEl).innerHTML;
      selectText(document.getElementById(copyEl));
      writeText(copyText).then(() => {
        e.target.innerHTML = 'Copied';
        clearSelection();
      });
    });
  });
});
/* eslint-enable */
