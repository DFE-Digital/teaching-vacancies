describe("Remove comma from number", function () {

  it("should remove commas from numbers", function () {
    var salary = '30,000'
    var cleanedSalary = removeCommaFromNumber(salary)
    expect(cleanedSalary).to.equal('30000');
  })

});