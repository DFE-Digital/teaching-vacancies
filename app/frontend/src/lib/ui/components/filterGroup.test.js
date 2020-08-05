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
});
