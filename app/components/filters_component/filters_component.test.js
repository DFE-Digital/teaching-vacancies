/**
 * @jest-environment jsdom
 */

import filterGroup, {
  init,
  addRemoveFilterEvent,
  addRemoveAllFiltersEvent,
  removeFilterHandler,
  removeAllFiltersHandler,
  getFilterGroup,
  findFilterCheckboxInGroup,
  getFilterCheckboxesInGroup,
  unCheckCheckbox,
  getFilterGroups,
  CHECKBOX_CLASS_SELECTOR,
  CHECKBOX_GROUP_CLASS_SELECTOR,
  REMOVE_FILTER_CLASS_SELECTOR,
} from './filters_component';

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

      document.body.innerHTML = `<form data-controller="form"><div class='filters-component'>
<h2 id="filters-component-show-mobile"></h2>
<button class="${REMOVE_FILTER_CLASS_SELECTOR}">remove</button>
<button class="${REMOVE_FILTER_CLASS_SELECTOR}">remove</button>
<button id="filters-component-clear-all">remove</button>
<button id="filters-component-close-all">remove</button>
</div>
</form>`;

      init(
        REMOVE_FILTER_CLASS_SELECTOR,
        'filters-component-clear-all',
        'filters-component-close-panel',
        'filters-component-show-mobile',
      );

      expect(addRemoveFilterEventMock).toHaveBeenCalledTimes(2);
      expect(addRemoveAllFiltersEventMock).toHaveBeenCalledTimes(1);
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

      document.body.innerHTML = '<a id="remove-filters-component">remove all</a>';
      const button = document.getElementById('remove-filters-component');
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
  });

  describe('removeAllFiltersHandler', () => {
    document.body.innerHTML = `<div class="${CHECKBOX_GROUP_CLASS_SELECTOR}">
<input type="checkbox" class="${CHECKBOX_CLASS_SELECTOR}" checked />
</div>
<div class="${CHECKBOX_GROUP_CLASS_SELECTOR}">
<input type="checkbox" class="${CHECKBOX_CLASS_SELECTOR}" checked />
</div>`;

    test('removes checked attribute for all filter checkboxes', () => {
      removeAllFiltersHandler(onRemove);
      Array.from(document.getElementsByClassName(CHECKBOX_CLASS_SELECTOR)).forEach((checkbox) => expect(checkbox.checked).toBe(false));
    });
  });

  describe('getFilterGroup', () => {
    test('finds the container element for a group of filters-component', () => {
      document.body.innerHTML = `<div class="${CHECKBOX_GROUP_CLASS_SELECTOR}" data-group="x"></div><div id="should-find" class="${CHECKBOX_GROUP_CLASS_SELECTOR}" data-group="y"></div>`;
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
      document.body.innerHTML = `<div class="${CHECKBOX_GROUP_CLASS_SELECTOR}"></div><div></div><div class="${CHECKBOX_GROUP_CLASS_SELECTOR}"></div>`;
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
});
