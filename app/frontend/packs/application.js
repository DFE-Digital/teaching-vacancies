require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import Rails from 'rails-ujs';

import { initAll } from 'govuk-frontend';

initAll();

import 'leaflet/dist/leaflet.css';

import 'src/application';
import 'src/components';

import 'src/styles/application.scss';

Rails.start();
