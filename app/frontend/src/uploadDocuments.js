document.addEventListener('DOMContentLoaded', function() {
  const inputFileUpload = document.getElementsByClassName('govuk-file-upload')[0];
  const selectFileButton = document.getElementsByClassName('govuk-button--secondary')[0];
  const uploadFileButton = document.getElementsByClassName('govuk-button--secondary')[1];
  const saveContinueButton = document.getElementsByName('commit')[1];

  if (inputFileUpload && selectFileButton && uploadFileButton && saveContinueButton) {
    selectFileButton.addEventListener('click', function(e) {
      e.preventDefault();
      inputFileUpload.click();
    });
  
    inputFileUpload.addEventListener('change', function(e) {
      saveContinueButton.disabled = true;
      injectDocumentsTable(inputFileUpload);
      inputFileUpload.form.submit();
    });
  
    inputFileUpload.classList.add('display-none');
    uploadFileButton.classList.add('display-none');
    selectFileButton.classList.remove('display-none');
  }
});

injectDocumentsTable = function(documentsInput) {
  const tableHTML = " \
    <table class='govuk-table'> \
      <thead class='govuk-table__head'> \
        <tr class='govuk-table__row'> \
         <th class='govuk-table__header'>File name</> \
         <th class='govuk-table__header'>Status</> \
         <th class='govuk-table__header'>File size</> \
         <th class='govuk-table__header'>Action</> \
        </tr> \
      </thead> \
      <tbody id='table-body' class='govuk-table__body'> \
      </tbody> \
    </table> \
  "
  const noFilesElement = document.getElementById('no-files');
  const filesList = documentsInput.files;

  if (filesList && filesList.length) {
    if (noFilesElement) {
      noFilesElement.insertAdjacentHTML("beforebegin", tableHTML);
      noFilesElement.remove();
    }
    for (let i = 0; i < filesList.length; i++) {
      const rowHTML = " \
        <tr class='govuk-table__row'> \
          <td class='govuk-table__cell' scope='row'>" +
            filesList[i].name +
          "</td>  \
          <td class='govuk-table__cell'>" +
            "Uploading" + "<span class='upload-progress'><div class='upload-progress-spinner'></span></div>" +
          "</td>  \
          <td class='govuk-table__cell'</td>  \
          <td class='govuk-table__cell' scope='row'>" +
            "<a href='#' class='govuk-link govuk-link--no-visited-state'>Cancel</a>" +
          "</td>  \
        </tr> \
      "
      const tableBody = document.getElementById('table-body');
      tableBody.insertAdjacentHTML("beforeend", rowHTML);
    }
  }
}
