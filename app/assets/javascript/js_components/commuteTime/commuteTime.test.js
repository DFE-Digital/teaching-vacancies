/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';
import axios from 'axios';

import CommuteTimeController from './commuteTime';

jest.mock('axios');

const flushPromises = () => new Promise((resolve) => { setTimeout(resolve, 0); });

describe('commute time', () => {
  let application;
  let controller;

  beforeEach(async () => {
    document.head.innerHTML = '<meta name="csrf-token" content="token">';
    document.body.innerHTML = `
      <div data-controller="commute-time"
           data-commute-time-url-value="/jobs/123/commute-time"
           data-commute-time-checking-value="Checking…"
           data-commute-time-error-value="Try again later">
        <form data-action="submit->commute-time#calculate" data-commute-time-target="form">
          <p data-commute-time-target="error" hidden></p>
          <input value="SW1A 1AA" data-commute-time-target="postcode">
          <button data-commute-time-target="button">Check</button>
        </form>
        <div data-commute-time-target="result"></div>
      </div>`;

    application = Application.start();
    application.register('commute-time', CommuteTimeController);
    await flushPromises();
    controller = application.getControllerForElementAndIdentifier(
      document.querySelector('[data-controller="commute-time"]'),
      'commute-time',
    );
  });

  afterEach(() => {
    application.stop();
    jest.resetAllMocks();
  });

  it('submits the postcode and displays the returned result', async () => {
    axios.post.mockResolvedValue({ data: '<p>26 minutes by car</p>' });

    controller.formTarget.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
    expect(controller.buttonTarget.disabled).toBe(true);
    expect(controller.buttonTarget.textContent).toBe('Checking…');

    await flushPromises();

    expect(axios.post).toHaveBeenCalledWith(
      '/jobs/123/commute-time',
      { postcode: 'SW1A 1AA' },
      { headers: { 'X-CSRF-Token': 'token' } },
    );
    expect(controller.formTarget.hidden).toBe(true);
    expect(controller.resultTarget.textContent).toContain('26 minutes by car');
    expect(controller.buttonTarget.disabled).toBe(false);
  });

  it('displays an error returned by the endpoint', async () => {
    axios.post.mockRejectedValue({ response: { data: { error: 'Enter a full UK postcode' } } });

    controller.formTarget.dispatchEvent(new Event('submit', { bubbles: true, cancelable: true }));
    await flushPromises();

    expect(controller.errorTarget.hidden).toBe(false);
    expect(controller.errorTarget.textContent).toBe('Enter a full UK postcode');
    expect(controller.postcodeTarget.classList.contains('govuk-input--error')).toBe(true);
    expect(controller.formTarget.hidden).toBe(false);
  });

  it('restores the form when changing postcode', () => {
    controller.formTarget.hidden = true;
    controller.resultTarget.innerHTML = '<p>26 minutes by car</p>';

    controller.reset({ preventDefault: jest.fn() });

    expect(controller.formTarget.hidden).toBe(false);
    expect(controller.resultTarget.innerHTML).toBe('');
    expect(document.activeElement).toBe(controller.postcodeTarget);
  });
});
