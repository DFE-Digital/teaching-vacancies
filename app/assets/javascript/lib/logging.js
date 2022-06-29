const environment = process.env.NODE_ENV;
const noop = () => true;
const silentMock = {
  log: noop,
  warn: noop,
  error: noop,
  info: noop,
};

/* eslint-disable no-console */
const consoleMock = {
  log: console.log,
  warn: console.warn,
  error: console.error,
  info: console.info,
};
/* eslint-enable no-console */

const mockLogger = environment === 'test' ? silentMock : consoleMock;

// TODO: window.Rollbar will always be undefined as we have migrated away from Rollbar.
//   We will re-implement logging with Sentry in the future.
const Logger = window.Rollbar || mockLogger;

export default Logger;
