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

const Logger = window.Rollbar || mockLogger;

export default Logger;
