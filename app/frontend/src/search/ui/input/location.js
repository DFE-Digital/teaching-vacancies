import { enableRadiusSelect } from './radius';

export const onChange = (value) => {
  if (/\d/.test(value)) {
    enableRadiusSelect();
  }
};

export const getCoords = () => {
  if (document.querySelector('#jobs-search-form-location-field').dataset.coordinates) {
    return document.querySelector('#jobs-search-form-location-field').dataset.coordinates.split(' ').join(',');
  }
  return false;
};
