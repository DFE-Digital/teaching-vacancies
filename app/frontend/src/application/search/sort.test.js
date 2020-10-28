import {
  hideSortSubmit,
  sortChange,
} from './sort';

describe('Sort select', () => {
  document.body.innerHTML = `
    <form id="jobs_sort_form" action="" accept-charset="UTF-8" method="get">
      <label class="govuk-label inline" id="jobs_sort_label" for="jobs_sort_select">Sort by</label>
      <select name="jobs_sort" id="jobs_sort_select" class="govuk-select govuk-input--width-10"><option value="">most relevant first</option>
        <option value="publish_on_desc">newest job listing</option>
        <option value="expiry_time_desc">most time to apply</option>
        <option selected="selected" value="expiry_time_asc">least time to apply</option>
      </select>
      <input type="submit" name="commit" value="Sort" class="govuk-button govuk-!-margin-0 govuk-input--width-5" id="submit_job_sort" data-disable-with="Sort">
    </form>
  `;

  describe('hideSortSubmit', () => {
    describe('on the jobs page', () => {
      test('hides the sort submit input element', () => {
        hideSortSubmit();
        expect(document.getElementById('submit_job_sort').style.display).toBe('none');
      });
    });
  });

  describe('sortChange', () => {
    test('changing sort input triggers form submit', () => {
      const submitButton = document.getElementById('submit_job_sort');
      submitButton.click = jest.fn();
      const submitMock = jest.spyOn(submitButton, 'click');
      sortChange();
      expect(submitMock).toHaveBeenCalled();
    });
  });
});
