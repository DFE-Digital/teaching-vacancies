import { convertEpochToUnixTimestamp, getUnixTimestampForDayStart } from './utils';

export const getFilters = () => `listing_status:published AND publication_date_timestamp <= ${getUnixTimestampForDayStart()} AND expires_at_timestamp > ${convertEpochToUnixTimestamp(Date.now())}`;
