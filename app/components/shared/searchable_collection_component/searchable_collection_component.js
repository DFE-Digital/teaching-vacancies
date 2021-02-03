import '../../../frontend/src/lib/polyfill/closest.polyfill';
import '../../../frontend/src/lib/polyfill/from.polyfill';

export const searchableClassNames = ['govuk-checkboxes__input', 'govuk-radiobuttons__input'];

export const init = (container, classNames) => {
  let collection = [];

  classNames.forEach((className) => {
    collection = collection.concat(Array.from(container.getElementsByClassName(className)));
  });

  const input = container.getElementsByClassName('collection-component__search-input')[0];

  input.addEventListener('input', (e) => {
    filterCollection(collection, e.target);
  });

  input.addEventListener('click', (e) => {
    e.stopPropagation();
  });
};

export const filterCollection = (collection, input) => Array.from(collection).forEach((item) => itemDisplay(item, input));

export const substringExistsInString = (original, input) => original.toUpperCase().indexOf(input.toUpperCase()) > -1;

export const getStringForMatch = (item) => {
  let matchString = '';

  if (item.nextSibling) {
    matchString = item.nextSibling.innerHTML;
  }

  return `${item.value}${matchString}`;
};

export const itemDisplay = (item, input) => {
  if (substringExistsInString(getStringForMatch(item), input.value)) {
    item.parentElement.style.display = 'block';
  } else {
    item.parentElement.style.display = 'none';
  }
};

window.addEventListener('DOMContentLoaded', () => {
  const groups = document.getElementsByClassName('collection-component');
  if (groups.length) {
    Array.from(groups).filter((group) => group.getElementsByClassName('collection-component__search-input').length).forEach((group) => init(group, searchableClassNames));
  }
});
