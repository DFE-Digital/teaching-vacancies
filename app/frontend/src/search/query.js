import { convertEpochToUnixTimestamp, getUnixTimestampForDayStart } from '../lib/utils';
import { stringMatchesPostcode } from '../lib/utils';

export const getFilters = () => `listing_status:published AND publication_date_timestamp <= ${getUnixTimestampForDayStart(new Date())} AND expires_at_timestamp > ${convertEpochToUnixTimestamp(Date.now())}`;

export const getQuery = () => [
    document.querySelector('#keyword').value,
    stringMatchesPostcode(document.querySelector('#location').value) ? null : document.querySelector('#location').value
].filter(value => value).join(' ');
