import { Controller } from '@hotwired/stimulus';

const Filters = class extends Controller {
  static targets = ['clear', 'group'];

  static MOBILE_BREAKPOINT = 768;

  static CHECKBOX_CLASS_SELECTOR = 'govuk-checkboxes__input';

  connect() {
    if (document.documentElement.clientWidth <= Filters.MOBILE_BREAKPOINT) {
      this.mobileBehaviour();
    } else {
      this.desktopBehaviour();
    }

    if (window.matchMedia) {
      const mediaQuery = `(max-width: ${Filters.MOBILE_BREAKPOINT}px)`;
      const mediaQueryList = window.matchMedia(mediaQuery);

      if (mediaQueryList.addEventListener) {
        mediaQueryList.addEventListener('change', (e) => {
          if (e.matches) {
            this.mobileBehaviour();
          } else {
            this.desktopBehaviour();
          }
        });
      }
    }
  }

  remove(e) {
    Filters.unCheckCheckbox(Filters.findCheckboxInGroup(this.getGroupEl(e.target.dataset.group), e.target.dataset.key));
  }

  clear() {
    this.groupTargets.forEach((groupEl) => Filters.getCheckboxesInGroup(groupEl).forEach((checkbox) => Filters.unCheckCheckbox(checkbox)));
  }

  mobileBehaviour() {
    this.element.closest('form').removeAttribute('data-controller');
    this.element.setAttribute('tabindex', '-1');
  }

  desktopBehaviour() {
    this.element.closest('form').setAttribute('data-controller', 'form');
    this.element.removeAttribute('tabindex');
  }

  getGroupEl(groupName) {
    return this.groupTargets.filter((group) => group.dataset.group === groupName)[0];
  }

  static findCheckboxInGroup(groupEl, key) {
    return Filters.getCheckboxesInGroup(groupEl).filter((checkbox) => checkbox.value === key)[0];
  }

  static unCheckCheckbox(checkbox) {
    checkbox.checked = false;
  }

  static getCheckboxesInGroup(groupEl) {
    return Array.from(groupEl.getElementsByClassName(Filters.CHECKBOX_CLASS_SELECTOR));
  }
};

export default Filters;
