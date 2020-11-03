require.context('govuk-frontend/govuk/assets');
require.context('../images', true);

import Rails from 'rails-ujs';
import { initAll } from 'govuk-frontend';

import 'src/styles/application.scss';

import 'src/application/init';

import 'shared/filters_component/filters_component';
import 'shared/notification_component/notification_component';

Rails.start();

initAll();
