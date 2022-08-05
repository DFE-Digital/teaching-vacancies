import axios from 'axios';

const EVENTS_ENDPOINT = '/api/events';

export const railsCsrfToken = () => {
  const tokenElem = document.getElementsByName('csrf-token')[0];
  return tokenElem && tokenElem.content;
};

// Triggers an event and makes a request to the backend endpoint with the event data.
export const triggerEvent = (type, data) => {
  const headers = { 'X-CSRF-Token': railsCsrfToken() };

  return new Promise((resolve) => {
    axios.post(EVENTS_ENDPOINT, { type, data }, { headers })
      .then(resolve)
      .catch(() => {
        // Events are not mission-critical: always resolve regardless of outcome
        resolve();
      });
  });
};
