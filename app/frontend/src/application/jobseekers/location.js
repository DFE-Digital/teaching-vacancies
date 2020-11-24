import { enableRadiusSelect, disableRadiusSelect } from './radius';

const INPUT_ELEMENT = document.getElementById('location-field');

export const onChange = (value) => {
  if (/\d/.test(value)) {
    enableRadiusSelect();
  } else {
    disableRadiusSelect();
  }
};

export const getCoords = () => {
  if (INPUT_ELEMENT.dataset.coordinates) {
    return INPUT_ELEMENT.dataset.coordinates.split(' ').join(',');
  }
  return false;
};

window.addEventListener('DOMContentLoaded', () => {
  if (INPUT_ELEMENT) {
    if (!getCoords()) {
      disableRadiusSelect();
    }

    INPUT_ELEMENT.addEventListener('input', (e) => {
      onChange(e.target.value);
    });
  }
});
