import './loadingIndicator.scss';

export const CLASS_NAME = 'loading-indicator__spinner';

const loadingIndicator = class {
  static svg = `<svg version="1.1" xmlns="http://www.w3.org/2000/svg" class="${CLASS_NAME}" width="32" height="32" viewBox="-32 -30 64 64" preserveAspectRatio="xMidYMid meet">
    <rect fill="#000" width="12" height="5" transform="rotate(0, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(30, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(60, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(90, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(120, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(150, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(180, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(210, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(240, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(270, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(300, 0, 2) translate(10 0)" opacity="0.3"></rect>
    <rect fill="#000" width="12" height="5" transform="rotate(330, 0, 2) translate(10 0)" opacity="0.3"></rect>
    </svg>`;

  static element;

  static add(targetEl) {
    targetEl.insertAdjacentHTML('beforeend', loadingIndicator.svg);
    [loadingIndicator.element] = Array.from(targetEl.getElementsByClassName(CLASS_NAME));
  }

  static remove() {
    loadingIndicator.element.parentNode.removeChild(loadingIndicator.element);
  }
};

export default loadingIndicator;
