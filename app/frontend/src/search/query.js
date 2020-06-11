import { convertEpochToUnixTimestamp, getUnixTimestampForDayStart, stringMatchesPostcode } from '../lib/utils';

export const getFilters = () => `listing_status:published AND publication_date_timestamp <= ${getUnixTimestampForDayStart(new Date())} AND expires_at_timestamp > ${convertEpochToUnixTimestamp(Date.now())}`;

export const getQuery = () => [
  document.getElementById('keyword').value,
  stringMatchesPostcode(document.getElementById('location').value) ? null : document.getElementById('location').value,
].filter((value) => value).join(' ');

export const shouldGeocodeQuery = (query, locations) => stringMatchesPostcode(query) || (query.length && locations.indexOf(query.toLowerCase()) === -1); // eslint-disable-line
