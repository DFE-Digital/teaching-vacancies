import logger from './logging';

export const stringMatchesPostcode = (postcode) => {
  const noSpacePostcode = postcode.replace(/\s/g, '');
  const regex = /^[A-Za-z]{1,2}[0-9]{1,2}[A-Za-z]? ?[0-9][A-Z]{2}$/i;
  return regex.test(noSpacePostcode);
};

export const stringContainsNumber = (string) => /\d/.test(string);

export const convertMilesToMetres = (miles) => Math.ceil(parseInt(miles, 10) * 1609.34);

export const convertEpochToUnixTimestamp = (timestamp) => Math.round(timestamp / 1000);

export const getUnixTimestampForDayStart = (date) => {
  date.setUTCHours(0, 0, 0, 0);
  return convertEpochToUnixTimestamp(+date);
};

export const removeDataAttribute = (element, key) => {
  if (element) {
    delete element.dataset[key];
  }
};

export const setDataAttribute = (element, key, value) => {
  if (element) {
    element.dataset[key] = value;
  }
};

export const getNewState = (state, add) => {
  const updatedState = { ...state, ...add };
  return updatedState;
};

export const storageAvailable = (type, logMessage = false) => {
  let storage = null;
  try {
    storage = window[type];
    const x = '__storage_test__';
    storage.setItem(x, x);
    storage.removeItem(x);
    return true;
  } catch (e) {
    if (logMessage) {
      logger.info(logMessage);
    }

    return e instanceof DOMException && (
    // everything except Firefox
      e.code === 22
          // Firefox
          || e.code === 1014
          // test name field too, because code might not be present
          // everything except Firefox
          || e.name === 'QuotaExceededError'
          // Firefox
          || e.name === 'NS_ERROR_DOM_QUOTA_REACHED')
          // acknowledge QuotaExceededError only if there's something already stored
          && (storage && storage.length !== 0);
  }
};

export const railsCsrfToken = () => document.getElementsByName('csrf-token')[0].content;
