export const renderAutocomplete = (renderOptions, isFirstRender) => {
    const { indices, currentRefinement, refine, widgetParams } = renderOptions;

    if (isFirstRender) {
        const ul = document.createElement('ul');

        ul.classList.add('app-site-search__menu--overlay');
        ul.classList.add('app-site-search__menu');

        widgetParams.container.appendChild(ul);
    }

    widgetParams.container.querySelector('#location').value = currentRefinement;

    widgetParams.container.querySelector('ul').innerHTML = indices
        .map(renderIndexListItem)
        .join('');
};

export const renderIndexListItem = ({ indexId, hits }) => `
${hits
  .map(hit => `<li class="app-site-search__option">${hit.school.town} (${hit.school.county})</li>`)
  .join('')}
`;