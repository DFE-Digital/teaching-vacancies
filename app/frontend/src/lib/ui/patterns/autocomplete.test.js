import autocomplete, {
  isActive,
  renderAutocomplete,
  clearOptions,
  showOptions,
} from './autocomplete';
import view, { show, hide, setInputValue } from './autocomplete.view';

describe('autocomplete', () => {
  describe('isActive', () => {
    test('activates autocomplete if threshold has been met', () => {
      expect(isActive(3, 'sou'.length)).toBe(true);
      expect(isActive(3, 'sout'.length)).toBe(true);
    });

    test('doesnt activate autocomplete if threshold hasnt been met', () => {
      expect(isActive(3, 'so'.length)).toBe(false);
      expect(isActive(3, ''.length)).toBe(false);
    });
  });
});

describe('autocomplete view', () => {
  let hideMock = null; let showMock = null; let focusMock = null; let renderMock = null; let showOptionsMock = null; let getOptions = null; let clearOptionsMock = null;

  const suggestions = ['option 1', 'option 2', 'choice 3'];
  const key = 'key';

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

    autocomplete.showOptions = jest.fn();
    showOptionsMock = jest.spyOn(autocomplete, 'showOptions');

    autocomplete.clearOptions = jest.fn();
    clearOptionsMock = jest.spyOn(autocomplete, 'clearOptions');

    getOptions = jest.fn(() => Promise.resolve(suggestions));

    renderAutocomplete({
      container,
      input,
      threshold: 3,
      getOptions,
      key,
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
      expect(optionList.getAttribute('aria-label')).toBe('Suggested keys');
      expect(optionList.id).toBe('key__listbox');
    });

    test('clicking on page closes hide autocomplete options', () => {
      const event = new Event('click');
      document.dispatchEvent(event);
      expect(hideMock).toHaveBeenCalledTimes(1);
      expect(hideMock).toHaveBeenCalledWith(container, input);
    });

    test('when user inputs number of characters above threshhold the options are retrieved', () => {
      input.value = 'option';
      const event = new Event('input');
      input.dispatchEvent(event);
      expect(showOptionsMock).toHaveBeenCalledTimes(1);
      expect(showOptionsMock).toHaveBeenCalledWith(getOptions, container, input, key);
    });

    test('when user inputs number of characters below threshhold the options are cleared', () => {
      input.value = 'op';
      const event = new Event('input');
      input.dispatchEvent(event);
      expect(clearOptionsMock).toHaveBeenCalledTimes(1);
      expect(clearOptionsMock).toHaveBeenCalledWith(container, input);
    });

    test('clears options calls the appropriate show options method in the view', () => {
      clearOptions(container, input);
      expect(hideMock).toHaveBeenCalledTimes(1);
      expect(hideMock).toHaveBeenCalledWith(container, input);
    });

    test('shows suggestions when the promise is resolved with options ', () => {
      showOptions(() => Promise.resolve(suggestions), container, input, key).then(() => {
        expect(showMock).toHaveBeenCalledTimes(1);
        expect(showMock).toHaveBeenCalledWith(suggestions, container, input, key);
      });
    });

    test('sets keyboard handlers to traverse options', () => {
      const event = new Event('keyup');
      event.code = 'ArrowDown';
      input.dispatchEvent(event);

      expect(focusMock).toHaveBeenNthCalledWith(1, container, 'next', input, key);

      event.code = 'ArrowUp';
      input.dispatchEvent(event);

      expect(focusMock).toHaveBeenNthCalledWith(2, container, 'previous', input, key);
    });
  });

  describe('view methods', () => {
    beforeAll(() => {
      view.render = jest.fn();
      renderMock = jest.spyOn(view, 'render');

      renderAutocomplete({
        container,
        input,
        threshold: 3,
        getOptions,
        key,
      });
    });

    test('show sets appropriate class and a11y attributes', () => {
      const options = ['option 1', 'option 2', 'choice 3'];
      show(options, container, input, key);
      const optionList = container.querySelector('ul');

      expect(renderMock).toHaveBeenNthCalledWith(1, options, container, input, key);
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

    test('hide sets appropriate class and a11y attributes', () => {
      setInputValue(input, 'value to set');

      expect(renderMock).not.toHaveBeenCalled();
      expect(input.value).toBe('value to set');
    });
  });
});
