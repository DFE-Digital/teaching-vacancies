import form from './form';

describe('form', () => {
  document.body.innerHTML = '<div class="clear-form"> <input id="test-text-input" type="text"/> <input id="test-checkbox" type="checkbox"/> </div>';
  const textField = document.querySelector('#test-text-input');
  textField.value = '01';
  const fields = Array.from(document.querySelectorAll('input[type="text"]'));

  describe('toggling inputs', () => {
    beforeEach(() => {
      form.disableInputs(fields);
    });

    describe('disableInputs', () => {
      test('removes the value from the input element', () => {
        expect(document.querySelector('#test-text-input').value).toBe('');
      });

      test('disables the input element', () => {
        expect(document.querySelector('#test-text-input').disabled).toBe(true);
      });
    });

    describe('enableInputs', () => {
      beforeEach(() => {
        form.enableInputs(fields);
        textField.value = '01';
      });

      test('allows for a value to be added to the input element', () => {
        expect(document.querySelector('#test-text-input').value).toBe('01');
      });

      test('enables the input element', () => {
        expect(document.querySelector('#test-text-input').disabled).toBe(false);
      });
    });
  });

  describe('checkboxClickHandler', () => {
    const formElement = document.querySelector('.clear-form');

    describe('when checkbox is checked', () => {
      test('calls disableInputs', () => {
        form.disableInputs = jest.fn();
        const disableInputsMock = jest.spyOn(form, 'disableInputs');
        form.checkboxClickHandler(formElement, true);
        expect(disableInputsMock).toHaveBeenCalled();
      });
    });

    describe('when checkbox is not checked', () => {
      test('calls enablesInputs', () => {
        form.enableInputs = jest.fn();
        const enableInputsMock = jest.spyOn(form, 'enableInputs');
        form.checkboxClickHandler(formElement, false);
        expect(enableInputsMock).toHaveBeenCalled();
      });
    });
  });
});
