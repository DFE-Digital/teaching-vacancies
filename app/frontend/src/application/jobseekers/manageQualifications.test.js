import manageQualifications, {
  addDeletionEventListener,
  addEventListenerForAddSubject,
  rowMarkup,
  addSubject,
  insertDeleteButton,
  onDelete,
  DELETE_BUTTON_CLASSNAME,
  FIELDSET_CLASSNAME,
  ROW_CLASS,
  SUBJECT_LINK_ID, renumberRemainingRows,
} from './manageQualifications';

describe('manageQualifications', () => {
  const originalMarkup = `<div class="${FIELDSET_CLASSNAME}">
      <div class="${ROW_CLASS}">
        <label for="subject1">Subject 1</label>
        <input class="govuk-input" id="s1" value="Maths">
      </div>
      <div class="${ROW_CLASS}">
        <label for="subject2">Subject 2</label>
        <input class="govuk-input" id="s2" value="Music">
        <a id="delete_2" class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
      </div>
      <div class="${ROW_CLASS}">
        <label for="subject3">Subject 3</label>
        <input class="govuk-input" id="s3" value="Geography">
        <a id="delete_3" class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
      </div>
      <div class="${ROW_CLASS}">
        <label for="subject4">Subject 4</label>
        <input class="govuk-input" id="s4" value="Economics 101">
        <a id="delete_4" class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
      </div>
    </div>
    <a id="${SUBJECT_LINK_ID}" href="#">Add subject</a>`;

  beforeEach(() => {
    document.body.innerHTML = originalMarkup;
  });

  describe('addEventListenerForAddSubject', () => {
    document.body.innerHTML = originalMarkup;
    const button = document.getElementById(SUBJECT_LINK_ID);
    test('when the link is clicked, it adds a subject', () => {
      manageQualifications.addSubject = jest.fn();
      const addSubjectSpy = jest.spyOn(manageQualifications, 'addSubject');
      addEventListenerForAddSubject(button);
      button.dispatchEvent(new Event('click'));
      expect(addSubjectSpy).toHaveBeenCalled();
    });
  });

  describe('addSubject', () => {
    manageQualifications.insertDeleteButton = jest.fn();
    manageQualifications.renumberRow = jest.fn();

    const initialNumberOfRows = document.getElementsByClassName(ROW_CLASS).length;

    beforeEach(() => {
      addSubject();
    });

    test('adds a row', () => {
      expect(document.getElementsByClassName(ROW_CLASS).length).toBe(initialNumberOfRows + 1);
    });

    test('renumbers row, discarding values and errors', () => {
      const renumberRowSpy = jest.spyOn(manageQualifications, 'renumberRow');
      expect(renumberRowSpy).toHaveBeenCalledWith(rowMarkup(), document.getElementsByClassName(ROW_CLASS).length, false);
    });

    test('adds a delete button', () => {
      const insertDeleteButtonSpy = jest.spyOn(manageQualifications, 'insertDeleteButton');
      expect(insertDeleteButtonSpy).toHaveBeenCalledWith(rowMarkup(), document.getElementsByClassName(ROW_CLASS).length);
    });

    test('puts the new subject input in focus', () => {
      expect(document.getElementsByClassName(ROW_CLASS)[initialNumberOfRows].querySelector('input') === document.activeElement).toBe(true);
    });
  });

  describe('insertDeleteButton', () => {
    manageQualifications.addDeletionEventListener = jest.fn();
    const addDeletionEventListenerSpy = jest.spyOn(manageQualifications, 'addDeletionEventListener');
    const newRow = document.getElementsByClassName(ROW_CLASS)[0].cloneNode(true);
    insertDeleteButton(newRow, 10);
    const deleteButton = newRow.lastElementChild;

    test('adds button markup', () => {
      expect(deleteButton.text).toBe('delete subject');
      expect(deleteButton.id).toBe('delete_10');
      expect(deleteButton.classList).toContain(DELETE_BUTTON_CLASSNAME);
    });

    test('adds deletion event listener', () => {
      expect(addDeletionEventListenerSpy).toHaveBeenCalledWith(deleteButton);
    });
  });

  describe('addDeletionEventListener', () => {
    manageQualifications.onDelete = jest.fn();
    const onDeleteSpy = jest.spyOn(manageQualifications, 'onDelete');
    const newRow = document.getElementsByClassName(ROW_CLASS)[0].cloneNode(true);
    const deleteButton = newRow.lastElementChild;
    addDeletionEventListener(deleteButton);
    deleteButton.dispatchEvent(new Event('click'));

    test('when the link is clicked, it deletes row and renumbers remaining rows', () => {
      expect(onDeleteSpy).toHaveBeenCalledWith(deleteButton);
    });
  });

  describe('onDelete', () => {
    manageQualifications.renumberRemainingRows = jest.fn();
    const initialNumberOfRows = document.getElementsByClassName(ROW_CLASS).length;
    const rowNumberToDelete = '2';

    beforeEach(() => {
      onDelete(document.getElementById(`delete_${rowNumberToDelete}`));
    });

    test('deletes row', () => {
      expect(document.getElementsByClassName(ROW_CLASS).length).toBe(initialNumberOfRows - 1);
    });

    test('renumbers the rows after the deleted row', () => {
      const renumberRemainingRowsSpy = jest.spyOn(manageQualifications, 'renumberRemainingRows');
      expect(renumberRemainingRowsSpy).toHaveBeenCalledWith(rowNumberToDelete);
    });
  });

  describe('renumberRemainingRows', () => {
    manageQualifications.renumberRow = jest.fn();
    const renumberRowSpy = jest.spyOn(manageQualifications, 'renumberRow');

    test('renumbers the rows after the deleted row, keeping the values and errors', () => {
      const rows = document.getElementsByClassName(ROW_CLASS);
      renumberRemainingRows(2);
      expect(renumberRowSpy).toHaveBeenCalledWith(rows[2], 3, true);
      expect(renumberRowSpy).toHaveBeenCalledWith(rows[3], 4, true);
    });
  });
});
