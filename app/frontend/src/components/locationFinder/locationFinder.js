import 'es6-promise/auto';

import '../../lib/polyfill/after.polyfill';
import '../../lib/polyfill/remove.polyfill';
import loader from '../loader/loader';
import { getPostcodeFromCoordinates } from '../../lib/api';
import { enableRadiusSelect, disableRadiusSelect } from '../../application/search/radius';
import Rollbar from '../../lib/logging';
import './locationFinder.scss';

const containerEl = document.getElementsByClassName('js-location-finder')[0];
const inputEl = document.getElementsByClassName('js-location-finder__input')[0];

export const ERROR_MESSAGE = 'Unable to find your location';
export const LOGGING_MESSAGE = '[Module: locationFinder]: Unable to find user location';

export const DEFAULT_PLACEHOLDER = 'City, town or postcode';
export const LOADING_PLACEHOLDER = 'Finding Location...';

export const startLoading = (container, input) => {
  input.disabled = true;
  container.classList.add('js-location-finder--loading');
  loader.add(document.getElementById(getTargetElementId()), LOADING_PLACEHOLDER);
};

export const stopLoading = (container, input) => {
  loader.remove(document.getElementById(getTargetElementId()), DEFAULT_PLACEHOLDER);
  container.classList.remove('js-location-finder--loading');
  input.removeAttribute('disabled');
};

const getTargetElementId = () => {
  if (document.getElementById('current-location')) {
    return document.getElementById('current-location').getAttribute('data-loader');
  }

  return 'form-location-field';
};

export const showLocationLink = (container) => {
  container.classList.add('js-geolocation-supported');
  container.id = 'location-text';
};

export const showErrorMessage = (link) => {
  if (!document.querySelector('.js-location-finder__link .govuk-error-message')) {
    const errorMessage = document.createElement('div');
    errorMessage.setAttribute('role', 'alert');
    errorMessage.id = 'js-location-finder__error';
    errorMessage.classList.add('govuk-error-message');
    errorMessage.classList.add('govuk-!-margin-top-2');
    errorMessage.innerHTML = ERROR_MESSAGE;
    link.after(errorMessage);
  }
};

export const removeErrorMessage = () => {
  if (document.querySelector('.js-location-finder__link .govuk-error-message')) {
    document.querySelector('.js-location-finder__link .govuk-error-message').remove();
  }
};

export const onSuccess = (postcode, element) => {
  element.value = postcode;
  enableRadiusSelect();
  locationFinder.stopLoading(containerEl, inputEl);
};

export const onFailure = () => {
  locationFinder.showErrorMessage(document.getElementById('current-location'));
  disableRadiusSelect();
  locationFinder.stopLoading(containerEl, inputEl);
  Rollbar.log(LOGGING_MESSAGE);
};

export const postcodeFromPosition = (position, apiPromise) => apiPromise(position.coords.latitude, position.coords.longitude).then((response) => {
  if (response && response.result) {
    onSuccess(response.result[0].postcode, document.getElementById('location-field'));
  } else {
    onFailure();
  }
}).catch(() => {
  onFailure();
});

export const init = () => {
  if (document.getElementById('current-location')) {
    document.getElementById('current-location').addEventListener('click', (event) => {
      event.stopPropagation();

      startLoading(containerEl, inputEl);

      navigator.geolocation.getCurrentPosition((data) => {
        postcodeFromPosition(data, getPostcodeFromCoordinates);
      }, () => {
        stopLoading(containerEl, inputEl);
        showErrorMessage(document.getElementById('current-location'));
      });
    });

    inputEl.addEventListener('focus', () => {
      removeErrorMessage();
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
