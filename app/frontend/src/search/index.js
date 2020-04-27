/* global algoliasearch instantsearch */
import { transform, templates, renderHits } from './hits'
import { searchClient } from './client'
import { renderSearchBox } from './ui/input'
import { renderAutocomplete } from './ui/autocomplete'
import { renderSortSelect } from './ui/sort'

const ALGOLIA_INDEX = 'Vacancy_production'

const searchClientInstance = searchClient(ALGOLIA_INDEX)

const locationSearchBox = instantsearch.connectors.connectSearchBox(renderSearchBox)
const keywordSearchBox = instantsearch.connectors.connectSearchBox(renderSearchBox)
const autocomplete = instantsearch.connectors.connectAutocomplete(renderAutocomplete)
const hits = instantsearch.connectors.connectHits(renderHits)
const sortBy = instantsearch.connectors.connectSortBy(renderSortSelect);

searchClientInstance.addWidgets([
    autocomplete({
        container: document.querySelector('.js-location-finder'),
    }),
    keywordSearchBox({
        container: document.querySelector('.filters-form'),
        element: '#job_title',
        key: 'job_title'
    }),
    locationSearchBox({
        container: document.querySelector('.filters-form'),
        element: '.js-location-finder__input',
        key: 'location'
    }),
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
            return transform(items)
        },
        templates,
        cssClasses: {
            list: ['vacancies'],
            item: 'vacancy'
        },
    }),
]);

if (document.querySelector('#pagination-hits')) {
    keywordClient.addWidgets([
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
