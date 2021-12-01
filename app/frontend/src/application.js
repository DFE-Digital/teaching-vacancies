import '@stimulus/polyfills';
import { Application } from '@hotwired/stimulus';

// view components
import PanelController from '../../components/panel_component/panel';

// js components
import AutocompleteController from './components/autocomplete/autocomplete';
import ClipboardController from './components/clipboard/clipboard';
import LocationFinderController from './components/locationFinder/locationFinder';
import ManageQualificationsController from './components/manageQualifications/manageQualifications';
import UploadDocumentsController from './components/uploadDocuments/uploadDocuments';
import UtilsController from './components/utils';

const application = Application.start();

application.warnings = false;
application.debug = false;
window.Stimulus = application;

application.register('autocomplete', AutocompleteController);
application.register('clipboard', ClipboardController);
application.register('locationFinder', LocationFinderController);
application.register('manage-qualifications', ManageQualificationsController);
application.register('panel', PanelController);
application.register('upload-documents', UploadDocumentsController);
application.register('utils', UtilsController);
