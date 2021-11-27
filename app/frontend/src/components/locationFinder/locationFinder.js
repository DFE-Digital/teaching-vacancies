import { Controller } from '@hotwired/stimulus';

import 'es6-promise/auto';

import loader from '../loader/loader';
import api from '../../lib/api';
import logger from '../../lib/logging';
import './locationFinder.scss';

export const ERROR_MESSAGE = 'Unable to find your location';
export const LOGGING_MESSAGE = '[component: locationFinder]: Unable to find user location';

export const DEFAULT_PLACEHOLDER = 'City, town or postcode';
export const LOADING_PLACEHOLDER = 'Finding Location...';

const LocationFinder = class extends Controller {
  static loader = loader;

  connect() {
    const [inputContainerEl] = document.getElementsByClassName('autocomplete');

    this.inputContainer = inputContainerEl;
    this.input = document.getElementById(this.element.dataset.target);

    navigator.geolocation.getCurrentPosition((data) => {
      this.element.classList.remove('location-finder--hidden');
      this.element.insertAdjacentHTML('afterbegin', '<span class="location-finder__link-prefix">or </span>');
      this.geolocation = data.coords;
    });
  }

  findLocation() {
    this.input.addEventListener('focus', () => {
      this.removeErrorMessage();
    });

    this.startLoading();

    if (this.geolocation) {
      api[this.element.dataset.source](this.geolocation.latitude, this.geolocation.longitude).then((postcode) => {
        if (postcode) {
          this.onSuccess(postcode);
        } else {
          this.onFailure();
        }
      }).catch(() => {
        this.onFailure();
      });
    }
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
      this.element.insertAdjacentHTML('afterend', this.errorMessage.outerHTML);
    }
  }

  startLoading() {
    this.input.disabled = true;
    this.inputContainer.classList.add('js-location-finder--loading');
    LocationFinder.loader.add(this.inputContainer, LOADING_PLACEHOLDER);
  }

  stopLoading() {
    this.inputContainer.classList.remove('js-location-finder--loading');
    this.input.removeAttribute('disabled');
    LocationFinder.loader.remove(this.inputContainer, DEFAULT_PLACEHOLDER);
  }
};

export default LocationFinder;
