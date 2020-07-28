import autocomplete, { isActive, renderAutocomplete } from './autocomplete';
import view, { show, hide } from './autocomplete.view';
import api, { getPlaceOptionsFromSearchQuery } from '../../api';

describe('autocomplete', () => {
  describe('isActive', () => {
    test('activates autocomplete if threshold has been met', () => {
      expect(isActive(3, 'sou')).toBe(true);
      expect(isActive(3, 'sout')).toBe(true);
    });

    test('doesnt activate autocomplete if threshold hasnt been met', () => {
      expect(isActive(3, 'so')).toBe(false);
      expect(isActive(3, '')).toBe(false);
    });
  });
});

describe('autocomplete view', () => {
  let hideMock = null; let showMock = null; let focusMock = null; let renderMock = null; const
    onSelect = jest.fn();

  document.body.innerHTML = '<div id="container"><input id="input" /></div>';

  const container = document.getElementById('container');
  const input = document.getElementById('input');

  beforeAll(() => {
    autocomplete.view.hide = jest.fn();
    hideMock = jest.spyOn(autocomplete.view, 'hide');

    autocomplete.view.show = jest.fn();
    showMock = jest.spyOn(autocomplete.view, 'show');

    autocomplete.view.focus = jest.fn();
    focusMock = jest.spyOn(autocomplete.view, 'focus');

    const suggestions = ['option 1', 'option 2', 'choice 3'];

    api.getPlaceOptionsFromSearchQuery = jest.fn(() => suggestions);

    renderAutocomplete({
      container,
      input,
      threshold: 3,
      onSelect,
    });
  });

  beforeEach(() => {
    jest.resetAllMocks();
  });

  describe('create method', () => {
    test('sets correct a11y attributes', () => {
      const optionList = container.querySelector('ul');
      expect(optionList.getAttribute('tabindex')).toBe('-1');
      expect(optionList.getAttribute('role')).toBe('listbox');
    });

    test('clicking on option calls onSelect handler', () => {
      const optionList = container.querySelector('ul');
      const event = new Event('click');
      optionList.dispatchEvent(event);
      expect(onSelect).toHaveBeenCalledTimes(1);
    });

    test('clicking on page closes hide autocomplete options', () => {
      const event = new Event('click');
      document.dispatchEvent(event);
      expect(hideMock).toHaveBeenCalledTimes(1);
      expect(hideMock).toHaveBeenCalledWith(container, input);
    });

    test('shows correct autocomplete options', () => {
      input.value = 'option';
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

  describe('display methods', () => {
    beforeAll(() => {
      view.render = jest.fn();
      renderMock = jest.spyOn(view, 'render');

      renderAutocomplete({
        container,
        input,
        dataset: ['option 1', 'option 2', 'choice 3'],
        threshold: 3,
        onSelect,
      });
    });

    test('show sets appropriate class and a11y attributes', () => {
      const options = ['option 1', 'option 2', 'choice 3'];
      show(options, container, input);
      const optionList = container.querySelector('ul');

      expect(renderMock).toHaveBeenNthCalledWith(1, options, container, input);
      expect(input.getAttribute('aria-expanded')).toBe('true');
      expect(optionList.classList.contains('autocomplete__menu--visible')).toBe(true);
      expect(optionList.classList.contains('autocomplete__menu--hidden')).toBe(false);
    });

    test('hide sets appropriate class and a11y attributes', () => {
      hide(container, input);
      const optionList = container.querySelector('ul');

      expect(renderMock).not.toHaveBeenCalled();
      expect(input.getAttribute('aria-expanded')).toBe('false');
      expect(optionList.classList.contains('autocomplete__menu--visible')).toBe(false);
      expect(optionList.classList.contains('autocomplete__menu--hidden')).toBe(true);
    });
  });
});
