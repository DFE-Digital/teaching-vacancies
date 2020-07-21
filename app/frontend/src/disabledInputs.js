/* eslint-disable */
document.addEventListener('DOMContentLoaded', () => {
  const allInputs = document.querySelectorAll('input');
  const textAreaInputs = document.querySelectorAll('textarea.govuk-textarea');
  const submitInput = document.querySelector('input[type="submit"].disabled-on-load');

  if (allInputs && submitInput) {
    submitInput.disabled = true;

    const inputArray = [];
    Array.prototype.push.apply(inputArray, allInputs);

    inputArray.forEach((input) => {
      input.addEventListener('input', () => {
        if (submitInput.disabled) {
          submitInput.disabled = false;
        }
      });
    });
  }

  if (textAreaInputs && submitInput) {
    submitInput.disabled = true;

    const textAreaInputArray = [];
    Array.prototype.push.apply(textAreaInputArray, textAreaInputs);

    textAreaInputArray.forEach((input) => {
      input.addEventListener('input', () => {
        if (submitInput.disabled) {
          submitInput.disabled = false;
        }
      });
    });
  }
});
