require.context('govuk-frontend/govuk/assets');
require.context('../images', true)

import 'styles/application.scss';

import Rails from 'rails-ujs';

import 'src/addTitleToGoogleMapsIframe';
import 'src/deleteAccordionControl';
import 'src/deleteDocument';
import 'src/details';
import 'src/dismissableElement';
import 'src/enableRadiusFilter';
import 'src/fetchLocation';
import 'src/googleOptimise';
import 'src/googleTagManagerUrlSnippet';
import 'src/removeCommaFromNumber';
import 'src/shareUrl';
import 'src/sortJobList';
import 'src/submitFeedback';
import 'src/uploadDocuments';
import 'src/vacancyShow';

import { initAll } from 'govuk-frontend';

Rails.start();

initAll();

// Expose jQuery to window
window.$ = window.jQuery = $
