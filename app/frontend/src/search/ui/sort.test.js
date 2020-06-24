import { renderSortSelectInput, getSearchIndexName } from './sort';

describe('renderSortSelectInput', () => {
  test('returns a function', () => {
    expect(typeof renderSortSelectInput).toBe('function');
  });
});

describe('getSearchIndexName', () => {
  test('returns the default search replica when no search replica is selected', () => {
    expect(getSearchIndexName('')).toBe('Vacancy_publish_on_desc');
    expect(getSearchIndexName(null)).toBe('Vacancy_publish_on_desc');
  });

  test('returns the base index Vacancy when most_relevant is selected', () => {
    expect(getSearchIndexName('most_relevant')).toBe('Vacancy');
  });

  test('returns correct index when search replica is selected', () => {
    expect(getSearchIndexName('this_index')).toBe('Vacancy_this_index');
  });
});
