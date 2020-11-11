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

const getRadiusInMetres = () => {
  if (document.getElementById('map').dataset.radius) {
    return JSON.parse(document.getElementById('map').dataset.radius);
  }
  return false;
};

const getPointCoordinates = () => {
  if (document.getElementById('map').dataset.pointCoordinates) {
    return JSON.parse(document.getElementById('map').dataset.pointCoordinates);
  }
  return false;
};

const getVacancies = () => {
  if (document.getElementById('map').dataset.vacanciesMapData) {
    return JSON.parse(document.getElementById('map').dataset.vacanciesMapData);
  }
  return false;
};

const addVacanciesToMapAsMarkers = (map, infoWindow) => {
  const vacancies = getVacancies();

  if (vacancies !== false) {
    // Add markers for each search result (with a school)

    vacancies.forEach((vacancy) => {
      const contentString = `<p>${vacancy.name_link}</p>
                            <p>${vacancy.location}</p>`;

      const latLng = { lat: vacancy.lat, lng: vacancy.lng };

      const marker = new google.maps.Marker({
        position: latLng,
        map,
        icon: {
          url: 'http://maps.google.com/mapfiles/ms/icons/red-dot.png',
        },
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
  }
};

const addDraggableRadiusCenter = (center, map, infoWindow) => {
  const contentString = `<p>Your search location</p>
                           <p>(Try dragging me!)</p>`;

  const marker = new google.maps.Marker({
    position: center,
    map,
    title: 'Your search location',
    icon: {
      url: 'http://maps.google.com/mapfiles/ms/icons/yellow-dot.png',
    },
    draggable: true,
  });

  marker.addListener('click', () => {
    infoWindow.setContent(contentString);
    infoWindow.open(map, marker);
    map.setCenter(latLng);
  });

  marker.addListener('dragend', () => {
    const url = new URL(window.location);

    url.searchParams.delete('user_input_point_coordinates[]');

    const position = marker.getPosition();

    url.searchParams.append('user_input_point_coordinates[]', position.lat().toFixed(3));
    url.searchParams.append('user_input_point_coordinates[]', position.lng().toFixed(3));

    url.searchParams = url.searchParams.toString();

    window.location = url;
  });
};

window.initMap = () => {
  // Linting: Allow 'google' to be used without defining it.
  // This function is a callback for the Google Maps API, which will define 'google'.
  /* eslint-disable */
  const schools = getSchools();
  const school = getSchool();
  const polygonCoordinates = getPolygonCoordinates();
  const radiusInMetres = getRadiusInMetres();
  const pointCoordinates = getPointCoordinates();

  const mapTypeControlOptions = {mapTypeIds: []};
  const tvsOrange = '#f47738';
  const tvsBlue = '#1d70b8';

  // Use one infoWindow for all markers.
  // This means that only one infoWindow can be open at a time.
  const infoWindow = new google.maps.InfoWindow();

  if (school !== false) {
    // A map for a single location

    const myLatLng = {lat: school.lat, lng: school.lng};

    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 14,
      center: myLatLng,
      mapTypeControlOptions: mapTypeControlOptions, // Removes terrain options section ('map' or 'satellite')
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
    const firstLatLng = {lat: firstSchool.lat, lng: firstSchool.lng};

    const map = new google.maps.Map(document.getElementById('map'), {
      zoom: 16,
      center: firstLatLng,
      mapTypeControlOptions: mapTypeControlOptions, // Removes terrain options section ('map' or 'satellite')
    });

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

  if (radiusInMetres !== false && pointCoordinates !== false) {
    // A map for the radiusInMetres searched in

    const center = new google.maps.LatLng(pointCoordinates)

    const radiusInMetresToZoom = (radiusInMetres) => {
      if (radiusInMetres < 2000) {
        return 13;
      } else if (radiusInMetres < 9000) {
        return 11;
      } else if (radiusInMetres < 17000) {
        return 10;
      } else if (radiusInMetres < 40000) {
        return 9;
      } else if (radiusInMetres < 80000) {
        return 8;
      } else if (radiusInMetres < 160000) {
        return 7;
      } else if (radiusInMetres < 320000) {
        return 6;
      } else {
        return 5;
      }
    };

    const map = new google.maps.Map(document.getElementById("map"), {
      zoom: radiusInMetresToZoom(radiusInMetres),
      center: center,
      mapTypeControlOptions: mapTypeControlOptions, // Removes terrain options section ('map' or 'satellite')
    });

    addDraggableRadiusCenter(center, map, infoWindow);

    addVacanciesToMapAsMarkers(map, infoWindow);

    const circle = new google.maps.Circle({
      map: map,
      radius: radiusInMetres,
      center: center,
      strokeColor: tvsOrange,
      strokeOpacity: 0.8,
      strokeWeight: 2,
      fillColor: tvsBlue,
      fillOpacity: 0.35
    });

  } else if (polygonCoordinates !== false) {
    // A map for the polygon searched in

    const bounds = new google.maps.LatLngBounds();

    const map = new google.maps.Map(document.getElementById("map"), {
      zoom: 14,
      center: polygonCoordinates[0],
      mapTypeControlOptions: mapTypeControlOptions, // Removes terrain options section ('map' or 'satellite')
    });

    // Construct the polygon
    const visiblePolygon = new google.maps.Polygon({
      paths: polygonCoordinates,
      strokeColor: tvsOrange,
      strokeOpacity: 0.8,
      strokeWeight: 2,
      fillColor: tvsBlue,
      fillOpacity: 0.35,
      editable: true
    });

    polygonCoordinates.forEach((latLng) => {
      bounds.extend(latLng);
    });

    map.fitBounds(bounds);

    visiblePolygon.setMap(map);

    addVacanciesToMapAsMarkers(map, infoWindow);

    document.getElementById('searchFromMap').addEventListener('click', () => {
      let url = new URL(window.location);

      url.searchParams.delete('user_input_polygon[]');

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

