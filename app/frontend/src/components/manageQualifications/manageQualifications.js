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
    manageQualifications.addAddSubjectEventListener(subjectLink);
  }

  Array.from(document.getElementsByClassName(FIELDSET_CLASSNAME)).forEach((fieldset) => addDeleteRowEventListener(fieldset));
});

export const addDeleteRowEventListener = (fieldset) => {
  fieldset.addEventListener('click', (e) => {
    if (e.target.classList.contains('delete-button') && e.target === document.activeElement) {
      manageQualifications.deleteRowHandler(e.target);
    }
  });
};

export const addAddSubjectEventListener = (el) => {
  el.addEventListener('click', (event) => {
    event.preventDefault();
    manageQualifications.addSubjectHandler();
  });
};

export const addSubjectHandler = () => {
  const newRow = rowMarkup().cloneNode(true);
  newRow.classList.remove('js-hidden');
  document.getElementsByClassName('js-hidden')[0].before(newRow);
  manageQualifications.renumberRows();
  newRow.getElementsByClassName(GOVUK_INPUT_CLASSNAME)[0].focus();
};

export const deleteRowHandler = (eventTarget) => {
  eventTarget.parentNode.parentNode.remove();
  manageQualifications.renumberRows();
};

export const renumberRows = () => Array.from(manageQualifications.rows()).forEach((row, index) => manageQualifications.renumberRow(row, index));

export const renumberRow = (row, newNumber) => {
  Array.from(row.children).forEach((column) => Array.from(column.children).forEach((cellEl) => {
    manageQualifications.renumberCell(cellEl, newNumber);
  }));
};

export const renumberCell = (renumberEl, newNumber) => {
  if (renumberEl.tagName === 'LABEL') {
    renumberEl.innerHTML = renumberEl.innerHTML.replace(/\d+/g, `${newNumber + 1}`);
  }

  Array.from(renumberEl.attributes).filter((a) => ['for', 'id', 'name'].includes(a.name)).forEach((attribute) => {
    renumberEl.setAttribute(attribute.name, attribute.value.replace(/\d+/g, `${newNumber}`));
  });
};

const manageQualifications = {
  addAddSubjectEventListener,
  addSubjectHandler,
  deleteRowHandler,
  renumberCell,
  renumberRows,
  renumberRow,
  rows,
};

export default manageQualifications;
