/**
 * @jest-environment jsdom
 */

import { init, substringExistsInString, searchableClassNames } from './searchable_collection_component';

describe('searchCheckbox', () => {
  beforeEach(() => {
    document.body.innerHTML = `<div class="accordion-content__group">
<input type="text" class="searchable-collection-component__search-input" />
<div class="govuk-visually-hidden collection-match" aria-live="polite" role="status"></div>
<div class="govuk-checkboxes__item">
<input type="checkbox" value="abc" class="govuk-checkboxes__input" />
</div>
<div class="govuk-radiobuttons__item">
<input type="radio" value="xyz" class="govuk-radios__input" />
</div>
<div class="govuk-checkboxes__item">
<input type="checkbox" value="mno" class="govuk-checkboxes__input" /><label>abc</label>
</div>
</div>`;
  });

  describe('searching group of checkboxes', () => {
    test('shows elements that match user input', () => {
      init(document.getElementsByClassName('accordion-content__group')[0], searchableClassNames);
      document.getElementsByClassName('searchable-collection-component__search-input')[0].value = 'abc';
      document.getElementsByClassName('searchable-collection-component__search-input')[0].dispatchEvent(new Event('keyup'));

      expect(document.getElementsByClassName('govuk-checkboxes__input')[0].parentElement.style.display).toBe('block');
      expect(document.getElementsByClassName('govuk-radios__input')[0].parentElement.style.display).toBe('none');
      expect(document.getElementsByClassName('govuk-checkboxes__input')[1].parentElement.style.display).toBe('block');

      expect(document.querySelector('.collection-match').innerHTML).toBe('2 subjects match abc');
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
