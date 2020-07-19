import {
  enableRadiusSelect,
  disableRadiusSelect,
} from './radius';

describe('Radius select', () => {
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
});
