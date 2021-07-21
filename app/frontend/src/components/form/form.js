document.addEventListener('DOMContentLoaded', () => {
  Array.from(document.getElementsByClassName('clear-form')).forEach((el) => {
    el.querySelector('input[type="checkbox"]').addEventListener('click', (event) => {
      checkboxClickHandler(el, event.target.checked);
    });
  });

  Array.from(document.querySelectorAll('[data-auto-submit="true"]')).forEach((el) => {
    el.addEventListener('change', (e) => {
      ['govuk-select', 'govuk-checkboxes__input'].forEach((selector) => {
        if (e.target.classList.contains(selector) && e.target.dataset.changeSubmit !== 'false') {
          changeHandler(e.target.closest('form'));
        }
      });
    });
  });
});

export const changeHandler = (formEl) => {
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
};

export default form;
