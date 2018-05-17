$(document).ready(function() {

  var customMessages = {
    valueMissing: 'Please fill out this field',
    emailMismatch: 'Custom email mismatch',
    patternMismatch: 'Custom pattern mismatch'
    // rangeUnderflow: `Must be at least 22917`,
    // rangeOverflow: 'Must not be more than 200000'
  }

  function getCustomMessage(type, validity) {
    if (validity.typeMismatch) {
      return customMessages[`${type}Mismatch`]
    } else {
      for (var invalidKey in customMessages) {
        if (validity[invalidKey]) {
          return customMessages[invalidKey]
        }
      }
    }
  }

  var inputs = $('input, select, textarea')

  inputs.each(function(input) {

    function checkValidity() {
      var message = this.validity.valid ?
        null :
        getCustomMessage(this.type, this.validity, customMessages)
      this.setCustomValidity(message || '')
    }
    $(this).on('input', checkValidity)
    $(this).on('invalid', checkValidity)
  })

});
