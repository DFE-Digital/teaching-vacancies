export const renderSortSelectInput = (renderOptions, isFirstRender) => {
  const { hasNoResults, refine, widgetParams } = renderOptions;

  if (isFirstRender) {
    if (document.querySelector('#submit_job_sort')) {
      document.querySelector('#submit_job_sort').style.display = 'none';
    }

    if (document.querySelector('#jobs_sort_select')) {
      document.querySelector('#jobs_sort_select').addEventListener('change', (event) => {
        refine(getSearchReplicaName(event.target.value));
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

export const getSearchReplicaName = (selected) => (selected ? `Vacancy_${selected}` : 'Vacancy');
