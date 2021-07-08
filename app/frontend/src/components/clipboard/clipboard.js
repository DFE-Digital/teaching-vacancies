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

Array.from(document.getElementsByClassName('copy-to-clipboard')).forEach((el) => {
  el.addEventListener('click', (e) => {
    const copyEl = e.target.dataset.targetId;
    const copyText = document.getElementById(copyEl).innerHTML;
    selectText(document.getElementById(copyEl));
    writeText(copyText).then(() => {
      if (e.target.dataset.copiedText) {
        e.target.innerHTML = e.target.dataset.copiedText;
      }

      clearSelection();
    });
  });
});
