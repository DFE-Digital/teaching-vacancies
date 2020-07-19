import { enableRadiusSelect, disableRadiusSelect } from './radius';

export const onChange = (value) => {
  if (/\d/.test(value)) {
    enableRadiusSelect();
  } else {
    disableRadiusSelect();
  }
};

export const getCoords = () => {
  if (document.querySelector('#location').dataset.coordinates) {
    return document.querySelector('#location').dataset.coordinates.split(' ').join(',');
  }
  return false;
};
