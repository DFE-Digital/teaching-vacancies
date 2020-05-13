export const renderHeading = (renderOptions) => {
  const { results, widgetParams } = renderOptions;

  if (results) {
    const location = results.query ? ` in ${results.query}` : '';
    widgetParams.container.innerHTML = `There are ${results.nbHits} jobs listed ${location}`;  
    document.querySelector('ul.vacancies').style.display = 'none';
    document.querySelector('ul.pagination-server').style.display = 'none';
  }
};

export const snakeCaseToHumanReadable = value => value.toLowerCase().replace(/_/g, ' ');

export const transform = items => items.map(item => ({
  ...item,
  working_patterns: Array.isArray(item.working_patterns) ? item.working_patterns.map(snakeCaseToHumanReadable).join(', ') : item.working_patterns,
}));

export const templates = {
  item: `
<article class="vacancy">
  <h2 class="govuk-heading-m mb0">
    <a href="/jobs/{{ permalink }}" class="govuk-link view-vacancy-link">
    {{ job_title }}
    </a>
    </h2>
  <p>{{ school.name }}, {{ school.town }}, {{ school.region }}.</p>
  <dl>
<dt>Salary</dt>
<dd class="double">
{{ salary }}
</dd>
<dt>School type</dt>
<dd class="double">
{{ school_type }}
</dd>
<dt>Working pattern</dt>
<dd class="double">
{{ working_patterns }}
</dd>
<dt>Closing date</dt>
<dd class="double">
{{ expires_at }}
</dd>
</dl>
</article>
`};
