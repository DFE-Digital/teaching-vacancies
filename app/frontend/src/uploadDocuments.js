// This triggers a file input when the button is clicked

document.addEventListener('DOMContentLoaded', function() {

  inputFileUpload = document.getElementById('documents-form-documents-field')
    ? document.getElementById('documents-form-documents-field')
    : document.getElementById('documents-form-documents-field-error')

  inputFileUpload.classList.add('display-none');

  document.getElementById('file-upload').addEventListener('click', function(e) {
    e.preventDefault();
    inputFileUpload.click();
  });

  document.getElementById('file-upload').classList.remove('display-none');
})
