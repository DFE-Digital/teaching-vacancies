/**
 * @jest-environment jsdom
 */
import { Application } from '@hotwired/stimulus';
import showHiddenContentController from './showHiddenContent';

let clickableEl;
let targetEl;

const initialiseStimulus = () => {
  const application = Application.start();
  application.register('show-hidden-content', showHiddenContentController);
};

describe('showing content', () => {
  beforeAll(() => {
    initialiseStimulus();

    document.body.innerHTML = `<div data-controller="show-hidden-content">
    <button id="button" data-action="click->show-hidden-content#show"></button>
    <div id="content" data-show-hidden-content-target="content"></div>
    </div>`;

    clickableEl = document.getElementById('button');
    targetEl = document.getElementById('content');
  });

  describe('when the page loads', () => {
    test('the content should be hidden', () => {
      expect(targetEl.style.display).toEqual('none');

      checkAriaHidden(targetEl);
      checkAriaExpanded(clickableEl);
    });
  });

  describe('when the clickable element is clicked', () => {
    test('the content should be visible', () => {
      clickableEl.click();

      expect(targetEl.style.display).toEqual('block');
      checkAriaExpanded(targetEl);
      checkAriaHidden(clickableEl);
    });
  });

  describe('when there are errors on the target element', () => {
    beforeAll(() => {
      const errorSummary = document.createElement('div');
      targetEl.appendChild(errorSummary);
      errorSummary.setAttribute('class', 'govuk-error-summary');
    });

    test('the content should be visible', () => {
      expect(targetEl.style.display).toEqual('block');
      checkAriaExpanded(targetEl);

      checkAriaHidden(clickableEl);
    });
  });

  const checkAriaHidden = (el) => {
    expect(el.getAttribute('aria-hidden')).toEqual('true');
    expect(el.getAttribute('aria-expanded')).toEqual('false');
  };

  const checkAriaExpanded = (el) => {
    expect(el.getAttribute('aria-hidden')).toEqual('false');
    expect(el.getAttribute('aria-expanded')).toEqual('true');
  };
});
