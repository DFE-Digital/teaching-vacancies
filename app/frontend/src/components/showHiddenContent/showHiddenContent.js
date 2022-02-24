import { Controller } from '@hotwired/stimulus';

const ShowHiddenContent = class extends Controller {
  static targets = ['content'];

  connect() {
    const [errors] = this.contentTarget.getElementsByClassName('govuk-error-summary');
    const actionEl = document.querySelector('[data-action="click->show-hidden-content#show"');

    if (!errors) {
      this.contentTarget.style.display = 'none';

      ShowHiddenContent.ariaHidden(this.contentTarget);
      ShowHiddenContent.ariaExpanded(actionEl);
    } else {
      actionEl.style.display = 'none';

      ShowHiddenContent.ariaExpanded(this.contentTarget);
      ShowHiddenContent.ariaHidden(actionEl);
    }
  }

  show(event) {
    event.preventDefault();

    event.target.style.display = 'none';
    ShowHiddenContent.ariaHidden(event.target);

    this.contentTarget.style.display = 'block';
    ShowHiddenContent.ariaExpanded(this.contentTarget);
  }

  static ariaHidden(el) {
    el.setAttribute('aria-hidden', 'true');
    el.setAttribute('aria-expanded', 'false');
  }

  static ariaExpanded(el) {
    el.setAttribute('aria-hidden', 'false');
    el.setAttribute('aria-expanded', 'true');
  }
};

export default ShowHiddenContent;
