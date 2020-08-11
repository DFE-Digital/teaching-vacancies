import { init, substringExistsInString } from './searchCheckbox';

describe('searchCheckbox', () => {
  beforeEach(() => {
    document.body.innerHTML = `<div class="accordion-content__group">
<input type="text" class="search-input__input" />
<div class="govuk-checkboxes__item">
<input type="checkbox" value="abc" class="govuk-checkboxes__input" />
</div>
<div class="govuk-checkboxes__item">
<input type="checkbox" value="xyz" class="govuk-checkboxes__input" />
</div>
<div class="govuk-checkboxes__item">
<input type="checkbox" value="mno" class="govuk-checkboxes__input" /><label>abc</label>
</div>
</div>`;
  });

  describe('searching group of checkboxes', () => {
    test('shows elements that match user input', () => {
      init(document.getElementsByClassName('accordion-content__group')[0]);
      document.getElementsByClassName('search-input__input')[0].value = 'abc';
      document.getElementsByClassName('search-input__input')[0].dispatchEvent(new Event('input'));

      expect(document.getElementsByClassName('govuk-checkboxes__input')[0].parentElement.style.display).toBe('block');
      expect(document.getElementsByClassName('govuk-checkboxes__input')[1].parentElement.style.display).toBe('none');
      expect(document.getElementsByClassName('govuk-checkboxes__input')[2].parentElement.style.display).toBe('block');
    });
  });

  describe('substringExistsInString', () => {
    test('returns true if string exists in string irrespective of letter casing', () => {
      expect(substringExistsInString('abc', 'abc')).toBe(true);
      expect(substringExistsInString('abc', 'ab')).toBe(true);
      expect(substringExistsInString('abc', 'aB')).toBe(true);
      expect(substringExistsInString('abc', 'bd')).toBe(false);
    });
  });
});
