import ClipboardJS from 'clipboard'

$(document).ready(function(){
  new ClipboardJS('.copy-to-clipboard');

  $('.copy-to-clipboard').click(function(event) {
    event.preventDefault();
  });
});
