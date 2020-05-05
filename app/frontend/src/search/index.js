import { connectSearchBox, connectAutocomplete, connectHits, connectSortBy, connectMenu } from 'instantsearch.js/es/connectors';
import { hits, pagination, configure } from 'instantsearch.js/es/widgets';

import { transform, templates, renderHeading } from './hits';
import { searchClient } from './client';

import { renderSearchBox } from './ui/input';
import { renderAutocomplete } from './ui/autocomplete';
import { renderSortSelect } from './ui/sort';
import { renderRadiusSelect } from './ui/radius';
import { locations } from './data/locations';
import { updateUrlQueryParams } from './utils';
import { getCoordinates } from './geoloc';

const ALGOLIA_INDEX = 'Vacancy';

const searchClientInstance = searchClient(ALGOLIA_INDEX);

const searchBox = connectSearchBox(renderSearchBox);
const autocomplete = connectAutocomplete(renderAutocomplete);
const heading = connectHits(renderHeading);
const sortBy = connectSortBy(renderSortSelect);
const locationRadius = connectMenu(renderRadiusSelect);

const locationSearchBox = searchBox({
    container: document.querySelector('.filters-form'),
    element: '#location',
    key: 'location',
});


searchClientInstance.addWidgets([
    configure({
        hitsPerPage: 10,
    }),
    autocomplete({
        container: document.querySelector('.js-location-finder'),
        dataset: locations,
        threshold: 3,
        onSelection: value => {
            getCoordinates(value).then(coords => {
                console.log('onSelection getCoordinates', value, coords, searchClientInstance.mainIndex);
                document.querySelector('#radius').removeAttribute('disabled');
                document.querySelector('#location').dataset.coordinates = `${coords.lat}, ${coords.lng}`;
                locationSearchBox._refine(value);
            });
            // updateUrlQueryParams('location', value, window.location.href)
        }
    }),
    locationSearchBox,
    searchBox({
        container: document.querySelector('.filters-form'),
        element: '#job_title',
        key: 'job_title',
        // queryHook(query, search) {
        //     query ? updateUrlQueryParams('job_title', query, window.location.href) : false;
        //     search(query);
        // },
    }),
    
    locationRadius({
        container: document.querySelector('#location-radius-select'),
        attribute: '_geoloc',
        element: '#radius',
        onSelection: value => {
            document.querySelector('#location').dataset.radius = `${value}`;
            searchClientInstance.refresh();
        }
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
    heading({
        container: document.querySelector('#job-count'),
    }),
    hits({
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
        pagination({
            container: '#pagination-hits',
            cssClasses: {
                list: ['pagination'],
                item: 'pagination__item'
            },
        }),
    ]);
}

searchClientInstance.start();
