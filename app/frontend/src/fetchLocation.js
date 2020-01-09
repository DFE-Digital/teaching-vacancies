import './loader';

if (navigator.geolocation) {
  $(showLocationLink);
}

var loader = new GOVUK.Loader();

function startLoading() {
  $('.js-location-finder__input').prop('disabled', true);
  $('.js-location-finder').addClass('js-location-finder--loading');
  loader.init({
    container: 'js-location-finder__input-container',
    size: 32,
    label: true,
    labelText: 'Finding location...'
  })
}

function stopLoading() {
  loader.stop();
  $('.js-location-finder').removeClass('js-location-finder--loading');
  $('.js-location-finder__input').prop('disabled', false);
}

function showLocationLink() {
  $('.js-location-finder').addClass('js-geolocation-supported');
}

function postcodeFromPosition(position) {
  $.ajax({
    url: "https://api.postcodes.io/postcodes",
    type: "get",
    data: {
      lat: position.coords.latitude,
      lon: position.coords.longitude
    },
    complete: function() {
      stopLoading()
    },
    success: function(response) {
      if (response.result) {
        $('#location').val(response.result[0].postcode);
        $("#radius").prop("disabled", false);
      }
    },
    error: function(xhr) {
    }
  });
}

$(document).on('click', '#current-location', function(event) {
  event.stopPropagation();

  startLoading();

  navigator.geolocation.getCurrentPosition(postcodeFromPosition, stopLoading);
})
