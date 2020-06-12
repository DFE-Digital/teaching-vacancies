import { getNewState, onSearch } from './client';

import { getKeyword } from './ui/input/keyword';
import { getCoords } from './ui/input/location';
import { getFilters } from './query';
import { getRadius } from './ui/input/radius';

describe('getNewState', () => {
    test('updates the state object with new properties', () => {
        expect(getNewState(
            { prop: 'has this' },
            { newProp: 'add'}
        )).toStrictEqual({
            prop: 'has this',
            newProp: 'add'
        });

        expect(getNewState(
            { prop: 'has this' },
            { prop: 'overwrite'}
        )).toStrictEqual({
            prop: 'overwrite'
        });
    });

    test('does not mutate state', () => {
        const state = { prop: 'has this' };
        getNewState(state,  { newProp: 'add'});
        expect(state).toStrictEqual({
            prop: 'has this'
        });
    });
});

jest.mock('./ui/input/location');
jest.mock('./ui/input/radius');
jest.mock('./ui/input/keyword');
jest.mock('./query');

describe('onSearch', () => {

    const helper = {};
    let performSearch = null, setState = null, setQuery = null;

    beforeEach(() => {
        jest.resetAllMocks();

        helper.search = jest.fn();
        performSearch = jest.spyOn(helper, 'search');
    
        helper.setState = jest.fn();
        setState = jest.spyOn(helper, 'setState');
    
        helper.setQuery = jest.fn();
        setQuery = jest.spyOn(helper, 'setQuery');
    });

    test('search state is correctly set when coordinates of location present only', () => {

        getCoords.mockReturnValue('51.7687925059338, 0.09572273060949459');
        getFilters.mockReturnValue('filters');
        getRadius.mockReturnValue(undefined);

        onSearch(helper);
        expect(getCoords).toHaveBeenCalledTimes(2);
        expect(performSearch).toHaveBeenCalledTimes(1);
        expect(setState).toHaveBeenNthCalledWith(1, {'aroundLatLng': '51.7687925059338, 0.09572273060949459'});
        expect(setState).toHaveBeenNthCalledWith(2, {'aroundRadius': 'all'});
        expect(setState).toHaveBeenNthCalledWith(3, {'filters': 'filters'});
        expect(setQuery).toHaveBeenCalledTimes(1);
        expect(getFilters).toHaveBeenCalledTimes(1);
    });

    test('search state is correctly set when no coordinates available', () => {

        getCoords.mockReturnValue(undefined);
        getFilters.mockReturnValue('filters');
        getRadius.mockReturnValue(undefined);

        onSearch(helper);
        expect(getCoords).toHaveBeenCalledTimes(1);
        expect(performSearch).toHaveBeenCalledTimes(1);
        expect(setState).toHaveBeenNthCalledWith(1, {'aroundRadius': 'all'});
        expect(setState).toHaveBeenNthCalledWith(2, {'filters': 'filters'});
        expect(setQuery).toHaveBeenCalledTimes(1);
        expect(getFilters).toHaveBeenCalledTimes(1);
    });

    test('search state is correctly set when coordinates available and radius given', () => {

        getCoords.mockReturnValue('51.7687925059338, 0.09572273060949459');
        getFilters.mockReturnValue('filters');
        getRadius.mockReturnValue(10);
        getKeyword.mockReturnValue('physics');

        onSearch(helper);
        expect(getCoords).toHaveBeenCalledTimes(2);
        expect(performSearch).toHaveBeenCalledTimes(1);
        expect(setState).toHaveBeenNthCalledWith(1, {'aroundLatLng': '51.7687925059338, 0.09572273060949459'});
        expect(setState).toHaveBeenNthCalledWith(2, {'aroundRadius': 10});
        expect(setState).toHaveBeenNthCalledWith(3, {'filters': 'filters'});
        expect(setQuery).toHaveBeenCalledTimes(1);
        expect(getFilters).toHaveBeenCalledTimes(1);
    });

    test('interacts with instant search correctly', () => {

        getCoords.mockReturnValue(undefined);
        getFilters.mockReturnValue('filters');
        getRadius.mockReturnValue(10);

        onSearch(helper);
        expect(getCoords).toHaveBeenCalledTimes(1);
        expect(performSearch).toHaveBeenCalledTimes(1);
        expect(setState).toHaveBeenNthCalledWith(1, {'aroundRadius': 10});
        expect(setState).toHaveBeenNthCalledWith(2, {'filters': 'filters'});
        expect(setQuery).toHaveBeenCalledTimes(1);
        expect(getFilters).toHaveBeenCalledTimes(1);
    });
});
