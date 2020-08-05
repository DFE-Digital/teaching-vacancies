import '../../polyfill/closest.polyfill';

export const CHECKBOX_CLASS_SELECTOR = 'govuk-checkboxes__input';

window.addEventListener('DOMContentLoaded', () => {
  Array.from(document.getElementsByClassName('moj-filter__tag')).map((removeButton) => addRemoveFilterEvent(removeButton, () => getForm(removeButton).submit()));

  const clearButton = document.getElementById('clear-filters');
  if (clearButton) {
    addRemoveAllFiltersEvent(clearButton, () => getForm(clearButton).submit());
  }
});

export const getForm = (el) => el.closest('form');

export const addRemoveFilterEvent = (el, onClear) => {
  el.addEventListener('click', (e) => {
    e.preventDefault();
    filterGroup.removeFilterHandler(filterGroup.getFilterGroup(el.dataset.group), el.dataset.key, onClear);
  });
};

export const removeFilterHandler = (group, key, onClear) => {
  filterGroup.unCheckCheckbox(filterGroup.findFilterCheckboxInGroup(group, key));
  onClear();
};

export const addRemoveAllFiltersEvent = (el, onClear) => {
  el.addEventListener('click', (e) => {
    e.preventDefault();
    filterGroup.removeAllFiltersHandler(onClear);
  });
};

export const removeAllFiltersHandler = (onClear) => {
  filterGroup.getFilterGroups().map((groupEl) => filterGroup.getFilterCheckboxesInGroup(groupEl).map((checkbox) => filterGroup.unCheckCheckbox(checkbox)));
  onClear();
};

export const unCheckCheckbox = (checkbox) => { checkbox.checked = false; };

export const getFilterGroup = (groupName) => getFilterGroups().filter((group) => group.dataset.group === groupName)[0];

export const getFilterGroups = () => Array.from(document.getElementsByClassName('filter-group__checkboxes'));

export const findFilterCheckboxInGroup = (groupEl, key) => getFilterCheckboxesInGroup(groupEl).filter((checkbox) => checkbox.value === key)[0];

export const getFilterCheckboxesInGroup = (groupEl) => Array.from(groupEl.getElementsByClassName(CHECKBOX_CLASS_SELECTOR));

const filterGroup = {
  removeFilterHandler,
  removeAllFiltersHandler,
  getFilterGroup,
  getFilterGroups,
  unCheckCheckbox,
  findFilterCheckboxInGroup,
  getFilterCheckboxesInGroup,
};

export default filterGroup;
