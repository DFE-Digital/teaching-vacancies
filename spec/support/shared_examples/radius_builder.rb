RSpec.shared_examples "a correct call of Search::RadiusBuilder" do
  it "sets the radius and location attributes" do
    expect(Search::RadiusBuilder).to receive(:new).with(location, radius).and_return(radius_builder)
    expect(subject.radius).to eq(expected_radius)
    expect(subject.location).to eq(location)
  end
end
