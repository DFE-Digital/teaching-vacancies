// TODO add ordanace survey geolocation functionality
export const get = () => {
    fetch('https://api.ordnancesurvey.co.uk/opennames/v1/find?query=ct9&fq=LOCAL_TYPE:Town%20LOCAL_TYPE:City%20LOCAL_TYPE:Postcode&key=9b38x8h7GIWBOzsEFzGtssMS2GaAN0lI')
        .then((response) => {
            return response.json();
        })
        .then((data) => {
            console.log(data);
        })
}