/**
 * @jest-environment jsdom
 */

import { readFileSync } from 'fs';
import path from 'path';

import { Application } from '@hotwired/stimulus';
import PanelController, {
  TOGGLE_ELEMENT_CLASS,
  CONTENT_ELEMENT_CLASS,
  CLOSE_ELEMENT_CLASS,
  PANEL_VISIBLE_CLASS,
} from './panel';

const htmlPath = path.join(__dirname, 'test_html/PanelComponent.test.html');
const testHTML = readFileSync(htmlPath);

const application = Application.start();

application.register('panel', PanelController);

describe('panel', () => {
  document.body.innerHTML = testHTML;

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
