/* eslint-disable */
document.addEventListener('DOMContentLoaded', () => {
  const inputFileUpload = document.getElementsByClassName('govuk-file-upload')[0];
  const selectFileButton = document.getElementsByClassName('govuk-button--secondary')[0];
  const uploadFileButton = document.getElementsByClassName('govuk-button--secondary')[1];
  const saveContinueButton = document.getElementsByName('commit')[1];

  if (inputFileUpload && selectFileButton && uploadFileButton && saveContinueButton) {
    selectFileButton.addEventListener('click', (e) => {
      e.preventDefault();
      inputFileUpload.click();
    });

    inputFileUpload.addEventListener('change', (e) => {
      saveContinueButton.disabled = true;
      injectDocumentsTable(inputFileUpload);
      inputFileUpload.form.submit();
    });

    inputFileUpload.classList.add('display-none');
    uploadFileButton.classList.add('display-none');
    selectFileButton.classList.remove('display-none');
  }
});

injectDocumentsTable = function (documentsInput) {
  const filesList = documentsInput.files;

  if (filesList && filesList.length) {
    const documentsContainerElement = document.querySelector('.js-documents');
    const tableBodyElement = documentsContainerElement.querySelector('#js-documents__table-body');

    documentsContainerElement.classList.remove('js-documents--empty');

    for (let i = 0; i < filesList.length; i++) {
      const rowHTML = ` \
        <tr class='govuk-table__row'> \
          <td class='govuk-table__cell' scope='row'>${
  filesList[i].name
}</td>  \
          <td class='govuk-table__cell'>`
            + 'Uploading' + '<span class=\'upload-progress\'><div class=\'upload-progress-spinner\'></div></span>'
          + '</td>  \
          <td class=\'govuk-table__cell\' scope=\'row\'></td>  \
          <td class=\'govuk-table__cell\' scope=\'row\'></td>  \
        </tr> \
      ';
      tableBodyElement.insertAdjacentHTML('beforeend', rowHTML);
    }
  }
};
