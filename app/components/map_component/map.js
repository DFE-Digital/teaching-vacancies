import 'leaflet';

import { Controller } from '@hotwired/stimulus';

import './map.scss';

const MapController = class extends Controller {
  static targets = ['markersTextList', 'organisation'];

  connect() {
    if (!this.element.querySelector('#map')) {
      return;
    }

    const singleOrg = this.organisationTargets.length === 1;

    this.organisationTargets.forEach((organisation, index) => {
      const point = {
        lat: organisation.dataset.lat,
        lon: organisation.dataset.lon,
      };

      if (index === 0) {
        this.create(point, this.element.dataset.zoom);
      }

      this.addMarker(point, organisation, index, singleOrg);
    });

    if (!singleOrg) {
      this.markersTextListTarget.classList.add('govuk-list--number');
      this.setMapBounds();
    }
  }

  create(point, zoom) {
    this.map = L.map('map', { tap: false }).setView(point, zoom);

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' },
    ).addTo(this.map);

    JSON.parse(document.getElementById('polygons').dataset.polygons).forEach((polygon) => {
      this.polygon({ coordinates: polygon });
    });
  }

  polygon({ coordinates }) {
    L.polygon(coordinates[0].map((point) => point.reverse()), { color: '#0b0c0c', weight: 1, smoothFactor: 2 }).addTo(this.map);
  }

  addMarker(point, organisation, index, singleOrg) {
    const originalLink = organisation.querySelector('a');

    const marker = L.marker(point, {
      icon: MapController.markerIcon(singleOrg ? '' : `<span aria-label="${originalLink.innerText}">${index + 1}</span>`),
      riseOnHover: true,
    });

    // const addressBlock = organisation.querySelector('.pop-up');
    const addressBlock = organisation.querySelector('.pop-up');
    addressBlock.remove();
    addressBlock.hidden = false;

    marker.addTo(this.map).bindPopup(
      addressBlock.outerHTML,
      { className: 'map-component__map__popup' },
    );

    // use keydown event as leaflet doesnt recognise focus
    marker.on('keydown', MapController.openMarkerPopup);

    if (singleOrg) {
      originalLink.remove();
      marker.openPopup();
    } else {
      originalLink.replaceWith(originalLink.innerText);
    }
  }

  setMapBounds() {
    this.map.fitBounds(
      this.organisationTargets.map((o) => ({ lat: o.dataset.lat, lon: o.dataset.lon })),
    );
  }

  static markerIcon(html) {
    return L.divIcon({
      className: 'map-component__map__marker--default',
      iconSize: [20, 20],
      html,
    });
  }

  static openMarkerPopup(e) {
    e.target.openPopup();
  }
};

export default MapController;
