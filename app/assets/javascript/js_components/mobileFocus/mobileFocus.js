import { Controller } from '@hotwired/stimulus';

export default class MobileFocusController extends Controller {
  connect() {
    this.handleMobilePageFocus();
  }

  static detectMobile() {
    return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
  }

  handleMobilePageFocus() {
    if (!this.constructor.detectMobile()) {
      return;
    }

    window.onbeforeunload = () => {
      window.scrollTo(0, 0);
    };

    if (window.location.href.includes('profile/personal-details')) {
      const skipLinkElement = document.querySelector('.govuk-skip-link');

      if (skipLinkElement && skipLinkElement.length > 0) {
        skipLinkElement[0].focus();
        document.activeElement.blur();
      }
    }
  }
}
