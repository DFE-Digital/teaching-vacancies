/* eslint-disable */
function addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(detailsElement) {
  const expandedText = detailsElement.getAttribute('data-summary-expanded');
  const collapsedText = detailsElement.getAttribute('data-summary-collapsed');
  const summaryTextElement = detailsElement.getElementsByClassName('govuk-details__summary-text').item(0);
  const hasAllPropertiesToBeDynamic = summaryTextElement && collapsedText && expandedText;

  if (hasAllPropertiesToBeDynamic) {
    summaryTextElement.textContent = collapsedText;

    detailsElement.addEventListener('toggle', () => {
      if (detailsElement.open) {
        summaryTextElement.textContent = expandedText;
      } else {
        summaryTextElement.textContent = collapsedText;
      }
    });
  }
}

$(document).ready(() => {
  $('details').each((_, details) => {
    addDynamicSummaryTextForExpandedAndCollapsedDetailsTag(details);
  });
});
