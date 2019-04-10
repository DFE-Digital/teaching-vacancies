require 'rails_helper'

RSpec.describe 'SchoolsInArea' do
  subject { SchoolsInArea.new(lat: lat, lng: lng, radius: 20) }

  let!(:school1) { create(:school, :with_live_vacancies, latitude: 53.148326, longitude: 0.337303) }
  let!(:school2) { create(:school, :with_live_vacancies, latitude: 52.820173, longitude: 0.517886) }
  let!(:school3) { create(:school, :with_expired_vacancies, latitude: 52.820173, longitude: 0.517886) }

  let(:lat) { 52.93493 }
  let(:lng) { 0.483486 }

  describe '#schools' do
    it 'only gets schools with vacancies' do
      expect(subject.send(:schools)).to match_array([school1, school2])
    end
  end

  describe '#data' do
    it 'makes the correct call to the Distance Matrix API' do
      destinations = [school1, school2].map do |s|
        [
          '(?=.*',
          Regexp.escape(s.latitude.round(5).to_s),
          ',',
          Regexp.escape(s.longitude.round(5).to_s),
          ')'
        ].join
      end.join

      url_regexp = %r{https:\/\/maps\.googleapis\.com\/maps\/api\/distancematrix\/json\?destinations\=#{destinations}.*}
      stub = stub_request(:get, url_regexp).and_return(body: { rows: [], status: 'OK' }.to_json)

      subject.send(:data)

      expect(stub).to have_been_requested
    end
  end

  describe '#results' do
    let(:results) { subject.results }

    it 'only includes the school within the radius' do
      allow(subject).to receive(:data) {
        [
          double(GoogleDistanceMatrix::Route, destination: school1.place, distance_in_meters: 113835),
          double(GoogleDistanceMatrix::Route, destination: school2.place, distance_in_meters: 17179)
        ]
      }

      expect(results.count).to eq(1)
      expect(results).to_not include(school1)
      expect(results).to include(school2)
    end
  end
end