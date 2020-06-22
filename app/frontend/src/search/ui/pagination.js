export const renderPagination = (renderOptions, isFirstRender) => {
  const {
    pages,
    currentRefinement,
    nbPages,
    isFirstPage,
    isLastPage,
    refine,
    widgetParams,
  } = renderOptions;

  if (isFirstRender) {
    if (document.querySelector('#pagination-hits')) {
      document.querySelector('#pagination-hits').style.display = 'none';
    }
  }

  if (nbPages > 1) {
    widgetParams.container.innerHTML = `
    <ul class="pagination">
      ${!isFirstPage ? `<li><a href="#" data-value="${currentRefinement - 1}" class="pagination__item pagination--prev">Previous</a></li>` : ''}
      ${pages.map((page) => `<li><a href="#" data-value="${page}" class="pagination__item ${currentRefinement === page ? 'current' : ''}">${page + 1}</a></li>`).join('')}
      ${!isLastPage ? `<li><a href="#" data-value="${currentRefinement + 1}" class="pagination__item pagination--next">Next</a></li>` : ''}
    </ul>
    `;

    [...widgetParams.container.querySelectorAll('a')].forEach((element) => {
      element.addEventListener('click', (event) => {
        event.preventDefault();
        refine(event.currentTarget.dataset.value);
        widgetParams.scrollTo.scrollIntoView();
      });
    });
  } else {
    widgetParams.container.innerHTML = '';
  }
};
