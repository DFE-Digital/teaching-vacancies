import '@stimulus/polyfills';
import { Application } from '@hotwired/stimulus';

import 'src/components';
import 'src/styles/application.scss';

// view components
import PanelController from '../../components/panel_component/panel';

// js components
import AutocompleteController from './components/autocomplete/autocomplete';
import ClipboardController from './components/clipboard/clipboard';
import LocationFinderController from './components/locationFinder/locationFinder';
import ManageQualificationsController from './components/manageQualifications/manageQualifications';
import UtilsController from './components/utils';
import UploadDocumentsController from './components/uploadDocuments/uploadDocuments';

const application = Application.start();

application.warnings = false;
application.debug = false;
window.Stimulus = application;

application.register('clipboard', ClipboardController);
application.register('manage-qualifications', ManageQualificationsController);
application.register('panel', PanelController);
application.register('utils', UtilsController);
application.register('autocomplete', AutocompleteController);
application.register('upload-documents', UploadDocumentsController);
application.register('locationFinder', LocationFinderController);
