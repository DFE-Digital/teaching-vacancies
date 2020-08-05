import filterGroup, {
  addRemoveEvent,
  clearFilter,
  clearAllFilters,
  addClearAllEvent,
  getFilterGroup,
  findFilterCheckboxInGroup,
  getFilterCheckboxesInGroup,
  unCheckCheckbox,
  getFilterGroups,
} from './filterGroup';

describe('filterGroup', () => {
  let clearFilterMock = null; let clearAllFiltersMock = null; let onClear = null;

  beforeEach(() => {
    jest.resetAllMocks();

    filterGroup.clearFilter = jest.fn();
    clearFilterMock = jest.spyOn(filterGroup, 'clearFilter');

    filterGroup.clearAllFilters = jest.fn();
    clearAllFiltersMock = jest.spyOn(filterGroup, 'clearAllFilters');

    onClear = jest.fn();
  });

  describe('addRemoveEvent', () => {
    test('adds event listener to element that calls handler with correct arguments', () => {
      document.body.innerHTML = '<button id="test-button" data-group="filter-group" data-key="filter-key">click me</button>';
      const button = document.getElementById('test-button');
      filterGroup.getFilterGroup = jest.fn(() => 'group');
      addRemoveEvent(button, onClear);
      button.dispatchEvent(new Event('click'));
      expect(clearFilterMock).toHaveBeenCalledWith('group', 'filter-key', onClear);
    });
  });

  describe('addClearAllEvent', () => {
    test('adds event listener to element that calls handler with correct arguments', () => {
      document.body.innerHTML = '<a id="clear-filters">clear all</a>';
      const button = document.getElementById('clear-filters');
      addClearAllEvent(button, onClear);
      button.dispatchEvent(new Event('click'));
      expect(clearAllFiltersMock).toHaveBeenCalledWith(onClear);
    });
  });

  describe('clearFilter', () => {
    document.body.innerHTML = '<div id="group"><input id="test-checkbox" type="checkbox" class="govuk-checkboxes__input" value="filter-key" checked /><div>';
    const checkbox = document.getElementById('test-checkbox');
    const group = document.getElementById('group');

    test('removes checked attribute for filter checkbox in group', () => {
      expect(checkbox.checked).toBe(true);
      clearFilter(group, 'filter-key', onClear);
      expect(checkbox.checked).toBe(false);
    });

    test('calls the supplied callback', () => {
      clearFilter(group, 'filter-key', onClear);
      expect(onClear).toHaveBeenCalled();
    });
  });

  describe('clearAllFilters', () => {
    document.body.innerHTML = `<div class="govuk-accordion__section-content">
<input type="checkbox" class="govuk-checkboxes__input" checked />
</div>
<div class="govuk-accordion__section-content">
<input type="checkbox" class="govuk-checkboxes__input" checked />
</div>`;

    test('removes checked attribute for all filter checkboxes', () => {
      clearAllFilters(onClear);
      Array.from(document.getElementsByClassName('govuk-checkboxes__input')).map((checkbox) => expect(checkbox.checked).toBe(false));
    });

    test('calls the supplied callback', () => {
      clearAllFilters(onClear);
      expect(onClear).toHaveBeenCalled();
    });
  });

  describe('getFilterGroup', () => {
    test('finds the container element for a group of filters', () => {
      document.body.innerHTML = '<div class="govuk-accordion__section-content" data-group="x"></div><div id="should-find" class="govuk-accordion__section-content" data-group="y"></div>';
      const shouldFind = document.getElementById('should-find');
      expect(getFilterGroup('y')).toEqual(shouldFind);
    });
  });

  describe('findFilterCheckboxInGroup', () => {
    test('finds a checkbox with a specified value in a group', () => {
      document.body.innerHTML = '<div id="group"><input class="govuk-checkboxes__input" value="x" /><input value="y" /><input id="should-find" class="govuk-checkboxes__input" value="z" /></div>';
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
      document.body.innerHTML = '<div class="govuk-accordion__section-content"></div><div></div><div class="govuk-accordion__section-content"></div>';
      expect(getFilterGroups().length).toBe(2);
    });
  });

  describe('getFilterCheckboxesInGroup', () => {
    test('finds all checkbox inputs in a group', () => {
      document.body.innerHTML = '<div id="group"><input class="govuk-checkboxes__input" /><input value="y" /><input class="govuk-checkboxes__input" /></div>';
      const group = document.getElementById('group');
      expect(getFilterCheckboxesInGroup(group).length).toBe(2);
    });
  });
});
