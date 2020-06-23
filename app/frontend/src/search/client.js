import algoliasearch from 'algoliasearch';
import instantsearch from 'instantsearch.js';

import { getFilters, getQuery } from './query';
import { getKeyword } from './ui/input/keyword';
import { getCoords, getPolygon } from './ui/input/location';
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

export const getNewState = (state, add) => {
  const updatedState = { ...state, ...add };
  return updatedState;
};

export const onSearch = (helper) => {
  const page = helper.getPage(); // subsequent setQuery calls reset the page to 0

  if (getCoords()) {
    helper.setState(getNewState(helper.state, { aroundLatLng: getCoords() }));
  }

  if (getPolygon()) {
    helper.setState(getNewState(helper.state, { insidePolygon: getPolygon() }));
  }

  if (getRadius()) {
    helper.setState(getNewState(helper.state, { aroundRadius: getRadius() }));
  } else {
    helper.setState(getNewState(helper.state, { aroundRadius: 'all' }));
  }

  if (getRadius() || getPolygon()) {
    helper.setQuery(getKeyword());
  } else {
    helper.setQuery(getQuery());
  }

  helper.setState(getNewState(helper.state, { filters: getFilters() }));

  helper.setPage(page);

  return helper.search();
};

export const index = (indexName) => search.initIndex(indexName);
