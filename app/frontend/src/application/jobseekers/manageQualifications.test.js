import manageQualifications, {
  addEventListenerForAddSubject,
  rowMarkup,
  addSubject,
  FIELDSET_ID,
  ROW_CLASS,
  SUBJECT_LINK_ID,
} from './manageQualifications';

describe('manageQualifications', () => {
  document.body.innerHTML = `<div id="${FIELDSET_ID}">
  <div class="${ROW_CLASS}">
    <label for="subject1">Subject 1</label>
    <input class="govuk-input" id="s1" value="Economics 101">
  </div>
  <div class="${ROW_CLASS}"></div>
  <a id="${SUBJECT_LINK_ID}" href="#">Add subject</a>
</div>`;

  // beforeEach(() => {
  //   jest.resetAllMocks();
  // });

  describe('addEventListenerForAddSubject', () => {
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
    const renumberRowSpy = jest.spyOn(manageQualifications, 'renumberRow');

    manageQualifications.insertDeleteButton = jest.fn();
    const insertDeleteButtonSpy = jest.spyOn(manageQualifications, 'insertDeleteButton');

    beforeAll(() => addSubject());
    
    test('adds a row', () => {
      expect(document.getElementsByClassName(ROW_CLASS).length).toBe(3);
    });

    test('renumbers row', () => {
      expect(renumberRowSpy).toHaveBeenCalledWith(rowMarkup(), document.getElementsByClassName(ROW_CLASS).length, false, false);
    });

    test('adds a delete button', () => {
      expect(insertDeleteButtonSpy).toHaveBeenCalledWith(rowMarkup(), document.getElementsByClassName(ROW_CLASS).length);
    });

    test('subject in focus', () => {
      expect(document.getElementsByClassName(ROW_CLASS)[2].querySelector('input') === document.activeElement).toBe(true);
    });
  });
});
