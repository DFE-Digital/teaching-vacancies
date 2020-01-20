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

  $('.submit_feedback').on('ajax:success', function(event) {
    var form = $(event.target);
    var notification = $('.notification');
    var count = Number(notification.text()) - 1;
    var table = $('table.vacancies')
    var notice = $('#awaiting_notice')
    var notice_count = notice.find('.count');
    var feedback_intro = $('#awaiting_feedback_intro')

    if (count > 0) {
      row = form.parents('tr');
      if (count == 1) {
        notice_count.text('1 job');
      } else {
        notice_count.text(count + ' jobs');
      }
      notification.text(count);
      text = form.data('successMessage');
      row.html('<td class="govuk-table__cell" colspan="6">'+ text +'</td>');
      row.fadeOut(3000, function() {
        $(this).remove();
      })
    } else {
      notification.remove();
      notice.remove();
      table.remove();
      feedback_intro.remove();
      text = form.data('allSubmittedMessage');
      $('section.govuk-tabs__panel').append('<p class="govuk-body govuk-!-font-size-19">' + text + '</p>');
    }
  });
});
