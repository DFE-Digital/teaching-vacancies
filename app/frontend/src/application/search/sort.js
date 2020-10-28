export const hideSortSubmit = () => {
  if (document.getElementById('submit_job_sort')) {
    document.getElementById('submit_job_sort').style.display = 'none';
  }
};

export const sortChange = () => {
  if (document.getElementById('submit_job_sort')) {
    document.getElementById('submit_job_sort').click();
  }
};

const sortSelect = {
  hideSortSubmit,
  sortChange,
};

export default sortSelect;
