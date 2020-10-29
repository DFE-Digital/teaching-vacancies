import {
  hideSortSubmit,
  sortChange,
} from './sort';

describe('Sort select', () => {
  document.body.innerHTML = `
    <form class="new_" id="new_" action="/jobs" accept-charset="UTF-8" method="get">
      <input value="" type="hidden" name="keyword" id="keyword">
      <input value="" type="hidden" name="location" id="location">
      <input value="10" type="hidden" name="radius" id="radius">
      <div class="govuk-form-group govuk-!-margin-bottom-0">
        <label for="jobs-sort-field" class="govuk-label inline govuk-!-margin-right-2" id="jobs_sort_label">Sort by</label>
        <select class="govuk-select govuk-select govuk-input--width-10" id="jobs-sort-field" name="jobs_sort">
          <option value="">most relevant first</option>
          <option value="publish_on_desc">newest job listing</option>
          <option value="expiry_time_desc">most time to apply</option>
          <option selected="selected" value="expiry_time_asc">least time to apply</option>
        </select>
      </div>
      <input type="submit" name="commit" value="Sort" class="jobs-sort-submit">
    </form>
  `;

  describe('hideSortSubmit', () => {
    describe('on the jobs page', () => {
      test('hides the sort submit input element', () => {
        hideSortSubmit();
        expect(document.querySelector('.jobs-sort-submit').style.display).toBe('none');
      });
    });
  });

  describe('sortChange', () => {
    test('changing sort input triggers form submit', () => {
      const submitButton = document.querySelector('.jobs-sort-submit');
      submitButton.click = jest.fn();
      const submitMock = jest.spyOn(submitButton, 'click');
      sortChange();
      expect(submitMock).toHaveBeenCalled();
    });
  });
});
