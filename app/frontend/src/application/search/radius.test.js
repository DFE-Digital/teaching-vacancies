import {
  enableRadiusSelect,
  disableRadiusSelect,
} from './radius';

describe('Radius select', () => {
  describe('enableRadiusSelect', () => {
    describe('on the home page', () => {
      test('displays and enables radius select element', () => {
        document.body.innerHTML = `<div class="location-radius-select location-radius-select-inline-block">
        <select name="jobs_search_form[radius]" id="jobs-search-form-radius-field"><option value="1">1 mile</option><option value="5">5 miles</option></select></div>`;
        enableRadiusSelect();
        expect(document.querySelector('.location-radius-select').style.display).toBe('inline-block');
        expect(document.querySelector('#jobs-search-form-radius-field').disabled).toBe(false);
      });
    });

    describe('on the jobs page', () => {
      test('displays and enables radius select element', () => {
        document.body.innerHTML = `<div class="location-radius-select location-radius-select-block">
        <select name="jobs_search_form[radius]" id="jobs-search-form-radius-field"><option value="1">1 mile</option><option value="5">5 miles</option></select></div>`;
        enableRadiusSelect();
        expect(document.querySelector('.location-radius-select').style.display).toBe('block');
        expect(document.querySelector('#jobs-search-form-radius-field').disabled).toBe(false);
      });
    });
  });

  describe('disableRadiusSelect', () => {
    test('hides and disables radius select element', () => {
      document.body.innerHTML = `<div class="location-radius-select">
      <select name="jobs_search_form[radius]" id="jobs-search-form-radius-field"><option value="1">1 mile</option><option value="5">5 miles</option></select></div>`;
      disableRadiusSelect();
      expect(document.querySelector('.location-radius-select').style.display).toBe('none');
      expect(document.querySelector('#jobs-search-form-radius-field').disabled).toBe(true);
    });
  });
});
