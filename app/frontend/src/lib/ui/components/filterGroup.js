import '../../polyfill/closest.polyfill';
import 'classlist-polyfill';

export const CHECKBOX_CLASS_SELECTOR = 'govuk-checkboxes__input';

window.addEventListener('DOMContentLoaded', () => init('filter-group__container', 'moj-filter__tag', 'clear-filters-button', 'close-all-groups', 'mobile-filters-button'));

export const init = (groupContainerSelector, removeButtonSelector, clearButtonSelector, closeButtonSelector, mobileFiltersButtonSelector) => {
  Array.from(document.getElementsByClassName(removeButtonSelector)).map((removeButton) => filterGroup.addRemoveFilterEvent(removeButton, () => getSubmitButton(removeButton).click()));

  const clearButton = document.getElementById(clearButtonSelector);
  if (clearButton) {
    filterGroup.addRemoveAllFiltersEvent(clearButton, () => getSubmitButton(clearButton).click());
  }

  addFilterChangeEvent(document.getElementsByClassName(groupContainerSelector));

  if (document.getElementById(closeButtonSelector)) {
    if (document.getElementById(closeButtonSelector).innerText === 'Close all' && document.getElementsByClassName('govuk-accordion__section--expanded').length === 0) {
      document.getElementById(closeButtonSelector).innerText = 'Open all';
    } else if (document.getElementById(closeButtonSelector).innerText === 'Open all' && document.getElementsByClassName('govuk-accordion__section--expanded').length > 0) {
      document.getElementById(closeButtonSelector).innerText = 'Close all';
    }
    document.getElementById(closeButtonSelector).addEventListener('click', closeAllSectionsHandler);
  }

  const toggleButton = document.getElementById('toggle-filters-sidebar');

  if (toggleButton) {
    toggleButton.addEventListener('click', () => {
      document.getElementsByClassName('moj-filter-sidebar')[0].classList.toggle('moj-filter-sidebar__hidden');
      document.getElementsByClassName('moj-filter-layout__content')[0].classList.toggle('govuk-grid-column-three-quarters');

      if (document.getElementsByClassName('moj-filter-sidebar')[0].classList.contains('moj-filter-sidebar__hidden')) {
        toggleButton.innerHTML = 'Show filters';
      } else {
        toggleButton.innerHTML = 'Hide filters';
      }
    });
  }

  const mobileFiltersButton = document.getElementById(mobileFiltersButtonSelector);

  if (mobileFiltersButton) {
    mobileFiltersButton.addEventListener('click', () => {
      Array.from(document.getElementsByClassName('filters--hide-mobile')).map((element) => showMobileFilters(element));
    });
  }
};

export const showMobileFilters = (element) => {
  element.classList.toggle('filters--show-mobile');
};

export const closeAllSectionsHandler = (e) => {
  e.preventDefault();
  if (e.target.innerText === 'Close all') {
    Array.from(document.getElementsByClassName('govuk-accordion__section')).map((section) => section.classList.remove('govuk-accordion__section--expanded'));
    e.target.innerText = 'Open all';
  } else if (e.target.innerText === 'Open all') {
    Array.from(document.getElementsByClassName('govuk-accordion__section')).map((section) => section.classList.add('govuk-accordion__section--expanded'));
    e.target.innerText = 'Close all';
  }
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
  addRemoveFilterEvent,
  addRemoveAllFiltersEvent,
  filterChangeHandler,
};

export default filterGroup;
