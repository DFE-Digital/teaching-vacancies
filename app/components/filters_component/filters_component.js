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
    'filters-component-close-panel',
    'filters-component-show-mobile',
  ),
);

export const init = (removeButtonSelector, clearButtonId, closeButtonId, showFilterPanelId) => {
  const clearFiltersEl = document.getElementById(clearButtonId);
  const closeFilterPanelEl = document.getElementById(closeButtonId);
  const showFilterPanelEl = document.getElementById(showFilterPanelId);

  Array.from(document.getElementsByClassName(removeButtonSelector)).forEach((removeButton) => filterGroup.addRemoveFilterEvent(removeButton));

  if (clearFiltersEl) {
    filterGroup.addRemoveAllFiltersEvent(clearFiltersEl);
  }

  if (showFilterPanelEl) {
    showFilterPanelEl.addEventListener('click', (e) => {
      togglePanel(e.target);
    });
  }

  if (closeFilterPanelEl) {
    closeFilterPanelEl.addEventListener('click', () => {
      togglePanel(showFilterPanelEl);
    });

    document.getElementsByClassName('filters-component')[0].addEventListener('keydown', (e) => {
      if (['Esc', 'Escape'].includes(e.key)) {
        document.getElementsByClassName('filters-component')[0].classList.remove('filters-component--show-mobile');
        setFiltersHiddenState(showFilterPanelEl, document.getElementsByClassName('filters-component')[0], true);
      }
    });
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

            if (filtersEl.classList.contains('filters-component--show-mobile')) {
              setFiltersVisibleState(showFilterPanelEl, filtersEl);
            }
          } else {
            desktopFiltersBehaviour(filtersEl);
            setFiltersHiddenState(filtersEl, showFilterPanelEl);
          }
        });
      }
    }
  });
};

const mobileFiltersBehaviour = (filtersEl) => {
  filtersEl.closest('form').removeAttribute('data-auto-submit');
  filtersEl.setAttribute('tabindex', '-1');
};

const desktopFiltersBehaviour = (filtersEl) => {
  filtersEl.closest('form').setAttribute('data-auto-submit', 'true');
  filtersEl.removeAttribute('tabindex');
};

export const togglePanel = (actionEl) => Array.from(document.getElementsByClassName('filters-component')).forEach((element) => {
  element.classList.toggle('filters-component--show-mobile') ? setFiltersVisibleState(actionEl, element) : setFiltersHiddenState(actionEl, element, true);
});

export const setFiltersVisibleState = (actionEl, filtersEl) => {
  filtersEl.focus();
  filtersEl.setAttribute('aria-hidden', 'false');
  actionEl.setAttribute('aria-expanded', 'true');
};

export const setFiltersHiddenState = (actionEl, filtersEl, shouldFocus) => {
  if (shouldFocus) {
    actionEl.focus();
  }

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
