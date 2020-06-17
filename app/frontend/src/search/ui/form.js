import { removeDataAttribute, setDataAttribute } from '../../lib/utils';

export const enableSubmitButton = (container) => container.querySelector('input[type="submit"]').disabled = false;

export const setGeocodeAttributes = (coords) => {
  setDataAttribute(document.querySelector('#location'), 'coordinates', `${coords.lat}, ${coords.lng}`);

  if (document.querySelector('#radius')) {
    setDataAttribute(document.querySelector('#radius'), 'radius', document.querySelector('#radius').value || 10);
  }
};

export const removeGeocodeAttributes = () => {
  removeDataAttribute(document.querySelector('#location'), 'coordinates');
  removeDataAttribute(document.querySelector('#radius'), 'radius');
};
