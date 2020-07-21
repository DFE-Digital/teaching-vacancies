export const enableRadiusSelect = () => {
  if (document.querySelector('#radius')) {
    document.querySelector('#radius').removeAttribute('disabled');
  }

  if (document.querySelector('#location-radius-select')) {
    document.querySelector('#location-radius-select').style.display = 'block';
  }
};

export const disableRadiusSelect = () => {
  if (document.querySelector('#radius')) {
    document.querySelector('#radius').disabled = true;
  }

  if (document.querySelector('#location-radius-select')) {
    document.querySelector('#location-radius-select').style.display = 'none';
  }
};

const radiusSelect = {
  enableRadiusSelect,
  disableRadiusSelect,
};

export default radiusSelect;
