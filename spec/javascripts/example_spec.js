describe("Testing", function () {

  it("should sum two numbers", function() {
    var result = add(1,2)
    expect(result).to.equal(3);
  })

  it("should subtract the second number from the first", function () {
    var result = subtract(2, 1)
    expect(result).to.equal(1);
  })

});