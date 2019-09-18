//Extract Parameters into array
function extractParams() {
    var urlParams = {},
        match,
        search = /([^&=]+)=?([^&]*)/g,
        query = window.location.search.substring(1);
    while (match = search.exec(query)) {
        urlParams[match[1]] = match[2];
    }
    return urlParams
}

var urlParams = extractParams()
//Get list of parameters to retain from GTM variable
var usefulParams = ["utm_medium",
        "utm_source",
        "utm_campaign",
        "utm_term",
        "utm_content",
        "gclid",
        "search"];
//Regex that defines email addresses
for (var key in urlParams) {
    //Check for and retain whitelisted parameters
    if (usefulParams.indexOf(key) == -1) {
        delete urlParams[key]
    }
    //Redact email address by regex
    else {
        urlParams[key] = decodeURIComponent(urlParams[key])
    }
}
//Rewrite URL
function rewriteURL(urlParams) {
    var keys = Object.keys(urlParams).sort();
    if (keys.length == 0) {
        return window.location.pathname + window.location.hash
    }
    var params = "?";
    for (var i = 0; i < keys.length; i++) {
        if (i > 0) {
            params = params.concat("&")
        }
        params = params.concat(keys[i] + "=" + urlParams[keys[i]])
    }
    return window.location.pathname + params + window.location.hash
}

function pushURLToDatalayer() {
  // var newURL = rewriteURL(urlParams);
  var newURL = removePIIfromURL(window.location);
  dataLayer.push({
    dePIIedURL: newURL,
    event: "parametersRemoved"
  })
}

function removePIIfromURL(url) {
  return url.pathname;
}

$(document).on('turbolinks:load', function(){
  pushURLToDatalayer();
});