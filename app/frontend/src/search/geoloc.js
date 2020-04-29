// TODO add ordanace survey geolocation functionality
export const get = () => {
    return fetch('https://api.ordnancesurvey.co.uk/opennames/v1/find?query=sout&fq=LOCAL_TYPE:Town%20LOCAL_TYPE:City%20LOCAL_TYPE:Postcode&key=9b38x8h7GIWBOzsEFzGtssMS2GaAN0lI')
        .then((response) => {
            return response.json();
        });
}