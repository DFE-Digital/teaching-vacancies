export const renderSortSelectInput = (renderOptions, isFirstRender) => {
  const { hasNoResults, refine, widgetParams } = renderOptions;

  if (isFirstRender) {
    if (document.querySelector('#submit_job_sort')) {
      document.querySelector('#submit_job_sort').style.display = 'none';
    }

    if (document.querySelector('#jobs_sort_select')) {
      document.querySelector('#jobs_sort_select').addEventListener('change', (event) => {
        refine(getSearchIndexName(event.target.value));
      });
    }
  }

  widgetParams.container.style.display = hasNoResults ? 'none' : 'inline-block';

  if (hasNoResults) {
    widgetParams.element.disabled = true;
  } else {
    widgetParams.element.removeAttribute('disabled');
  }
};

export const getSearchIndexName = (selected) => {
  const defaultSearchIndexName = 'Vacancy_publish_on_desc';
  if (selected === 'most_relevant') {
    return 'Vacancy';
  }
  return selected ? `Vacancy_${selected}` : defaultSearchIndexName;
};
