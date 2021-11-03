import accessibleAutocomplete from 'accessible-autocomplete';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';
import { Controller } from '@hotwired/stimulus';
import './autocomplete.scss';
import api from '../../lib/api';

const SHOW_SUGGESTIONS_THRESHOLD = 3;

export const highlightRefinement = (text, refinement) => {
  const index = text.toLowerCase().indexOf(refinement.toLowerCase());

  /* eslint-disable max-len */
  return `${text.substring(0, index)}<span class='accessible-autocomplete__suggestion-highlight'>${text.substring(index, index + refinement.length)}</span>${text.substring(index + refinement.length, text.length)}`;
  /* eslint-enable */
};

export default class extends Controller {
  connect() {
    let currentInputValue = this.element.value;
    this.element.parentNode.removeChild(this.element);

    accessibleAutocomplete({
      element: document.querySelector('#accessible-autocomplete'),
      id: this.element.id,
      name: this.element.name,
      defaultValue: currentInputValue,
      source: (query, populateResults) => {
        currentInputValue = query;
        return api[this.element.dataset.autocompleteSource]({ query, populateResults });
      },
      minLength: SHOW_SUGGESTIONS_THRESHOLD,
      templates: {
        suggestion: (value) => highlightRefinement(value, currentInputValue),
      },
      tNoResults: () => 'Loading...',
    });
  }
}
