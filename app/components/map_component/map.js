import 'leaflet';

import { Controller } from '@hotwired/stimulus';

import './map.scss';

const MapController = class extends Controller {
  static targets = ['markersTextList', 'marker'];

  connect() {
    if (!this.element.querySelector('#map')) {
      return;
    }

    const singleMarker = this.markerTargets.length === 1;

    this.markerTargets.forEach((marker, index) => {
      const point = {
        lat: marker.dataset.lat,
        lon: marker.dataset.lon,
      };

      if (index === 0) {
        this.create(point, this.element.dataset.zoom);
      }

      this.addMarker(point, marker, index, singleMarker);
    });

    if (!singleMarker) {
      this.markersTextListTarget.classList.add('govuk-list--number');
      this.setMapBounds();
    }
  }

  create(point, zoom) {
    this.map = L.map('map', { tap: false, fullscreenControl: true }).setView(point, zoom);

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' },
    ).addTo(this.map);
  }

  addMarker(point, marker, index, singleMarker) {
    const originalLink = marker.querySelector('a');

    const leafletMarker = L.marker(point, {
      icon: MapController.markerIcon(singleMarker ? '' : `<span aria-label="${originalLink.innerText}">${index + 1}</span>`),
      riseOnHover: true,
    });

    const addressBlock = marker.querySelector('.pop-up');
    addressBlock.remove();
    addressBlock.hidden = false;

    leafletMarker.addTo(this.map).bindPopup(
      addressBlock.outerHTML,
      { className: 'map-component__map__popup' },
    );

    // use keydown event as leaflet doesnt recognise focus
    leafletMarker.on('keydown', MapController.openMarkerPopup);

    if (singleMarker) {
      originalLink.remove();
      leafletMarker.openPopup();
    } else {
      originalLink.replaceWith(originalLink.innerText);
    }
  }

  setMapBounds() {
    this.map.fitBounds(
      this.markerTargets.map((m) => ({ lat: m.dataset.lat, lon: m.dataset.lon })),
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
