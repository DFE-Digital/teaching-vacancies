document.addEventListener('DOMContentLoaded', function() {
  const inputFileUpload = document.getElementsByClassName('govuk-file-upload')[0];
  const selectFileButton = document.getElementsByClassName('govuk-button--secondary')[0];
  const uploadFileButton = document.getElementsByClassName('govuk-button--secondary')[1];
  const saveContinueButton = document.getElementsByName('commit')[1];

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
});

injectDocumentsTable = function(documentsInput) {
  var tableHTML = " \
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
  var p = document.getElementById('no-files');
  var filesList = documentsInput.files;

  if (filesList.length) {
    if (p) {
      p.insertAdjacentHTML("beforebegin", tableHTML);
    }
    for (var i = 0; i < filesList.length; i++) {
      var rowHTML = " \
        <tr class='govuk-table__row'> \
          <td class='govuk-table__cell' scope='row'>" + 
            filesList[i].name +
          "</td>  \
          <td class='govuk-table__cell'>" + 
            "Uploading..." +
          "</td>  \
          <td class='govuk-table__cell' scope='row'>" + 
            (filesList[i].size / 1024.0 / 1024.0).toFixed(2) + " MB" +
          "</td>  \
          <td class='govuk-table__cell' scope='row'>" + 
            "<a href='#' class='govuk-link govuk-link--no-visited-state'>Cancel</a>" +
          "</td>  \
        </tr> \
      "
      var b = document.getElementById('table-body');
      b.insertAdjacentHTML("beforeend", rowHTML);
    }
    if (p) {
      p.remove();
    }
  }
}
