import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  connect() {
    this.handleMobilePageFocus();
  }

  static detectMobile() {
    return /iPhone|iPad|iPod|Android/i.test(navigator.userAgent);
  }

  handleMobilePageFocus() {
    if (!this.detectMobile()) {
      return;
    }

    if (window.location.href.includes('profile/personal-details')) {
      const skipLinkElement = document.getElementsByClassName('govuk-skip-link');

      if (skipLinkElement && skipLinkElement.length > 0) {
        skipLinkElement[0].focus();
        document.activeElement.blur();
      }
    }
  }
}
