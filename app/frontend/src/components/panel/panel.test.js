import panel, {
  toggleButtonText,
  isPanelClosed,
  togglePanel,
  HIDDEN_CLASS,
} from './panel';

describe('panel', () => {
  document.body.innerHTML = '<div id="panel-container"></div><button id="toggle-button">original text</button>';

  const HIDE_BUTTON_TEXT = 'Hide panel';
  const SHOW_BUTTON_TEXT = 'Show panel';
  const container = document.getElementById('panel-container');
  const button = document.getElementById('toggle-button');
  let options = null;

  beforeEach(() => {
    jest.resetAllMocks();

    options = {
      container,
      toggleButton: button,
      hideText: HIDE_BUTTON_TEXT,
      showText: SHOW_BUTTON_TEXT,
      toggleClass: HIDDEN_CLASS,
      onToggleHandler: jest.fn(),
      onClosedHandler: jest.fn(),
      onOpenedHandler: jest.fn(),
    };
  });

  describe('togglePanel', () => {
    test('calls toggle handler when button is clicked', () => {
      const toggleMock = jest.spyOn(options, 'onToggleHandler');
      togglePanel(options);
      options.toggleButton.dispatchEvent(new Event('click'));
      expect(toggleMock).toHaveBeenCalled();
    });

    test('toggles supplied class when button is clicked', () => {
      options.toggleButton.dispatchEvent(new Event('click'));
      expect(container.classList.contains(HIDDEN_CLASS)).toBe(true);

      options.toggleButton.dispatchEvent(new Event('click'));
      expect(container.classList.contains(HIDDEN_CLASS)).toBe(false);
    });

    test('sets the correct initial state of the panel', () => {
      panel.isInitialStateOpen = jest.fn(() => true);
      panel.openPanel = jest.fn();
      const openPanelMock = jest.spyOn(panel, 'openPanel');
      togglePanel(options);
      expect(openPanelMock).toHaveBeenCalledWith(options);

      panel.isInitialStateOpen = jest.fn(() => false);
      panel.closePanel = jest.fn();
      const closePanelMock = jest.spyOn(panel, 'closePanel');
      togglePanel(options);
      expect(closePanelMock).toHaveBeenCalledWith(options);
    });
  });

  describe('toggleButtonText', () => {
    test('changes button text to hide panel text when panel is visible', () => {
      toggleButtonText(options);
      expect(button.innerHTML).toBe(HIDE_BUTTON_TEXT);
      expect(isPanelClosed(container)).toBe(false);
    });
    test('changes button text to show panel text when panel is hidden', () => {
      container.classList.toggle(HIDDEN_CLASS);
      toggleButtonText(options);
      expect(button.innerHTML).toBe(SHOW_BUTTON_TEXT);
      expect(isPanelClosed(container)).toBe(true);
    });
  });
});
