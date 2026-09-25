/**
 * @jest-environment jsdom
 */
import enablePrintButton from './print';

describe('print button', () => {
  beforeEach(() => {
    document.body.innerHTML = '<button type="button" data-print-button>Print</button>';
    jest.spyOn(window, 'print').mockImplementation(() => {});

    enablePrintButton();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  test('opens the browser print dialog when selected', () => {
    document.querySelector('[data-print-button]').click();

    expect(window.print).toHaveBeenCalledTimes(1);
  });
});
