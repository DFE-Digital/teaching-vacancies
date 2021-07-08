/**
 * @jest-environment jsdom
 */

import locationFinder, {
  startLoading, stopLoading, onSuccess, onFailure, showErrorMessage, ERROR_MESSAGE, DEFAULT_PLACEHOLDER, LOADING_PLACEHOLDER, postcodeFromPosition,
} from './locationFinder';
import loader from '../loader/loader';

describe('current location', () => {
  let showErrorMessageMock = null; let stopLoadingMock = null; let onSuccessMock = null; let
    onFailureMock = null; let addLoaderMock = null; let removeLoaderMock = null; let input = null; let container = null;

  beforeEach(() => {
    jest.resetAllMocks();

    locationFinder.showErrorMessage = jest.fn();
    showErrorMessageMock = jest.spyOn(locationFinder, 'showErrorMessage');

    locationFinder.stopLoading = jest.fn();
    stopLoadingMock = jest.spyOn(locationFinder, 'stopLoading');

    loader.add = jest.fn();
    addLoaderMock = jest.spyOn(loader, 'add');

    loader.remove = jest.fn();
    removeLoaderMock = jest.spyOn(loader, 'remove');

    document.body.innerHTML = `<div class="js-location-finder" id="test-container">
<input type="text" id="form-location-field" class="js-location-finder__input" />
</div>`;

    input = document.getElementById('form-location-field');
    container = document.getElementById('test-container');
  });

  describe('startLoading', () => {
    test('adds loader to UI', () => {
      startLoading(container, input);
      expect(addLoaderMock).toHaveBeenCalledWith(input, LOADING_PLACEHOLDER);
      expect(removeLoaderMock).not.toHaveBeenCalled();
    });
  });

  describe('stopLoading', () => {
    test('removes loader from UI', () => {
      stopLoading(container, input);
      expect(addLoaderMock).not.toHaveBeenCalled();
      expect(removeLoaderMock).toHaveBeenCalledWith(input, DEFAULT_PLACEHOLDER);
    });
  });

  describe('onFaliure', () => {
    test('updates the UI correctly and adds error message', () => {
      onFailure();
      expect(input.value).toBe('');
      expect(stopLoadingMock).toHaveBeenCalled();
      expect(showErrorMessageMock).toHaveBeenCalled();
    });
  });

  describe('onSuccess', () => {
    test('updates the UI correctly', () => {
      onSuccess('W12 8QT', input);
      expect(input.value).toBe('W12 8QT');
      expect(stopLoadingMock).toHaveBeenCalled();
      expect(showErrorMessageMock).not.toHaveBeenCalled();
    });
  });

  describe('showErrorMessage', () => {
    beforeEach(() => {
      jest.resetAllMocks();
      document.body.innerHTML = '<div class="js-location-finder"><a href="/" id="current-location" data-loader="form-location-field">link</a></div>';
    });

    test('displays correct message in error displayed', () => {
      showErrorMessage(document.getElementById('current-location'));
      expect(document.getElementById('js-location-finder__error').innerHTML).toBe(ERROR_MESSAGE);
    });
  });

  describe('postcodeFromPosition', () => {
    beforeEach(() => {
      jest.resetAllMocks();
      locationFinder.onSuccess = jest.fn();
      onSuccessMock = jest.spyOn(locationFinder, 'onSuccess');

      locationFinder.onFailure = jest.fn();
      onFailureMock = jest.spyOn(locationFinder, 'onFailure');
    });

    test('calls onSuccess handler when API returns postcode', () => {
      postcodeFromPosition({
        coords: {
          latitude: 10,
          longitude: 10,
        },
      }, () => Promise.resolve({ status: 200, result: [{ postcode: 'E2 0BT' }] }))
        .then(() => {
          expect(onSuccessMock).toHaveBeenCalled();
          expect(onFailureMock).not.toHaveBeenCalled();
        })
        .catch(() => true);
    });

    test('calls onFailure handler when API returns falsy value', () => {
      postcodeFromPosition({
        coords: {
          latitude: 10,
          longitude: 10,
        },
      }, () => Promise.resolve({ status: 200, result: null }))
        .then(() => {
          expect(onFailureMock).toHaveBeenCalled();
          expect(onSuccessMock).not.toHaveBeenCalled();
        })
        .catch(() => true);
    });
  });
});
