import { Application } from '@hotwired/stimulus';
import MarketingTrackingController from './marketingTracking';

describe('MarketingTrackingController', () => {
  let application;

  afterEach(() => {
    if (application) application.stop();
    document.body.innerHTML = '';
    jest.restoreAllMocks();
  });

  describe('applyForJob', () => {
    let element;

    beforeEach(() => {
      document.body.innerHTML = `
        <button
          data-controller="marketing-tracking"
          data-action="click->marketing-tracking#applyForJob"
          id="apply-btn"
        >Apply for this job</button>
      `;
      application = Application.start();
      application.register('marketing-tracking', MarketingTrackingController);
      element = document.getElementById('apply-btn');
    });

    it('calls fbq, lintrk, and rdt if present', () => {
      window.fbq = jest.fn();
      window.lintrk = jest.fn();
      window.rdt = jest.fn();

      element.click();

      expect(window.fbq).toHaveBeenCalledWith('trackCustom', 'Apply for Job');
      expect(window.lintrk).toHaveBeenCalledWith('track', { conversion_id: 23034978 });
      expect(window.rdt).toHaveBeenCalledWith('track', 'Lead');
    });

    it('does not throw if fbq, lintrk, or rdt are missing', () => {
      delete window.fbq;
      delete window.lintrk;
      delete window.rdt;
      expect(() => element.click()).not.toThrow();
    });
  });

  describe('siteSearch', () => {
    let searchBtn;

    beforeEach(() => {
      document.body.innerHTML = `
        <button
          data-controller="marketing-tracking"
          data-action="click->marketing-tracking#siteSearch"
          id="search-btn"
        >Search</button>
      `;
      application = Application.start();
      application.register('marketing-tracking', MarketingTrackingController);
      searchBtn = document.getElementById('search-btn');
    });

    it('calls fbq, lintrk, and rdt if present', () => {
      window.fbq = jest.fn();
      window.lintrk = jest.fn();
      window.rdt = jest.fn();

      searchBtn.click();

      expect(window.fbq).toHaveBeenCalledWith('trackCustom', 'Site Search');
      expect(window.lintrk).toHaveBeenCalledWith('track', { conversion_id: 23034986 });
      expect(window.rdt).toHaveBeenCalledWith('track', 'Search');
    });

    it('does not throw if fbq, lintrk, or rdt are missing', () => {
      delete window.fbq;
      delete window.lintrk;
      delete window.rdt;
      expect(() => searchBtn.click()).not.toThrow();
    });
  });

  describe('setUpAlerts', () => {
    let alertsBtn;

    beforeEach(() => {
      document.body.innerHTML = `
        <button
          data-controller="marketing-tracking"
          data-action="click->marketing-tracking#setUpAlerts"
          id="alerts-btn"
        >Set up alerts</button>
      `;
      application = Application.start();
      application.register('marketing-tracking', MarketingTrackingController);
      alertsBtn = document.getElementById('alerts-btn');
    });

    it('calls fbq and lintrk if present', () => {
      window.fbq = jest.fn();
      window.lintrk = jest.fn();

      alertsBtn.click();

      expect(window.fbq).toHaveBeenCalledWith('trackCustom', 'Set up Alerts');
      expect(window.lintrk).toHaveBeenCalledWith('track', { conversion_id: 23035010 });
    });

    it('does not throw if fbq or lintrk are missing', () => {
      delete window.fbq;
      delete window.lintrk;
      expect(() => alertsBtn.click()).not.toThrow();
    });
  });

  describe('alertSubscriptionConfirmation', () => {
    beforeEach(() => {
      // Set up the mock before Stimulus initializes the controller
      window.rdt = jest.fn();
      document.body.innerHTML = `
        <div class="js-alert-subscription-confirmation" data-controller="marketing-tracking">
          <span class="govuk-notification-banner__heading">Your job alert has been created</span>
        </div>
      `;
      application = Application.start();
      application.register('marketing-tracking', MarketingTrackingController);
    });

    it('calls rdt if present', () => {
      expect(window.rdt).toHaveBeenCalledWith('track', 'AddToWishlist');
    });

    it('does not throw if rdt is missing', () => {
      delete window.rdt;
      expect(() => {
        application.stop();
        application = Application.start();
        application.register('marketing-tracking', MarketingTrackingController);
      }).not.toThrow();
    });
  });
});
