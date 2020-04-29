export const renderSortSelect = (renderOptions, isFirstRender) => {
    const {
        options,
        currentRefinement,
        hasNoResults,
        refine,
        widgetParams,
    } = renderOptions;

    if (isFirstRender) {

        const select = document.createElement('select');
        select.classList.add('govuk-select');
        select.classList.add('govuk-input--width-10');
        select.id = 'algolia-select';

        select.addEventListener('change', event => {
            document.querySelector('ul.vacancies').style.display = 'none';
            refine(event.target.value);
        });

        widgetParams.container.appendChild(select);
    }

    const select = widgetParams.container.querySelector('#algolia-select');

    select.disabled = hasNoResults;

    select.innerHTML = `
  ${options
            .map(
                option => `
        <option
          value="${option.value}"
          ${option.value === currentRefinement ? 'selected' : ''}
        >
          ${option.label}
        </option>
      `
            )
            .join('')}
`;
};