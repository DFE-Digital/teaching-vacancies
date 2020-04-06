function addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(detailsElement) {
    var expandedText = detailsElement.getAttribute('data-summary-expanded');
    var collapsedText = detailsElement.getAttribute('data-summary-collapsed');
    var summaryTextElement = detailsElement.getElementsByClassName('govuk-details__summary-text').item(0);
    var hasAllPropertiesToBeDynamic = summaryTextElement && collapsedText && expandedText;

    if(hasAllPropertiesToBeDynamic) {
        summaryTextElement.textContent = collapsedText;

        detailsElement.addEventListener('toggle', function () {
            if (detailsElement.open) {
                summaryTextElement.textContent = expandedText;
            } else {
                summaryTextElement.textContent = collapsedText;
            }
        });
    }
}

$( document ).ready(function() {
    $('details').each(function(_, details) {
        addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(details);
    });
});
