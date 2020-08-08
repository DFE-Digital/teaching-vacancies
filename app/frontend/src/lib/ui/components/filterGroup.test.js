import filterGroup, {
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
  closeAllSectionsHandler,
  filterChangeHandler,
  CHECKBOX_CLASS_SELECTOR,
} from './filterGroup';

describe('filterGroup', () => {
  let removeFilterMock = null; let removeAllFiltersMock = null; let onRemove = null; let filterChangeHandlerMock = null;

  beforeEach(() => {
    jest.resetAllMocks();

    filterGroup.removeFilterHandler = jest.fn();
    removeFilterMock = jest.spyOn(filterGroup, 'removeFilterHandler');

    filterGroup.removeAllFiltersHandler = jest.fn();
    removeAllFiltersMock = jest.spyOn(filterGroup, 'removeAllFiltersHandler');

    filterGroup.filterChangeHandler = jest.fn();
    filterChangeHandlerMock = jest.spyOn(filterGroup, 'filterChangeHandler');

    onRemove = jest.fn();
  });

  describe('addRemoveFilterEvent', () => {
    test('adds event listener to element that calls handler with correct arguments', () => {
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

  describe('closeAllSectionsHandler', () => {
    test('removes the class selector from all filter groups that makes them visible', () => {
      document.body.innerHTML = '<div class="govuk-accordion__section"></div><div class="govuk-accordion__section"></div><div class="govuk-accordion__section"></div>';

      const event = { preventDefault: jest.fn() };
      const dontFollowLinkMock = jest.spyOn(event, 'preventDefault');

      closeAllSectionsHandler(event);

      expect(dontFollowLinkMock).toHaveBeenCalled();
      expect(document.getElementsByClassName('govuk-accordion__section--expanded').length).toEqual(0);
    });
  });
});
