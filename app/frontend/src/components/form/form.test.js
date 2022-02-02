/**
 * @jest-environment jsdom
 */
import { Application } from 'stimulus';

import FormController from './form';

const initialiseStimulus = () => {
  const application = Application.start();
  application.register('form', FormController);
};

let inputEl;
let submitHandlerMock;
let clearHandlerMock;

describe('form auto submit', () => {
  beforeEach(() => {
    initialiseStimulus();
    document.body.innerHTML = '<form data-controller=\'form\'><input type=\'checkbox\' data-action=\'change->form#submitListener\' /></form>';

    [inputEl] = document.getElementsByTagName('input');

    FormController.prototype.submitHandler = jest.fn();
    submitHandlerMock = jest.spyOn(FormController.prototype, 'submitHandler');
  });

  describe('when input element changes', () => {
    test('submitHandler should be called', () => {
      inputEl.click();
      expect(submitHandlerMock).toHaveBeenCalled();
    });
  });
});

describe('form clear', () => {
  beforeEach(() => {
    initialiseStimulus();
    document.body.innerHTML = '<form data-controller=\'form\'><input type=\'text\' data-form-target=\'inputText\' />'
    + '<input type=\'radio\' data-action=\'click->form#clearListener\' id=\'test-radio-button\' /></form>';

    [inputEl] = [document.getElementById('test-radio-button')];

    FormController.prototype.clearHandler = jest.fn();
    clearHandlerMock = jest.spyOn(FormController.prototype, 'clearHandler');
  });

  describe('when radio button clicked', () => {
    test('clearHandler should be called', () => {
      inputEl.click();
      expect(clearHandlerMock).toHaveBeenCalled();
    });
  });
});
