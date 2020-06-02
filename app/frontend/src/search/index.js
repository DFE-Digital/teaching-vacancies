/* global window */

import 'core-js/stable';
import 'regenerator-runtime/runtime';
import '../polyfill/classlist.polyfill';

import { connectSearchBox, connectAutocomplete, connectHits, connectSortBy, connectMenu } from 'instantsearch.js/es/connectors';
import { hits, pagination, configure } from 'instantsearch.js/es/widgets';

import { transform, templates, renderContent } from './hits';
import { searchClient } from './client';

import { renderSearchBox } from './ui/input';
import { renderAutocomplete } from '../lib/autocomplete';
import { renderSortSelect } from './ui/sort';
import { renderRadiusSelect, enableRadiusSelect, disableRadiusSelect } from './ui/radius';
import { locations } from './data/locations';
import { updateUrlQueryParams, stringMatchesPostcode, removeDataAttribute, setDataAttribute } from '../lib/utils';
import { getGeolocatedCoordinates } from '../lib/api';
import { enableSubmitButton } from './ui/form';

if (document.querySelector('#vacancies-hits')) {
    const ALGOLIA_INDEX = 'Vacancy';
    const SEARCH_THRESHOLD = 3;

    const searchClientInstance = searchClient(ALGOLIA_INDEX);

    const searchBox = connectSearchBox(renderSearchBox);
    const autocomplete = connectAutocomplete(renderAutocomplete);
    const heading = connectHits(renderContent);
    const sortBy = connectSortBy(renderSortSelect);
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
        onChange: (query) => {
            return new Promise(resolve => {
                if (stringMatchesPostcode(query) || (query.length && locations.indexOf(query.toLowerCase()) === -1)) {
                    getGeolocatedCoordinates(query).then(coords => {
                        coords.success ? enableRadiusSelect() : disableRadiusSelect();
                        setDataAttribute(document.querySelector('#location'), 'coordinates', `${coords.lat}, ${coords.lng}`);
                        setDataAttribute(document.querySelector('#radius'), 'radius', document.querySelector('#radius').value || 10);
                        resolve();
                    });
                } else {
                    disableRadiusSelect();
                    removeDataAttribute(document.querySelector('#location'), 'coordinates');
                    removeDataAttribute(document.querySelector('#radius'), 'radius');
                    resolve();
                }
            });
        }
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
        onChange: () => new Promise(resolve => resolve())
    });

    searchClientInstance.addWidgets([
        configure({
            hitsPerPage: 10,
        }),
        autocomplete({
            container: document.querySelector('#location-search'),
            input: document.querySelector('#location'),
            dataset: locations,
            threshold: SEARCH_THRESHOLD,
            onSelection: value => {
                updateUrlQueryParams('location', value, window.location.href);
            }
        }),
        locationSearchBox,
        keywordSearchBox,
        locationRadius({
            container: document.querySelector('#location-radius-select'),
            attribute: '_geoloc',
            inputElement: document.getElementById('radius'),
            onSelection: location => {
                updateUrlQueryParams('radius', location, window.location.href);
                setDataAttribute(document.querySelector('#radius'), 'radius', location);
                enableSubmitButton(document.querySelector('.filters-form'));
            }
        }),
        sortBy({
            container: document.querySelector('#jobs_sort_form'),
            element: '#jobs_sort',
            items: [
                { label: 'Most relevant', value: 'Vacancy' },
                { label: 'Newest job listing', value: 'Vacancy_publish_on_desc' },
                { label: 'Oldest job listing', value: 'Vacancy_publish_on_asc' },
                { label: 'Least time to apply', value: 'Vacancy_expiry_time_asc' },
                { label: 'Most time to apply', value: 'Vacancy_expiry_time_desc' },
            ],
        }),
        heading({
            container: document.querySelector('#job-count'),
            alert: document.querySelector('.vacancies-count'),
            threshold: SEARCH_THRESHOLD,
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
                    item: 'pagination__item',
                    selectedItem: 'active'
                },
            }),
        ]);
    }

    searchClientInstance.start();
}

