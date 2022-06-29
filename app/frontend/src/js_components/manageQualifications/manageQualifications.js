import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['row'];

  connect() {
    this.emptyRow = this.rowTargets.find((row) => row.classList.contains('js-hidden'));

    const params = new URLSearchParams(document.location.search);

    if (params.get('new_subject') === 'true') {
      this.addRow();
    }
  }

  addRow(event) {
    if (event) {
      event.preventDefault();
    }

    const newRow = this.emptyRow.cloneNode(true);
    newRow.classList.remove('js-hidden');
    this.emptyRow.before(newRow);
    this.renumberRows();
    newRow.querySelector('.govuk-input').focus();
  }

  deleteRow(event) {
    event.currentTarget.parentNode.parentNode.remove();
    this.renumberRows();
  }

  renumberRows() {
    this.rowTargets.forEach((row, index) => {
      Array.from(row.children).forEach((column) => {
        Array.from(column.children).forEach((cell) => {
          if (cell.tagName === 'LABEL') {
            cell.innerHTML = cell.innerHTML.replace(/\d+/, `${index + 1}`);
          }

          Array.from(cell.attributes).filter((a) => ['for', 'id', 'name'].includes(a.name)).forEach((attribute) => {
            cell.setAttribute(attribute.name, attribute.value.replace(/\d+/, `${index}`));
          });
        });
      });
    });
  }
}
