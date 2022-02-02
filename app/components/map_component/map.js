import 'leaflet';

import { Controller } from 'stimulus';

import './map.scss';

import api from '../../frontend/src/lib/api';

const MapController = class extends Controller {
  static targets = ['markersTextList'];

  connect() {
    const config = JSON.parse(this.element.dataset.config);

    api.getMapData(config).then((items) => {
      if (!items.length) return;

      if (!this.map) {
        const [mapCenter] = items.filter((mapItem) => mapItem.data.point);
        this.create(mapCenter.data.point, this.element.dataset.zoom);
      }

      const bounds = [];

      this.markersTextListTarget.innerHTML = '';

      items.forEach((item, index) => {
        this[item.type](item.data, items.length === 1, index + 1);
        bounds.push(item.data.point);
      });

      if (items.length > 1) {
        this.markersTextListTarget.classList.add('govuk-list--number');
        this.setMapBounds(bounds);
      }
    });
  }

  create(point, zoom) {
    this.map = L.map('map', { tap: false }).setView(point, zoom);

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' },
    ).addTo(this.map);
  }

  polygon({ coordinates }) {
    L.polygon(coordinates, { color: 'green' }).addTo(this.map);
  }

  marker({ point, meta }, showPopup, index) {
    const marker = L.marker(point, {
      icon: MapController.markerIcon(showPopup ? '' : `<span aria-label="${meta.name}, ${meta.address}">${index}</span>`),
      riseOnHover: true,
    });

    marker.addTo(this.map).bindPopup(
      MapController.popupHTML(meta),
      { className: 'map-component__map__popup' },
    );

    // use keydown event as leaflet doesnt recognise focus
    marker.on('keydown', MapController.openMarkerPopup);

    if (!showPopup) {
      this.markerItemHtml(`${meta.name}, ${meta.address}`);
    } else {
      marker.openPopup();
    }
  }

  static markerIcon(html) {
    return L.divIcon({
      className: 'map-component__map__marker--default',
      iconSize: [20, 20],
      html,
    });
  }

  setMapBounds(bounds) {
    this.map.fitBounds(bounds);
  }

  markerItemHtml(text) {
    this.markersTextListTarget.insertAdjacentHTML('beforeend', `<li>${text}</li>`);
  }

  static openMarkerPopup(e) {
    e.target.openPopup();
  }

  static popupHTML(data) {
    return `<h4 class="govuk-body-m govuk-!-margin-bottom-2">
    <a class="govuk-link" href="${data.name_link}">${data.name}</a>
    </h4>
    <ul class="govuk-list govuk-body-s">
    <li>${data.organisation_type}</li>
    <li>${data.address}</li>
    </ul>`;
  }
};

export default MapController;
