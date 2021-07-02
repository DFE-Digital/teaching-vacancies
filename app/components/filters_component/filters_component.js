import '../../frontend/src/lib/polyfill/closest.polyfill';
import '../../frontend/src/lib/polyfill/from.polyfill';
import 'classlist-polyfill';

export const CHECKBOX_CLASS_SELECTOR = 'govuk-checkboxes__input';
export const CHECKBOX_GROUP_CLASS_SELECTOR = 'filters-component__groups__group';
export const REMOVE_FILTER_CLASS_SELECTOR = 'filters-component__remove-tags__tag';
export const MOBILE_BREAKPOINT = 640;

window.addEventListener(
  'DOMContentLoaded',
  () => init(
    REMOVE_FILTER_CLASS_SELECTOR,
    'filters-component-clear-all',
    'filters-component-close-panel',
    'filters-component-show-mobile',
  ),
);

export const init = (removeButtonSelector, clearButtonId, closeButtonId, showFilterPanelId) => {
  Array.from(document.getElementsByClassName(removeButtonSelector)).forEach((removeButton) => filterGroup.addRemoveFilterEvent(removeButton));

  const clearButton = document.getElementById(clearButtonId);
  if (clearButton) {
    filterGroup.addRemoveAllFiltersEvent(clearButton);
  }

  if (document.getElementById(showFilterPanelId)) {
    document.getElementById(showFilterPanelId).addEventListener('click', (e) => {
      togglePanel(e.target);

      if (document.getElementsByClassName('filters-component--show-mobile').length) {
        document.getElementsByClassName('filters-component--show-mobile')[0].closest('form').removeAttribute('data-auto-submit');
      }
    });
  }

  if (document.documentElement.clientWidth <= MOBILE_BREAKPOINT) {
    setFiltersHiddenState(document.getElementById(showFilterPanelId), document.getElementsByClassName('filters-component')[0]);
  }

  if (document.getElementById(closeButtonId)) {
    document.getElementById(closeButtonId).addEventListener('click', () => {
      togglePanel(document.getElementById(showFilterPanelId));
    });

    document.addEventListener('keydown', (e) => {
      if (['Esc', 'Escape'].includes(e.key)) {
        togglePanel(document.getElementById(showFilterPanelId));
      }
    });
  }

  if (window.matchMedia) {
    const mediaQuery = `(max-width: ${MOBILE_BREAKPOINT}px)`;
    const mediaQueryList = window.matchMedia(mediaQuery);

    mediaQueryList.addEventListener('change', (e) => {
      if (e.matches) {
        document.getElementsByClassName('filters-component')[0].setAttribute('aria-hidden', 'true');
        document.getElementById(showFilterPanelId).setAttribute('aria-expanded', 'false');
      } else {
        document.getElementsByClassName('filters-component')[0].removeAttribute('aria-hidden', 'true');
      }
    });
  }
};

export const togglePanel = (actionEl) => Array.from(document.getElementsByClassName('filters-component')).map((element) => {
  element.classList.toggle('filters-component--show-mobile');

  return element.classList.contains('filters-component--show-mobile') ? setFiltersVisibleState(actionEl, element) : setFiltersHiddenState(actionEl, element);
});

export const setFiltersVisibleState = (actionEl, filtersEl) => {
  filtersEl.focus();
  filtersEl.setAttribute('aria-hidden', 'false');
  actionEl.setAttribute('aria-expanded', 'true');
};

export const setFiltersHiddenState = (actionEl, filtersEl) => {
  actionEl.focus();
  filtersEl.setAttribute('aria-hidden', 'true');
  actionEl.setAttribute('aria-expanded', 'false');
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
