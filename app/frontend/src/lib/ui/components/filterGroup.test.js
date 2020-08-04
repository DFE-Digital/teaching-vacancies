import filterGroup, {
  addRemoveEvent,
  clearFilter,
  getFilterGroup,
  findFilterCheckbox,
} from './filterGroup';

describe('filterGroup', () => {
  let clearFilterMock = null;

  beforeEach(() => {
    jest.resetAllMocks();

    filterGroup.clearFilter = jest.fn();
    clearFilterMock = jest.spyOn(filterGroup, 'clearFilter');
  });

  describe('addRemoveEvent', () => {
    test('ds', () => {
      document.body.innerHTML = '<button id="test-button" data-group="filter-group" data-key="filter-key">click me</button>';
      const button = document.getElementById('test-button');
      const onRemove = jest.fn();
      filterGroup.getFilterGroup = jest.fn(() => 'group');
      addRemoveEvent(button, onRemove);
      button.dispatchEvent(new Event('click'));
      expect(clearFilterMock).toHaveBeenCalledWith('group', 'filter-key', onRemove);
    });
  });

  describe('clearFilter', () => {
    test('ds', () => {
      document.body.innerHTML = '<input id="test-checkbox" type="checkbox" class="govuk-checkboxes__input" value="filter-key" checked />';
      const checkbox = document.getElementById('test-checkbox');
      expect(checkbox.checked).toBe(true);

      const onRemove = jest.fn();
      filterGroup.findFilterCheckbox = jest.fn(() => checkbox);
      clearFilter('something', 'something', onRemove);
      expect(checkbox.checked).toBe(false);
    });
  });

  describe('getFilterGroup', () => {
    test('ds', () => {
      document.body.innerHTML = '<div class="govuk-accordion__section-content" data-group="x"></div><div id="should-find" class="govuk-accordion__section-content" data-group="y"></div>';
      const shouldFind = document.getElementById('should-find');
      expect(getFilterGroup('y')).toEqual(shouldFind);
    });
  });

  describe('findFilterCheckbox', () => {
    test('ds', () => {
      document.body.innerHTML = '<div id="group"><input class="govuk-checkboxes__input" value="x" /><input value="y" /><input id="should-find" class="govuk-checkboxes__input" value="z" /></div>';
      const group = document.getElementById('group');
      const shouldFind = document.getElementById('should-find');
      expect(findFilterCheckbox(group, 'y')).toEqual(undefined);
      expect(findFilterCheckbox(group, 'z')).toEqual(shouldFind);
    });
  });
});
