$(document).ready(function(){
  $('.submit_feedback').on('submit', function(event) {
    var valid = true;
    var id = $(event.target).attr('id');
    var form = $(event.target);

    $('select[form="'+ id +'"]').each(function() {
      if ($(this).val() == '') {
        valid = false;
        if (!$(this).hasClass('govuk-input--error')) {
          $(this).addClass('govuk-input--error');
          $(this).wrap("<div class='govuk-form-group--error'></div>");
          text = form.data('optionNotSelectedMessage');
          $(this).parent('div').prepend('<span class="govuk-error-message">'+ '<span class="govuk-visually-hidden">' + 'Error:' +'</span>' + text + '</span>')
        }
      } else {
        $(this).removeClass('govuk-input--error');
        $(this).parents('div').children('span').remove();
        if($(this).parents('div').hasClass('govuk-form-group--error')){
          $(this).unwrap();
        }
      }
    })

    return valid;
  })
});
