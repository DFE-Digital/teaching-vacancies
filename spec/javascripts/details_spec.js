describe("Details element with custom summary text for expanded & collapsed states", function () {

    it("Updates the summary text to be the collapsed value", function() {
        fixture.set('<details data-summary-expanded="expanded-text" data-summary-collapsed="collapsed-text">'
            + '<summary><span class="govuk-details__summary-text">Pre-text</span></summary>'
            + '</details>');

        addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(fixtureDetailsTag());

        expect(summaryTextValue()).to.equal("collapsed-text");
    });

    it("Doesn't update summary text if no data-summary-expanded attribute", function() {
        fixture.set('<details data-summary-collapsed="collapsed-text">'
            + '<summary><span class="govuk-details__summary-text">Pre-text</span></summary>'
            + '</details>');

        addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(fixtureDetailsTag());

        expect(summaryTextValue()).to.equal("Pre-text");
    });

    it("Doesn't update summary text if no data-summary-collapsed attribute", function() {
        fixture.set('<details data-summary-expanded="expanded-text">'
            + '<summary><span class="govuk-details__summary-text">Pre-text</span></summary>'
            + '</details>');

        addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(fixtureDetailsTag());

        expect(summaryTextValue()).to.equal("Pre-text");
    });

    it("Doesn't update summary text if no govuk-details_summary-text element", function() {
        fixture.set('<details data-summary-expanded="expanded-text" data-summary-collapsed="collapsed-text">'
            + '<summary>Pre-text</summary>'
            + '</details>');

        addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(fixtureDetailsTag());

        expect(fixture.el.textContent).to.equal("Pre-text");
    });

    describe("When details is expanded", function() {
        // PhantomJS isn't respecting the `.open = true` and raising events.
        // This test needs manual testing at the moment.
        xit("displays the expanded text", function() {
            fixture.set('<details data-summary-expanded="expanded-text" data-summary-collapsed="collapsed-text">'
                + '<summary><span class="govuk-details__summary-text">-Pretext</span></summary>'
                + '</details>');

            addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(fixtureDetailsTag());
            fixtureDetailsTag().open = true;

            expect(summaryTextValue()).to.equal("expanded-text");
        });
    });

    describe("When details is collapsed", function() {
        // PhantomJS isn't respecting the `.open` calls and raising events.
        // This test needs manual testing at the moment.
        xit("displays the collapsed text", function() {
            fixture.set('<details data-summary-expanded="expanded-text" data-summary-collapsed="collapsed-text">'
                + '<summary><span class="govuk-details__summary-text">-Pretext</span></summary>'
                + '</details>');

            addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(fixtureDetailsTag());
            fixtureDetailsTag().open = true;
            fixtureDetailsTag().open = false;

            expect(summaryTextValue()).to.equal("collapsed-text");
        });
    });

    function summaryTextValue() {
        return fixture.el.getElementsByClassName('govuk-details__summary-text')[0].textContent;
    }

    function fixtureDetailsTag() {
        return fixture.el.getElementsByTagName('details')[0];
    }

});
