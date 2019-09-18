function pushURLToDatalayer() {
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