export const DELETE_BUTTON_CLASSNAME = 'delete-button';
export const GOVUK_ERROR_MESSAGE_CLASSNAME = '.govuk-error-message';
export const GOVUK_INPUT_CLASSNAME = '.govuk-input';

export const rows = () => document.getElementsByClassName('subject-row');

window.addEventListener('DOMContentLoaded', () => {
  manageQualifications.addEventListenerForAddSubject();
  Array.from(manageQualifications.rows()).forEach((row, index) => {
    if (index > 0) {
      manageQualifications.addDeletionEventListener(row);
    }
  });
});

export const addEventListenerForAddSubject = () => {
  const addSubjectLink = document.getElementById('add_subject');
  const fieldset = document.getElementById('subjects-and-grades');
  if (addSubjectLink && fieldset) {
    addSubjectLink.addEventListener('click', (e) => {
      e.preventDefault();

      const originalRows = manageQualifications.rows();
      const newNumber = originalRows.length + 1;

      if (originalRows && newNumber) {
        const newRow = originalRows[originalRows.length - 1].cloneNode(true);
        if (newNumber === 2) {
          manageQualifications.insertInitialDeleteButton(newRow);
        }
        fieldset.appendChild(newRow);
        manageQualifications.renumberRow(newRow, originalRows.length, false, false);
        manageQualifications.addDeletionEventListener(newRow);
        newRow.querySelector(GOVUK_INPUT_CLASSNAME).focus();
      }
    });
  }
};

export const insertInitialDeleteButton = (row) => {
  row.insertAdjacentHTML('beforeend', `<a id="delete_2"
    class="govuk-link ${DELETE_BUTTON_CLASSNAME} govuk-!-margin-bottom-6 govuk-!-padding-bottom-2"
    rel="nofollow"
    href="#">delete subject</a>`);
};

export const addDeletionEventListener = (row) => {
  row.querySelector(`.${DELETE_BUTTON_CLASSNAME}`).addEventListener('click', (event) => {
    event.preventDefault();
    const indexToDelete = event.target.id.replace(/\D/g, '');
    document.getElementById(`subject_row_${indexToDelete}`).remove();
    manageQualifications.renumberRemainingRows(indexToDelete);
  });
};

export const renumberRemainingRows = (deletedIndex) => {
  Array.from(manageQualifications.rows()).forEach((row, index) => {
    if (index >= deletedIndex - 1) {
      manageQualifications.renumberRow(row, index + 1, true, true);
    }
  });
};

export const renumberRow = (row, newNumber, keepValues, keepErrors) => {
  row.id = `subject_row_${newNumber}`;
  Array.from(row.children).forEach((column) => manageQualifications.renumberColumn(column, newNumber, keepValues, keepErrors));
};

export const renumberColumn = (column, newNumber, keepValues, keepErrors) => {
  let input = column.querySelector(GOVUK_INPUT_CLASSNAME);
  let inputValue;
  if (input && keepValues) {
    inputValue = input.value;
  }
  column.id = column.id.replace(/\d+/g, `${newNumber}`);
  column.innerHTML = column.innerHTML.replace(/\d+/g, `${newNumber}`);
  if (!keepErrors && column.querySelector(GOVUK_ERROR_MESSAGE_CLASSNAME)) {
    manageQualifications.removeErrors(column);
  }
  input = column.querySelector(GOVUK_INPUT_CLASSNAME);
  if (input) {
    if (inputValue && keepValues) {
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
  column.querySelector(GOVUK_ERROR_MESSAGE_CLASSNAME).remove();
  column.querySelector(GOVUK_INPUT_CLASSNAME).removeAttribute('aria-describedby');
};

const manageQualifications = {
  addDeletionEventListener,
  addEventListenerForAddSubject,
  insertInitialDeleteButton,
  removeErrors,
  renumberColumn,
  renumberRemainingRows,
  renumberRow,
  rows,
};

export default manageQualifications;
