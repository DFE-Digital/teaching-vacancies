import algoliasearch from 'algoliasearch';
import instantsearch from 'instantsearch.js';

import { getFilters, getQuery } from './query';
import { getKeyword } from './ui/input/keyword';
import { getCoords } from './ui/input/location';
import { getRadius } from './ui/input/radius';

// This is the public API key which can be safely used in your frontend code.
// This key is usable for search queries and list the indices you've got access to.
export const search = algoliasearch('QM2YE0HRBW', '4082ba44346a92023eac1f794d739dd1');

export const searchClient = (indexName) => instantsearch({
  indexName,
  searchClient: search,
  searchFunction(helper) {
    onSearch(helper);
  },
});

export const onSearch = (helper) => {
  if (getCoords()) {
    helper.setState(getNewState(helper.state, { aroundLatLng: getCoords() }));
  }

  if (getRadius()) {
    helper.setState(getNewState(helper.state, { aroundRadius: getRadius() }));
    helper.setQuery(getKeyword());
  } else {
    helper.setState(getNewState(helper.state, { aroundRadius: 'all' }));
    helper.setQuery(getQuery());
  }

  helper.setState(getNewState(helper.state, { filters: getFilters() }));

  return helper.search();
};

export const index = (indexName) => search.initIndex(indexName);

export const getNewState = (state, add) => {
  const updatedState = { ...state, ...add };
  return updatedState;
};
