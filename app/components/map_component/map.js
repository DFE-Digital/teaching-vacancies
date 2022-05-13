import 'leaflet';
import { GestureHandling } from 'leaflet-gesture-handling';

const Map = class {
  constructor(point, zoom) {
    L.Map.addInitHook('addHandler', 'gestureHandling', GestureHandling);
    this.container = L.map('map', { tap: false, gestureHandling: true }).setView(point.coordinates.reverse(), zoom);

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' },
    ).addTo(this.container);
  }

  createMarker({
    point,
    variant,
    popup = {},
    addToLayer,
  }) {
    L.geoJSON(point, {
      pointToLayer: (feature, latlng) => {
        const marker = L.marker(latlng, { icon: Map.markerIcon(variant) });

        if (popup.data) {
          marker.bindPopup('', { className: 'map-component__map__popup' });
          marker.on('keydown', (e) => e.target.closePopup());
          marker.on('popupopen', () => popup.data(marker));

          if (popup.open) {
            marker.on('add', () => marker.openPopup());
          }
        }
        addToLayer ? addToLayer.addLayer(marker) : this.container.addLayer(marker);
      },
    });
  }

  static createPolygon(polygon, styles) {
    return L.geoJSON(polygon, Object.assign(styles, { smoothFactor: 2 }));
  }

  static createCircle(radius, point, styles) {
    return L.geoJSON(point, {
      pointToLayer: (feature, latlng) => L.circle(latlng, Object.assign(styles, { radius })),
    });
  }

  static markerIcon(variant) {
    return L.divIcon({
      className: `icon icon--map-${variant} map-component__map__marker`,
      iconSize: [22, 30],
    });
  }
};

export default Map;
