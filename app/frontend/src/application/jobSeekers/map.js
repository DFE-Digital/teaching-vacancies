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
const getPolygonCoordinates = () => {
  if (document.getElementById('map').dataset.polygonCoordinates) {
    return JSON.parse(document.getElementById('map').dataset.polygonCoordinates);
  }
  return false;
};

const getVacancies = () => {
  if (document.getElementById('map').dataset.vacanciesMapData) {
    return JSON.parse(document.getElementById('map').dataset.vacanciesMapData);
  }
  return false;
};

window.initMap = () => {
  // Linting: Allow 'google' to be used without defining it.
  // This function is a callback for the Google Maps API, which will define 'google'.
  /* eslint-disable */
  const schools = getSchools();
  const school = getSchool();
  const polygonCoordinates = getPolygonCoordinates();

  if (school != false) {
    // A map for a single location

    const myLatLng = {lat: school.lat, lng: school.lng};

    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 14,
      center: myLatLng,
      mapTypeControlOptions: {mapTypeIds: []}, // Removes terrain options section ('map' or 'satellite')
    });

    new google.maps.Marker({
      position: myLatLng,
      map,
      title: '#{name}',
    });
  } else if (schools != false) {
    // A map for multiple locations

    const bounds = new google.maps.LatLngBounds();

    // Create map with default position and zoom as fitBounds sometimes
    // does nothing until page refresh

    const firstSchool = schools[0];
    const firstLatLng = {lat: firstSchool.lat, lng: firstSchool.lng};

    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 16,
      center: firstLatLng,
      mapTypeControlOptions: {mapTypeIds: []}, // Removes terrain options section ('map' or 'satellite')
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

  }
  ;

  if (polygonCoordinates != false) {
    // A map for the polygon searched in

    const bounds = new google.maps.LatLngBounds();

    const map = new google.maps.Map(document.getElementById("map"), {
      zoom: 14,
      center: polygonCoordinates[0],
      mapTypeControlOptions: {mapTypeIds: []}, // Removes terrain options section ('map' or 'satellite')
    });

    // Construct the polygon
    const visiblePolygon = new google.maps.Polygon({
      paths: polygonCoordinates,
      strokeColor: "#f47738",
      strokeOpacity: 0.8,
      strokeWeight: 2,
      fillColor: "#1d70b8",
      fillOpacity: 0.35,
      editable: true
    });

    polygonCoordinates.forEach((latLng) => {
      bounds.extend(latLng);
    });

    map.fitBounds(bounds);

    visiblePolygon.setMap(map);

    const vacancies = getVacancies();

    if (vacancies != false) {
      // Add markers for each search result (with a school)

      // Use one infoWindow for all markers.
      // This means that only one infoWindow can be open at a time.
      const infoWindow = new google.maps.InfoWindow();

      vacancies.forEach((vacancy) => {
        const contentString = `<p>${vacancy.name_link}</p>
                            <p>${vacancy.location}</p>`;

        const latLng = {lat: vacancy.lat, lng: vacancy.lng};

        const marker = new google.maps.Marker({
          position: latLng,
          map,
          title: vacancy.name,
        });

        marker.addListener('click', () => {
          infoWindow.setContent(contentString);
          infoWindow.open(map, marker);
          map.setCenter(latLng);
        });
      });

      // Close the infoWindow on clicking outside the infoWindow.
      google.maps.event.addListener(map, 'click', (event) => {
        infoWindow.close();
      });
    };

    document.getElementById('searchFromMap').addEventListener('click', () => {
      let url = new URL(window.location);
      visiblePolygon.getPath().i.forEach((i) => {
        url.searchParams.append('user_input_polygon[]', i.lat().toFixed(3))
        url.searchParams.append('user_input_polygon[]', i.lng().toFixed(3))
      });
      url.searchParams = url.searchParams.toString();
      window.location = url;
    });
  }
  /* eslint-enable */
};

