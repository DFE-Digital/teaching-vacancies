import { Controller } from '@hotwired/stimulus';

// Stimulus controller for marketing pixel tracking
//
// Currently supports Facebook, LinkedIn, and Reddit pixels.
//
// Each method corresponds to a specific user action to be tracked
// Methods check for the existence of the respective pixel tracking functions
// before attempting to call them to avoid errors if the pixels are not loaded
export default class extends Controller {
  connect() {
    // If this JS controller has been loaded from the alert subscription confirmation banner, trigger the event.
    if (this.element.classList.contains('js-alert-subscription-confirmation')) {
      this.alertSubscriptionConfirmation();
    }
  }

  // Called from the "Apply for this job" button click
  applyForJob() {
    // Facebook
    if (typeof fbq === 'function') fbq('trackCustom', 'Apply for Job');
    // LinkedIn
    if (window.lintrk) window.lintrk('track', { conversion_id: 23034978 });
    // Reddit
    if (typeof rdt === 'function') rdt('track', 'Lead');
  }

  // Called when user clicks on the vacancies search button
  siteSearch() {
    // Facebook
    if (typeof fbq === 'function') fbq('trackCustom', 'Site Search');
    // LinkedIn
    if (window.lintrk) window.lintrk('track', { conversion_id: 23034986 });
    // Reddit
    if (typeof rdt === 'function') rdt('track', 'Search');
  }

  // Called when user clicks on the "Set up alerts" button
  setUpAlerts() {
    // Facebook
    if (typeof fbq === 'function') fbq('trackCustom', 'Set up Alerts');
    // LinkedIn
    if (window.lintrk) window.lintrk('track', { conversion_id: 23035010 });
    // Reddit: No call needed here
  }

  // Called when user lands on the alert subscription confirmation page
  alertSubscriptionConfirmation() {
    // Reddit
    if (typeof rdt === 'function') rdt('track', 'AddToWishlist');
    // Facebook/LinkedIn: No call needed here
  }
}
