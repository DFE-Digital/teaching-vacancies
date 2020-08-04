import '../../polyfill/closest.polyfill';

window.addEventListener('DOMContentLoaded', () => {
  Array.from(document.getElementsByClassName('moj-filter__tag')).map((removeButton) => addRemoveEvent(removeButton, () => removeButton.closest('form').submit()));
});

export const addRemoveEvent = (button, onRemove) => {
  button.addEventListener('click', (e) => {
    e.preventDefault();
    removeFilters.removeFilter(removeFilters.getFilterGroup(button.dataset.group), button.dataset.key, onRemove);
  });
};

export const removeFilter = (group, key, onRemove) => {
  removeFilters.findFilterCheckbox(group, key).checked = false;
  onRemove();
};

export const getFilterGroup = (groupName) => Array.from(document.getElementsByClassName('govuk-accordion__section-content')).filter((group) => group.dataset.group === groupName)[0];

export const findFilterCheckbox = (groupEl, key) => Array.from(groupEl.getElementsByClassName('govuk-checkboxes__input')).filter((checkbox) => checkbox.value === key)[0];

const removeFilters = {
  removeFilter,
  getFilterGroup,
  findFilterCheckbox,
};

export default removeFilters;
