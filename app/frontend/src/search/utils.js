export const updateUrlQueryParams = (key, value, url) => {
    return false
    history.replaceState({}, null, `${url}&${key}=${value}#jobs_sort`);
};