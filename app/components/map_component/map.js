import 'leaflet';
import 'leaflet/dist/leaflet.css';

import { Controller } from '@hotwired/stimulus';

import './map.scss';

import api from '../../frontend/src/lib/api';

const MapController = class extends Controller {
  connect() {
    const config = JSON.parse(this.element.dataset.config);

    api.getMapData(config).then((items) => {
      if (!this.map) {
        const [[mapCenter]] = items.filter((mapItem) => mapItem[0].data.point);
        this.create(mapCenter.data.point, this.element.dataset.zoom);
      }

      items.forEach((mapItem) => {
        mapItem.forEach((item) => {
          this[item.type](item.data);
        });
      });
    });
  }

  create(point, zoom) {
    this.map = L.map('map').setView(point, zoom);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(this.map);
  }

  polygon({ coordinates }) {
    L.polygon(coordinates, { color: 'green' }).addTo(this.map);
  }

  marker({ point, meta }) {
    const icon = L.divIcon({ className: 'map-component__map__marker--default', iconSize: [20, 20] });

    L.marker(point, { icon }).addTo(this.map).bindPopup(MapController.markerHTML(meta)).openPopup();
  }

  static markerHTML(data) {
    return `<h4 class="govuk-body-m"><a href="${data.name_link}">${data.name}</a></h4><p>${data.school_type}</p><p>${data.address}</p>`;
  }
};

export default MapController;
