/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';
import SearchableCollectionComponent from './searchable_collection';

let application;
let controller;

const initialiseStimulus = () => {
  application = Application.start();
  application.register('searchable-collection', SearchableCollectionComponent);
};

beforeAll(() => {
  document.body.innerHTML = `<div class="searchable-collection-component" data-controller="searchable-collection">
  <input type="text" data-searchable-collection-target="input" data-action="input->searchable-collection#input" />
  <div class="govuk-visually-hidden collection-match" aria-live="assertive" role="status"></div>
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

  initialiseStimulus();
});

describe('searching group of checkboxes', () => {
  beforeEach(() => {
    controller = application.getControllerForElementAndIdentifier(document.querySelector('[data-controller="searchable-collection"]'), 'searchable-collection');
  });

  it('shows elements that match user input', () => {
    controller.inputTarget.value = 'abc';
    controller.inputTarget.dispatchEvent(new Event('input'));

    expect(document.getElementsByClassName('govuk-checkboxes__input')[0].parentElement.style.display).toBe('block');
    expect(document.getElementsByClassName('govuk-radios__input')[0].parentElement.style.display).toBe('none');
    expect(document.getElementsByClassName('govuk-checkboxes__input')[1].parentElement.style.display).toBe('block');

    expect(document.querySelector('.collection-match').innerHTML).toBe('2 subjects match abc');
  });

  it('returns true if string exists in string irrespective of letter casing', () => {
    expect(SearchableCollectionComponent.substringExistsInString('abc', 'abc')).toBe(true);
    expect(SearchableCollectionComponent.substringExistsInString('abc', 'ab')).toBe(true);
    expect(SearchableCollectionComponent.substringExistsInString('abc', 'aB')).toBe(true);
    expect(SearchableCollectionComponent.substringExistsInString('abc', 'bd')).toBe(false);
  });
});
