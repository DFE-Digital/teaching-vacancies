require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import Rails from 'rails-ujs';

import { initAll } from 'govuk-frontend';

import 'src/components';

import 'src/styles/application.scss';

import 'src/application';
import 'src/application/init';

Rails.start();

initAll();
