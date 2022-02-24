import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['content'];

  connect() {
    const [errors] = this.contentTarget.getElementsByClassName('govuk-error-summary');
    const actionEl = document.querySelector('[data-action="click->show-hidden-content#show"');

    if (!errors) {
      this.contentTarget.style.display = 'none';

      ariaHidden(this.contentTarget);
      ariaExpanded(actionEl);
    } else {
      actionEl.style.display = 'none';

      ariaExpanded(this.contentTarget);
      ariaHidden(actionEl);
    }
  }

  show(event) {
    event.preventDefault();

    event.target.style.display = 'none';
    ariaHidden(event.target);

    this.contentTarget.style.display = 'block';
    ariaExpanded(this.contentTarget);
  }
}

const ariaHidden = (el) => {
  el.setAttribute('aria-hidden', 'true');
  el.setAttribute('aria-expanded', 'false');
};

const ariaExpanded = (el) => {
  el.setAttribute('aria-hidden', 'false');
  el.setAttribute('aria-expanded', 'true');
};
