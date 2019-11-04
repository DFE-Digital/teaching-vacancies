(function() {
  "use strict";

  document.addEventListener("turbolinks:click", function(event) {
    if (event.target.getAttribute("href").charAt(0) === "#") {
      event.preventDefault();
    }
  });
}).call(this);
