export const CHECKBOX_CLASS = 'govuk-checkboxes__input';
export const RADIO_CLASS = 'govuk-radios__input';
export const SELECT_CLASS = 'govuk-select';
export const CLEARFORM_CLASS = 'clear-form';
export const AUTOSUBMIT_ATTR_KEY = 'auto-submit';

document.addEventListener('DOMContentLoaded', () => {
  initClearForm();
  initAutoSubmit();
});

export const initClearForm = () => {
  Array.from(document.getElementsByClassName(CLEARFORM_CLASS)).forEach((clearFormEl) => {
    Array.from(clearFormEl.querySelectorAll(`.${RADIO_CLASS}`)).forEach((controlEl) => {
      controlEl.addEventListener('click', (event) => {
        form.checkboxClickHandler(clearFormEl, event.target.checked);
      });
    });
  });
};

export const initAutoSubmit = () => {
  Array.from(document.querySelectorAll(`[data-${AUTOSUBMIT_ATTR_KEY}="true"]`)).forEach((formEl) => {
    Array.from(formEl.querySelectorAll(`.${SELECT_CLASS}, .${CHECKBOX_CLASS}`)).forEach((el) => {
      el.addEventListener('change', (e) => {
        if (e.target.dataset.changeSubmit !== 'false') {
          form.formSubmit(e.target.closest('form'));
        }
      });
    });
  });
};

export const formSubmit = (formEl) => {
  if (formEl.dataset.autoSubmit) {
    formEl.submit();
  }
};

export const disableInputs = (inputs) => {
  inputs.forEach((input) => {
    input.value = '';
  });
};

export const enableInputs = (inputs) => {
  inputs.forEach((input) => {
    input.disabled = false;
    input.value = input.getAttribute('value');
  });
};

export const checkboxClickHandler = (element, checked) => {
  const fields = Array.from(element.querySelectorAll('input[type="text"]'));
  if (checked) {
    form.disableInputs(fields);
  } else {
    form.enableInputs(fields);
  }
};

const form = {
  disableInputs,
  enableInputs,
  checkboxClickHandler,
  formSubmit,
  CHECKBOX_CLASS,
  SELECT_CLASS,
  CLEARFORM_CLASS,
  AUTOSUBMIT_ATTR_KEY,
};

export default form;
