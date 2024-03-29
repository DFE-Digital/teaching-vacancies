/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';
import SidebarController, {
  SIDEBAR_VISIBLE_CLASS,
} from './sidebar';

let application;
let controller;

const initialiseStimulus = () => {
  application = Application.start();
  application.register('sidebar', SidebarController);
};

beforeAll(() => {
  document.body.innerHTML = `<div data-controller="sidebar" data-action="sidebar:marker:click->sidebar#update">
    <div data-sidebar-target="container">
    <button data-action="click->sidebar#close" data-sidebar-target="close">close</button>
    <div data-sidebar-target="content"></div>
  </div>
  </div>
  <button id="open">open</button>`;

  initialiseStimulus();
});

describe('sidebar is opened', () => {
  beforeAll(() => {
    controller = application.getControllerForElementAndIdentifier(document.querySelector('[data-controller="sidebar"]'), 'sidebar');
    controller.dispatch('marker:click', { detail: { id: 'open' } });
  });

  test('container is visible', () => {
    expect(controller.containerTarget.classList.contains(SIDEBAR_VISIBLE_CLASS)).toBe(true);
  });

  test('content is set', () => {
    expect(controller.contentTarget.innerHTML).toBeTruthy();
  });
});

describe('sidebar is closed', () => {
  beforeAll(() => {
    controller.closeTarget.click();
  });

  test('container is hidden', () => {
    expect(controller.containerTarget.classList.contains(SIDEBAR_VISIBLE_CLASS)).toBe(false);
  });
});
