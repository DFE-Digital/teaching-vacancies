require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import Rails from 'rails-ujs';

const HTMLDocument = window.HTMLDocument;

console.log('db1');

import { initAll } from 'govuk-frontend';

import 'leaflet/dist/leaflet.css';

import 'src/application';
import 'src/components';

import 'src/styles/application.scss';

Rails.start();

initAll();
