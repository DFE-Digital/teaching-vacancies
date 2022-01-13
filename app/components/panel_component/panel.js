import { Controller } from '@stimulus/core';
import './panel.scss';

export const COMPONENT_CLASS = 'panel-component';
export const TOGGLE_ELEMENT_CLASS = `${COMPONENT_CLASS}__toggle`;
export const CONTENT_ELEMENT_CLASS = `${COMPONENT_CLASS}__content`;
export const CLOSE_ELEMENT_CLASS = `${COMPONENT_CLASS}__content__close-button`;
export const PANEL_VISIBLE_CLASS = `${CONTENT_ELEMENT_CLASS}--visible`;

export default class extends Controller {
  static targets = ['toggle', 'content'];

  connect() {
    this.contentTarget.addEventListener('keydown', (e) => {
      if (['Esc', 'Escape'].includes(e.key)) {
        this.contentTarget.classList.remove(PANEL_VISIBLE_CLASS);
        this.setHiddenState(true);
      }
    });
  }

  toggleVisibility() {
    this.contentTarget.classList.toggle(PANEL_VISIBLE_CLASS) ? this.setVisibleState() : this.setHiddenState(true);
  }

  setVisibleState() {
    this.contentTarget.focus();
    this.contentTarget.setAttribute('aria-hidden', 'false');
    this.toggleTarget.setAttribute('aria-expanded', 'true');
  }

  setHiddenState(shouldFocus) {
    if (shouldFocus) {
      this.toggleTarget.focus();
    }

    this.contentTarget.setAttribute('aria-hidden', 'true');
    this.toggleTarget.setAttribute('aria-expanded', 'false');
  }
}
