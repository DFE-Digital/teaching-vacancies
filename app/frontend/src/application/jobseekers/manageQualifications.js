export const DELETE_BUTTON_CLASSNAME = 'delete-button';
export const FIELDSET_CLASSNAME = 'subjects-and-grades';
export const GOVUK_ERROR_MESSAGE_SELECTOR = '.govuk-error-message';
export const GOVUK_INPUT_CLASSNAME = 'govuk-input';
export const ROW_CLASS = 'subject-row';
export const SUBJECT_LINK_ID = 'add_subject';

export const rows = () => document.getElementsByClassName(ROW_CLASS);
export const rowMarkup = () => rows()[document.getElementsByClassName(ROW_CLASS).length - 1];

window.addEventListener('DOMContentLoaded', () => {
  const subjectLink = document.getElementById(SUBJECT_LINK_ID);
  if (subjectLink) {
    manageQualifications.addEventListenerForAddSubject(subjectLink);
  }

  Array.from(document.getElementsByClassName(FIELDSET_CLASSNAME)).forEach((fieldset) => addDeleteRowEventListener(fieldset));
});

export const addDeleteRowEventListener = (fieldset) => {
  fieldset.addEventListener('click', (e) => {
    if (e.target.classList.contains('delete-button')) {
      manageQualifications.onDelete(e.target);
    }
  });
};

export const addEventListenerForAddSubject = (el) => {
  el.addEventListener('click', (event) => {
    event.preventDefault();
    manageQualifications.addSubject();
  });
};

export const addSubject = () => {
  const newRow = rowMarkup().cloneNode(true);
  document.getElementsByClassName(FIELDSET_CLASSNAME)[0].appendChild(newRow);
  manageQualifications.renumberRow(newRow, rows().length, true);
  newRow.getElementsByClassName(GOVUK_INPUT_CLASSNAME)[0].focus();
};

export const onDelete = (eventTarget) => {
  eventTarget.parentNode.remove();
  manageQualifications.renumberRows();
};

export const renumberRows = () => Array.from(manageQualifications.rows()).forEach((row, index) => manageQualifications.renumberRow(row, index + 1));

export const renumberRow = (row, newNumber, clearValues) => {
  Array.from(row.children).forEach((column) => Array.from(column.children).forEach((cellEl) => {
    manageQualifications.renumberCell(cellEl, newNumber, clearValues);
  }));
};

export const renumberCell = (renumberEl, newNumber, clearValues) => {
  renumberEl.innerHTML = renumberEl.innerHTML.replace(/\d+/g, `${newNumber}`);

  Array.from(renumberEl.attributes).forEach((attribute) => {
    if (clearValues) {
      manageQualifications.removeErrors(renumberEl);

      renumberEl.removeAttribute('value');
      renumberEl.removeAttribute('aria-required');
    }

    renumberEl.setAttribute(attribute.name, attribute.value.replace(/\d+/g, `${newNumber}`));
  });
};

export const removeErrors = (column) => {
  column.classList.remove('govuk-form-group--error');
  column.classList.remove('govuk-input--error');
};

const manageQualifications = {
  addEventListenerForAddSubject,
  addSubject,
  onDelete,
  removeErrors,
  renumberCell,
  renumberRows,
  renumberRow,
  rows,
};

export default manageQualifications;
