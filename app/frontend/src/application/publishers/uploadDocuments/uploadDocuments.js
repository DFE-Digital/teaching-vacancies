import 'classlist-polyfill';
import './uploadDocuments.scss';

document.addEventListener('DOMContentLoaded', () => {
  const inputFileUpload = document.getElementById('publishers-job-listing-documents-form-documents-field');
  const selectFileButton = document.getElementById('select-files-button');
  const uploadFileButton = document.getElementsByClassName('upload-files-button')[0];
  const continueButton = document.getElementsByClassName('save-listing-gtm')[0];
  const updateButton = document.getElementsByClassName('save-listing-gtm')[0];
  const saveButton = document.getElementsByClassName('save-and-return-listing-gtm')[0];

  if (inputFileUpload && selectFileButton && uploadFileButton) {
    selectFileButton.addEventListener('click', (e) => {
      e.preventDefault();
      inputFileUpload.click();
    });

    inputFileUpload.addEventListener('change', () => {
      if (continueButton) {
        continueButton.disabled = true;
      }
      if (updateButton) {
        updateButton.disabled = true;
      }
      if (saveButton) {
        saveButton.disabled = true;
      }
      injectDocumentsTable(inputFileUpload);
      inputFileUpload.form.submit();
    });

    inputFileUpload.classList.add('display-none');
    uploadFileButton.classList.add('display-none');
    selectFileButton.classList.remove('display-none');
  }
});

const injectDocumentsTable = (documentsInput) => {
  const filesList = documentsInput.files;

  if (filesList && filesList.length) {
    const documentsContainerElement = document.querySelector('.js-documents');
    const tableBodyElement = documentsContainerElement.querySelector('#js-documents__table-body');

    documentsContainerElement.classList.remove('js-documents--empty');

    Array.from(filesList).forEach((file) => {
      const rowHTML = `
<tr class='govuk-table__row'>
<td class='govuk-table__cell' scope='row'>${file.name}</td>
<td class='govuk-table__cell'>
Uploading<span class='upload-progress'><div class='upload-progress-spinner'></div></span>
</td>
<td class='govuk-table__cell' scope='row'></td>
<td class='govuk-table__cell' scope='row'></td>
</tr> `;
      tableBodyElement.insertAdjacentHTML('beforeend', rowHTML);
    });
  }
};
