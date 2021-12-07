import { Controller } from '@hotwired/stimulus';
// import './panel.scss';

import accessibleAutocomplete from 'accessible-autocomplete';
import 'accessible-autocomplete/dist/accessible-autocomplete.min.css';

const selectId = 'vacancy-selector';

export default class extends Controller {
  static targets = [
    'fieldset',
    'heading',
    'legend',
    'radioItem'
  ];

  connect() {
    // this.radioBlockTarget.hidden = true;
    this.legendTarget.hidden = true;

    const label = document.createElement('label');
    label.for = selectId;
    label.innerText = this.legendTarget.innerText;

    this.fieldsetTarget.insertAdjacentElement('afterbegin', label);

    const select = document.createElement('select');
    select.id = selectId;
    select.name = this.radioItemTarget.name;

    label.insertAdjacentElement('afterend', select);

    let choiceData = {};
    this.radioItemTargets.forEach((radio) => {
      const value = radio.getElementsByTagName('input').item(0).value;
      const jobTitleElement = radio.getElementsByClassName('job-title').item(0);

      choiceData[value] = {
        'job-title': jobTitleElement,
        'job-ends-on': radio.getElementsByClassName('job-ends-on').item(0),
      };

      const endsOn = radio.getElementsByClassName('job-title').item(0);
      if (endsOn) {
        choiceData[value]['job-organisation-name'] = endsOn;
      }

      const option = document.createElement('option');
      option.value = value;
      option.innerText = jobTitle.innerText;

      select.insertAdjacentElement('beforeend', option);
    });

    accessibleAutocomplete.enhanceSelectElement({
      selectElement: select,
      templates: {
        suggestion: (value) => {
          const suggestionLabel = document.createElement('label');

          suggestionLabel.insertAdjacentElement('beforeend', choiceData[value]['job-title']);
          suggestionLabel.insertAdjacentElement('beforeend', choiceData[value]['job-ends-on']);
          suggestionLabel.insertAdjacentElement('beforeend', choiceData[value]['job-organisation-name']);

          return suggestionLabel.outerHTML;
        }
      }
    });
  }
}
