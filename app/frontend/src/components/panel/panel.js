import { Controller } from '@hotwired/stimulus';
import './panel.scss';

export const COMPONENT_CLASS = 'panel-component';
export const TOGGLE_ELEMENT_CLASS = `${COMPONENT_CLASS}__toggle`;
export const CONTENT_ELEMENT_CLASS = `${COMPONENT_CLASS}__content`;
export const CLOSE_ELEMENT_CLASS = `${COMPONENT_CLASS}__content__close-button`;
export const PANEL_VISIBLE_CLASS = `${CONTENT_ELEMENT_CLASS}--visible`;

const Panel = class extends Controller {
  static targets = ['toggle'];

  connect() {
    this.content = document.getElementById(this.element.dataset.contentId);
    this.content.classList.add(CONTENT_ELEMENT_CLASS);
    this.addContentCloseButton();

    this.content.addEventListener('keydown', (e) => {
      if (['Esc', 'Escape'].includes(e.key)) {
        this.setHiddenState(true);
      }
    });
  }

  toggleVisibility() {
    this.content.classList.toggle(PANEL_VISIBLE_CLASS) ? this.setVisibleState() : this.setHiddenState(true);
  }

  setVisibleState() {
    this.content.focus();
    this.content.classList.add(PANEL_VISIBLE_CLASS);
    this.content.setAttribute('aria-hidden', 'false');
    this.toggleTarget.setAttribute('aria-expanded', 'true');
  }

  setHiddenState(shouldFocus) {
    if (shouldFocus) {
      this.toggleTarget.focus();
    }

    this.content.classList.remove(PANEL_VISIBLE_CLASS);
    this.content.setAttribute('aria-hidden', 'true');
    this.toggleTarget.setAttribute('aria-expanded', 'false');
  }

  addContentCloseButton() {
    [this.closeButtonContainerEl] = this.content.getElementsByClassName(this.element.dataset.closeContainer);
    this.closeButtonContainerEl.insertAdjacentHTML('beforeend', this.closeButtonHTML);
    Array.from(this.content.getElementsByClassName(CLOSE_ELEMENT_CLASS)).forEach((el) => el.addEventListener('click', () => this.setHiddenState(true)));
  }

  closeButtonHTML = `<button class="${CLOSE_ELEMENT_CLASS} icon--close" type="button"><span class="govuk-body-s">Close</span></button>`;
};

export default Panel;
