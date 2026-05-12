/**
 * @jest-environment jsdom
 */

import WordCounterController from './wordCounter';

describe('word counter', () => {
  describe('countWordsInText', () => {
    it('counts words without counting spaces as words', () => {
      expect(WordCounterController.countWordsInText('Education and Experience I have some text here')).toBe(8);
    });

    it('collapses repeated whitespace between words', () => {
      expect(WordCounterController.countWordsInText('Education   and\nExperience\tI have some text here')).toBe(8);
    });

    it('returns zero for blank text', () => {
      expect(WordCounterController.countWordsInText('   ')).toBe(0);
    });
  });
});
