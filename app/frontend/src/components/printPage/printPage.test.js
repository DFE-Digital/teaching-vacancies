import printPage, { initTriggerElements, addTriggerEvent } from './printPage';

describe('printPage', () => {
  document.body.innerHTML = '<button id="print-me">print</button>';

  const button = document.getElementById('print-me');

  beforeEach(() => {
    jest.resetAllMocks();
  });

  test('calls toggle handler when button is clicked', () => {
    printPage.addTriggerEvent = jest.fn();
    const toggleMock = jest.spyOn(printPage, 'addTriggerEvent');
    initTriggerElements('#print-me');
    expect(toggleMock).toHaveBeenCalled();
  });

  test('x toggle handler when button is clicked', () => {
    printPage.printHandler = jest.fn();

    const xMock = jest.spyOn(printPage, 'printHandler');
    addTriggerEvent(button);
    button.dispatchEvent(new Event('click'));
    expect(xMock).toHaveBeenCalled();
  });
});
