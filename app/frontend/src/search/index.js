/* global instantsearch window */

import { transform, templates, renderHits } from './hits';
import { searchClient } from './client';
import { renderSearchBox } from './ui/input';
import { renderAutocomplete } from './ui/autocomplete';
import { renderSortSelect } from './ui/sort';
import { locations } from './data/locations';
import { updateUrlQueryParams } from './utils';

const ALGOLIA_INDEX = 'Vacancy_production';

const searchClientInstance = searchClient(ALGOLIA_INDEX);

const searchBox = instantsearch.connectors.connectSearchBox(renderSearchBox);
const autocomplete = instantsearch.connectors.connectAutocomplete(renderAutocomplete);
const hits = instantsearch.connectors.connectHits(renderHits);
const sortBy = instantsearch.connectors.connectSortBy(renderSortSelect);

const locationSearchBoxInstance = searchBox({
    container: document.querySelector('.filters-form'),
    element: '#location',
    key: 'location',
    queryHook(query, search) {
        query ? updateUrlQueryParams('location', query, window.location.href) : false;
        search(query);
    },
});

searchClientInstance.addWidgets([
    autocomplete({
        container: document.querySelector('.js-location-finder'),
        dataset: locations,
        threshold: 3,
        onSelection: value => {
            locationSearchBoxInstance._refine(value);
            document.querySelector('#location').value = value;
        }
    }),
    searchBox({
        container: document.querySelector('.filters-form'),
        element: '#job_title',
        key: 'job_title',
        queryHook(query, search) {
            query ? updateUrlQueryParams('job_title', query, window.location.href) : false;
            search(query);
        },
    }),
    locationSearchBoxInstance,
    sortBy({
        container: document.querySelector('#jobs_sort_form'),
        element: '#jobs_sort',
        items: [
            { label: 'Newest job listing', value: 'Vacancy_production_newest_listing' },
            { label: 'Oldest job listing', value: 'Vacancy_production_oldest_listing' },
            { label: 'Newest closing date', value: 'Vacancy_production_newest_closing' },
            { label: 'Oldest closing date', value: 'Vacancy_production_oldest_closing' },
        ],
    }),
    hits({
        container: document.querySelector('#job-count'),
    }),
    instantsearch.widgets.hits({
        container: '#vacancies-hits',
        transformItems(items) {
            return transform(items);
        },
        templates,
        cssClasses: {
            list: ['vacancies'],
            item: 'vacancy'
        },
    }),
]);

if (document.querySelector('#pagination-hits')) {
    searchClientInstance.addWidgets([
        instantsearch.widgets.pagination({
            container: '#pagination-hits',
            cssClasses: {
                list: ['pagination'],
                item: 'pagination__item'
            },
        }),
    ]);
}

searchClientInstance.start();
