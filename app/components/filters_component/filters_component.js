import '../../frontend/src/lib/polyfill/closest.polyfill';
import '../../frontend/src/lib/polyfill/from.polyfill';
import logger from '../../frontend/src/lib/logging';
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
  Array.from(document.getElementsByClassName(removeButtonSelector)).forEach((removeButton) => filterGroup.addRemoveFilterEvent(removeButton));

  const clearButton = document.getElementById(clearButtonId);
  if (clearButton) {
    filterGroup.addRemoveAllFiltersEvent(clearButton);
  }

  if (document.getElementById(showFilterPanelId)) {
    document.getElementById(showFilterPanelId).addEventListener('click', (e) => {
      togglePanel(e.target);

      if (document.getElementsByClassName('filters-component--show-mobile').length) {
        removeAutoSubmit();
      }
    });
  }

  if (document.documentElement.clientWidth <= MOBILE_BREAKPOINT) {
    setFiltersHiddenState(document.getElementById(showFilterPanelId), document.getElementsByClassName('filters-component')[0], false);
  } else {
    filtersUnfocusble();
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

  if (window.matchMedia && document.getElementsByClassName('filters-component').length) {
    const mediaQuery = `(max-width: ${MOBILE_BREAKPOINT}px)`;
    const mediaQueryList = window.matchMedia(mediaQuery);

    if (mediaQueryList.addEventListener) {
      mediaQueryList.addEventListener('change', (e) => {
        if (e.matches) {
          removeAutoSubmit();
          filtersFocusble();
          document.getElementsByClassName('filters-component')[0].setAttribute('aria-hidden', 'true');
          document.getElementById(showFilterPanelId).setAttribute('aria-expanded', 'false');
        } else {
          addAutoSubmit();
          filtersUnfocusble();
          document.getElementsByClassName('filters-component')[0].removeAttribute('aria-hidden');
        }
      });
    }
  }
};

export const togglePanel = (actionEl) => Array.from(document.getElementsByClassName('filters-component')).forEach((element) => {
  element.classList.toggle('filters-component--show-mobile') ? setFiltersVisibleState(actionEl, element) : setFiltersHiddenState(actionEl, element);
});

export const filtersFocusble = () => {
  document.getElementsByClassName('filters-component')[0].setAttribute('tabindex', '-1');
};

export const filtersUnfocusble = () => {
  document.getElementsByClassName('filters-component')[0].removeAttribute('tabindex');
};

export const addAutoSubmit = () => {
  document.getElementsByClassName('filters-component')[0].closest('form').setAttribute('data-auto-submit', 'true');
};

export const removeAutoSubmit = () => {
  document.getElementsByClassName('filters-component')[0].closest('form').removeAttribute('data-auto-submit');
};

export const setFiltersVisibleState = (actionEl, filtersEl) => {
  filtersEl.focus();
  filtersEl.setAttribute('aria-hidden', 'false');
  actionEl.setAttribute('aria-expanded', 'true');
};

export const setFiltersHiddenState = (actionEl, filtersEl, shouldFocus = true) => {
  if (shouldFocus) {
    actionEl.focus();
  }

  try {
    filtersEl.setAttribute('aria-hidden', 'true');
    actionEl.setAttribute('aria-expanded', 'false');
  } catch (e) {
    logger.log('setFiltersHiddenState', e);
  }
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
