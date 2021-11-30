import './loader.scss';

export const add = (targetEl, placeholder) => {
  targetEl.insertAdjacentHTML('beforeend', loaderSvg);
  targetEl.placeholder = placeholder;
};

export const remove = (targetEl, placeholder) => {
  const loaderEl = document.getElementById('loader');
  loaderEl.parentNode.removeChild(loaderEl);
  targetEl.setAttribute('placeholder', placeholder);
};

const loaderSvg = `<svg version="1.1" xmlns="http://www.w3.org/2000/svg" class="govuk-c-loader__spinner" id="loader" width="32" height="32" viewBox="-32 -30 64 64" preserveAspectRatio="xMidYMid meet">
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

const loader = {
  add,
  remove,
};

export default loader;
