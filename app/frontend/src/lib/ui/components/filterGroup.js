import '../../polyfill/closest.polyfill';

window.addEventListener('DOMContentLoaded', () => {
  Array.from(document.getElementsByClassName('moj-filter__tag')).map((removeButton) => addRemoveEvent(removeButton, () => removeButton.closest('form').submit()));
});

export const addRemoveEvent = (button, onRemove) => {
  button.addEventListener('click', (e) => {
    e.preventDefault();
    filterGroup.clearFilter(filterGroup.getFilterGroup(button.dataset.group), button.dataset.key, onRemove);
  });
};

export const clearFilter = (group, key, onRemove) => {
  filterGroup.findFilterCheckbox(group, key).checked = false;
  onRemove();
};

export const getFilterGroup = (groupName) => Array.from(document.getElementsByClassName('govuk-accordion__section-content')).filter((group) => group.dataset.group === groupName)[0];

export const findFilterCheckbox = (groupEl, key) => Array.from(groupEl.getElementsByClassName('govuk-checkboxes__input')).filter((checkbox) => checkbox.value === key)[0];

const filterGroup = {
  clearFilter,
  getFilterGroup,
  findFilterCheckbox,
};

export default filterGroup;
