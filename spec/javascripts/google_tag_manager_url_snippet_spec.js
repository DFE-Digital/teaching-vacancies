describe("Google Tag Manager snippet", function () {

  it("should remove params from the URL", function () {
    var urlString = "https://example.com/jobs?utf8=✓&location=CH52DD&radius=5";
    var url = createLocationFake(urlString);
    expect(removePIIfromURL(url)).to.equal('/jobs');
  })

  it("should keep URL without any params", function () {
    var urlString = "https://example.com/subscriptions.new";
    var url = createLocationFake(urlString);
    expect(removePIIfromURL(url)).to.equal('/subscriptions.new');
  })

  function createLocationFake(site) {
    var url = document.createElement('a');
    url.href = site;
    return url;
  }

});