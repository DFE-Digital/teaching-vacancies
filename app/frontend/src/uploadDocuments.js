document.addEventListener('DOMContentLoaded', function() {
  const inputFileUpload = document.getElementsByClassName('govuk-file-upload')[0];
  const selectFileButton = document.getElementsByClassName('govuk-button--secondary')[0];
  const uploadFileButton = document.getElementsByClassName('govuk-button--secondary')[1];

  selectFileButton.addEventListener('click', function(e) {
    e.preventDefault();

    inputFileUpload.click();
  });

  inputFileUpload.addEventListener('change', function(e) {
    inputFileUpload.form.submit();
  });

  inputFileUpload.classList.add('display-none');
  uploadFileButton.classList.add('display-none');
  selectFileButton.classList.remove('display-none');
});
