import manageQualifications, {
  addEventListenerForAddSubject,
  addSubject,
  FIELDSET_ID,
  ROW_CLASS,
  SUBJECT_LINK_ID,
} from './manageQualifications';

describe('manageQualifications', () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });
  document.body.innerHTML = `<div id="${FIELDSET_ID}">
    <div class="${ROW_CLASS}">
      <label for="subject1">Subject 1</label>
      <input id="s1" value="Economics 101">
    </div>
    <div class="${ROW_CLASS}"></div>
    <a id="${SUBJECT_LINK_ID}" href="#">Click me</a>
  </div>`;
  const firstRowHardCoded = document.getElementsByClassName(ROW_CLASS)[0];
  describe('addEventListenerForAddSubject', () => {
    const button = document.getElementById(SUBJECT_LINK_ID);
    test('when the link is clicked, it adds a subject with the right number', () => {
      manageQualifications.addSubject = jest.fn();
      const addSubjectMock = jest.spyOn(manageQualifications, 'addSubject');
      addEventListenerForAddSubject(button, firstRowHardCoded);
      button.dispatchEvent(new Event('click'));
      expect(addSubjectMock).toHaveBeenCalledWith(2, firstRowHardCoded);
    });
  });
  describe('addSubject', () => {
    addSubject(2, firstRowHardCoded);
    test('adds a row', () => {
      expect(document.getElementsByClassName(ROW_CLASS).length).toBe(3);
    });
    //  adds a delete button
    //  subject in focus
    //  label with right number
  });
});
