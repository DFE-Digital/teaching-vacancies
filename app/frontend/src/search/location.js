/* global algoliasearch instantsearch */
import { transform, templates, renderHits } from './hits'
import { client } from './client'
import { renderSearchBox } from './ui/input'
import { renderAutocomplete } from './ui/autocomplete'

const ALGOLIA_INDEX = 'Vacancy_production_location'
const SEARCH_PARAM_KEY = 'location'

const keywordClient = client(ALGOLIA_INDEX)

const customSearchBox = instantsearch.connectors.connectSearchBox(renderSearchBox)

const customAutocomplete = instantsearch.connectors.connectAutocomplete(renderAutocomplete)

const customHits = instantsearch.connectors.connectHits(renderHits)

keywordClient.addWidgets([
    // index({ indexName: 'school.town' }),
    // index({ indexName: 'school.region' }),

    customAutocomplete({
        container: document.querySelector('.js-location-finder'),
    }),
    customSearchBox({
        container: document.querySelector('.filters-form'),
        element: '.js-location-finder__input',
        key: SEARCH_PARAM_KEY
    }),
    customHits({
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
    instantsearch.widgets.pagination({
        container: '#pagination-hits',
        cssClasses: {
            list: ['pagination'],
            item: 'pagination__item'
        },
    }),
]);

keywordClient.start();
