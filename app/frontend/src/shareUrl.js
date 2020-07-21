/* eslint-disable */
import ClipboardJS from 'clipboard';

$(document).ready(() => {
  new ClipboardJS('.copy-to-clipboard');

  $('.copy-to-clipboard').click((event) => {
    event.preventDefault();
  });
});
