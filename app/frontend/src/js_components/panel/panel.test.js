/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';
import PanelController, {
  COMPONENT_CLASS,
  TOGGLE_ELEMENT_CLASS,
  CONTENT_ELEMENT_CLASS,
  CLOSE_ELEMENT_CLASS,
  PANEL_VISIBLE_CLASS,
} from './panel';

const application = Application.start();

application.register('panel', PanelController);

describe('panel', () => {
  document.body.innerHTML = `<div class="${COMPONENT_CLASS}" data-controller="panel" data-content-id="some-content" data-close-container="content-container">
  <button data-action="panel#toggleVisibility" class="${TOGGLE_ELEMENT_CLASS}" data-panel-target="toggle">panel toggle</button>
  </div>
  <div class="${CONTENT_ELEMENT_CLASS}" tabindex="-1" data-panel-target="content" id="some-content">
  <div class="content-container"></div>
</div>`;

  let container;
  let openButton;
  let closeButton;

  beforeAll(() => {
    [container] = document.getElementsByClassName(CONTENT_ELEMENT_CLASS);
    [openButton] = document.getElementsByClassName(TOGGLE_ELEMENT_CLASS);
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
