export const constructNewUrlWithParam = (key, value, url) => {
    const re = new RegExp(`[\\?&]${key}=([^&#]*)`);
    return url.replace(re, `&${key}=${value}`);
};

export const updateUrlQueryParams = (key, value, url) => {
    history.replaceState({}, null, constructNewUrlWithParam(key, value, url));
};
