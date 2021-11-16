import 'es6-promise/auto';

import '../../lib/polyfill/after.polyfill';
import '../../lib/polyfill/remove.polyfill';
import loader from '../loader/loader';
import { getPostcodeFromCoordinates } from '../../lib/api';
import logger from '../../lib/logging';
import './locationFinder.scss';

const containerEl = document.getElementsByClassName('accessible-autocomplete__container')[0];
let inputEl;

export const ERROR_MESSAGE = 'Unable to find your location';
export const LOGGING_MESSAGE = '[component: locationFinder]: Unable to find user location';

export const DEFAULT_PLACEHOLDER = 'City, town or postcode';
export const LOADING_PLACEHOLDER = 'Finding Location...';

export const startLoading = (container, input) => {
  input.disabled = true;
  container.classList.add('js-location-finder--loading');
  loader.add(document.querySelector(getTargetSelector()), LOADING_PLACEHOLDER);
};

export const stopLoading = (container, input) => {
  loader.remove(document.querySelector(getTargetSelector()), DEFAULT_PLACEHOLDER);
  container.classList.remove('js-location-finder--loading');
  input.removeAttribute('disabled');
};

const getTargetSelector = () => {
  if (document.getElementById('current-location')) {
    return document.getElementById('current-location').getAttribute('data-loader');
  }

  return '#location-field';
};

export const showLocationLink = (container) => {
  container.classList.add('js-geolocation-supported');
};

export const showErrorMessage = (link) => {
  if (!document.getElementById('js-location-finder__error')) {
    const errorMessage = document.createElement('div');
    errorMessage.setAttribute('role', 'alert');
    errorMessage.id = 'js-location-finder__error';
    errorMessage.classList.add('js-location-finder__error');
    errorMessage.innerHTML = ERROR_MESSAGE;
    link.after(errorMessage);
  }
};

export const removeErrorMessage = () => {
  if (document.querySelector('.js-location-finder__error')) {
    document.querySelector('.js-location-finder__error').remove();
  }
};

export const onSuccess = (postcode, element) => {
  element.value = postcode;
  locationFinder.stopLoading(containerEl, inputEl);
  logger.log('location finder usage: success');
};

export const onFailure = () => {
  locationFinder.showErrorMessage(document.getElementById('current-location'));
  locationFinder.stopLoading(containerEl, inputEl);
  logger.log(LOGGING_MESSAGE);
};

export const postcodeFromPosition = (position, apiPromise) => apiPromise(position.coords.latitude, position.coords.longitude).then((response) => {
  if (response && response.result) {
    onSuccess(response.result[0].postcode, document.getElementsByClassName('autocomplete__input')[0]);
  } else {
    onFailure();
  }
}).catch(() => {
  onFailure();
});

export const init = () => {
  if (document.getElementById('current-location')) {
    document.getElementById('current-location').addEventListener('click', (event) => {
      [inputEl] = document.getElementsByClassName('autocomplete__input');

      inputEl.addEventListener('focus', () => {
        removeErrorMessage();
      });

      event.stopPropagation();

      startLoading(containerEl, inputEl);

      navigator.geolocation.getCurrentPosition((data) => {
        postcodeFromPosition(data, getPostcodeFromCoordinates);
      }, () => {
        stopLoading(containerEl, inputEl);
        showErrorMessage(document.getElementById('current-location'));
      });
    });
  }
};

const locationFinder = {
  showErrorMessage,
  stopLoading,
  onSuccess,
  init,
};

export default locationFinder;

window.addEventListener('DOMContentLoaded', () => {
  if (navigator.geolocation && containerEl) {
    showLocationLink(containerEl);
    init();
  }
});
