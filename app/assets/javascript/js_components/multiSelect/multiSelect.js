import { Controller } from '@hotwired/stimulus';

class MultiSelectController extends Controller {
  connect() {
    const idPrefix = this.element.dataset.idPrefix || '';
    const $container = this.element.querySelector(`#${idPrefix}select-all`);
    const $checkboxes = Array.from(this.element.querySelectorAll('tbody input.govuk-checkboxes__input'));

    if (!$container || !$checkboxes.length) return;

    this.$checkboxes = $checkboxes;
    this.$toggle = MultiSelectController.buildToggle(`${idPrefix}checkboxes-all`);
    this.$toggleInput = this.$toggle.querySelector('input');

    $container.append(this.$toggle);

    this.$toggleInput.addEventListener('click', this.onToggleClick.bind(this));
    this.$checkboxes.forEach(($input) => $input.addEventListener('click', this.onCheckboxClick.bind(this)));
  }

  static buildToggle(id) {
    const $toggle = document.createElement('div');
    const $input = document.createElement('input');
    const $label = document.createElement('label');
    const $span = document.createElement('span');

    $toggle.classList.add('govuk-checkboxes__item', 'govuk-checkboxes--small', 'multi-select__checkbox');

    $input.id = id;
    $input.type = 'checkbox';
    $input.classList.add('govuk-checkboxes__input');

    $label.setAttribute('for', id);
    $label.classList.add('govuk-label', 'govuk-checkboxes__label', 'multi-select__toggle-label');

    $span.classList.add('govuk-visually-hidden');
    $span.textContent = 'Select all';

    $label.append($span);
    $toggle.append($input, $label);

    return $toggle;
  }

  onToggleClick() {
    const { checked } = this.$toggleInput;
    this.$checkboxes.forEach(($input) => { $input.checked = checked; });
  }

  onCheckboxClick() {
    const allChecked = this.$checkboxes.every(($input) => $input.checked);
    this.$toggleInput.checked = allChecked;
  }
}

export default MultiSelectController;
