import { Controller } from '@hotwired/stimulus';
import accessibleAutocomplete from 'accessible-autocomplete';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';
import './autocomplete.scss';

import api from '../../lib/api';

const SHOW_SUGGESTIONS_THRESHOLD = 3;

const suggestionHTML = (text, inputValue) => {
  const index = text.toLowerCase().indexOf(inputValue.toLowerCase());

  /* eslint-disable max-len */
  return `${text.substring(0, index)}<span class='accessible-autocomplete__suggestion-highlight'>${text.substring(index, index + inputValue.length)}</span>${text.substring(index + inputValue.length, text.length)}`;
  /* eslint-enable */
};

export default class extends Controller {
  connect() {
    const formInput = this.element.querySelector('input');
    const dataSource = api[this.element.dataset.source];
    const position = this.element.dataset.autocompletePosition;

    this.addContainers();

    if (formInput && dataSource) {
      let currentInputValue = formInput.value;
      formInput.parentNode.removeChild(formInput);

      accessibleAutocomplete({
        element: this.element.querySelector('.accessible-autocomplete'),
        id: formInput.id,
        name: formInput.name,
        defaultValue: currentInputValue,
        displayMenu: position,
        source: (query, populateResults) => {
          currentInputValue = query;
          return dataSource({ query, populateResults });
        },
        minLength: SHOW_SUGGESTIONS_THRESHOLD,
        templates: {
          suggestion: (value) => suggestionHTML(value, currentInputValue),
        },
        tNoResults: () => 'Loading...',
      });
    }
  }

  addContainers() {
    const html = '<div class="accessible-autocomplete__container"><div class="accessible-autocomplete govuk-body"></div></div>';
    this.element.insertAdjacentHTML('beforeend', html);
  }
}
