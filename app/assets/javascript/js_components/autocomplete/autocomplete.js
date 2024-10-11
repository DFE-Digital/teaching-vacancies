import { Controller } from '@hotwired/stimulus';
import accessibleAutocomplete from 'accessible-autocomplete';

import { debounce } from 'lodash';
import api from './api';

const SHOW_SUGGESTIONS_THRESHOLD = 3;
const SUGGESTIONS_CLASSNAME = 'autocomplete__suggestions';
const suggestionsContainerHTML = `<div class="${SUGGESTIONS_CLASSNAME} govuk-body"></div>`;

const suggestionHTML = (text, inputValue) => {
  const index = text.toLowerCase().indexOf(inputValue.toLowerCase());

  /* eslint-disable max-len */
  return `${text.substring(0, index)}<span class='${SUGGESTIONS_CLASSNAME}--highlight'>${text.substring(index, index + inputValue.length)}</span>${text.substring(index + inputValue.length, text.length)}`;
  /* eslint-enable */
};

export default class extends Controller {
  #debouncing;

  #currentSearchValue;

  connect() {
    const formInput = this.element.querySelector('input');
    const dataSource = api[this.element.dataset.source];
    const position = this.element.dataset.autocompletePosition;
    const inputParent = formInput.parentNode;
    const debounceMsValue = this.element.dataset.debouncems;

    inputParent.insertAdjacentHTML('beforeend', suggestionsContainerHTML);

    this.#debouncing = false;

    if (formInput && dataSource) {
      let currentInputValue = formInput.value;
      inputParent.removeChild(formInput);

      const handleQuery = async (query, populateResults) => {
        currentInputValue = query;
        return dataSource({ query, populateResults });
      };

      // Debouncing code inspired by https://github.com/alphagov/accessible-autocomplete/pull/611

      const handleQueryDebounced = debounce(async (query, populateResults) => {
        await handleQuery(query, populateResults);
      }, debounceMsValue);

      this.debouncedSource = async (query, populateResults) => {
        this.#debouncing = true;
        this.#currentSearchValue = query;
        try {
          await handleQueryDebounced(query, populateResults);
        } finally {
          this.#debouncing = false;
        }
      };

      accessibleAutocomplete({
        element: inputParent.getElementsByClassName(SUGGESTIONS_CLASSNAME).item(0),
        id: formInput.id,
        name: formInput.name,
        defaultValue: currentInputValue,
        displayMenu: position,
        source: this.debouncedSource.bind(this),
        tNoResults: () => (this.#debouncing ? this.#currentSearchValue : 'No Results Found'),
        minLength: SHOW_SUGGESTIONS_THRESHOLD,
        templates: {
          suggestion: (value) => suggestionHTML(value, currentInputValue),
        },
      });
    }
  }
}
