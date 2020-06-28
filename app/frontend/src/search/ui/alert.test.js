import { getJobAlertLinkParam, getJobAlertLink } from './alert';

describe('getJobAlertLink', () => {
  let resultsUrl = '';
  test('creates a valid url for location not in predefined list', () => {
    document.body.innerHTML = `<select name="radius" id="radius" data-radius="10"><option value="10">10 mile</option>
    <option value="50">50 miles</option>
</select>`;

    resultsUrl = 'jobs?utf8=✓&keyword=&location=harlow&commit=Search#job-count';

    expect(getJobAlertLink(resultsUrl))
      .toBe('/subscriptions/new?search_criteria%5Blocation%5D=harlow&search_criteria%5Bradius%5D=10&');

    expect(typeof new URL(`http://host${getJobAlertLink(resultsUrl)}`)).toBe('object');
  });

  test('creates a valid url for location in predefined list', () => {
    document.body.innerHTML = `<select name="radius" id="radius"><option value="10">10 mile</option>
      <option value="50">50 miles</option>
  </select>`;
    resultsUrl = 'jobs?utf8=✓&keyword=teacher&location=london&commit=Search#job-count';
    expect(getJobAlertLink(resultsUrl))
      .toBe('/subscriptions/new?search_criteria%5Bkeyword%5D=teacher&search_criteria%5Blocation%5D=london&search_criteria%5Blocation_category%5D=london&');

    expect(typeof new URL(`http://host${getJobAlertLink(resultsUrl)}`)).toBe('object');
  });
});

describe('getJobAlertLinkParam', () => {
  test('converts key,value to valid url parameter string', () => {
    expect(getJobAlertLinkParam('location', 'south east')).toBe('search_criteria%5Blocation%5D=south+east&');
  });

  test('converts key,value to valid url parameter string for a sub array', () => {
    expect(getJobAlertLinkParam('coordinates', '51', true)).toBe('search_criteria%5Bcoordinates%5D%5B%5D=51&');
  });
});
