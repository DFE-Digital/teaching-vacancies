import '../../../frontend/src/lib/polyfill/closest.polyfill';
import '../../../frontend/src/lib/polyfill/remove.polyfill';

const CTA_LINK_CLASS = 'js-dismissable__link';
const DISMISSIBLE_ELEMENT_SELECTOR = '.js-dismissable';

document.addEventListener('click', (e) => {
  if (e.target.classList.contains(CTA_LINK_CLASS)) {
    const dismissibleEl = e.target.closest(DISMISSIBLE_ELEMENT_SELECTOR);
    dismissibleEl.style.opacity = '0';

    dismissibleEl.addEventListener('transitionend', () => {
      dismissibleEl.remove();
    });
  }
});
