import { Controller } from '@hotwired/stimulus';

const FiltersComponent = class extends Controller {
  static MOBILE_BREAKPOINT = 768;

  connect() {
    if (document.documentElement.clientWidth <= FiltersComponent.MOBILE_BREAKPOINT) {
      this.mobileBehaviour();
    } else {
      this.desktopBehaviour();
    }

    if (window.matchMedia) {
      const mediaQuery = `(max-width: ${FiltersComponent.MOBILE_BREAKPOINT}px)`;
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

  mobileBehaviour() {
    this.element.closest('form').removeAttribute('data-controller');
    this.element.setAttribute('tabindex', '-1');
  }

  desktopBehaviour() {
    this.element.closest('form').setAttribute('data-controller', 'form');
    this.element.removeAttribute('tabindex');
  }
};

export default FiltersComponent;
