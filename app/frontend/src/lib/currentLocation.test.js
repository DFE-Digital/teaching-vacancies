import currentLocation, {
  onSuccess, onFailiure, showErrorMessage, ERROR_MESSAGE,
} from './currentLocation';
import radius from '../search/ui/input/radius';

jest.mock('../search/ui/input/radius');

describe('location search box', () => {
  let showErrorMessageMock = null; let stopLoadingMock = null; let enableRadiusMock = null; let
    disableRadiusMock = null;

  beforeEach(() => {
    jest.resetAllMocks();

    currentLocation.showErrorMessage = jest.fn();
    showErrorMessageMock = jest.spyOn(currentLocation, 'showErrorMessage');

    currentLocation.stopLoading = jest.fn();
    stopLoadingMock = jest.spyOn(currentLocation, 'stopLoading');

    enableRadiusMock = jest.spyOn(radius, 'enableRadiusSelect');
    disableRadiusMock = jest.spyOn(radius, 'disableRadiusSelect');

    document.body.innerHTML = '<div class="js-location-finder"><input type="text" id="location" class="js-location-finder__input" /></div>';
  });

  describe('onFaliure', () => {
    test('updates the UI correctly and adds error message', () => {
      onFailiure();
      expect(document.getElementById('location').value).toBe('');
      expect(disableRadiusMock).toHaveBeenCalled();
      expect(stopLoadingMock).toHaveBeenCalled();
      expect(showErrorMessageMock).toHaveBeenCalled();
    });
  });

  describe('onSuccess', () => {
    test('updates the UI correctly and enables radius control', () => {
      onSuccess('W12 8QT', document.getElementById('location'));
      expect(document.getElementById('location').value).toBe('W12 8QT');
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
      expect(document.querySelector('.govuk-error-message').innerHTML).toBe(ERROR_MESSAGE);
    });
  });
});
