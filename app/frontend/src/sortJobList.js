document.addEventListener('DOMContentLoaded', function() {
  const jobSortSelect = document.getElementById('jobs_sort_select');
  const jobSortSubmitButton = document.getElementById('submit_job_sort');

  if (jobSortSubmitButton) {
    jobSortSubmitButton.style.display = 'none';
  }

  if (jobSortSelect) {
      jobSortSelect.style.display = 'none';
  }
});
