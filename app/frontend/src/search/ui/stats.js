export const renderStats = (renderOptions, isFirstRender) => {
  const { nbHits, nbPages, page, hitsPerPage, widgetParams } = renderOptions;

  if (isFirstRender) {
    return;
  }

  let results = constructResults(nbHits);
  let last = constructLastResultNumber(nbPages, page, nbHits, hitsPerPage);
  let first = constructFirstResultNumber(nbPages, page, hitsPerPage);

  if (nbHits) {
    widgetParams.container.innerHTML = `
      Showing <span class="govuk-!-font-weight-bold">${first}</span> to <span class="govuk-!-font-weight-bold">${last}</span> of <span class="govuk-!-font-weight-bold">${nbHits}</span> ${results}
    `;
  } else {
    widgetParams.container.innerHTML = '';
  }
};

export const constructResults = (results) => {
  if (results === 1) {
    return 'result';
  } else {
    return 'results';
  }
};

export const constructLastResultNumber = (pages, page, results, resultsPerPage) => {
  if (pages === 0) {
    return 0;
  } else if (page + 1 === pages) {
    return results;
  } else {
    return (page + 1) * resultsPerPage;
  }
};

export const constructFirstResultNumber = (pages, page, resultsPerPage) => pages === 0 ? 0 : page * resultsPerPage + 1;
