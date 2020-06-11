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
        select.id = 'jobs_sort_select';

        select.addEventListener('change', event => {
            if (document.querySelector('ul.vacancies')) {
                document.querySelector('ul.vacancies').style.display = 'none';
            }
            refine(event.target.value);
        });

        widgetParams.container.appendChild(select);
    }

    if (document.getElementById('jobs_sort_label')) {
        document.getElementById('jobs_sort_label').style.display = hasNoResults ? 'none' : 'inline-block';
    }

    const select = document.getElementById('jobs_sort_select');
    if (select) {
        select.style.display = hasNoResults ? 'none' : 'inline-block';

        select.innerHTML = constructOptions(options, currentRefinement);
    }
};

export const constructOptions = (options, selected) => `${options.map(option => `<option value="${option.value}"${option.value === selected ? ' selected' : ''}>${option.label}</option>`).join('')}`;
