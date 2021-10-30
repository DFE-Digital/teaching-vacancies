/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';
import PanelController, {
  COMPONENT_CLASS,
  ACTION_ELEMENT_CLASS,
  PANEL_VISIBLE_CLASS,
  CLOSE_ELEMENT_CLASS,
} from './panel';

const application = Application.start();

// Configure Stimulus development experience
// application.warnings = true
// application.debug    = false
// window.Stimulus      = application

application.register('panel', PanelController);

describe('panel', () => {
  document.body.innerHTML = `<div data-controller="panel">
  <button data-action="click->panel#toggle" class="${ACTION_ELEMENT_CLASS}" data-panel-id="test-panel">panel toggle</button>
  <div class="${COMPONENT_CLASS}" tabindex="-1" id="test-panel">
    <button class="${CLOSE_ELEMENT_CLASS}" data-action="click->panel#toggle">close</button>
  </div>
  </div>`;

  let container;
  let openButton;
  let closeButton;

  beforeAll(() => {
    [container] = document.getElementsByClassName(COMPONENT_CLASS);
    [openButton] = document.getElementsByClassName(ACTION_ELEMENT_CLASS);
    [closeButton] = document.getElementsByClassName(CLOSE_ELEMENT_CLASS);
  });

  describe('open panel', () => {
    beforeAll(() => {
      openButton.click();
    });
    test('panel is visible', () => {
      expect(container.classList.contains(PANEL_VISIBLE_CLASS)).toBe(true);
    });

    test('correct a11y', () => {
      expect(container === document.activeElement).toBe(true);
      expect(container.getAttribute('aria-hidden')).toEqual('false');
      expect(openButton.getAttribute('aria-expanded')).toEqual('true');
    });
  });

  describe('close panel', () => {
    beforeAll(() => {
      closeButton.click();
    });
    test('panel is hidden', () => {
      expect(container.classList.contains(PANEL_VISIBLE_CLASS)).toBe(false);
    });

    test('correct a11y', () => {
      expect(openButton === document.activeElement).toBe(true);
      expect(container.getAttribute('aria-hidden')).toEqual('true');
      expect(openButton.getAttribute('aria-expanded')).toEqual('false');
    });
  });
});
