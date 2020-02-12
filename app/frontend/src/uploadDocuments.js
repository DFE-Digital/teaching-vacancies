// This triggers a file input when the button is clicked

document.addEventListener('DOMContentLoaded', function() {
  document.getElementById('file-upload').addEventListener("click", function(e) {
    e.preventDefault();
    document.getElementById('upload').click();
  });
})