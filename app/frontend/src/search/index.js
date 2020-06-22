import 'core-js/stable';
import 'regenerator-runtime/runtime';
import '../polyfill/classlist.polyfill';

import {
  connectSearchBox, connectHits, connectSortBy, connectMenu, connectStats, connectPagination,
  connectSearchBox, connectHits, connectSortBy, connectMenu, connectStats,
} from 'instantsearch.js/es/connectors';
import { hits, configure } from 'instantsearch.js/es/widgets';

import { searchClient } from './client';

import { renderSearchBox } from './ui/input';
import { templates, renderContent } from './ui/hits';
import { onSubmit as locationSubmit } from './ui/input/location';
import { onSubmit as keywordSubmit } from './ui/input/keyword';
import { renderAutocomplete } from '../lib/autocomplete';
import { renderSortSelectInput } from './ui/sort';
import { renderPagination } from './ui/pagination';
import { renderStats } from './ui/stats';
import { renderRadiusSelect } from './ui/input/radius';
import { locations } from './data/locations';
import { updateUrlQueryParams, setDataAttribute } from '../lib/utils';
import { enableSubmitButton } from './ui/form';

const ALGOLIA_INDEX = 'Vacancy';
const SEARCH_THRESHOLD = 3;

const searchClientInstance = searchClient(ALGOLIA_INDEX);

const searchBox = connectSearchBox(renderSearchBox);
const heading = connectHits(renderContent);
const sortBy = connectSortBy(renderSortSelectInput);
const pagination = connectPagination(renderPagination);
const statsBottom = connectStats(renderStats);
const statsTop = connectStats(renderStats);
const locationRadius = connectMenu(renderRadiusSelect);

const locationSearchBox = searchBox({
  container: document.querySelector('.filters-form'),
  inputElement: document.getElementById('location'),
  key: 'location',
  autofocus: true,
  queryHook(query, search) {
    updateUrlQueryParams('location', document.querySelector('#location').value, window.location.href);
    search(query);
  },
  onSubmit: (query) => locationSubmit(query, locations, searchClientInstance),
});

const keywordSearchBox = searchBox({
  container: document.querySelector('.filters-form'),
  inputElement: document.getElementById('keyword'),
  key: 'keyword',
  autofocus: true,
  queryHook(query, search) {
    updateUrlQueryParams('keyword', document.querySelector('#keyword').value, window.location.href);
    search(query);
  },
  onSubmit: () => keywordSubmit(searchClientInstance),
});

searchClientInstance.addWidgets([
  configure({
    hitsPerPage: 10,
  }),
  locationSearchBox,
  keywordSearchBox,
  locationRadius({
    container: document.querySelector('#location-radius-select'),
    attribute: '_geoloc',
    inputElement: document.getElementById('radius'),
    onSelection: (radiusInMiles) => {
      updateUrlQueryParams('radius', radiusInMiles, window.location.href);
      setDataAttribute(document.querySelector('#radius'), 'radius', radiusInMiles);
      enableSubmitButton(document.querySelector('.filters-form'));
    },
  }),
  sortBy({
    container: document.querySelector('#jobs_sort_form'),
    element: document.querySelector('#jobs_sort_select'),
    items: [
      { label: 'most relevant first', value: 'Vacancy' },
      { label: 'newest job listing', value: 'Vacancy_publish_on_desc' },
      { label: 'least time to apply', value: 'Vacancy_expiry_time_asc' },
      { label: 'most time to apply', value: 'Vacancy_expiry_time_desc' },
    ],
  }),
  pagination({
    container: document.querySelector('.pagination-results'),
    scrollTo: document.querySelector('#main-content'),
    padding: 2,
  }),
  statsBottom({
    container: document.querySelector('#vacancies-stats-bottom'),
  }),
  statsTop({
    container: document.querySelector('#vacancies-stats-top'),
  }),
  heading({
    container: document.querySelector('#job-count'),
    threshold: SEARCH_THRESHOLD,
  }),
  hits({
    container: '#vacancies-hits',
    templates,
    cssClasses: {
      list: ['vacancies'],
      item: 'vacancy',
    },
  }),
]);

document.querySelector('.filters-form').addEventListener('submit', (e) => {
  e.preventDefault();
  if (!searchClientInstance.started) {
    searchClientInstance.start();
  }
});

renderAutocomplete({
  container: document.querySelector('#location-search'),
  input: document.querySelector('#location'),
  dataset: locations,
  threshold: SEARCH_THRESHOLD,
  onSelection: (value) => {
    updateUrlQueryParams('location', value, window.location.href);
  },
});
