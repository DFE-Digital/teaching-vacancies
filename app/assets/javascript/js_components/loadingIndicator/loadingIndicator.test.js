/**
 * @jest-environment jsdom
 */

import loader, { CLASS_NAME } from './loadingIndicator';

let targetEl;

describe('loader', () => {
  beforeEach(() => {
    document.body.innerHTML = '<div id="container"></div>';
    targetEl = document.getElementById('container');
  });

  describe('add', () => {
    test('inserts loading animation next to target element', () => {
      loader.add(targetEl);
      expect(targetEl.getElementsByClassName(CLASS_NAME).length).toEqual(1);
    });
  });

  describe('remove', () => {
    test('removes loading animation from target element', () => {
      loader.add(targetEl);
      loader.remove();
      expect(targetEl.getElementsByClassName(CLASS_NAME).length).toEqual(0);
    });
  });
});
