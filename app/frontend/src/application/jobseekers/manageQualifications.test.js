import manageQualifications, {
  addEventListenerForAddSubject,
  SUBJECT_LINK_ID,
} from './manageQualifications';

describe('manageQualifications', () => {
  beforeEach(() => {
    jest.resetAllMocks();
  });
  describe('addEventListenerForAddSubject', () => {
    document.body.innerHTML = `
      <div class="subject-row"></div>
      <div class="subject-row"></div>
      <a id="${SUBJECT_LINK_ID}" href="#">Click me</a>`;
    const button = document.getElementById(SUBJECT_LINK_ID);
    test('when the link is clicked, it adds a subject with the right number', () => {
      manageQualifications.addSubject = jest.fn();
      const addSubjectMock = jest.spyOn(manageQualifications, 'addSubject');
      addEventListenerForAddSubject(button);
      button.dispatchEvent(new Event('click'));
      expect(addSubjectMock).toHaveBeenCalledWith(2);
    });
  });
  describe('addSubject', () => {

  });
});
