import { renderSearchBox } from './input';
import { updateUrlQueryParams } from '../../lib/utils';
import { enableSubmitButton } from './form';

jest.mock('../../lib/utils');
jest.mock('./form');

describe('renderSearchBox', () => {
  let inputParams = {};
  let onSubmitMock = null;

  beforeEach(() => {
    jest.resetAllMocks();

    document.body.innerHTML = '<form id="test-container"><input id="test-input" type="text" /><input type="submit" disabled /></form>';

    inputParams = {
      key: 'location',
      container: document.getElementById('test-container'),
      inputElement: document.getElementById('test-input'),
      onSubmit: jest.fn(),
    };

    updateUrlQueryParams.mockReturnValue(true);
    enableSubmitButton.mockReturnValue(true);

    onSubmitMock = jest.spyOn(inputParams, 'onSubmit');

    renderSearchBox({
      widgetParams: inputParams,
    }, true);
  });

  test('calls on submit handler and update url with correct params', () => {
    inputParams.inputElement.value = 'london';
    const event = new Event('submit');
    inputParams.container.dispatchEvent(event);

    expect(onSubmitMock).toHaveBeenCalledWith('london');
    expect(updateUrlQueryParams).toHaveBeenCalledWith(inputParams.key, 'london', 'http://localhost/');
  });

  test('change event enables submit button', () => {
    const event = new Event('change');
    inputParams.inputElement.dispatchEvent(event);

    expect(enableSubmitButton).toHaveBeenCalledWith(inputParams.container);
  });

  test('input event enables submit button', () => {
    const event = new Event('input');
    inputParams.inputElement.dispatchEvent(event);

    expect(enableSubmitButton).toHaveBeenCalledWith(inputParams.container);
  });
});
