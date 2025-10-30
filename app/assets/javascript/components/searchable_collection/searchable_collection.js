import { Controller } from '@hotwired/stimulus';

const SearchableCollectionComponent = class extends Controller {
  static targets = ['input'];

  static searchableClassNames = ['govuk-checkboxes__input', 'govuk-radios__input'];

  connect() {
    this.collection = [];
    SearchableCollectionComponent.searchableClassNames.forEach((className) => {
      this.collection = this.collection.concat(Array.from(this.element.getElementsByClassName(className)));
    });
  }

  input() {
    this.collection.forEach((item) => {
      item.removeAttribute('aria-setsize');
      item.removeAttribute('aria-posinset');
    });

    this.filterCollection();

    const visibleItems = this.collection.filter((item) => item.parentElement.style.display === 'block');

    visibleItems.forEach((item, i) => {
      item.setAttribute('aria-posinset', i + 1);
      item.setAttribute('aria-setsize', visibleItems.length);
    });

    if (this.inputTarget.value.length) {
      this.element.querySelector('.collection-match').innerHTML = `${visibleItems.length} subjects match ${this.inputTarget.value}`;
    } else {
      this.element.querySelector('.collection-match').innerHTML = '';
    }
  }

  filterCollection() {
    return Array.from(this.collection).forEach((item) => this.itemDisplay(item));
  }

  itemDisplay(item) {
    if (SearchableCollectionComponent.substringExistsInString(SearchableCollectionComponent.getStringForMatch(item), this.inputTarget.value)) {
      item.parentElement.style.display = 'flex';
    } else {
      item.parentElement.style.display = 'none';
    }
  }

  static substringExistsInString = (original, input) => original.toUpperCase().indexOf(input.toUpperCase()) > -1;

  static getStringForMatch = (item) => {
    let matchString = '';

    if (item.nextSibling) {
      matchString = item.nextSibling.innerHTML;
    }

    return `${item.value}${matchString}`;
  };
};

export default SearchableCollectionComponent;
