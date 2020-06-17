export const constructResults = (results) => {
  if (results === 1) {
    return 'result';
  }
  return 'results';
};

export const constructLastResultNumber = (pages, page, results, resultsPerPage) => {
  if (pages === 0) {
    return 0;
  } if (page + 1 === pages) {
    return results;
  }
  return (page + 1) * resultsPerPage;
};

export const constructFirstResultNumber = (pages, page, resultsPerPage) => (pages === 0 ? 0 : page * resultsPerPage + 1);

export const renderStats = (renderOptions, isFirstRender) => {
  const {
    nbHits, nbPages, page, hitsPerPage, widgetParams,
  } = renderOptions;

  if (isFirstRender) {
    return;
  }

  const results = constructResults(nbHits);
  const last = constructLastResultNumber(nbPages, page, nbHits, hitsPerPage);
  const first = constructFirstResultNumber(nbPages, page, hitsPerPage);

  if (nbHits) {
    widgetParams.container.innerHTML = `
      Showing <span class="govuk-!-font-weight-bold">${first}</span> to <span class="govuk-!-font-weight-bold">${last}</span> of <span class="govuk-!-font-weight-bold">${nbHits}</span> ${results}
    `;
  } else {
    widgetParams.container.innerHTML = '';
  }
};
