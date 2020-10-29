require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import 'styles/application.scss';

import Rails from 'rails-ujs';

import 'src/application/init';

import 'src/deleteDocument';
import 'src/uploadDocuments';

import 'shared/filters_component/filters_component';
import 'shared/notification_component/notification_component';

import { initAll } from 'govuk-frontend';

Rails.start();

initAll();

// Expose jQuery to window
window.$ = window.jQuery = $
