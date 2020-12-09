import {
  sortChange,
  SUBMIT_SELECTOR,
  FIELD_ID,
} from './sort';

describe('Sort select', () => {
  document.body.innerHTML = `
    <form class="new_" id="new_" action="/jobs" accept-charset="UTF-8" method="get">
      <label for="${FIELD_ID}" class="govuk-label inline govuk-!-margin-right-2" id="jobs_sort_label">Sort by</label>
      <select class="govuk-select govuk-select govuk-input--width-10" id="${FIELD_ID}" name="jobs_sort">
        <option value="">most relevant first</option>
      </select>
      <input type="submit" name="commit" value="Sort" class="jobs-sort-submit">
    </form>
  `;

  describe('sortChange', () => {
    test('changing sort input triggers form submit', () => {
      const submitButton = document.querySelector(SUBMIT_SELECTOR);
      submitButton.click = jest.fn();
      const submitMock = jest.spyOn(submitButton, 'click');
      sortChange();
      expect(submitMock).toHaveBeenCalled();
    });
  });
});
