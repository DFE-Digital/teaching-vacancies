import {
  railsCsrfToken,
} from './events';

describe('railsCsrfToken', () => {
  describe('when the token is present in the document', () => {
    beforeEach(() => {
      document.head.innerHTML = '<meta name="csrf-token" content="aloha">';
    });

    test('extracts the Rails CSRF token from the HTML', () => {
      expect(railsCsrfToken()).toBe('aloha');
    });
  });

  describe('when the token is missing from the document', () => {
    beforeEach(() => {
      document.head.innerHTML = '<html><blink>Nothing to see here</blink></html>';
    });

    test('returns undefined', () => {
      expect(railsCsrfToken()).toBeUndefined();
    });
  });
});
