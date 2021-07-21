/**
 * @jest-environment jsdom
 */
import form from './form';

describe('form', () => {
  describe('toggling inputs', () => {
    let textField;

    beforeEach(() => {
      document.body.innerHTML = '<div> <input id="test-text-input" type="text" value="10" /> <input id="test-checkbox" type="checkbox"/> </div>';
      textField = document.getElementById('test-text-input');
    });

    describe('disableInputs', () => {
      beforeEach(() => {
        form.disableInputs(Array.from(document.querySelectorAll('input[type="text"]')));
      });

      test('removes the value from the input element', () => {
        expect(textField.value).toBe('');
      });

      test('disables the input element', () => {
        expect(textField.disabled).toBe(true);
      });
    });

    describe('enableInputs', () => {
      beforeEach(() => {
        form.enableInputs(Array.from(document.querySelectorAll('input[type="text"]')));
      });

      test('restores the original value of the input element', () => {
        expect(textField.value).toBe('10');
      });

      test('enables the input element', () => {
        expect(textField.disabled).toBe(false);
      });
    });
  });

  describe('clear form', () => {
    let clearContainer;

    beforeEach(() => {
      document.body.innerHTML = '<div class="clear-form"> <input id="test-text-input" type="text"/> <input id="test-checkbox" type="checkbox"/> </div>';
      clearContainer = document.querySelector('.clear-form');
    });

    describe('when checkbox is checked', () => {
      test('calls disableInputs', () => {
        form.disableInputs = jest.fn();
        const disableInputsMock = jest.spyOn(form, 'disableInputs');
        form.checkboxClickHandler(clearContainer, true);
        expect(disableInputsMock).toHaveBeenCalledWith(Array.from(document.querySelectorAll('input[type="text"]')));
      });
    });

    describe('when checkbox is not checked', () => {
      test('calls enablesInputs', () => {
        form.enableInputs = jest.fn();
        const enableInputsMock = jest.spyOn(form, 'enableInputs');
        form.checkboxClickHandler(clearContainer, false);
        expect(enableInputsMock).toHaveBeenCalledWith(Array.from(document.querySelectorAll('input[type="text"]')));
      });
    });
  });
});
