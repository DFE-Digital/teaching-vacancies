require.context('govuk-frontend/govuk/assets');

import Rails from 'rails-ujs';

import { initAll } from 'govuk-frontend';

import 'src/application';
import 'src/components';

Rails.start();

initAll();
