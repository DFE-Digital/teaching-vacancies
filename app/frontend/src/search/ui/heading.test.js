import { createHeadingMarkup, getSearchTermsPrefix, createHeadingHTMLForSearchTerm } from './heading';

describe('createHeadingMarkup', () => {
  test('creates formatted and readable markup for number of results with no search terms', () => {
    expect(createHeadingMarkup({
      count: 582,
    })).toBe('There are <span class="govuk-!-font-weight-bold">582</span> jobs listed ');
  });

  test('creates formatted and readable markup to reflect search terms for plural number of results', () => {
    expect(createHeadingMarkup({
      count: 4,
      keyword: 'physics',
    })).toBe('<span class="govuk-!-font-weight-bold">4</span> jobs  match  <span class="govuk-!-font-weight-bold text-wrap-apostrophe">physics</span> ');
    expect(createHeadingMarkup({
      count: 4,
      location: 'W12 8QT',
    })).toBe('<span class="govuk-!-font-weight-bold">4</span> jobs found near <span class="govuk-!-font-weight-bold text-capitalize text-wrap-apostrophe">W12 8QT</span>');
    expect(createHeadingMarkup({
      count: 4,
      keyword: 'physics',
      location: 'W12 8QT',
    })).toBe('<span class="govuk-!-font-weight-bold">4</span> jobs  match  <span class="govuk-!-font-weight-bold text-wrap-apostrophe">physics</span> near <span class="govuk-!-font-weight-bold text-capitalize text-wrap-apostrophe">W12 8QT</span>');
  });

  test('creates formatted and readable markup to reflect search terms for one result', () => {
    expect(createHeadingMarkup({
      count: 1,
    })).toBe('There is <span class="govuk-!-font-weight-bold">1</span> job listed ');
    expect(createHeadingMarkup({
      count: 1,
      keyword: 'physics',
    })).toBe('<span class="govuk-!-font-weight-bold">1</span> job  matches  <span class="govuk-!-font-weight-bold text-wrap-apostrophe">physics</span> ');
    expect(createHeadingMarkup({
      count: 1,
      keyword: 'physics',
      location: 'W12 8QT',
    })).toBe('<span class="govuk-!-font-weight-bold">1</span> job  matches  <span class="govuk-!-font-weight-bold text-wrap-apostrophe">physics</span> near <span class="govuk-!-font-weight-bold text-capitalize text-wrap-apostrophe">W12 8QT</span>');
  });
});

describe('getSearchTermsPrefix', () => {
  test('returns a string of capitalized words after a prefix', () => {
    expect(getSearchTermsPrefix('babylon gardens', 'physics', 1)).toBe(' matches ');
    expect(getSearchTermsPrefix('babylon gardens', 'physics', 10)).toBe(' match ');
    expect(getSearchTermsPrefix('', '', 10)).toBe('listed');
    expect(getSearchTermsPrefix('babylon gardens', '', 10)).toBe('found');
  });
});

describe('createHeadingHTMLForSearchTerm', () => {
  test('returns a string of capitalized words after a prefix', () => {
    expect(createHeadingHTMLForSearchTerm('176 jobs near', 'babylon gardens', true)).toBe('176 jobs near <span class="govuk-!-font-weight-bold text-capitalize text-wrap-apostrophe">babylon gardens</span>');
  });
});
