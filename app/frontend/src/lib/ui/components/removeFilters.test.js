import removeFilters, {
  addRemoveEvent,
  removeFilter,
  getFilterGroup,
  findFilterCheckbox,
} from './removeFilters';

describe('removeFilters', () => {
  let removeFilterMock = null;

  beforeEach(() => {
    jest.resetAllMocks();

    removeFilters.removeFilter = jest.fn();
    removeFilterMock = jest.spyOn(removeFilters, 'removeFilter');
  });

  describe('addRemoveEvent', () => {
    test('ds', () => {
      document.body.innerHTML = '<button id="test-button" data-group="filter-group" data-key="filter-key">click me</button>';
      const button = document.getElementById('test-button');
      const onRemove = jest.fn();
      removeFilters.getFilterGroup = jest.fn(() => 'group');
      addRemoveEvent(button, onRemove);
      button.dispatchEvent(new Event('click'));
      expect(removeFilterMock).toHaveBeenCalledWith('group', 'filter-key', onRemove);
    });
  });

  describe('removeFilter', () => {
    test('ds', () => {
      document.body.innerHTML = '<input id="test-checkbox" type="checkbox" class="govuk-checkboxes__input" value="filter-key" checked />';
      const checkbox = document.getElementById('test-checkbox');
      expect(checkbox.checked).toBe(true);

      const onRemove = jest.fn();
      removeFilters.findFilterCheckbox = jest.fn(() => checkbox);
      removeFilter('something', 'something', onRemove);
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
