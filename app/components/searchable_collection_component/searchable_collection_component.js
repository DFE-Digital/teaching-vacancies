import '../../frontend/src/lib/polyfill/closest.polyfill';
import '../../frontend/src/lib/polyfill/from.polyfill';

export const searchableClassNames = ['govuk-checkboxes__input', 'govuk-radios__input'];

export const init = (container, classNames) => {
  let collection = [];

  classNames.forEach((className) => {
    collection = collection.concat(Array.from(container.getElementsByClassName(className)));
  });

  const input = container.getElementsByClassName('searchable-collection-component__search-input')[0];

  input.addEventListener('keydown', () => {
    collection.forEach((item) => {
      item.removeAttribute('aria-setsize');
      item.removeAttribute('aria-posinset');
    });
  });

  input.addEventListener('keyup', (e) => {
    filterCollection(collection, e.target);

    const visibleItems = collection.filter((item) => item.parentElement.style.display === 'block');

    Array.from(container.getElementsByClassName('govuk-checkboxes')).forEach((el) => {
      el.setAttribute('role', 'listbox');
      el.id = 'subjects__listbox';
    });

    visibleItems.forEach((item, i) => {
      item.setAttribute('aria-posinset', i + 1);
      item.setAttribute('aria-setsize', visibleItems.length);
    });

    if (e.target.value.length) {
      container.querySelector('.collection-match').innerHTML = `${visibleItems.length} subjects match ${e.target.value}`;
    } else {
      container.querySelector('.collection-match').innerHTML = '';
    }
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
  item.parentElement.setAttribute('role', 'option');

  if (substringExistsInString(getStringForMatch(item), input.value)) {
    item.parentElement.style.display = 'block';
  } else {
    item.parentElement.style.display = 'none';
  }
};

window.addEventListener('DOMContentLoaded', () => {
  const groups = document.getElementsByClassName('searchable-collection-component');
  if (groups.length) {
    Array.from(groups).filter((group) => group.getElementsByClassName('searchable-collection-component__search-input').length).forEach((group) => init(group, searchableClassNames));
  }
});
