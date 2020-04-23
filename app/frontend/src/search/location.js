/* global algoliasearch instantsearch */
import { transform, templates, renderHits } from './hits'
import { client, index } from './client'
import { renderSearchBox } from './ui/input'
import { renderAutocomplete } from './ui/autocomplete'
import { renderRadiusSelect } from './ui/radius'

const ALGOLIA_INDEX = 'Vacancy_production_location'
const SEARCH_PARAM_KEY = 'location'

const locationClient = client(ALGOLIA_INDEX)

const customSearchBox = instantsearch.connectors.connectSearchBox(renderSearchBox)

const customAutocomplete = instantsearch.connectors.connectAutocomplete(renderAutocomplete)

const customRadius = instantsearch.connectors.connectMenu(renderRadiusSelect)

const customHits = instantsearch.connectors.connectHits(renderHits)

// TODO link up with os geoloc
const locationIndex = index(ALGOLIA_INDEX);

// locationIndex.setSettings({
//     searchableAttributes: [
//         'school.region',
//         'school.town',
//         'school.county',
//         'school.postcode'
//     ],
//     customRanking: ['desc(links_count)'],
// }).then(() => { })

// locationIndex.search('', {
//     aroundLatLng: '40.71, -74.01'
// }).then(({ hits }) => {
//     console.log(hits);
// })

locationClient.addWidgets([
    customAutocomplete({
        container: document.querySelector('.js-location-finder'),
    }),
    customSearchBox({
        container: document.querySelector('.filters-form'),
        element: '.js-location-finder__input',
        key: SEARCH_PARAM_KEY
    }),
    // customRadius({
    //     container: document.querySelector('.filters-form'),
    //     element: '#radius',
    //     key: SEARCH_PARAM_KEY
    // }),
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

locationClient.start();
