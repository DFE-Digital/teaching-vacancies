import { Controller } from '@hotwired/stimulus';

let emptyRow;

export default class extends Controller {
  static targets = ['row'];

  connect() {
    emptyRow = this.rowTargets.find((row) => row.classList.contains('js-hidden'));
  }

  addRow(event) {
    event.preventDefault();

    const newRow = emptyRow.cloneNode(true);
    newRow.classList.remove('js-hidden');
    emptyRow.before(newRow);
    this.renumberRows();
    newRow.getElementsByClassName('govuk-input')[0].focus();
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
