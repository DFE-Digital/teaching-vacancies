import autocomplete, { isActive, getOptions, renderAutocomplete } from './autocomplete';

describe('autocomplete', () => {
  describe('isActive', () => {
    test('should activate autocomplete if threshold has been met', () => {
      expect(isActive(3, 'sou')).toBe(true);
      expect(isActive(3, 'sout')).toBe(true);
    });

    test('should not activate autocomplete if threshold hasnt been met', () => {
      expect(isActive(3, 'so')).toBe(false);
      expect(isActive(3, '')).toBe(false);
    });
  });

  const options = [
    'apple',
    'banana',
    'apple apple',
    'banana apple',
    'applebanana',
    'cherry',
  ];

  describe('getOptions', () => {
    test('should return an array of matches from the options array that contain the supplied string', () => {
      expect(getOptions(options, 'appl')).toEqual(['apple', 'apple apple', 'banana apple', 'applebanana']);
      expect(getOptions(options, 'a')).toEqual(['apple', 'banana', 'apple apple', 'banana apple', 'applebanana']);
    });

    test('should return an array of matches from the options irrespective of letter case', () => {
      expect(getOptions(options, 'Appl')).toEqual(['apple', 'apple apple', 'banana apple', 'applebanana']);
      expect(getOptions(options, 'ApPL')).toEqual(['apple', 'apple apple', 'banana apple', 'applebanana']);
    });
  });
});

describe('autocomplete view', () => {

  let hideMock = null, showMock = null, focusMock = null, onSelection = jest.fn(), container = null, input = null;

  document.body.innerHTML = '<div id="container"><input id="input" /></div>';

  container = document.getElementById('container');
  input = document.getElementById('input');

  beforeAll(() => {
    autocomplete.view.hide = jest.fn();
    hideMock = jest.spyOn(autocomplete.view, 'hide');

    autocomplete.view.show = jest.fn();
    showMock = jest.spyOn(autocomplete.view, 'show');

    autocomplete.view.focus = jest.fn();
    focusMock = jest.spyOn(autocomplete.view, 'focus');

    renderAutocomplete({
      container,
      input,
      dataset: ['option 1', 'option 2', 'choice 3'],
      threshold: 3,
      onSelection
    });
  });

  beforeEach(() => {
    jest.resetAllMocks();
  });

  describe('create method', () => {
    test('sets correct a11y attributes', () => {
      const optionList = container.querySelector('ul')
      expect(optionList.getAttribute('tabindex')).toBe('-1');
      expect(optionList.getAttribute('role')).toBe('listbox');
    });

    test('clicking on option calls onSelect handler', () => {
      const optionList = container.querySelector('ul');
      const event = new Event('click');
      optionList.dispatchEvent(event);
      expect(onSelection).toHaveBeenCalledTimes(1);
    });


    test('clicking on page closes hide autocomplete options', () => {
      const event = new Event('click');
      document.dispatchEvent(event);
      expect(hideMock).toHaveBeenCalledTimes(1);
      expect(hideMock).toHaveBeenCalledWith(container, input);
    });

    test('shows correct autocomplete options', () => {
      input.value = 'option'
      const event = new Event('input');
      input.dispatchEvent(event);
      expect(showMock).toHaveBeenCalledTimes(1);
      expect(showMock).toHaveBeenCalledWith(['option 1', 'option 2'], container, input);
    });

    test('sets keyboard handlers to traverse options', () => {
      const event = new Event('keyup');
      event.code = 'ArrowDown';
      input.dispatchEvent(event);

      expect(focusMock).toHaveBeenNthCalledWith(1, container, 'next', input);

      event.code = 'ArrowUp';
      input.dispatchEvent(event);

      expect(focusMock).toHaveBeenNthCalledWith(2, container, 'previous', input);
    });
  });
});
