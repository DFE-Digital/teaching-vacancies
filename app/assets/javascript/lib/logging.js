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
  log: (msg = '[Sentry captureMessage] log unknown message') => Sentry.captureMessage(msg),
  info: (msg = '[Sentry captureMessage] info unknown message') => Sentry.captureMessage(msg),
  warn: (msg = '[Sentry captureMessage] warn unknown message') => Sentry.captureMessage(msg),
  error: (error) => Sentry.captureException(error),
};

const mockLogger = environment === 'test' ? silentLogger : consoleLogger;

const Logger = sentryLogger || mockLogger;

export default Logger;
