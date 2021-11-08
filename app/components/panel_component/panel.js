import { Controller } from '@hotwired/stimulus';
import './panel.scss';

export const COMPONENT_CLASS = 'panel-component';
export const ACTION_ELEMENT_CLASS = `${COMPONENT_CLASS}__toggle`;
export const CLOSE_ELEMENT_CLASS = `${COMPONENT_CLASS}__close-button`;
export const PANEL_VISIBLE_CLASS = `${COMPONENT_CLASS}--visible`;

export default class extends Controller {
  connect() {
    Array.from(this.element.getElementsByClassName(ACTION_ELEMENT_CLASS)).forEach((actionEl) => {
      this.actionEl = actionEl;
      this.panelEl = document.getElementById(actionEl.dataset.panelId);

      this.panelEl.addEventListener('keydown', (e) => {
        if (['Esc', 'Escape'].includes(e.key)) {
          this.panelEl.classList.remove(PANEL_VISIBLE_CLASS);
          this.setHiddenState(true);
        }
      });
    });
  }

  toggle() {
    this.panelEl.classList.toggle(PANEL_VISIBLE_CLASS) ? this.setVisibleState() : this.setHiddenState(true);
  }

  setVisibleState() {
    this.panelEl.focus();
    this.panelEl.setAttribute('aria-hidden', 'false');
    this.actionEl.setAttribute('aria-expanded', 'true');
  }

  setHiddenState(shouldFocus) {
    if (shouldFocus) {
      this.actionEl.focus();
    }

    this.panelEl.setAttribute('aria-hidden', 'true');
    this.actionEl.setAttribute('aria-expanded', 'false');
  }
}
