

export const init = (container) => {
  const checkboxes = container.getElementsByClassName('govuk-checkboxes__input');
  const input = container.getElementsByClassName('search-input__input')[0];

  input.addEventListener('input', (e) => {
    filterCheckboxes(checkboxes, e.target);
  });

  input.addEventListener('change', (e) => {
    filterCheckboxes(checkboxes, e.target);
  });
}

export const filterCheckboxes = (checkboxes, input) => Array.from(checkboxes).map(checkbox => checkboxDisplay(checkbox, input));

export const stringExistsInString = (original, input) => original.toUpperCase().indexOf(input.toUpperCase()) > -1;

export const checkboxDisplay = (checkbox, input) => {
  if (stringExistsInString(checkbox.value, input.value)) {
    checkbox.parentElement.style.display = 'block';
  } else {
    checkbox.parentElement.style.display = 'none';
  }
}

window.addEventListener('DOMContentLoaded', () => {
  init(document.getElementsByClassName('accordion-content__group')[0]);
});
