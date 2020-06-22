import radiusSelect, { getRadius, enableRadiusSelect, disableRadiusSelect } from './radius';

describe('Radius select', () => {
  describe('getRadius', () => {
    test('to be truthy when radius data attribute is present', () => {
      document.body.innerHTML = `<select name="radius" id="radius" data-radius="10"><option value="1">1 mile</option>
      <option value="5">5 miles</option>
  </select>`;
      expect(getRadius()).toBe(16094);
    });

    test('to be false when radius data attribute is not present', () => {
      document.body.innerHTML = `<select name="radius" id="radius"><option value="1">1 mile</option>
      <option value="5">5 miles</option>
  </select>`;
      expect(getRadius()).toBe(false);
    });

    test('to be false when radius element is not present', () => {
      document.body.innerHTML = `<select name="radius" id="wrong-id"><option value="1">1 mile</option>
      <option value="5">5 miles</option>
  </select>`;
      expect(getRadius()).toBe(false);
    });
  });

  describe('enableRadiusSelect', () => {
    test('displays and enables radius select element', () => {
      document.body.innerHTML = `<div id="location-radius-select"><select name="radius" id="radius" data-radius="10"><option value="1">1 mile</option>
      <option value="5">5 miles</option>
  </select></div>`;
      enableRadiusSelect();
      expect(document.querySelector('#location-radius-select').style.display).toBe('block');
      expect(document.querySelector('#radius').disabled).toBe(false);
    });
  });

  describe('disableRadiusSelect', () => {
    test('hides and disables radius select element', () => {
      document.body.innerHTML = `<div id="location-radius-select"><select name="radius" id="radius" data-radius="10"><option value="1">1 mile</option>
      <option value="5">5 miles</option>
  </select></div>`;
      disableRadiusSelect();
      expect(document.querySelector('#location-radius-select').style.display).toBe('none');
      expect(document.querySelector('#radius').disabled).toBe(true);
    });
  });

  describe('renderRadiusSelect', () => {
    let disableRadiusSelectMock = null;
    let radiusSelectParams = {};

    beforeEach(() => {
      document.body.innerHTML = `<div id="location-radius-select"><select name="radius" id="radius" data-radius="10"><option value="1">1 mile</option>
      <option value="5">5 miles</option>
  </select></div>`;

      radiusSelectParams = {
        container: document.querySelector('#location-radius-select'),
        attribute: '_geoloc',
        inputElement: document.getElementById('radius'),
        onSelection: jest.fn(),
      };

      radiusSelect.disableRadiusSelect = jest.fn();

      disableRadiusSelectMock = jest.spyOn(radiusSelect, 'disableRadiusSelect');
    });

    test('does not disable radius select on first render', () => {
      radiusSelect.renderRadiusSelect({
        widgetParams: radiusSelectParams,
      }, true);
      expect(disableRadiusSelectMock).not.toHaveBeenCalled();
    });

    test('does not disable radius select on susequent renders', () => {
      radiusSelect.renderRadiusSelect({
        widgetParams: radiusSelectParams,
      }, false);
      expect(disableRadiusSelectMock).not.toHaveBeenCalled();
    });
  });
});
