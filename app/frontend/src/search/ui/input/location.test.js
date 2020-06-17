import { shouldNotGeocode, onSubmit, geocodeSuccess } from './location';
import { locations } from '../../data/locations';

import { getGeolocatedCoordinates } from '../../../lib/api';
import { enableRadiusSelect, disableRadiusSelect } from './radius';

jest.mock('../../../lib/api');
jest.mock('./radius');

describe('location search box', () => {
  const client = {};
  let performSearch = null;

  beforeEach(() => {
    jest.resetAllMocks();

    client.refresh = jest.fn();
    performSearch = jest.spyOn(client, 'refresh');

    getGeolocatedCoordinates.mockReturnValue(Promise.resolve({ success: true }));
  });

  describe('shouldNotGeocode', () => {
    test('returns false if location is not in predefined list or matches a postcode pattern', () => {
      expect(shouldNotGeocode('harlow', locations)).toBe(false);
      expect(shouldNotGeocode('SE17 4BT', locations)).toBe(false);
    });

    test('returns true if location is in predefined list', () => {
      expect(shouldNotGeocode('london', locations)).toBe(true);
    });
  });

  describe('onSubmit getGeolocatedCoordinates', () => {
    test('is called once if location provided that is not in predefined list', () => {
      onSubmit('harlow', locations, client);
      expect(getGeolocatedCoordinates).toHaveBeenCalledTimes(1);
      expect(getGeolocatedCoordinates).toHaveBeenCalledWith('harlow');
    });

    test('is called once if location is detected to be a postcode', () => {
      onSubmit('w12 8qt', locations, client);
      expect(getGeolocatedCoordinates).toHaveBeenCalledTimes(1);
      expect(getGeolocatedCoordinates).toHaveBeenCalledWith('w12 8qt');
    });
  });

  describe('onSubmit getGeolocatedCoordinates', () => {
    test('does not get called if location supplied that exists in predefined list and radius disabled', () => {
      onSubmit('london', locations, client);
      expect(disableRadiusSelect).toHaveBeenCalledTimes(1);
      expect(getGeolocatedCoordinates).not.toHaveBeenCalled();
    });
  });

  describe('geocodeSuccess', () => {
    test('does not performs search if unsuccesful', () => {
      const coords = { success: false };
      geocodeSuccess(coords, client);
      expect(performSearch).not.toHaveBeenCalled();
    });

    test('performs a search if successful and radius is enabled', () => {
      const coords = { success: true };
      geocodeSuccess(coords, client);
      expect(enableRadiusSelect).toHaveBeenCalledTimes(1);
      expect(performSearch).toHaveBeenCalled();
      expect(performSearch).toHaveBeenCalledTimes(1);
    });
  });
});
