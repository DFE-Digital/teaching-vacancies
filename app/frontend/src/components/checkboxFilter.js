import '../lib/polyfill/closest.polyfill';
import '../lib/polyfill/from.polyfill';

export const init = (container) => {
  const checkboxes = container.getElementsByClassName('govuk-checkboxes__input');
  const input = container.getElementsByClassName('search-input__input')[0];

  input.addEventListener('input', (e) => {
    filterCheckboxes(checkboxes, e.target);
  });

  input.addEventListener('click', (e) => {
    e.stopPropagation();
  });
};

export const filterCheckboxes = (checkboxes, input) => Array.from(checkboxes).forEach((checkbox) => checkboxDisplay(checkbox, input));

export const substringExistsInString = (original, input) => original.toUpperCase().indexOf(input.toUpperCase()) > -1;

export const getStringForMatch = (checkbox) => {
  let matchString = '';

  if (checkbox.nextSibling) {
    matchString = checkbox.nextSibling.innerHTML;
  }

  return `${checkbox.value}${matchString}`;
};

export const checkboxDisplay = (checkbox, input) => {
  if (substringExistsInString(getStringForMatch(checkbox), input.value)) {
    checkbox.parentElement.style.display = 'block';
  } else {
    checkbox.parentElement.style.display = 'none';
  }
};

window.addEventListener('DOMContentLoaded', () => {
  const groups = document.getElementsByClassName('tv-checkbox__group');
  if (groups.length) {
    Array.from(groups).filter((group) => group.getElementsByClassName('search-input').length).forEach((group) => init(group));
  }
});
