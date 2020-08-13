import currentLocation, {
  startLoading, stopLoading, onSuccess, onFailure, showErrorMessage, ERROR_MESSAGE, DEFAULT_PLACEHOLDER, LOADING_PLACEHOLDER, postcodeFromPosition,
} from './currentLocation';
import radius from '../../../search/ui/input/radius';
import loader from '../components/loader';

jest.mock('../../../search/ui/input/radius');

describe('current location', () => {
  let showErrorMessageMock = null; let stopLoadingMock = null; let enableRadiusMock = null; let
    disableRadiusMock = null; let onSuccessMock = null; let
    onFailureMock = null; let addLoaderMock = null; let removeLoaderMock = null; let input = null; let container = null;

  beforeEach(() => {
    jest.resetAllMocks();

    currentLocation.showErrorMessage = jest.fn();
    showErrorMessageMock = jest.spyOn(currentLocation, 'showErrorMessage');

    currentLocation.stopLoading = jest.fn();
    stopLoadingMock = jest.spyOn(currentLocation, 'stopLoading');

    enableRadiusMock = jest.spyOn(radius, 'enableRadiusSelect');
    disableRadiusMock = jest.spyOn(radius, 'disableRadiusSelect');

    loader.add = jest.fn();
    addLoaderMock = jest.spyOn(loader, 'add');

    loader.remove = jest.fn();
    removeLoaderMock = jest.spyOn(loader, 'remove');

    document.body.innerHTML = `<div class="js-location-finder" id="test-container">
<input type="text" id="jobs-search-form-location-field" class="js-location-finder__input" />
</div>`;

    input = document.getElementById('jobs-search-form-location-field');
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
      expect(document.getElementById('jobs-search-form-location-field').value).toBe('');
      expect(disableRadiusMock).toHaveBeenCalled();
      expect(stopLoadingMock).toHaveBeenCalled();
      expect(showErrorMessageMock).toHaveBeenCalled();
    });
  });

  describe('onSuccess', () => {
    test('updates the UI correctly and enables radius control', () => {
      onSuccess('W12 8QT', document.getElementById('jobs-search-form-location-field'));
      expect(document.getElementById('jobs-search-form-location-field').value).toBe('W12 8QT');
      expect(enableRadiusMock).toHaveBeenCalled();
      expect(stopLoadingMock).toHaveBeenCalled();
      expect(showErrorMessageMock).not.toHaveBeenCalled();
    });
  });

  describe('showErrorMessage', () => {
    beforeEach(() => {
      jest.resetAllMocks();
      document.body.innerHTML = '<div class="js-location-finder"><a href="" id="current-location">link</a></div>';
    });

    test('displays correct message in error displayed', () => {
      showErrorMessage(document.getElementById('current-location'));
      expect(document.getElementById('js-location-finder__error').innerHTML).toBe(ERROR_MESSAGE);
    });
  });

  describe('postcodeFromPosition', () => {
    beforeEach(() => {
      jest.resetAllMocks();
      currentLocation.onSuccess = jest.fn();
      onSuccessMock = jest.spyOn(currentLocation, 'onSuccess');

      currentLocation.onFailure = jest.fn();
      onFailureMock = jest.spyOn(currentLocation, 'onFailure');
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
        });
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
        });
    });
  });
});
