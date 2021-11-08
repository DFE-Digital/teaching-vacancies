import { Application } from '@hotwired/stimulus';

import PanelController from '../../components/panel_component/panel';
import UtilsController from './components/utils';

const application = Application.start();

application.warnings = true;
application.debug = false;
window.Stimulus = application;

application.register('panel', PanelController);
application.register('utils', UtilsController);
