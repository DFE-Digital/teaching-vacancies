// For multi-school maps
const getSchools = () => {
  if (document.getElementById('map').dataset.schools) {
    return JSON.parse(document.getElementById('map').dataset.schools);
  }
  return false;
};

// For uni-school maps
const getSchool = () => {
  if (document.getElementById('map').dataset.school) {
    return JSON.parse(document.getElementById('map').dataset.school);
  }
  return false;
};

window.initMap = () => {
  // Linting: Allow 'google' to be used without defining it.
  // This function is a callback for the Google Maps API, which will define 'google'.
  /* eslint-disable */
  const schools = getSchools();
  const school = getSchool();

  if (schools === false) {
    // A map for a single location

    const myLatLng = { lat: school.lat, lng: school.lng };

    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 16,
      center: myLatLng,
    });

    const marker = new google.maps.Marker({
      position: myLatLng,
      map,
      title: '#{name}',
    });
  } else if (school === false) {
    // A map for multiple locations

    const bounds = new google.maps.LatLngBounds();

    // Create map with default position and zoom as fitBounds sometimes
    // does nothing

    const firstSchool = schools[0];
    const firstLatLng = { lat: firstSchool.lat, lng: firstSchool.lng };

    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 16,
      center: firstLatLng,
    });

    // Use one infoWindow for all markers.
    // This means that only one infoWindow can be open at a time.
    const infoWindow = new google.maps.InfoWindow();

    schools.forEach((sch) => {
      const contentString = `<p>${sch.name_link}</p>
                            <p>${sch.address}</p>
                            <p>${sch.school_type}</p>`;

      const latLng = { lat: sch.lat, lng: sch.lng };

      const marker = new google.maps.Marker({
        position: latLng,
        map,
        title: sch.name,
      });

      marker.addListener('click', () => {
        infoWindow.setContent(contentString);
        infoWindow.open(map, marker);
        map.setCenter(latLng);
      });

      bounds.extend(latLng);
    });

    map.fitBounds(bounds);

    // Close the infoWindow on clicking outside the infoWindow.
    google.maps.event.addListener(map, 'click', (event) => {
      infoWindow.close();
    });

    /* eslint-enable */
  }
};

