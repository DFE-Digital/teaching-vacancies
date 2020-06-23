import { renderPagination } from './pagination';

describe('renderPagination', () => {
  test('returns a function', () => {
    expect(typeof renderPagination).toBe('function');
  });
});
