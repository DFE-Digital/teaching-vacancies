import '../../polyfill/closest.polyfill';

window.addEventListener('DOMContentLoaded', () => {
  Array.from(document.getElementsByClassName('moj-filter__tag')).map((removeButton) => addRemoveEvent(removeButton, () => removeButton.closest('form').submit()));

  if (document.getElementById('clear-filters')) {
    addClearAllEvent(document.getElementById('clear-filters'), () => document.getElementById('clear-filters').closest('form').submit());
  }
});

export const addRemoveEvent = (el, onClear) => {
  el.addEventListener('click', (e) => {
    e.preventDefault();
    filterGroup.clearFilter(filterGroup.getFilterGroup(el.dataset.group), el.dataset.key, onClear);
  });
};

export const addClearAllEvent = (el, onClear) => {
  el.addEventListener('click', (e) => {
    e.preventDefault();
    filterGroup.clearAllFilters(onClear);
  });
};

export const clearFilter = (group, key, onClear) => {
  filterGroup.unCheckCheckbox(filterGroup.findFilterCheckboxInGroup(group, key));
  onClear();
};

export const clearAllFilters = (onClear) => {
  filterGroup.getFilterGroups().map((groupEl) => filterGroup.getFilterCheckboxesInGroup(groupEl).map((checkbox) => filterGroup.unCheckCheckbox(checkbox)));
  onClear();
};

export const unCheckCheckbox = (checkbox) => { checkbox.checked = false; };

export const getFilterGroup = (groupName) => getFilterGroups().filter((group) => group.dataset.group === groupName)[0];

export const getFilterGroups = () => Array.from(document.getElementsByClassName('govuk-accordion__section-content'));

export const findFilterCheckboxInGroup = (groupEl, key) => getFilterCheckboxesInGroup(groupEl).filter((checkbox) => checkbox.value === key)[0];

export const getFilterCheckboxesInGroup = (groupEl) => Array.from(groupEl.getElementsByClassName('govuk-checkboxes__input'));

const filterGroup = {
  clearFilter,
  clearAllFilters,
  getFilterGroup,
  getFilterGroups,
  unCheckCheckbox,
  findFilterCheckboxInGroup,
  getFilterCheckboxesInGroup,
};

export default filterGroup;
