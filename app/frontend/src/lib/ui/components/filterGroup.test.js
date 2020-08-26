import filterGroup, {
  init,
  isFormAutoSubmitEnabled,
  addRemoveFilterEvent,
  addRemoveAllFiltersEvent,
  removeFilterHandler,
  removeAllFiltersHandler,
  getFilterGroup,
  findFilterCheckboxInGroup,
  getFilterCheckboxesInGroup,
  unCheckCheckbox,
  getFilterGroups,
  addFilterChangeEvent,
  getSubmitButton,
  displayOpenOrCloseText,
  openOrCloseAllSectionsHandler,
  openOrCloseAllSections,
  filterChangeHandler,
  CHECKBOX_CLASS_SELECTOR,
  CLOSE_ALL_TEXT,
  OPEN_ALL_TEXT,
  addUpdateOpenOrCloseEvent,
} from './filterGroup';

describe('filterGroup', () => {
  let onRemove = null;

  beforeEach(() => {
    jest.resetAllMocks();

    onRemove = jest.fn();
  });

  describe('init', () => {
    test('adds event listener to element that calls handler with correct arguments', () => {
      filterGroup.addRemoveFilterEvent = jest.fn();
      const addRemoveFilterEventMock = jest.spyOn(filterGroup, 'addRemoveFilterEvent');

      filterGroup.addRemoveAllFiltersEvent = jest.fn();
      const addRemoveAllFiltersEventMock = jest.spyOn(filterGroup, 'addRemoveAllFiltersEvent');

      filterGroup.addUpdateOpenOrCloseEvent = jest.fn();
      const addUpdateOpenOrCloseEventMock = jest.spyOn(filterGroup, 'addUpdateOpenOrCloseEvent');

      document.body.innerHTML = `<form data-auto-submit="true"><div>
<h2 id="mobile-filters-button"></h2>
<button class="moj-filter__tag">remove</button>
<button class="moj-filter__tag">remove</button>
<button id="clear-filters-button">remove</button>
<button id="close-all-groups">remove</button>
</div>
<div class="filter-group__container"><div class="govuk-accordion__section-header"><h3 class="heading"><button class="govuk-accordion__section-button"></button></h3></div></div>
<div class="filter-group__container"><div class="govuk-accordion__section-header"><h3 class="heading"><button class="govuk-accordion__section-button"></button></h3></div></div>
</form>`;

      init('filter-group__container', 'moj-filter__tag', 'clear-filters-button', 'close-all-groups', 'mobile-filters-button', 'govuk-accordion__section-header');

      expect(addRemoveFilterEventMock).toHaveBeenCalledTimes(2);
      expect(addRemoveAllFiltersEventMock).toHaveBeenCalledTimes(1);
      expect(addUpdateOpenOrCloseEventMock).toHaveBeenCalledTimes(2);
    });
  });

  describe('isFormAutoSubmitEnabled', () => {
    test('returns true if the auto submit data attribute has been added to the form', () => {
      document.body.innerHTML = '<form data-auto-submit="true"><div class="filter-group"></div></form>';
      expect(isFormAutoSubmitEnabled('filter-group')).toBe('true');
    });

    test('returns false if the auto submit data attribute has NOT been added to the form', () => {
      document.body.innerHTML = '<form><div class="filter-group"></div></form>';
      expect(isFormAutoSubmitEnabled('filter-group')).toBeFalsy();
    });

    test('returns false if the element in form doesnt exist', () => {
      document.body.innerHTML = '<form><div></div></form>';
      expect(isFormAutoSubmitEnabled('filter-group')).toBeFalsy();
    });
  });

  describe('addRemoveFilterEvent', () => {
    test('adds event listener to element that calls handler with correct arguments', () => {
      filterGroup.removeFilterHandler = jest.fn();
      const removeFilterMock = jest.spyOn(filterGroup, 'removeFilterHandler');

      document.body.innerHTML = '<button id="test-button" data-group="filter-group" data-key="filter-key">click me</button>';
      const button = document.getElementById('test-button');
      filterGroup.getFilterGroup = jest.fn(() => 'group');
      addRemoveFilterEvent(button, onRemove);
      button.dispatchEvent(new Event('click'));

      expect(removeFilterMock).toHaveBeenCalledWith('group', 'filter-key', onRemove);
    });
  });

  describe('addRemoveAllFiltersEvent', () => {
    test('adds event listener to element that calls handler with correct arguments', () => {
      filterGroup.removeAllFiltersHandler = jest.fn();
      const removeAllFiltersMock = jest.spyOn(filterGroup, 'removeAllFiltersHandler');

      document.body.innerHTML = '<a id="remove-filters">remove all</a>';
      const button = document.getElementById('remove-filters');
      addRemoveAllFiltersEvent(button, onRemove);
      button.dispatchEvent(new Event('click'));

      expect(removeAllFiltersMock).toHaveBeenCalledWith(onRemove);
    });
  });

  describe('removeFilterHandler', () => {
    document.body.innerHTML = `<div id="group"><input id="test-checkbox" type="checkbox" class="${CHECKBOX_CLASS_SELECTOR}" value="filter-key" checked /><div>`;
    const checkbox = document.getElementById('test-checkbox');
    const group = document.getElementById('group');

    test('removes checked attribute for filter checkbox in group', () => {
      expect(checkbox.checked).toBe(true);
      removeFilterHandler(group, 'filter-key', onRemove);
      expect(checkbox.checked).toBe(false);
    });

    test('calls the supplied callback', () => {
      removeFilterHandler(group, 'filter-key', onRemove);
      expect(onRemove).toHaveBeenCalled();
    });
  });

  describe('removeAllFiltersHandler', () => {
    document.body.innerHTML = `<div class="filter-group__checkboxes">
<input type="checkbox" class="${CHECKBOX_CLASS_SELECTOR}" checked />
</div>
<div class="filter-group__checkboxes">
<input type="checkbox" class="${CHECKBOX_CLASS_SELECTOR}" checked />
</div>`;

    test('removes checked attribute for all filter checkboxes', () => {
      removeAllFiltersHandler(onRemove);
      Array.from(document.getElementsByClassName(CHECKBOX_CLASS_SELECTOR)).map((checkbox) => expect(checkbox.checked).toBe(false));
    });

    test('calls the supplied callback', () => {
      removeAllFiltersHandler(onRemove);
      expect(onRemove).toHaveBeenCalled();
    });
  });

  describe('getFilterGroup', () => {
    test('finds the container element for a group of filters', () => {
      document.body.innerHTML = '<div class="filter-group__checkboxes" data-group="x"></div><div id="should-find" class="filter-group__checkboxes" data-group="y"></div>';
      const shouldFind = document.getElementById('should-find');

      expect(getFilterGroup('y')).toEqual(shouldFind);
    });
  });

  describe('findFilterCheckboxInGroup', () => {
    test('finds a checkbox with a specified value in a group', () => {
      document.body.innerHTML = `<div id="group">
<input class="${CHECKBOX_CLASS_SELECTOR}" value="x" />
<input value="y" />
<input id="should-find" class="${CHECKBOX_CLASS_SELECTOR}" value="z" />
</div>`;

      const group = document.getElementById('group');
      const shouldFind = document.getElementById('should-find');

      expect(findFilterCheckboxInGroup(group, 'y')).toEqual(undefined);
      expect(findFilterCheckboxInGroup(group, 'z')).toEqual(shouldFind);
    });
  });

  describe('unCheckCheckbox', () => {
    test('sets the checked attribute to false', () => {
      document.body.innerHTML = '<input id="test-checkbox" type="checkbox" checked />';
      const checkbox = document.getElementById('test-checkbox');
      expect(checkbox.checked).toBe(true);
      unCheckCheckbox(checkbox);
      expect(checkbox.checked).toBe(false);
    });
  });

  describe('getFilterGroups', () => {
    test('finds all filter group container elements', () => {
      document.body.innerHTML = '<div class="filter-group__checkboxes"></div><div></div><div class="filter-group__checkboxes"></div>';
      expect(getFilterGroups().length).toBe(2);
    });
  });

  describe('getFilterCheckboxesInGroup', () => {
    test('finds all checkbox inputs in a group', () => {
      document.body.innerHTML = `<div id="group"><input class="${CHECKBOX_CLASS_SELECTOR}" /><input value="y" /><input class="${CHECKBOX_CLASS_SELECTOR}" /></div>`;
      const group = document.getElementById('group');
      expect(getFilterCheckboxesInGroup(group).length).toBe(2);
    });
  });

  describe('addFilterChangeEvent', () => {
    test('adds event listener to element that calls handler with correct arguments', () => {
      filterGroup.filterChangeHandler = jest.fn();
      const filterChangeHandlerMock = jest.spyOn(filterGroup, 'filterChangeHandler');

      document.body.innerHTML = '<div id="test-group" class="group"></div><div class="group"></div>';
      const groups = document.getElementsByClassName('group');
      const group = document.getElementById('test-group');

      addFilterChangeEvent(groups);
      group.dispatchEvent(new Event('click'));

      expect(filterChangeHandlerMock).toHaveBeenCalledWith(group);
    });
  });

  describe('filterChangeHandler', () => {
    test('submits the form only if a filter checkbox is clicked', () => {
      document.body.innerHTML = `<form>
  <div>
  <input type="text" id="should-submit" class="${CHECKBOX_CLASS_SELECTOR}" />
  <span id="should-not-submit">abc</span>
  </div>
  <input type="submit" id="submit-button" />
  </form>`;

      const submitButton = document.getElementById('submit-button');
      const shouldNotSubmit = document.getElementById('should-not-submit');
      const shouldSubmit = document.getElementById('should-submit');

      submitButton.click = jest.fn();
      const submitMock = jest.spyOn(submitButton, 'click');

      filterChangeHandler(shouldNotSubmit);
      expect(submitMock).not.toHaveBeenCalled();

      filterChangeHandler(shouldSubmit);
      expect(submitMock).toHaveBeenCalled();
    });
  });

  describe('getSubmitButton', () => {
    test('finds and returns the DOM element of the submit button for the form thst supplied element is in', () => {
      document.body.innerHTML = '<form><div><input type="checkbox" id="test-element" /></div><div><input type="submit" id="find-this" /></div></form>';

      const submitButton = document.getElementById('find-this');
      const found = getSubmitButton(document.getElementById('test-element'));

      expect(found).toBe(submitButton);
    });
  });

  describe('openOrCloseAllSectionsHandler', () => {
    test('removes the class selector from all filter groups that makes them visible', () => {
      document.body.innerHTML = `<div class="govuk-accordion__section govuk-accordion__section--expanded"></div>
      <div class="govuk-accordion__section govuk-accordion__section--expanded"></div>
      <div class="govuk-accordion__section"></div>`;

      const event = { preventDefault: jest.fn(), target: { innerText: CLOSE_ALL_TEXT } };
      const dontFollowLinkMock = jest.spyOn(event, 'preventDefault');

      openOrCloseAllSectionsHandler(event);

      expect(dontFollowLinkMock).toHaveBeenCalled();
      expect(document.getElementsByClassName('govuk-accordion__section--expanded').length).toEqual(0);
    });

    test('adds the class selector from all filter groups that makes them visible', () => {
      document.body.innerHTML = `<div class="govuk-accordion__section govuk-accordion__section--expanded"></div>
      <div class="govuk-accordion__section govuk-accordion__section--expanded"></div>
      <div class="govuk-accordion__section"></div>`;

      const event = { preventDefault: jest.fn(), target: { innerText: OPEN_ALL_TEXT } };
      const dontFollowLinkMock = jest.spyOn(event, 'preventDefault');

      openOrCloseAllSectionsHandler(event);

      expect(dontFollowLinkMock).toHaveBeenCalled();
      expect(document.getElementsByClassName('govuk-accordion__section--expanded').length).toEqual(3);
    });
  });

  describe('displayOpenOrCloseText', () => {
    test('displays open text when all elements are closed', () => {
      const targetElement = { innerText: CLOSE_ALL_TEXT };
      const expandedElements = 0;
      const maxElements = 2;

      displayOpenOrCloseText(targetElement, expandedElements, maxElements);
      expect(targetElement.innerText).toEqual(OPEN_ALL_TEXT);
    });

    test('displays close text when all elements are open', () => {
      const targetElement = { innerText: OPEN_ALL_TEXT };
      const expandedElements = 2;
      const maxElements = 2;

      displayOpenOrCloseText(targetElement, expandedElements, maxElements);
      expect(targetElement.innerText).toEqual(CLOSE_ALL_TEXT);
    });
  });

  describe('openOrCloseAllSections', () => {
    test('closes all elements when called', () => {
      document.body.innerHTML = `<div class="govuk-accordion__section govuk-accordion__section--expanded"></div>
      <div class="govuk-accordion__section govuk-accordion__section--expanded"></div>
      <div class="govuk-accordion__section"></div>`;
      const targetElement = { innerText: CLOSE_ALL_TEXT };

      openOrCloseAllSections(targetElement);
      expect(targetElement.innerText).toEqual(OPEN_ALL_TEXT);
      expect(document.getElementsByClassName('govuk-accordion__section--expanded').length).toEqual(0);
    });

    test('opens all elements when called', () => {
      document.body.innerHTML = `<div class="govuk-accordion__section govuk-accordion__section--expanded"></div>
      <div class="govuk-accordion__section govuk-accordion__section--expanded"></div>
      <div class="govuk-accordion__section"></div>`;
      const targetElement = { innerText: OPEN_ALL_TEXT };

      openOrCloseAllSections(targetElement);
      expect(targetElement.innerText).toEqual(CLOSE_ALL_TEXT);
      expect(document.getElementsByClassName('govuk-accordion__section--expanded').length).toEqual(3);
    });
  });

  describe('addUpdateOpenOrCloseEvent', () => {
    test('displays close all when all elements are open', () => {
      document.body.innerHTML = `
      <form data-auto-submit="true">
        <div><button id="close-all-groups">Open all</button></div>
        <div class="govuk-accordion__section govuk-accordion__section--expanded filter-group__container">
          <div class="govuk-accordion__section-header"><h3 class="heading"><button class="govuk-accordion__section-button"></button></h3></div>
        </div>
        <div class="govuk-accordion__section govuk-accordion__section--expanded filter-group__container">
          <div class="govuk-accordion__section-header"><h3 class="heading"><button class="govuk-accordion__section-button"></button></h3></div>
        </div>
        <div class="govuk-accordion__section govuk-accordion__section--expanded filter-group__container">
          <div class="govuk-accordion__section-header" id="closed-section-header"><h3 class="heading"><button class="govuk-accordion__section-button"></button></h3></div>
        </div>
      </form>
      `;

      const sectionHeaderElement = document.getElementById('closed-section-header');
      const openOrCloseAllSelector = 'close-all-groups';

      addUpdateOpenOrCloseEvent(sectionHeaderElement, openOrCloseAllSelector);
      sectionHeaderElement.dispatchEvent(new Event('click'));

      expect(document.getElementById(openOrCloseAllSelector).innerText).toEqual(CLOSE_ALL_TEXT);
    });

    test('displays open all when all elements are closed', () => {
      document.body.innerHTML = `
      <form data-auto-submit="true">
        <div><button id="close-all-groups">Close all</button></div>
        <div class="govuk-accordion__section filter-group__container">
          <div class="govuk-accordion__section-header"><h3 class="heading"><button class="govuk-accordion__section-button"></button></h3></div>
        </div>
        <div class="govuk-accordion__section filter-group__container">
          <div class="govuk-accordion__section-header"><h3 class="heading"><button class="govuk-accordion__section-button"></button></h3></div>
        </div>
        <div class="govuk-accordion__section filter-group__container">
          <div class="govuk-accordion__section-header" id="open-section-header"><h3 class="heading"><button class="govuk-accordion__section-button"></button></h3></div>
        </div>
      </form>
      `;

      const sectionHeaderElement = document.getElementById('open-section-header');
      const openOrCloseAllSelector = 'close-all-groups';

      addUpdateOpenOrCloseEvent(sectionHeaderElement, openOrCloseAllSelector);
      sectionHeaderElement.dispatchEvent(new Event('click'));

      expect(document.getElementById(openOrCloseAllSelector).innerText).toEqual(OPEN_ALL_TEXT);
    });
  });
});
