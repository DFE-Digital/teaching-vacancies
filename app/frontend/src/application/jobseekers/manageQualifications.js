export const DELETE_BUTTON_CLASSNAME = 'delete-button';
export const FIELDSET_CLASSNAME = 'subjects-and-grades';
export const GOVUK_ERROR_MESSAGE_SELECTOR = '.govuk-error-message';
export const GOVUK_INPUT_SELECTOR = '.govuk-input';
export const ROW_CLASS = 'subject-row';
export const SUBJECT_LINK_ID = 'add_subject';

export const rows = () => document.getElementsByClassName(ROW_CLASS);
export const rowMarkup = () => rows()[0];

window.addEventListener('DOMContentLoaded', () => {
  const subjectLink = document.getElementById(SUBJECT_LINK_ID);
  if (subjectLink) {
    manageQualifications.addEventListenerForAddSubject(subjectLink);
    Array.from(manageQualifications.rows()).forEach((row, index) => {
      if (index > 0) {
        manageQualifications.addDeletionEventListener(row.querySelector(`.${DELETE_BUTTON_CLASSNAME}`));
      }
    });
  }
});

export const addEventListenerForAddSubject = (el) => {
  el.addEventListener('click', (event) => {
    event.preventDefault();
    manageQualifications.addSubject();
  });
};

export const addSubject = () => {
  const newRow = rowMarkup().cloneNode(true);
  document.getElementsByClassName(FIELDSET_CLASSNAME)[0].appendChild(newRow);
  const numberRows = rows().length;
  manageQualifications.insertDeleteButton(newRow, numberRows);
  manageQualifications.renumberRow(newRow, numberRows, false);
  newRow.querySelector(GOVUK_INPUT_SELECTOR).focus();
};

export const insertDeleteButton = (row, newNumber) => {
  row.insertAdjacentHTML('beforeend', `<a id="delete_${newNumber}"
    class="govuk-link ${DELETE_BUTTON_CLASSNAME} govuk-!-margin-bottom-6 govuk-!-padding-bottom-2"
    rel="nofollow"
    href="#">delete subject</a>`);
  manageQualifications.addDeletionEventListener(row.querySelector(`.${DELETE_BUTTON_CLASSNAME}`));
};

export const addDeletionEventListener = (el) => {
  el.addEventListener('click', (event) => {
    event.preventDefault();
    manageQualifications.onDelete(event.target);
  });
};

export const onDelete = (eventTarget) => {
  eventTarget.parentNode.remove();
  manageQualifications.renumberRemainingRows(eventTarget.id.replace(/\D/g, ''));
};

export const renumberRemainingRows = (numberOfDeletedRow) => {
  Array.from(manageQualifications.rows()).forEach((row, index) => {
    if (index >= numberOfDeletedRow - 1) {
      manageQualifications.renumberRow(row, index + 1, true);
    }
  });
};

export const renumberRow = (row, newNumber, keepValuesAndErrors) => {
  Array.from(row.children).forEach((column) => manageQualifications.renumberColumn(column, newNumber, keepValuesAndErrors));
};

export const renumberColumn = (column, newNumber, keepValuesAndErrors) => {
  // Directly modify attributes?
  let input = column.querySelector(GOVUK_INPUT_SELECTOR);
  let inputValue;
  if (input && keepValuesAndErrors) {
    inputValue = input.value;
  }
  column.id = column.id.replace(/\d+/g, `${newNumber}`);
  column.innerHTML = column.innerHTML.replace(/\d+/g, `${newNumber}`);
  if (!keepValuesAndErrors && column.querySelector(GOVUK_ERROR_MESSAGE_SELECTOR)) {
    manageQualifications.removeErrors(column);
  }
  input = column.querySelector(GOVUK_INPUT_SELECTOR);
  if (input) {
    if (inputValue && keepValuesAndErrors) {
      input.value = inputValue;
    } else {
      input.removeAttribute('value');
      input.removeAttribute('aria-required');
    }
  }
};

export const removeErrors = (column) => {
  column.className = column.className.replace(/\bgovuk-form-group--error\b/g, '');
  column.innerHTML = column.innerHTML.replace(/field-error\b/g, 'field');
  column.innerHTML = column.innerHTML.replace(/govuk-input--error\b/g, '');
  column.querySelector(GOVUK_ERROR_MESSAGE_SELECTOR).remove();
  column.querySelector(GOVUK_INPUT_SELECTOR).removeAttribute('aria-describedby');
};

const manageQualifications = {
  addDeletionEventListener,
  addEventListenerForAddSubject,
  addSubject,
  insertDeleteButton,
  onDelete,
  removeErrors,
  renumberColumn,
  renumberRemainingRows,
  renumberRow,
  rows,
  DELETE_BUTTON_CLASSNAME,
  FIELDSET_CLASSNAME,
  ROW_CLASS,
  SUBJECT_LINK_ID,
};

export default manageQualifications;
