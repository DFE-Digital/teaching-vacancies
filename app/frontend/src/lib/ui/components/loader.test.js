import { add, remove } from './loader';

describe('loader', () => {
  const LOADING = 'loading placeholder';
  const DEFAULT = 'default placeholder';

  describe('add', () => {
    document.body.innerHTML = '<input id="test-input" />';
    const input = document.getElementById('test-input');

    add(input, LOADING);
    test('inserts loading animation next to target element', () => {
      expect(typeof document.getElementById('loader')).toBe('object');
    });

    test('changes placeholder text of the input', () => {
      expect(input.placeholder).toBe(LOADING);
    });
  });

  describe('remove', () => {
    document.body.innerHTML = '<input id="test-input" />';
    const input = document.getElementById('test-input');

    add(input, LOADING);
    remove(input, DEFAULT);
    test('removes loading animation from target element', () => {
      expect(document.getElementById('loader')).toBeFalsy();
    });

    test('reverts placeholder text of the input', () => {
      expect(input.placeholder).toBe(DEFAULT);
    });
  });
});
