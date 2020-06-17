import {
  renderStats, constructResults, constructLastResultNumber, constructFirstResultNumber,
} from './stats';

describe('renderStats', () => {
  test('returns a function', () => {
    expect(typeof renderStats).toBe('function');
  });
});

describe('constructResults', () => {
  test('returns result if 1 result', () => {
    expect(constructResults(1)).toBe('result');
  });

  test('returns results if more than 1 result', () => {
    expect(constructResults(100)).toBe('results');
  });
});

describe('constructLastResult', () => {
  test('returns 0 if no pages', () => {
    expect(constructLastResultNumber(0, 0, 0, 10)).toBe(0);
  });

  test('returns correct number of results if last page', () => {
    expect(constructLastResultNumber(1, 0, 8, 10)).toBe(8);
  });

  test('returns correct number of results', () => {
    expect(constructLastResultNumber(10, 1, 100, 10)).toBe(20);
  });
});

describe('constructFirstResult', () => {
  test('returns 0 if no pages', () => {
    expect(constructFirstResultNumber(0, 0, 0)).toBe(0);
  });

  test('returns correct number of results', () => {
    expect(constructFirstResultNumber(5, 2, 10)).toBe(21);
  });
});
