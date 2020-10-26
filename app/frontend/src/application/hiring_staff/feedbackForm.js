/* eslint-disable */
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
  const expired = document.getElementsByClassName('submit_feedback');
  Array.from(expired).map(form => {
    form.addEventListener('submit', (event) => {
      const form = event.target
      const id = event.target.id
      Array.from(document.querySelectorAll(`select[form="${id}"]`)).map(select => {
        if (select.value === '') {
          if (!formElementHasError(select)) {
            formElementAddError(select)
          }
        } else {
          formElementRemoveError(select)
        }
      })
  
      event.preventDefault();

      console.log(form, form.querySelectorAll('input[type="submit"]'))

      //form.querySelectorAll('input[type="submit"]')[0].enabled = true;
    });
  })
});

const formElementHasError = (formEl) => {
  return formEl.classList.contains(FORM_ELEMENT_ERROR_CLASS)
}

const formElementAddError = (formEl) => {
  return formEl.classList.add(FORM_ELEMENT_ERROR_CLASS)
}

const formElementRemoveError = (formEl) => {
  return formEl.classList.remove(FORM_ELEMENT_ERROR_CLASS)
}