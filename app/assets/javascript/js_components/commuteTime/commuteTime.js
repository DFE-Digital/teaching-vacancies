import { Controller } from '@hotwired/stimulus';
import axios from 'axios';

import { railsCsrfToken } from '../../lib/events';

export default class extends Controller {
  static targets = ['button', 'error', 'form', 'postcode', 'result'];

  static values = {
    checking: String,
    error: String,
    url: String,
  };

  connect() {
    this.buttonText = this.buttonTarget.textContent;
  }

  calculate(event) {
    event.preventDefault();
    this.startLoading();

    axios.post(
      this.urlValue,
      { postcode: this.postcodeTarget.value },
      { headers: { 'X-CSRF-Token': railsCsrfToken() } },
    ).then((response) => {
      this.formTarget.hidden = true;
      this.resultTarget.innerHTML = response.data;
    }).catch((error) => {
      this.showError(error.response?.data?.error || this.errorValue);
    }).finally(() => {
      this.stopLoading();
    });
  }

  reset(event) {
    event.preventDefault();
    this.resultTarget.innerHTML = '';
    this.formTarget.hidden = false;
    this.postcodeTarget.focus();
  }

  startLoading() {
    this.errorTarget.hidden = true;
    this.postcodeTarget.classList.remove('govuk-input--error');
    this.buttonTarget.disabled = true;
    this.buttonTarget.textContent = this.checkingValue;
  }

  stopLoading() {
    this.buttonTarget.disabled = false;
    this.buttonTarget.textContent = this.buttonText;
  }

  showError(message) {
    this.errorTarget.textContent = message;
    this.errorTarget.hidden = false;
    this.postcodeTarget.classList.add('govuk-input--error');
  }
}
