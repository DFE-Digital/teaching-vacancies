/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';

import FiltersController from './filters_component';

const initialiseStimulus = () => {
  const application = Application.start();
  application.register('filters', FiltersController);
};

describe('filters view component', () => {
  beforeAll(() => {
    initialiseStimulus();

    document.body.innerHTML = `<form data-controller="form"><div class="filters-component" data-controller="filters">
    <ul>
    <li><button data-action="click->filters#remove" data-group="group_1" data-key="option_1">option1</button></li>
    <li><button data-action="click->filters#remove" data-group="group_1" data-key="option_2">option2</button></li>
    </ul>
    <ul>
    <li><button data-action="click->filters#remove" data-group="group_2" data-key="option_1">option1</button></li>
    <li><button data-action="click->filters#remove" data-group="group_2" data-key="option_2">option2</button></li>
    </ul>
    <div data-filters-target="group" data-group="group_1">
      <input class="govuk-checkboxes__input" type="checkbox" value="option_1" />
      <input class="govuk-checkboxes__input" type="checkbox" value="option_2" />
    </div>
    <div data-filters-target="group" data-group="group_2">
      <input class="govuk-checkboxes__input" type="checkbox" value="option_1" />
      <input class="govuk-checkboxes__input" type="checkbox" value="option_2" />
    </div>
    </div>
    </form>`;
  });

  describe('remove button for specific filter control', () => {
    it('should uncheck corresponding filter', () => {
      const [form] = document.getElementsByTagName('form');

      form.addEventListener('submit', (e) => {
        e.preventDefault();
      });

      const filterCheckbox1 = document.querySelector('[data-group="group_1"] input[value="option_1"]');
      const filterCheckbox2 = document.querySelector('[data-group="group_2"] input[value="option_2"]');

      filterCheckbox1.checked = true;
      filterCheckbox2.checked = true;

      const [removeGroup1, removeGroup2] = Array.from(document.getElementsByTagName('ul'));

      removeGroup1.querySelector('button[data-key="option_1"]').click();
      expect(filterCheckbox1.checked).toBe(false);

      removeGroup2.querySelector('button[data-key="option_2"]').click();
      expect(filterCheckbox2.checked).toBe(false);
    });
  });
});
