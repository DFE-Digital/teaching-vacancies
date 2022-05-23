import { Controller } from '@hotwired/stimulus';
import template from './marker/template';
import './sidebar.scss';

export const COMPONENT_CLASS = 'sidebar-component';
export const SIDEBAR_VISIBLE_CLASS = `${COMPONENT_CLASS}--visible`;

const Sidebar = class extends Controller {
  static targets = ['container', 'content', 'close'];

  static MOBILE_BREAKPOINT = 768;

  static OFFSET = { x: 0, y: 0 };

  connect() {
    this.userClosed = false;

    this.containerTarget.addEventListener('keydown', (e) => {
      if (['Escape', 'Esc'].includes(e.key)) {
        this.close();
      }
    });
  }

  get markerOffset() {
    let offset;

    if (document.documentElement.clientWidth <= Sidebar.MOBILE_BREAKPOINT) {
      offset = { x: 0, y: this.containerTarget.offsetHeight / 2 };
    } else {
      offset = { x: (this.element.offsetWidth - this.containerTarget.offsetWidth) / 2, y: 0 };
    }

    if (!this.containerTarget.classList.contains(SIDEBAR_VISIBLE_CLASS)) {
      offset = Sidebar.OFFSET;
    }

    return offset;
  }

  open() {
    this.containerTarget.classList.add(SIDEBAR_VISIBLE_CLASS);
    this.userClosed = false;
    this.dispatch('opened', { detail: { id: this.currentId, offset: this.markerOffset } });
  }

  update({ detail }) {
    this.currentId = detail.id;

    if (!this.containerTarget.classList.contains(SIDEBAR_VISIBLE_CLASS) && !this.userClosed) {
      this.open();
    }

    this.contentTarget.innerHTML = '';
    this.contentTarget.appendChild(template.sidebar(detail));
    this.userClosed = false;
  }

  close() {
    this.containerTarget.classList.remove(SIDEBAR_VISIBLE_CLASS);
    this.userClosed = true;
    this.dispatch('closed', { detail: { id: this.currentId, offset: this.markerOffset } });
    this.closeTarget.blur();
  }

  focus() {
    this.open();
    this.containerTarget.focus();
  }

  blur() {
    this.containerTarget.classList.remove(SIDEBAR_VISIBLE_CLASS);
  }
};

export default Sidebar;
