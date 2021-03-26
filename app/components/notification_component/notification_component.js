import '../../frontend/src/lib/polyfill/closest.polyfill';
import '../../frontend/src/lib/polyfill/remove.polyfill';

const CTA_LINK_CLASS = 'js-dismissible__link';
const DISMISSIBLE_ELEMENT_SELECTOR = '.js-dismissible';

document.addEventListener('click', (e) => {
  if (e.target.classList.contains(CTA_LINK_CLASS)) {
    const dismissibleEl = e.target.closest(DISMISSIBLE_ELEMENT_SELECTOR);
    dismissibleEl.style.opacity = '0';

    dismissibleEl.addEventListener('transitionend', () => {
      if (dismissibleEl.closest('.govuk-main-wrapper__notification')) {
        dismissibleEl.closest('.govuk-main-wrapper__notification').remove();
      }

      dismissibleEl.remove();
    });
  }
});
