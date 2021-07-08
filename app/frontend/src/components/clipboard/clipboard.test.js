/**
 * @jest-environment jsdom
 */

import clipboard, { COPY_CLASS_SELECTOR, init } from './clipboard';

describe('clipboard', () => {
  document.body.innerHTML = `<div>
    <span id="copy-this">some text to copy to clipboard</span>
    <button class="${COPY_CLASS_SELECTOR}" data-target-id="copy-this">copy to clipboard</button>
    </div>`;

  let selectTextMock = null;
  let writeTextMock = null;

  const actionEl = document.getElementsByClassName(COPY_CLASS_SELECTOR)[0];
  const targetEl = document.getElementById('copy-this');

  beforeEach(() => {
    jest.resetAllMocks();

    clipboard.selectText = jest.fn();
    selectTextMock = jest.spyOn(clipboard, 'selectText');

    clipboard.writeText = jest.fn(() => Promise.resolve());
    writeTextMock = jest.spyOn(clipboard, 'writeText');
  });

  describe('togglePanel', () => {
    test('calls toggle handler when button is clicked', () => {
      init(actionEl);
      actionEl.dispatchEvent(new Event('click'));
      expect(selectTextMock).toHaveBeenCalledWith(targetEl);
      expect(writeTextMock).toHaveBeenCalledWith(targetEl.innerHTML);
    });
  });
});
