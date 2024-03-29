import { Controller } from '@hotwired/stimulus';
import axios from 'axios';

import logger from '../../lib/logging';

const CookiesBannerController = class extends Controller {
  connect() {
    if (!navigator.cookieEnabled) {
      this.element.parentElement.removeChild(this.element);
    }
  }

  submit(e) {
    const form = e.target.closest('form');
    const token = form.querySelector('input[name="authenticity_token"]').value;

    e.preventDefault();
    this.handler(form.action, token);
  }

  handler(action, token) {
    axios.post(action, { authenticity_token: token, no_redirect: true })
      .then((response) => {
        if (response.status === 204 || response.statusText === 'OK') {
          this.element.remove();
        }
      })
      .catch((error) => {
        if (error.response && (error.response.status !== 200 || error.response.status !== 204)) {
          logger.warn(error.message);
        } else {
          logger.log(error.message);
        }
      });
  }
};

export default CookiesBannerController;
