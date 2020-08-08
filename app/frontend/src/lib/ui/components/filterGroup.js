import '../../polyfill/closest.polyfill';

export const CHECKBOX_CLASS_SELECTOR = 'govuk-checkboxes__input';

window.addEventListener('DOMContentLoaded', () => {
  Array.from(document.getElementsByClassName('moj-filter__tag')).map((removeButton) => addRemoveFilterEvent(removeButton, () => getSubmitButton(removeButton).click()));

  const clearButton = document.getElementById('clear-filters-button');
  if (clearButton) {
    addRemoveAllFiltersEvent(clearButton, () => getSubmitButton(clearButton).click());
  }

  addFilterChangeEvent(document.getElementsByClassName('filter-group__container'));

  document.getElementById('close-all-accordion').addEventListener('click', closeAllSectionsHandler);
});

export const closeAllSectionsHandler = (e) => {
  e.preventDefault();
  Array.from(document.getElementsByClassName('govuk-accordion__section')).map((section) => section.classList.remove('govuk-accordion__section--expanded'));
};

export const getSubmitButton = (el) => Array.from(el.closest('form').getElementsByTagName('input')).filter((input) => input.type === 'submit')[0];

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

export const addFilterChangeEvent = (groups) => {
  Array.from(groups).map((group) => group.addEventListener('click', (e) => {
    filterGroup.filterChangeHandler(e.target);
  }));
};

export const filterChangeHandler = (el) => {
  if (el.className === CHECKBOX_CLASS_SELECTOR) {
    getSubmitButton(el).click();
  }
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
  addFilterChangeEvent,
  filterChangeHandler,
};

export default filterGroup;
