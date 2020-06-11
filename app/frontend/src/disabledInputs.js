document.addEventListener('DOMContentLoaded', function() {
  var allInputs = document.querySelectorAll('input');
  var textAreaInputs = document.querySelectorAll('textarea.govuk-textarea');
  var submitInput = document.querySelector('input[type="submit"].update-listing-gtm');

  if (allInputs && submitInput) {
    submitInput.disabled = true;

    var inputArray = [];
    Array.prototype.push.apply(inputArray, allInputs);

    inputArray.forEach(function(input) {
      input.addEventListener('input', function() {
        if (submitInput.disabled) {
          submitInput.disabled = false;
        }
      });
    });
  }

  if (textAreaInputs && submitInput) {
    submitInput.disabled = true;

    var textAreaInputArray = [];
    Array.prototype.push.apply(textAreaInputArray, textAreaInputs);

    textAreaInputArray.forEach(function(input) {
      input.addEventListener('input', function() {
        if (submitInput.disabled) {
          submitInput.disabled = false;
        }
      });
    });
  }
});
