import { Controller } from '@hotwired/stimulus';
import template from './marker/template';
import './sidebar.scss';

export const COMPONENT_CLASS = 'sidebar-component';
export const SIDEBAR_VISIBLE_CLASS = `${COMPONENT_CLASS}--visible`;

const Sidebar = class extends Controller {
  static targets = ['container', 'content', 'close'];

  open({ detail }) {
    this.containerTarget.classList.add(SIDEBAR_VISIBLE_CLASS);
    this.contentTarget.innerHTML = template.sidebar(detail);
    this.closeTarget.focus();
    this.currentId = detail.id;
  }

  close() {
    this.containerTarget.classList.remove(SIDEBAR_VISIBLE_CLASS);
    document.getElementById(this.currentId).focus();
  }
};

export default Sidebar;
