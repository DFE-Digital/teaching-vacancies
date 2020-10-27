require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import 'styles/application.scss';

import Rails from 'rails-ujs';

import 'src/addVacancyStateToDataLayer';
import 'src/deleteDocument';
import 'src/details';
import 'src/map';
import 'src/shareUrl';
import 'src/uploadDocuments';

import 'shared/filters_component/filters_component';
import 'shared/notification_component/notification_component';

import 'src/components/searchCheckbox';

import 'src/application/search/init';
import 'src/application/hiring_staff/init';
import 'src/application/init';

import { initAll } from 'govuk-frontend';

Rails.start();

initAll();

// Expose jQuery to window
window.$ = window.jQuery = $
