import * as Sentry from '@sentry/browser';

import 'core-js/modules/es.weak-map';
import 'core-js/modules/es.weak-set';
import '@stimulus/polyfills';
import * as govukFrontend from 'govuk-frontend';
import $ from 'jquery';
import * as mojFrontend from '@ministryofjustice/frontend';

import { Application } from '@hotwired/stimulus';
import Rails from 'rails-ujs';

// view components
import CookiesBannerController from './components/cookiesBanner/enhance';
import EditorController from './components/editor/editor';
import EditorPreviewController from './components/editor/preview';
import FiltersController from './components/filters/filters';
import MapController from './components/map/map';
import MapSidebarController from './components/map/sidebar';
import SearchableCollectionComponent from './components/searchable_collection/searchable_collection';

// js components
import AutocompleteController from './js_components/autocomplete/autocomplete';
import ClipboardController from './js_components/clipboard/clipboard';
import FormController from './js_components/form/form';
import LocationFinderController from './js_components/locationFinder/locationFinder';
import ManageQualificationsController from './js_components/manageQualifications/manageQualifications';
import PanelController from './js_components/panel/panel';
import ShowHiddenContentController from './js_components/showHiddenContent/showHiddenContent';
import TrackedLinkController from './js_components/trackedLink/trackedLink';
import UtilsController from './js_components/utils';

const MOJFrontend = require('@ministryofjustice/frontend/moj/all');

Sentry.init({
  // `sentryConfig` is set from the application layout
  dsn: window.sentryConfig.dsn,
  integrations: [Sentry.replayIntegration()],
  replaysSessionSampleRate: 0,
  replaysOnErrorSampleRate: 1.0,
  environment: window.sentryConfig.environment,
  release: window.sentryConfig.release,
  tracesSampleRate: 0, // Disable tracing (performance monitoring, doesn't impact errors)
  ignoreErrors: [/'Object\.prototype\.hasOwnProperty\.call\([eo],"telephone"\)'/],
});

const application = Application.start();

application.warnings = false;
application.debug = false;
window.Stimulus = application;

application.register('autocomplete', AutocompleteController);
application.register('clipboard', ClipboardController);
application.register('cookies-banner', CookiesBannerController);
application.register('filters', FiltersController);
application.register('form', FormController);
application.register('location-finder', LocationFinderController);
application.register('manage-qualifications', ManageQualificationsController);
application.register('map', MapController);
application.register('map-sidebar', MapSidebarController);
application.register('panel', PanelController);
application.register('searchable-collection', SearchableCollectionComponent);
application.register('editor', EditorController);
application.register('editor-preview', EditorPreviewController);
application.register('show-hidden-content', ShowHiddenContentController);
application.register('tracked-link', TrackedLinkController);
application.register('utils', UtilsController);

Rails.start();
govukFrontend.initAll();
window.$ = $;
mojFrontend.initAll();

if (typeof mojFrontend.MultiFileUpload !== 'undefined') {
  // eslint-disable-next-line no-new
  new MOJFrontend.MultiFileUpload({
    container: document.querySelector('.moj-multi-file-upload'),
    uploadUrl: '/ajax-upload-url',
    deleteUrl: '/ajax-delete-url',
  });
}
