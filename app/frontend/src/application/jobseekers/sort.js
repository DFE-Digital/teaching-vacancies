export const SUBMIT_SELECTOR = '.jobs-sort-submit';
export const FIELD_ID = 'jobs-sort-field';

export const hideSortSubmit = () => {
  if (document.querySelector(SUBMIT_SELECTOR)) {
    document.querySelector(SUBMIT_SELECTOR).style.display = 'none';
  }
};

export const sortChange = () => {
  if (document.querySelector(SUBMIT_SELECTOR)) {
    document.querySelector(SUBMIT_SELECTOR).click();
  }
};

window.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById(FIELD_ID)) {
    hideSortSubmit();

    document.getElementById(FIELD_ID).addEventListener('input', () => {
      sortChange();
    });
  }
});

const sortSelect = {
  hideSortSubmit,
  sortChange,
};

export default sortSelect;
