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

$(document).ready(function(){
  pushURLToDatalayer();
});

// Exposing function to window to let teaspoon specs pass
// TODO: remove this after removing teaspoon
window.removePIIfromURL = removePIIfromURL
