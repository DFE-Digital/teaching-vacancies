import { renderSortSelectInput, getSearchReplicaName } from './sort';

describe('renderSortSelectInput', () => {
  test('returns a function', () => {
    expect(typeof renderSortSelectInput).toBe('function');
  });
});

describe('getSearchReplicaName', () => {
  test('returns Vacancy when no search replica is selected', () => {
    expect(getSearchReplicaName('')).toBe('Vacancy');
  });

  test('returns correct index when search replica is selected', () => {
    expect(getSearchReplicaName('this_index')).toBe('Vacancy_this_index');
  });
});
