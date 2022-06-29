import * as Sentry from '@sentry/browser';

import 'core-js/modules/es.weak-map';
import 'core-js/modules/es.weak-set';
import '@stimulus/polyfills';

import { Application } from '@hotwired/stimulus';

// view components
import FiltersController from './components/filters_component/filters_component';
import MapController from './components/map_component/map_component';
import MapSidebarController from './components/map_component/sidebar';

// js components
import AutocompleteController from './js_components/autocomplete/autocomplete';
import ClipboardController from './js_components/clipboard/clipboard';
import FormController from './js_components/form/form';
import LocationFinderController from './js_components/locationFinder/locationFinder';
import ManageQualificationsController from './js_components/manageQualifications/manageQualifications';
import PanelController from './js_components/panel/panel';
import ShowHiddenContentController from './js_components/showHiddenContent/showHiddenContent';
import TrackedLinkController from './js_components/trackedLink/trackedLink';
import UploadDocumentsController from './js_components/uploadDocuments/uploadDocuments';
import UtilsController from './js_components/utils';

Sentry.init({
  // `sentryConfig` is set from the application layout
  dsn: window.sentryConfig.dsn,
  environment: window.sentryConfig.environment,
  release: window.sentryConfig.release,
  integrations: [],
  tracesSampleRate: 0, // Disable tracing (performance monitoring, doesn't impact errors)
});

const application = Application.start();

application.warnings = false;
application.debug = false;
window.Stimulus = application;

application.register('autocomplete', AutocompleteController);
application.register('clipboard', ClipboardController);
application.register('filters', FiltersController);
application.register('form', FormController);
application.register('location-finder', LocationFinderController);
application.register('manage-qualifications', ManageQualificationsController);
application.register('map', MapController);
application.register('map-sidebar', MapSidebarController);
application.register('panel', PanelController);
application.register('show-hidden-content', ShowHiddenContentController);
application.register('tracked-link', TrackedLinkController);
application.register('upload-documents', UploadDocumentsController);
application.register('utils', UtilsController);
