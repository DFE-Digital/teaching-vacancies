require 'rails_helper'

RSpec.feature 'Using the current location shortcut link', js: true do
  let(:dfe_postcode) { 'SW1P 2LU' }
  let(:dfe_lat) { 51.4980026 }
  let(:dfe_lon) { -0.1323527 }

  before do
    visit_path_with_simulated_location_api(root_path)
  end

  def visit_path_with_simulated_location_api(path)
    visit path
    simulate_location
    page.execute_script "$('.js-location-finder').addClass('js-geolocation-supported');"
  end

  def mock_postcodes_io(response_type = 200, null = false)
    fixture_path = "postcodes_io_#{response_type}#{'_null' if null}.json"
    response_text = response_type == 200 ? file_fixture(fixture_path).read : ''.to_json

    page.execute_script <<-JS
      #{file_fixture('jquery.mockjax.min.js').read}
      $.mockjaxSettings.logging = 0;

      $.mockjax({
        url: "https://api.postcodes.io/postcodes",
        status: #{response_type},
        responseText: #{response_text}
      });
    JS
  end

  def simulate_location(lat = dfe_lat, lng = dfe_lon)
    page.execute_script <<-JS
      navigator = navigator || {};
      navigator.geolocation = navigator.geolocation || {};
      navigator.geolocation.getCurrentPosition = function(success){
        var position = {"coords" : { "latitude": "#{lat}", "longitude": "#{lng}" }};
        success(position);
      }
    JS
  end

  context 'when call to postcodes.io succeed' do
    scenario 'fills in the location textfield' do
      mock_postcodes_io

      find('#current-location').click
      expect(page).to have_field('location', with: 'SW1P 2LU')
    end

    context 'on location category page' do
      before do
        visit_path_with_simulated_location_api(location_category_path('camden'))
      end

      # TODO: this should have always failed, reimplement when fixing https://dfedigital.atlassian.net/browse/TEVA-861
      xscenario 're-enables the radius field' do
        mock_postcodes_io

        expect(page).to have_field('radius', disabled: true)
        find('#current-location').click
        expect(page).to have_field('radius', disabled: false)
      end
    end
  end

  context 'when call to postcodes.io fails' do
    scenario 're-enables the location field input' do
      mock_postcodes_io 404

      find('#current-location').click
      expect(page).to have_field('location')
    end
  end

  context 'when user is outside UK' do
    scenario 're-enables the location field input' do
      mock_postcodes_io 200, true

      find('#current-location').click
      expect(page).to have_field('location')
    end
  end
end
