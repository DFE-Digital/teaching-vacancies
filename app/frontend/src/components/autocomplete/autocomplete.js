import { Controller } from '@hotwired/stimulus';
import accessibleAutocomplete from 'accessible-autocomplete';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';
import './autocomplete.scss';

import api from '../../lib/api';

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
  connect() {
    const formInput = this.element.querySelector('input');
    const dataSource = api[this.element.dataset.source];
    const position = this.element.dataset.autocompletePosition;

    this.element.insertAdjacentHTML('beforeend', suggestionsContainerHTML);

    if (formInput && dataSource) {
      let currentInputValue = formInput.value;
      formInput.parentNode.removeChild(formInput);

      accessibleAutocomplete({
        element: this.element.getElementsByClassName(SUGGESTIONS_CLASSNAME).item(0),
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
      });
    }
  }
}
