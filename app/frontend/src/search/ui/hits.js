import { createHeadingMarkup } from './heading';
import { addJobAlertMarkup, getJobAlertLink, removeJobAlertMarkup } from './alert';

export const hideServerMarkup = () => {
  if (document.querySelector('ul.vacancies')) {
    document.querySelector('ul.vacancies').style.display = 'none';
  }

  if (document.querySelector('ul.pagination-server')) {
    document.querySelector('ul.pagination-server').style.display = 'none';
  }
};

export const renderContent = (renderOptions) => {
  const { results, widgetParams } = renderOptions;

  if (results) {
    widgetParams.container.innerHTML = createHeadingMarkup({
      count: results.nbHits,
      keyword: document.getElementById('keyword').value,
      location: document.getElementById('location').value,
    });

    if (results.query.length >= widgetParams.threshold) {
      addJobAlertMarkup(widgetParams.container);
      document.querySelector('#job-alert-link').href = getJobAlertLink(window.location.href);
    } else {
      removeJobAlertMarkup();
    }
    hideServerMarkup();
  }
};

export const templates = {
  item: `
<article class="vacancy" role="article">
  <h2 class="govuk-heading-m mb0" role="heading" aria-level="2">
    <a href="/jobs/{{ permalink }}" class="govuk-link view-vacancy-link">
    {{ job_title }}
    </a>
    </h2>
  <p>{{ location }}</p>
  <dl>
<dt>Salary</dt>
<dd class="double">
{{ salary }}
</dd>
<dt>School type</dt>
<dd class="double">
{{ school.school_type }}
</dd>
<dt>Working pattern</dt>
<dd class="double">
{{ working_patterns_for_display }}
</dd>
<dt>Closing date</dt>
<dd class="double">
{{ expires_at }}
</dd>
</dl>
</article>
`,
  empty: '<h4 class="govuk-heading-m">Try another search</h4><ul class="govuk-list govuk-list--bullet"><li>with different keywords</li><li>and/or a wider radius</li></ul>',
};
