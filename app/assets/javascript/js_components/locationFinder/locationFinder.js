import { Controller } from '@hotwired/stimulus';

import loader from '../loadingIndicator/loadingIndicator';
import api from './api';
import logger from '../../lib/logging';

export const ERROR_MESSAGE = 'Unable to find your location';
export const LOGGING_MESSAGE = '[component: locationFinder]: Unable to find user location';

export const DEFAULT_PLACEHOLDER = 'City, town or postcode';
export const LOADING_PLACEHOLDER = 'Finding Location...';

const LocationFinder = class extends Controller {
  static loader = loader;

  static values = {
    input: String,
    source: String,
  };

  static targets = ['button'];

  connect() {
    this.input = document.getElementById(this.inputValue);

    this.input.addEventListener('focus', () => {
      this.removeErrorMessage();
    });
  }

  findLocation() {
    this.startLoading();

    navigator.geolocation.getCurrentPosition((data) => {
      api[this.sourceValue](data.coords.latitude, data.coords.longitude).then((postcode) => {
        postcode ? this.onSuccess(postcode) : this.onFailure();
      }).catch(() => {
        this.onFailure();
      });
    });
  }

  onFailure() {
    this.showErrorMessage();
    this.stopLoading();
    logger.log(LOGGING_MESSAGE);
  }

  onSuccess(postcode) {
    this.input.value = postcode;
    this.stopLoading();
    logger.log('location finder usage: success');
  }

  removeErrorMessage() {
    if (this.errorMessage) {
      this.errorMessage.parentNode.removeChild(this.errorMessage);
    }
  }

  showErrorMessage() {
    if (!this.errorMessage) {
      this.errorMessage = document.createElement('div');
      this.errorMessage.setAttribute('role', 'alert');
      this.errorMessage.id = 'location-finder__error';
      this.errorMessage.classList.add('location-finder__error');
      this.errorMessage.innerHTML = ERROR_MESSAGE;
      this.element.insertAdjacentHTML('beforeend', this.errorMessage.outerHTML);
    }
  }

  startLoading() {
    this.input.disabled = true;
    this.input.value = '';
    LocationFinder.loader.add(this.input.parentElement, LOADING_PLACEHOLDER);
  }

  stopLoading() {
    this.input.removeAttribute('disabled');
    LocationFinder.loader.remove(this.input.parentElement, DEFAULT_PLACEHOLDER);
  }
};

export default LocationFinder;
