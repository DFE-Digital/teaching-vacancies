import '../../frontend/src/lib/polyfill/closest.polyfill';
import '../../frontend/src/lib/polyfill/from.polyfill';
import 'classlist-polyfill';

export const CHECKBOX_CLASS_SELECTOR = 'govuk-checkboxes__input';
export const CHECKBOX_GROUP_CLASS_SELECTOR = 'filters-component__groups__group';
export const REMOVE_FILTER_CLASS_SELECTOR = 'filters-component__remove-tags__tag';
export const MOBILE_BREAKPOINT = 768;

window.addEventListener(
  'DOMContentLoaded',
  () => init(
    REMOVE_FILTER_CLASS_SELECTOR,
    'filters-component-clear-all',
  ),
);

export const init = (removeButtonSelector, clearButtonId) => {
  const clearFiltersEl = document.getElementById(clearButtonId);

  Array.from(document.getElementsByClassName(removeButtonSelector)).forEach((removeButton) => filterGroup.addRemoveFilterEvent(removeButton));

  if (clearFiltersEl) {
    filterGroup.addRemoveAllFiltersEvent(clearFiltersEl);
  }

  Array.from(document.getElementsByClassName('filters-component')).forEach((filtersEl) => {
    if (document.documentElement.clientWidth <= MOBILE_BREAKPOINT) {
      mobileFiltersBehaviour(filtersEl);
    } else {
      desktopFiltersBehaviour(filtersEl);
    }

    if (window.matchMedia) {
      const mediaQuery = `(max-width: ${MOBILE_BREAKPOINT}px)`;
      const mediaQueryList = window.matchMedia(mediaQuery);

      if (mediaQueryList.addEventListener) {
        mediaQueryList.addEventListener('change', (e) => {
          if (e.matches) {
            mobileFiltersBehaviour(filtersEl);
          } else {
            desktopFiltersBehaviour(filtersEl);
          }
        });
      }
    }
  });
};

const mobileFiltersBehaviour = (filtersEl) => {
  filtersEl.closest('form').removeAttribute('data-controller');
  filtersEl.setAttribute('tabindex', '-1');
};

const desktopFiltersBehaviour = (filtersEl) => {
  filtersEl.closest('form').setAttribute('data-controller', 'form');
  filtersEl.removeAttribute('tabindex');
};

export const addRemoveFilterEvent = (el, onClear) => {
  el.addEventListener('click', () => {
    filterGroup.removeFilterHandler(filterGroup.getFilterGroup(el.dataset.group), el.dataset.key, onClear);
  });
};

export const removeFilterHandler = (group, key) => {
  filterGroup.unCheckCheckbox(filterGroup.findFilterCheckboxInGroup(group, key));
};

export const addRemoveAllFiltersEvent = (el, onClear) => {
  el.addEventListener('click', () => {
    filterGroup.removeAllFiltersHandler(onClear);
  });
};

export const removeAllFiltersHandler = () => {
  filterGroup.getFilterGroups().forEach((groupEl) => filterGroup.getFilterCheckboxesInGroup(groupEl).forEach((checkbox) => filterGroup.unCheckCheckbox(checkbox)));
};

export const unCheckCheckbox = (checkbox) => { checkbox.checked = false; };

export const getFilterGroup = (groupName) => getFilterGroups().filter((group) => group.dataset.group === groupName)[0];

export const getFilterGroups = () => Array.from(document.getElementsByClassName(CHECKBOX_GROUP_CLASS_SELECTOR));

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
  addRemoveFilterEvent,
  addRemoveAllFiltersEvent,
};

export default filterGroup;
