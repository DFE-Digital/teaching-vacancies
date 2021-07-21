document.addEventListener('DOMContentLoaded', () => {
  initClearForm();
  initAutoSubmit();
});

export const initClearForm = () => {
  Array.from(document.getElementsByClassName('clear-form')).forEach((el) => {
    el.querySelector('input[type="checkbox"]').addEventListener('click', (event) => {
      form.checkboxClickHandler(el, event.target.checked);
    });
  });
};

export const initAutoSubmit = () => {
  Array.from(document.querySelectorAll('[data-auto-submit="true"]')).forEach((formEl) => {
    Array.from(formEl.querySelectorAll('.govuk-select, .govuk-checkboxes__input')).forEach((el) => {
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
    input.disabled = true;
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
};

export default form;
