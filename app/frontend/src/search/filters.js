import { convertEpochToUnixTimestamp } from './utils';

export const getFilters = () => `listing_status:published AND publication_date_timestamp <= ${convertEpochToUnixTimestamp(Date.now())} AND expires_at_timestamp > ${convertEpochToUnixTimestamp(Date.now())}`;
