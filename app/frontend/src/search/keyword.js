/* global algoliasearch instantsearch */
import { transform, templates, renderHits } from './hits'
import { client } from './client'
import { renderSearchBox } from './ui/input'

const ALGOLIA_INDEX = 'Vacancy_production'
const SEARCH_PARAM_KEY = 'job_title'

const keywordClient = client(ALGOLIA_INDEX)

const customSearchBox = instantsearch.connectors.connectSearchBox(renderSearchBox)

const customHits = instantsearch.connectors.connectHits(renderHits)

keywordClient.addWidgets([
    customSearchBox({
        container: document.querySelector('.filters-form'),
        element: '#job_title',
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
