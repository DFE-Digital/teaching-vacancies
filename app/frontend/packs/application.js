require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import 'core-js/modules/es.weak-map';
import 'core-js/modules/es.weak-set';
import 'mutationobserver-shim';

import Rails from 'rails-ujs';

import { initAll } from 'govuk-frontend';

import 'leaflet/dist/leaflet.css';

import 'src/application';
import 'src/components';

import 'src/styles/application.scss';

Rails.start();

initAll();
