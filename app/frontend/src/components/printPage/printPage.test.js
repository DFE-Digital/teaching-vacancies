import printPage, { initTriggerElements, addTriggerEvent } from './printPage';

describe('printPage', () => {
  document.body.innerHTML = '<button id="print-me">print</button>';

  const button = document.getElementById('print-me');

  beforeEach(() => {
    jest.resetAllMocks();
  });

  test('calls addTriggerEvent', () => {
    printPage.addTriggerEvent = jest.fn();
    const triggerMock = jest.spyOn(printPage, 'addTriggerEvent');
    initTriggerElements('#print-me');
    expect(triggerMock).toHaveBeenCalled();
  });

  test('calls printHandler when trigger element clicked', () => {
    printPage.printHandler = jest.fn();

    const handlerMock = jest.spyOn(printPage, 'printHandler');
    addTriggerEvent(button);
    button.dispatchEvent(new Event('click'));
    expect(handlerMock).toHaveBeenCalled();
  });
});
