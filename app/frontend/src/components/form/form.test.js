/**
 * @jest-environment jsdom
 */
import form, {
  initAutoSubmit,
  initClearForm,
  CHECKBOX_CLASS,
  CLEARFORM_CLASS,
  AUTOSUBMIT_ATTR_KEY,
} from './form';

describe('form', () => {
  describe('form auto submit behaviour', () => {
    beforeEach(() => {
      document.body.innerHTML = `<form data-${AUTOSUBMIT_ATTR_KEY}="true">
      <input type="checkbox" class="${CHECKBOX_CLASS}" data-change-submit="false" id="no-submit" />
      <input type="checkbox" class="${CHECKBOX_CLASS}" id="should-submit" />
      </form>`;
    });

    describe('form has auto submit data attribute', () => {
      let formSubmitMock = null;

      beforeEach(() => {
        form.formSubmit = jest.fn();
        formSubmitMock = jest.spyOn(form, 'formSubmit');
        initAutoSubmit();
      });

      test('changing state of an input with data-change-submit="false" attribute does not submit form', () => {
        const event = new Event('change');
        document.getElementById('no-submit').dispatchEvent(event);
        expect(formSubmitMock).not.toHaveBeenCalled();
      });

      test('changing state of an input without data-change-submit="false" attribute does submit form', () => {
        const event = new Event('change');
        document.getElementById('should-submit').dispatchEvent(event);
        expect(formSubmitMock).toHaveBeenCalled();
      });
    });
  });

  describe('toggling inputs', () => {
    let textField;

    beforeEach(() => {
      document.body.innerHTML = `<div class="${CLEARFORM_CLASS}"> <input id="test-text-input" type="text" value="10" /> </div>`;
      textField = document.getElementById('test-text-input');
    });

    describe('disableInputs', () => {
      beforeEach(() => {
        form.disableInputs(Array.from(document.querySelectorAll('input[type="text"]')));
      });

      test('removes the value from the input element', () => {
        expect(textField.value).toBe('');
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
    beforeEach(() => {
      document.body.innerHTML = `<div class="${CLEARFORM_CLASS}"> <input id="test-text-input" type="text" /> <input id="test-checkbox" type="checkbox" class="${CHECKBOX_CLASS}" /> </div>`;
      initClearForm();
    });

    describe('when checkbox is checked', () => {
      test('calls disableInputs', () => {
        form.disableInputs = jest.fn();
        const disableInputsMock = jest.spyOn(form, 'disableInputs');
        form.checkboxClickHandler(document.querySelector(`.${CLEARFORM_CLASS}`), true);
        expect(disableInputsMock).toHaveBeenCalledWith(Array.from(document.querySelectorAll('input[type="text"]')));
      });
    });

    describe('when checkbox is not checked', () => {
      test('calls enablesInputs', () => {
        form.enableInputs = jest.fn();
        const enableInputsMock = jest.spyOn(form, 'enableInputs');
        form.checkboxClickHandler(document.querySelector(`.${CLEARFORM_CLASS}`), false);
        expect(enableInputsMock).toHaveBeenCalledWith(Array.from(document.querySelectorAll('input[type="text"]')));
      });
    });
  });
});
