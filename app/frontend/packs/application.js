require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import Rails from 'rails-ujs';
import { initAll } from 'govuk-frontend';

import 'src/styles/application.scss';

import 'src/application/init';

import "src/components";

Rails.start();

initAll();
