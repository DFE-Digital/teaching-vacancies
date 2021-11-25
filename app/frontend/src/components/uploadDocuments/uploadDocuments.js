import 'classlist-polyfill';
import './uploadDocuments.scss';
import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['inputFileUpload', 'uploadFilesButton', 'selectFileButton', 'saveListingButton'];

  connect() {
    if (this.inputFileUploadTarget && this.uploadFilesButtonTarget && this.selectFileButtonTarget) {
      this.selectFileButtonTarget.addEventListener('click', (e) => {
        e.preventDefault();
        this.inputFileUploadTarget.click();
      });

      this.inputFileUploadTarget.addEventListener('change', () => {
        this.saveListingButtonTarget.disabled = true;
        this.injectDocumentsTable();
        this.inputFileUploadTarget.form.submit();
      });

      this.inputFileUploadTarget.classList.add('display-none');
      this.uploadFilesButtonTarget.classList.add('display-none');
      this.selectFileButtonTarget.classList.remove('display-none');
    }
  }

  injectDocumentsTable() {
    const filesList = this.inputFileUploadTarget.files;

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
  }
}
