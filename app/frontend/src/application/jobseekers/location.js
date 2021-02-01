import { enableRadiusSelect, disableRadiusSelect } from './radius';

export const INPUT_ELEMENT_CLASSNAME = 'js-location-finder__input';

export const onLoad = (el) => {
  if (el) {
    if (!getCoords(el)) {
      disableRadiusSelect();
    }

    el.addEventListener('input', (e) => {
      onChange(e.target.value);
    });
  }
};

export const onChange = (value) => {
  if (/\d/.test(value)) {
    enableRadiusSelect();
  } else {
    disableRadiusSelect();
  }
};

export const getCoords = (el) => el.dataset.coordinates;

window.addEventListener('DOMContentLoaded', () => {
  locationInput.onLoad(document.getElementsByClassName(INPUT_ELEMENT_CLASSNAME)[0]);
});

const locationInput = {
  disableRadiusSelect,
  onLoad,
};

export default locationInput;
