require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import 'styles/application.scss';

import Rails from 'rails-ujs';

import 'src/modules/search/init';
import 'src/patterns/currentLocation';
import 'src/components/searchCheckbox';

import 'src/addTitleToGoogleMapsIframe';
import 'src/addVacancyStateToDataLayer';
import 'src/deleteDocument';
import 'src/details';
import 'src/googleOptimise';
import 'src/googleTagManagerUrlSnippet';
import 'src/map';
import 'src/shareUrl';
import 'src/submitFeedback';
import 'src/uploadDocuments';

import 'shared/filters_component/filters_component';
import 'shared/notification_component/notification_component';

import { initAll } from 'govuk-frontend';

Rails.start();

initAll();

// Expose jQuery to window
window.$ = window.jQuery = $
