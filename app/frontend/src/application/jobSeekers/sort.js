export const hideSortSubmit = () => {
  if (document.querySelector('.jobs-sort-submit')) {
    document.querySelector('.jobs-sort-submit').style.display = 'none';
  }
};

export const sortChange = () => {
  if (document.querySelector('.jobs-sort-submit')) {
    document.querySelector('.jobs-sort-submit').click();
  }
};

const sortSelect = {
  hideSortSubmit,
  sortChange,
};

export default sortSelect;
