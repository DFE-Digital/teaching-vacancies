$(document).on('turbolinks:load', function(){
  new ClipboardJS('.copy-to-clipboard');

  $('.copy-to-clipboard').click(function(event) {
    event.preventDefault();
  });
});
