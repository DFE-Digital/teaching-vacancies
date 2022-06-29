// Entrypoint for "basic" Javascript

// This will be transpiled to ES5 and provides some minimal functionality for very outdated legacy
// browsers still supported by GOV.UK Frontend for now so we don't *completely* leave them hanging.
// This is separate from the more advanced javascript in the regular entrypoint, which is transpiled
// only to ES6 and will thus refuse to run on IE11 or other unsupported browsers.

// Note that this gets compiled in a NPM `pre` script, so any changes you make in here will not be
// picked up by the `--watch` option as part of the dev workflow (which shouldn't be an issue as
// this is unlikely to change)

// TODO: This needs to go, and the contents moved into the regular `application.js`, ideally no
//       later than when GOV.UK Frontend stops supporting IE11 (planned for v5.x)

import Rails from 'rails-ujs';
import { initAll } from 'govuk-frontend';

Rails.start();
initAll();
