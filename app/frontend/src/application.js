import { Application } from '@hotwired/stimulus';

import './lib/polyfill/promise.polyfill';

import ClipboardController from './components/clipboard/clipboard';
import ManageQualificationsController from './components/manageQualifications/manageQualifications';
import PanelController from '../../components/panel_component/panel';
import UtilsController from './components/utils';
import AutocompleteController from './components/autocomplete/autocomplete';
import UploadDocumentsController from './components/uploadDocuments/uploadDocuments';

const application = Application.start();

application.warnings = true;
application.debug = false;
window.Stimulus = application;

application.register('clipboard', ClipboardController);
application.register('manage-qualifications', ManageQualificationsController);
application.register('panel', PanelController);
application.register('utils', UtilsController);
application.register('autocomplete', AutocompleteController);
application.register('upload-documents', UploadDocumentsController);
