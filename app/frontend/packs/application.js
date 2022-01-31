console.log('db1');
require.context('govuk-frontend/govuk/assets');
console.log('db2');
require.context('../images', true);
console.log('db3');

import Rails from 'rails-ujs';
console.log('db4');

const HTMLDocument = window.HTMLDocument;

console.log('db5');

import { initAll } from 'govuk-frontend';
console.log('db6');

import 'leaflet/dist/leaflet.css';

import 'src/application';
import 'src/components';

import 'src/styles/application.scss';

Rails.start();

initAll();
