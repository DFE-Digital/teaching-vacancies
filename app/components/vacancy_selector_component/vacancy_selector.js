import { Controller } from '@hotwired/stimulus';

import accessibleAutocomplete from 'accessible-autocomplete';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';

export default class extends Controller {
  static targets = [
    'fieldset',
    'legend',
    'radioBlock',
    'radioItem'
  ];

  static selectorID = 'vacancy-selector';

  #choiceData;

  connect() {
    if (this.radioItemTargets.length <= 20) {
      return;
    }

    this.#hideExistingDOM();
    this.#addLabelToHeading();
    const hiddenField = this.#insertHiddenField();
    const autocompleteSuggestions = this.#insertAutocompleteSuggestions();

    this.#initializeAutocomplete(autocompleteSuggestions, hiddenField);
  }

  #hideExistingDOM() { this.radioBlockTarget.hidden = true; }

  #addLabelToHeading() {
    const label = document.createElement('label');
    label.className = 'govuk-fieldset__heading';
    label.htmlFor = this.constructor.selectorID;
    label.innerText = this.legendTarget.innerText;

    this.legendTarget.outerHTML = label.outerHTML;
  }

  #insertHiddenField() {
    const hiddenField = document.createElement('input');
    hiddenField.type = 'hidden';
    hiddenField.name = this.radioItemTarget.getElementsByTagName('input').item(0).name;
    this.fieldsetTarget.insertAdjacentElement('beforeend', hiddenField);

    return hiddenField;
  }

  #insertAutocompleteSuggestions() {
    const autocompleteSuggestions = document.createElement('div');
    autocompleteSuggestions.className = 'autocomplete__suggestions govuk-body govuk-!-margin-bottom-0';

    this.fieldsetTarget.insertAdjacentElement('afterbegin', autocompleteSuggestions);

    return autocompleteSuggestions;
  }

  #buildChoiceData() {
    if (!this.#choiceData) {
      this.#choiceData = this.radioItemTargets.map((radio) => {
        return {
          'id': radio.getElementsByTagName('input').item(0).value,
          'job-title': radio.getElementsByClassName('job-title').item(0),
          'job-ends-on': radio.getElementsByClassName('job-ends-on').item(0),
          'job-organisation-name': radio.getElementsByClassName('job-organisation-name').item(0)
        };
      });
    }

    return this.#choiceData;
  }

  #initializeAutocomplete(autocompleteSuggestions, hiddenField) {
    accessibleAutocomplete({
      element: autocompleteSuggestions,
      id: this.constructor.selectorID,
      source: this.#onSearch(this.#buildChoiceData(), hiddenField),
      templates: {
        inputValue: this.#inputValueTemplate,
        suggestion: this.#suggestionTemplate,
      },
      onConfirm: (choice) => {
        if (choice) {
          hiddenField.value = choice.id;
        }
      }
    });
  }

  #inputValueTemplate(choice) {
    if (choice) {
      return choice['job-title'].innerText;
    }
  }

  #onSearch(choiceData, hiddenField) {
    return (query, callback) => {
      const results = choiceData.filter((c) =>
        -1 !== c['job-title'].innerText
          .toLowerCase()
          .indexOf(query.toLowerCase())
      );
      callback(results);
      hiddenField.value = null;
    };
  }

  #suggestionTemplate(choice) {
    if (choice) {
      const label = document.createElement('label');
      label.className = 'govuk-label';

      label.insertAdjacentElement('beforeend', choice['job-title']);
      label.insertAdjacentElement('beforeend', choice['job-ends-on']);

      if (choice['job-organisation-name']) {
        label.insertAdjacentElement('beforeend', choice['job-organisation-name']);
      }

      return label.outerHTML;
    }
  }
}
