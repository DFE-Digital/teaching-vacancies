import manageQualifications, {
  addEventListenerForAddSubject,
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

  beforeEach(() => {
    jest.resetAllMocks();
  });

  describe('addEventListenerForAddSubject', () => {
    const button = document.getElementById(SUBJECT_LINK_ID);
    test('when the link is clicked, it adds a subject', () => {
      manageQualifications.addSubject = jest.fn();
      const addSubjectMock = jest.spyOn(manageQualifications, 'addSubject');
      addEventListenerForAddSubject(button);
      button.dispatchEvent(new Event('click'));
      expect(addSubjectMock).toHaveBeenCalled();
    });
  });

  describe('addSubject', () => {
    addSubject();
    test('adds a row', () => {
      expect(document.getElementsByClassName(ROW_CLASS).length).toBe(3);
    });

    test('label with right number', () => {
      expect(document.getElementsByClassName(ROW_CLASS)[2].querySelector('label').innerHTML).toBe('Subject 3');
    });

    test('subject in focus', () => {
      expect(document.getElementsByClassName(ROW_CLASS)[2].querySelector('input') === document.activeElement).toBe(true);
    });
    //  adds a delete button
    //  subject in focus
    //  label with right number
  });
});
