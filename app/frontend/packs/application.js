require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import Rails from 'rails-ujs';

import { initAll } from 'govuk-frontend';

import 'leaflet/dist/leaflet.css';
import 'leaflet.fullscreen/Control.FullScreen.css';

import 'src/application';
import 'src/components';

import 'leaflet.fullscreen/Control.FullScreen';

import 'src/styles/application.scss';

Rails.start();

initAll();
