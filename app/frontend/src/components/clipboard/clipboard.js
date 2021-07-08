export const COPY_CLASS_SELECTOR = 'copy-to-clipboard';

/**
 * this is because IE needs text to be selected to copy it to clipboard
 */
export const selectText = (node) => {
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

/**
 * this removes the selection after copy to clipboard has happened
 */
export const clearSelection = () => {
  if (window.getSelection) {
    window.getSelection().removeAllRanges();
  } else if (document.selection) {
    document.selection.empty();
  }
};

/**
 * IE compatible writetext to clipboard function
 */
export const writeText = (copytext) => new Promise((resolve) => {
  const listener = (e) => {
    e.clipboardData.setData('text/plain', copytext);
    e.preventDefault();
  };
  document.addEventListener('copy', listener);
  document.execCommand('copy');
  document.removeEventListener('copy', listener);
  resolve();
});

export const init = (el) => {
  el.addEventListener('click', (e) => {
    const copyEl = e.target.dataset.targetId;
    const copyText = document.getElementById(copyEl).innerHTML;
    clipboard.selectText(document.getElementById(copyEl));
    clipboard.writeText(copyText).then(() => {
      if (e.target.dataset.copiedText) {
        e.target.innerHTML = e.target.dataset.copiedText;
      }

      clearSelection();
    });
  });
};

Array.from(document.getElementsByClassName(COPY_CLASS_SELECTOR)).forEach((el) => init(el));

const clipboard = {
  COPY_CLASS_SELECTOR,
  init,
  selectText,
  writeText,
};

export default clipboard;
