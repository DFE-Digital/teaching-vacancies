const FORM_ELEMENT_ERROR_CLASS = 'govuk-input--error';

document.addEventListener('DOMContentLoaded', () => {
  if (document.querySelector('.expired__vacancy-form')) {
    Array.from(document.getElementsByClassName('vacancy-feedback__form')).forEach((form) => {
      form.addEventListener('submit', (event) => {
        Array.from(document.querySelectorAll(`select[form="${event.target.id}"]`)).forEach((select) => {
          if (select.value === '') {
            if (!formElementHasError(select)) {
              formElementAddError(select, event.target.dataset.optionNotSelectedMessage);
            }
            event.preventDefault();
          } else {
            formElementRemoveError(select);
          }
        });
      });
    });

    Array.from(document.getElementsByTagName('select')).forEach((select) => {
      select.addEventListener('change', () => {
        Array.from(select.closest('tr').getElementsByTagName('input')).forEach((input) => { input.disabled = false; });
      });
    });
  }
});

const formElementHasError = (formEl) => formEl.classList.contains(FORM_ELEMENT_ERROR_CLASS);

const formElementAddError = (formEl, errorMessage) => {
  formEl.parentNode.classList.add('govuk-form-group--error');
  formEl.parentNode.style.paddingLeft = '15px';
  formEl.parentNode.insertAdjacentHTML('afterbegin', `
<span class="govuk-error-message">
<span class="govuk-visually-hidden">Error:</span>
${errorMessage}
</span>`);
  return formEl.classList.add(FORM_ELEMENT_ERROR_CLASS);
};

const formElementRemoveError = (formEl) => {
  Array.from(formEl.parentNode.getElementsByClassName('govuk-error-message')).forEach((error) => error.remove());
  formEl.parentNode.classList.remove('govuk-form-group--error');
  return formEl.classList.remove(FORM_ELEMENT_ERROR_CLASS);
};
