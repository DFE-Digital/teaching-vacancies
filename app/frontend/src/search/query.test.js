import { getFilters, getQuery } from './query';

describe('getFilters', () => {
  test('returns a string', () => {
    expect(typeof getFilters()).toBe('string');
  });
});

describe('getQuery', () => {
  test('returns an array', () => {
    expect(typeof getQuery()).toBe('string');
  });
});
