import 'leaflet';
import 'leaflet/dist/leaflet.css';

import { Controller } from '@hotwired/stimulus';

import './map.scss';

import api from '../../frontend/src/lib/api';

export default class extends Controller {
  connect() {
    const config = JSON.parse(this.element.dataset.config);

    api.getMapData(config).then((data) => {
      if (!this.map) {
        this.create(data[0][0].data, this.element.dataset.zoom);
      }

      data.forEach((mapItem) => {
        mapItem.forEach((item) => {
          this[item.type](item.data);
        });
      });
    });
  }

  create({ point }, zoom) {
    this.map = L.map('map').setView(point, zoom);

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png').addTo(this.map);
  }

  polygon({ coordinates }) {
    L.polygon(coordinates, { color: 'green' }).addTo(this.map);
  }

  marker({ point, meta }) {
    const icon = L.divIcon({ className: 'map-component__map__icon', iconSize: [20, 20] });

    L.marker(point, { icon }).addTo(this.map).bindPopup(meta.name).openPopup();
  }
}
