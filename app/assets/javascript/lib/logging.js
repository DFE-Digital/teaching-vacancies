import * as Sentry from '@sentry/browser';

const environment = process.env.NODE_ENV;
const noop = () => true;
const silentLogger = {
  log: noop,
  warn: noop,
  error: noop,
  info: noop,
};

/* eslint-disable no-console */
const consoleLogger = {
  log: console.log,
  warn: console.warn,
  error: console.error,
  info: console.info,
};
/* eslint-enable no-console */

const sentryLogger = {
  log: Sentry.captureMessage,
  error: Sentry.captureException,
};

const mockLogger = environment === 'test' ? silentLogger : consoleLogger;

const Logger = sentryLogger || mockLogger;

export default Logger;
