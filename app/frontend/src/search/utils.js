export const constructNewUrlWithParam = (key, value, url) => {
    const re = new RegExp(`[\\?&]${key}=([^&#]*)`);
    return url.replace(re, `&${key}=${value}`);
};

export const updateUrlQueryParams = (key, value, url) => {
    history.replaceState({}, null, constructNewUrlWithParam(key, value, url));
};

export const stringMatchesPostcode = postcode => {
    postcode = postcode.replace(/\s/g, '');
    var regex = /^[A-Z]{1,2}[0-9]{1,2} ?[0-9][A-Z]{2}$/i;
    return regex.test(postcode);
};

export const convertMilesToMetres = miles => parseInt(miles, 10) * 1760;

export const convertEpochToUnixTimestamp = timestamp => Math.floor(timestamp / 1000);
