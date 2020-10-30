// document.addEventListener('DOMContentLoaded', () => {
//   $('.submit_feedback').on('submit', (event) => {
//     let valid = true;
//     const id = $(event.target).attr('id');
//     const form = $(event.target);

//     $(`select[form="${id}"]`).each(function () {
//       if ($(this).val() == '') {
//         valid = false;
//         if (!$(this).hasClass('govuk-input--error')) {
//           $(this).addClass('govuk-input--error');
//           $(this).wrap('<div class=\'govuk-form-group--error\'></div>');
//           const text = form.data('optionNotSelectedMessage');
//           $(this).parent('div').prepend(`${'<span class="govuk-error-message">' + '<span class="govuk-visually-hidden">' + 'Error:' + '</span>'}${text}</span>`);
//         }
//       } else {
//         $(this).removeClass('govuk-input--error');
//         $(this).parents('div').children('span').remove();
//         if ($(this).parents('div').hasClass('govuk-form-group--error')) {
//           $(this).unwrap();
//         }
//       }
//     });

//     return valid;
//   });
// });

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
