import manageQualifications, {
  addEventListenerForAddSubject,
  rowMarkup,
  addSubject,
  renumberRow,
  renumberRows,
  onDelete,
  DELETE_BUTTON_CLASSNAME,
  FIELDSET_CLASSNAME,
  GOVUK_INPUT_CLASSNAME,
  ROW_CLASS,
  SUBJECT_LINK_ID,
} from './manageQualifications';

describe('manageQualifications', () => {
  const originalMarkup = `<div class="${FIELDSET_CLASSNAME}">
      <div class="${ROW_CLASS}">
        <label for="subject1">Subject 1</label>
        <input class="${GOVUK_INPUT_CLASSNAME}" id="s1" value="Maths" />
      </div>
      <div class="${ROW_CLASS}">
        <label for="subject2">Subject 2</label>
        <input class="${GOVUK_INPUT_CLASSNAME}" id="s2" value="Music" />
        <a class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
      </div>
      <div class="${ROW_CLASS}">
        <label for="subject3">Subject 3</label>
        <input class="${GOVUK_INPUT_CLASSNAME}" class="govuk-input--error" id="s3" value="Geography" />
        <a class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
      </div>
      <div class="${ROW_CLASS}">
        <label for="subject4">Subject 4</label>
        <input class="${GOVUK_INPUT_CLASSNAME}" id="s4" value="Economics 101" />
        <a class="${DELETE_BUTTON_CLASSNAME}" href="#">delete subject</a>
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
      expect(renumberRowSpy).toHaveBeenCalledWith(rowMarkup(), document.getElementsByClassName(ROW_CLASS).length, true);
    });

    test('puts the new subject input in focus', () => {
      expect(document.getElementsByClassName(ROW_CLASS)[initialNumberOfRows].querySelector('input') === document.activeElement).toBe(true);
    });
  });

  describe('onDelete', () => {
    manageQualifications.renumberRows = jest.fn();
    const renumberRowsSpy = jest.spyOn(manageQualifications, 'renumberRows');

    const initialNumberOfRows = document.getElementsByClassName(ROW_CLASS).length;
    const rowNumberToDelete = '2';

    beforeEach(() => {
      onDelete(document.getElementsByClassName(ROW_CLASS)[rowNumberToDelete].children[2]);
    });

    test('deletes row', () => {
      expect(document.getElementsByClassName(ROW_CLASS).length).toBe(initialNumberOfRows - 1);
    });

    test('renumbers the rows', () => {
      expect(renumberRowsSpy).toHaveBeenCalledTimes(2);
    });
  });

  describe('renumber rows', () => {
    manageQualifications.renumberRow = jest.fn();
    const renumberRowSpy = jest.spyOn(manageQualifications, 'renumberRow');

    beforeEach(() => {
      renumberRows();
    });

    test('renumbers all rows', () => {
      expect(renumberRowSpy).toHaveBeenCalledWith(document.getElementsByClassName(ROW_CLASS)[3], 5, true);
    });
  });

  describe('renumber row', () => {
    manageQualifications.renumberCell = jest.fn();
    const renumberCellSpy = jest.spyOn(manageQualifications, 'renumberCell');

    const row = document.getElementsByClassName(FIELDSET_CLASSNAME)[0];

    beforeEach(() => {
      renumberRow(row, 3, false);
    });

    test('renumbers all cells', () => {
      expect(renumberCellSpy).toHaveBeenCalledTimes(11);
    });
  });

  describe('renumbers cells', () => {
    const row = document.getElementsByClassName(FIELDSET_CLASSNAME)[0];

    test('renumbers all cell attributes and labels', () => {
      renumberRow(row, 3, false);
      expect(document.getElementsByClassName(ROW_CLASS)[3].children[0].innerHTML).toBe('Subject 4');
      expect(document.getElementsByClassName(ROW_CLASS)[3].children[0].getAttribute('for')).toBe('subject4');
      expect(document.getElementsByClassName(ROW_CLASS)[3].children[1].value).toBe('Economics 101');
    });
  });
});

