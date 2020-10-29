export const enableRadiusSelect = () => {
  if (document.querySelector('#radius-field')) {
    document.querySelector('#radius-field').removeAttribute('disabled');
  }

  if (document.querySelector('.location-radius-select')) {
    if (document.querySelector('.location-radius-select-inline-block')) {
      document.querySelector('.location-radius-select').style.display = 'inline-block';
    } else if (document.querySelector('.location-radius-select-block')) {
      document.querySelector('.location-radius-select').style.display = 'block';
    }
  }
};

export const disableRadiusSelect = () => {
  if (document.querySelector('#radius-field')) {
    document.querySelector('#radius-field').disabled = true;
  }

  if (document.querySelector('.location-radius-select')) {
    document.querySelector('.location-radius-select').style.display = 'none';
  }
};

const radiusSelect = {
  enableRadiusSelect,
  disableRadiusSelect,
};

export default radiusSelect;
