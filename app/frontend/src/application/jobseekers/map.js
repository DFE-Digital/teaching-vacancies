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

// For search result map
const getPolygonBoundaries = () => {
  if (document.getElementById('map').dataset.polygon_boundaries) {
    return JSON.parse(document.getElementById('map').dataset.polygon_boundaries);
  }
  return false;
};

const getSearchPointCoordinates = () => {
  if (document.getElementById('map').dataset.search_point_coordinates) {
    return JSON.parse(document.getElementById('map').dataset.search_point_coordinates);
  }
  return false;
};

window.initMap = () => {
  // Linting: Allow 'google' to be used without defining it.
  // This function is a callback for the Google Maps API, which will define 'google'.
  /* eslint-disable */

  const schools = getSchools();
  const school = getSchool();
  const polygonBoundaries = getPolygonBoundaries();
  const searchPointCoordinates = getSearchPointCoordinates();
  const mapTypeControlOptions = { mapTypeIds: [] };
  const tvOrange = '#f47738';
  const tvBlue = '#1d70b8';

  if (school !== false) {
    // A map for a single location

    const myLatLng = { lat: school.lat, lng: school.lng };

    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 14,
      scrollwheel: false,
      center: myLatLng,
      mapTypeControlOptions, // Removes terrain options section ('map' or 'satellite')
    });

    new google.maps.Marker({
      position: myLatLng,
      map,
      title: '#{name}',
    });
  } else if (schools !== false) {
    // A map for multiple locations

    const bounds = new google.maps.LatLngBounds();

    // Create map with default position and zoom as fitBounds sometimes
    // does nothing until page refresh

    const firstSchool = schools[0];
    const firstLatLng = { lat: firstSchool.lat, lng: firstSchool.lng };

    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 16,
      center: firstLatLng,
      mapTypeControlOptions, // Removes terrain options section ('map' or 'satellite')
    });

    // Use one infoWindow for all markers.
    // This means that only one infoWindow can be open at a time.
    const infoWindow = new google.maps.InfoWindow();

    schools.forEach((sch) => {
      const contentString = `<p>${sch.name_link}</p>
                            <p>${sch.address}</p>
                            <p>School type: ${sch.school_type}</p>`;

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

  } else if (polygonBoundaries !== false) {

    // A map to display the polygons searched in

    const bounds = new google.maps.LatLngBounds();

    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 14,
      center: polygonBoundaries[0][0],
      mapTypeControlOptions, // Removes terrain options section ('map' or 'satellite')
    });

    polygonBoundaries.forEach((polygonBoundary) => {
      // Construct the polygon
      const visiblePolygon = new google.maps.Polygon({
        paths: polygonBoundary,
        strokeColor: tvOrange,
        strokeOpacity: 0.8,
        strokeWeight: 2,
        fillColor: tvBlue,
        fillOpacity: 0.35,
      });

      polygonBoundary.forEach((latLng) => {
        bounds.extend(latLng);
      });

      map.fitBounds(bounds);

      visiblePolygon.setMap(map);
    })
  } else if (searchPointCoordinates !== false) {
    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 14,
      center: searchPointCoordinates,
      mapTypeControlOptions, // Removes terrain options section ('map' or 'satellite')
    });

    const marker = new google.maps.Marker({
      position: searchPointCoordinates,
      map,
      title: 'Your search location',
    });
  }

  /* eslint-enable */
};
