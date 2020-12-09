export const SUBMIT_SELECTOR = '.jobs-sort-submit';
export const FIELD_ID = 'jobs-sort-field';

export const sortChange = () => {
  if (document.querySelector(SUBMIT_SELECTOR)) {
    document.querySelector(SUBMIT_SELECTOR).click();
  }
};

window.addEventListener('DOMContentLoaded', () => {
  if (document.getElementById(FIELD_ID)) {
    document.getElementById(FIELD_ID).addEventListener('input', () => {
      sortChange();
    });
  }
});

const sortSelect = {
  sortChange,
};

export default sortSelect;
