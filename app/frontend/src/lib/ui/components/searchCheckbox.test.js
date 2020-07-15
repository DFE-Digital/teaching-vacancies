import { init, substringExistsInString } from './searchCheckbox';

describe('search group of checkboxes', () => {

  beforeEach(() => {
    document.body.innerHTML = '<div class="accordion-content__group"><input type="text" class="search-input__input" /><div class="govuk-checkboxes__item"><input type="checkbox" value="abc" class="govuk-checkboxes__input" /></div><div class="govuk-checkboxes__item"><input type="checkbox" value="xyz" class="govuk-checkboxes__input" /></div></div>';
  });

  describe('module behaviour', () => {
    test('only shows elements that match user input', () => {
      init(document.getElementsByClassName('accordion-content__group')[0]);
      document.getElementsByClassName('search-input__input')[0].value = 'abc';
      const event = new Event('input');
      document.getElementsByClassName('search-input__input')[0].dispatchEvent(event);
      expect(document.getElementsByClassName('govuk-checkboxes__input')[0].parentElement.style.display).toBe('block');
      expect(document.getElementsByClassName('govuk-checkboxes__input')[1].parentElement.style.display).toBe('none');
    });
  });

  describe('module methods', () => {
    test('returns true if string exists in string irrespective of letter casing', () => {
      expect(substringExistsInString('abc', 'abc')).toBe(true);
      expect(substringExistsInString('abc', 'ab')).toBe(true);
      expect(substringExistsInString('abc', 'aB')).toBe(true);
      expect(substringExistsInString('abc', 'bd')).toBe(false);
    });
  });
});
