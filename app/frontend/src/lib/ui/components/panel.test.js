import { toggleButtonText, isPanelClosed, panelToggle } from './panel';

describe('panel', () => {
  document.body.innerHTML = '<div id="panel-container"></div><button id="toggle-button">original text</button>';

  const HIDE_BUTTON_TEXT = 'Hide panel';
  const SHOW_BUTTON_TEXT = 'Show panel';
  const CLOSED_CLASS = 'closed';
  const container = document.getElementById('panel-container');
  const button = document.getElementById('toggle-button');
  const options = {
    container,
    toggleButton: button,
    hideText: HIDE_BUTTON_TEXT,
    showText: SHOW_BUTTON_TEXT,
    toggleClass: CLOSED_CLASS,
    onToggleHandler: jest.fn(),
  };

  describe('toggleButtonText', () => {
    test('changes button text to show panel state when panel is hidden', () => {
      toggleButtonText(options);
      expect(button.innerHTML).toBe(HIDE_BUTTON_TEXT);
    });

    test('changes button text to hide panel state when panel is visible', () => {
      container.classList.toggle(CLOSED_CLASS);
      toggleButtonText(options);
      expect(button.innerHTML).toBe(SHOW_BUTTON_TEXT);
    });
  });

  describe('isPanelClosed', () => {
    test('changes button text to show panel state when panel is hidden', () => {
      expect(isPanelClosed(container, CLOSED_CLASS)).toBe(true);
    });
  });

  describe('panelToggle', () => {
    test('calls toggle handler when button is clicked', () => {
      const toggleMock = jest.spyOn(options, 'onToggleHandler');
      panelToggle(options);
      options.toggleButton.dispatchEvent(new Event('click'));
      expect(toggleMock).toHaveBeenCalled();
    });

    test('toggles supplied class when button is clicked', () => {
      options.toggleButton.dispatchEvent(new Event('click'));
      expect(container.classList.contains(CLOSED_CLASS)).toBe(true);

      options.toggleButton.dispatchEvent(new Event('click'));
      expect(container.classList.contains(CLOSED_CLASS)).toBe(false);
    });
  });
});
