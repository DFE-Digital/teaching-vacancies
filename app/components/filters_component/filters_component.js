import '../../frontend/src/lib/polyfill/closest.polyfill';
import '../../frontend/src/lib/polyfill/from.polyfill';
import 'classlist-polyfill';

export const ACCORDION_SECTION_CLASS_SELECTOR = 'govuk-accordion__section';
export const ACCORDION_SECTION_EXPANDED_CLASS_SELECTOR = 'govuk-accordion__section--expanded';
export const CHECKBOX_CLASS_SELECTOR = 'govuk-checkboxes__input';
export const CHECKBOX_GROUP_CLASS_SELECTOR = 'filters-component__groups__group';
export const REMOVE_FILTER_CLASS_SELECTOR = 'filters-component__remove-tags__tag';
export const CLOSE_ALL_TEXT = 'Close all';
export const OPEN_ALL_TEXT = 'Open all';

window.addEventListener(
  'DOMContentLoaded',
  () => init(
    ACCORDION_SECTION_CLASS_SELECTOR,
    REMOVE_FILTER_CLASS_SELECTOR,
    'clear-filters-component-button',
    'close-all-groups',
    'mobile-filters-component-button',
    'govuk-accordion__section-header',
  ),
);

export const init = (groupContainerSelector, removeButtonSelector, clearButtonId, closeButtonId, mobileFiltersButtonSelector, accordionButtonsSelector) => {
  if (!isFormAutoSubmitEnabled(groupContainerSelector)) { return; }

  Array.from(document.getElementsByClassName(accordionButtonsSelector)).forEach((accordionButton) => filterGroup.addUpdateOpenOrCloseEvent(accordionButton, closeButtonId));

  Array.from(document.getElementsByClassName(removeButtonSelector)).forEach((removeButton) => filterGroup.addRemoveFilterEvent(removeButton, () => getSubmitButton(removeButton).click()));

  const clearButton = document.getElementById(clearButtonId);
  if (clearButton) {
    filterGroup.addRemoveAllFiltersEvent(clearButton, () => getSubmitButton(clearButton).click());
  }

  addFilterChangeEvent(document.getElementsByClassName(groupContainerSelector));
  if (document.getElementById(closeButtonId)) {
    displayOpenOrCloseText(
      document.getElementById(closeButtonId),
      document.getElementsByClassName(ACCORDION_SECTION_EXPANDED_CLASS_SELECTOR).length,
      document.getElementsByClassName(ACCORDION_SECTION_CLASS_SELECTOR).length,
    );
    document.getElementById(closeButtonId).addEventListener('click', openOrCloseAllSectionsHandler);
  }

  if (document.getElementById(mobileFiltersButtonSelector)) {
    document.getElementById(mobileFiltersButtonSelector).addEventListener('click', () => {
      document.getElementsByClassName('filters-component')[0].classList.toggle('filters-component--show-mobile');

      if (document.getElementsByClassName('filters-component--show-mobile').length) {
        document.getElementsByClassName('filters-component--show-mobile')[0].closest('form').removeAttribute('data-auto-submit');
      }
    });
  }

  if (document.getElementById('return-to-results')) {
    document.getElementById('return-to-results').addEventListener('click', (e) => {
      e.preventDefault();
      return Array.from(document.getElementsByClassName('filters-component')).map((element) => element.classList.toggle('filters-component--show-mobile'));
    });
  }
};

export const displayOpenOrCloseText = (targetElement, expandedElements, maxElements) => {
  if (expandedElements === 0) {
    targetElement.innerText = OPEN_ALL_TEXT;
  } else if (expandedElements === maxElements) {
    targetElement.innerText = CLOSE_ALL_TEXT;
  }
};

export const addUpdateOpenOrCloseEvent = (sectionHeaderElement, openOrCloseAllSelector) => {
  const openOrCloseAllElement = document.getElementById(openOrCloseAllSelector);
  if (openOrCloseAllElement) {
    sectionHeaderElement.addEventListener('click', () => {
      displayOpenOrCloseText(
        openOrCloseAllElement,
        document.getElementsByClassName(ACCORDION_SECTION_EXPANDED_CLASS_SELECTOR).length,
        document.getElementsByClassName(ACCORDION_SECTION_CLASS_SELECTOR).length,
      );
    });
  }
};

export const isFormAutoSubmitEnabled = (groupContainerSelector) => {
  if (!document.getElementsByClassName(groupContainerSelector).length) {
    return false;
  }
  const form = document.getElementsByClassName(groupContainerSelector)[0].closest('form');
  return form && form.dataset.autoSubmit;
};

export const openOrCloseAllSectionsHandler = (e) => {
  e.preventDefault();
  openOrCloseAllSections(e.target);
};

export const openOrCloseAllSections = (targetElement) => {
  if (targetElement.innerText === CLOSE_ALL_TEXT) {
    Array.from(document.getElementsByClassName(ACCORDION_SECTION_CLASS_SELECTOR)).forEach((section) => section.classList.remove(ACCORDION_SECTION_EXPANDED_CLASS_SELECTOR));
    targetElement.innerText = OPEN_ALL_TEXT;
  } else if (targetElement.innerText === OPEN_ALL_TEXT) {
    Array.from(document.getElementsByClassName(ACCORDION_SECTION_CLASS_SELECTOR)).forEach((section) => section.classList.add(ACCORDION_SECTION_EXPANDED_CLASS_SELECTOR));
    targetElement.innerText = CLOSE_ALL_TEXT;
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
  filterGroup.getFilterGroups().forEach((groupEl) => filterGroup.getFilterCheckboxesInGroup(groupEl).forEach((checkbox) => filterGroup.unCheckCheckbox(checkbox)));
  onClear();
};

export const addFilterChangeEvent = (groups) => {
  Array.from(groups).forEach((group) => group.addEventListener('click', (e) => {
    filterGroup.filterChangeHandler(e.target);
  }));
};

export const filterChangeHandler = (el) => {
  if (el.className === CHECKBOX_CLASS_SELECTOR && isFormAutoSubmitEnabled('govuk-accordion__section')) {
    getSubmitButton(el).click();
  }
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
  addFilterChangeEvent,
  addRemoveFilterEvent,
  addRemoveAllFiltersEvent,
  addUpdateOpenOrCloseEvent,
  filterChangeHandler,
};

export default filterGroup;
