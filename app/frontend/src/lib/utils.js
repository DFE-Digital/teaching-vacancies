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
