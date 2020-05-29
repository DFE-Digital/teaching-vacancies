import URLSearchParams from '../lib/URLSearchParams.polyfill';

export const constructNewUrlWithParam = (key, value, url) => {
    const re = new RegExp(`[\\?&]${key}=([^&#]*)`);
    return url.replace(re, `&${key}=${value}`);
};

export const updateUrlQueryParams = (key, value, url) => {
    history.replaceState({}, null, constructNewUrlWithParam(key, value, url));
};

export const extractQueryParams = (url, keys) => {

    const paramsObj = {};
    const params = new URLSearchParams(url);

    params.forEach((value, key) => {
        if (keys.indexOf(key) > -1 && value.length) {
            paramsObj[key] = value;
        }
    });

    return paramsObj;
};

export const stringMatchesPostcode = postcode => {
    postcode = postcode.replace(/\s/g, '');
    const regex = /^[A-Z]{1,2}[0-9]{1,2} ?[0-9][A-Z]{2}$/i;
    return regex.test(postcode);
};

export const convertMilesToMetres = miles => Math.ceil(parseInt(miles, 10) * 1609.34);

export const convertEpochToUnixTimestamp = timestamp => Math.round(timestamp / 1000);

export const getUnixTimestampForDayStart = date => {
    date.setUTCHours(0, 0, 0, 0);
    return convertEpochToUnixTimestamp(+date);
};
