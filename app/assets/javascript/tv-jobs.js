(function() {
  'use strict';

  const API_BASE = 'http://localhost:3000/api/v1';

  function loadStyles(customStylingEnabled) {
    if (customStylingEnabled) { "Do not add styling" }
    else {
      const css = `
      .tv-jobs { max-width: 800px; border: 1px solid black; }
      .tv-jobs .tv-jobs__loading { padding: 20px; text-align: center; color: #666; }
      .tv-jobs .tv-jobs__error { padding: 20px; background: #fee; border-left: 3px solid #c00; color: #c00; }
      .tv-jobs .tv-jobs__job { border: 1px solid #ddd; margin-bottom: 16px; padding: 16px; border-radius: 4px; }
      .tv-jobs .tv-jobs__job:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
      .tv-jobs .tv-jobs__title { font-size: 18px; font-weight: 600; margin: 0 0 8px; color: #222; }
`;
      const style = document.createElement('style');
      style.textContent = css;
      document.head.appendChild(style);
    }
  }

  async function fetchJobs(schoolSlug) {
    const response = await fetch(`${API_BASE}/organisations/${schoolSlug}.json`);
    if (!response.ok) throw new Error(`HTTP ${response.status}`);
    return response.json();
  }

  function getJobTemplate(functionName) {
    if (!functionName) {
      return defaultJobTemplate;
    }

    const templateFunction = window[functionName];

    if (typeof templateFunction !== 'function') {
      return defaultJobTemplate;
    }

    return function render(job) {
      try {
        return templateFunction(job);
      }
      catch (error) {
        return `Template error: ${error.message}`;
      }
    };
  }

  function defaultJobTemplate(job) {
    return `
      <div class="tv-jobs__job">
        <h3 class="tv-jobs__title">
          <span class="govuk-!-margin-right-2">
            <a href="${job.url}">${escapeHtml(job.title)}</a>
          </span>
        </h3>
        <dl class="tv-jobs__summary-list">
          <div class="job-embed__summary-list__row">
            <dt>Published date</dt><dd>${escapeHtml(job.datePosted)}</dd>
            <dt>Closure date</dt><dd>${escapeHtml(job.validThrough)}</dd>
            <dt>Location</dt><dd></dd>
          </div>
        </dl>
      </div>
    `;
  }

  function renderJobs(container, jobs, jobTemplateFn) {
    if (jobs.length === 0) {
      container.innerHTML = '<div>No jobs available.</div>';
      return;
    }

    const templateFn = getJobTemplate(jobTemplateFn);
    const html = jobs.map(job => templateFn(job)).join('');

    container.innerHTML = html;
  }

  function escapeHtml(text) {
    const div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
  }

  function init() {
    const containers = document.querySelectorAll('[data-tv-jobs]');
    const customStylingEnabled = containers[0].getAttribute('data-tv-us-style');

    loadStyles(customStylingEnabled);

    containers.forEach(async (container) => {
      const schoolSlug = container.getAttribute('data-tv-school');
      const jobTemplateFn = container.getAttribute('data-tv-job-template-fn');

      if (!schoolSlug) {
        container.innerHTML = '<div class="tv-jobs__error">Missing school slug.</div>';
        return;
      }

      container.innerHTML = '<div class="tv-jobs__loading">Loading jobs...</div>';

      try {
        const jobs = await fetchJobs(schoolSlug);
        renderJobs(container, jobs.data, jobTemplateFn);
      } catch (error) {
        container.innerHTML = `<div class="tv-jobs__error">Failed to load jobs: ${error.message}</div>`;
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
