document.addEventListener('DOMContentLoaded', () => {
  Array.from(document.getElementsByClassName('clear-form')).forEach((el) => {
    el.querySelector('input[type="checkbox"]').addEventListener('click', (event) => {
      checkboxClickHandler(el, event.target.checked);
    });
  });

  Array.from(document.querySelectorAll('[data-auto-submit="true"]')).forEach((el) => {
    Array.from(el.querySelectorAll('.govuk-select')).forEach((select) => {
      select.addEventListener('change', (e) => {
        e.target.closest('form').submit();
      });
    });
  });
});

export const disableInputs = (inputs) => {
  inputs.forEach((input) => {
    input.disabled = true;
    input.value = '';
  });
};

export const enableInputs = (inputs) => {
  inputs.forEach((input) => {
    input.disabled = false;
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
};

export default form;
