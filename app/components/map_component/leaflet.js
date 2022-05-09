import 'leaflet';
import 'leaflet.markercluster/dist/leaflet.markercluster';
import { GestureHandling } from 'leaflet-gesture-handling';

const map = {
  create: (point, zoom) => {
    L.Map.addInitHook('addHandler', 'gestureHandling', GestureHandling);
    const m = L.map('map', { tap: false, gestureHandling: true }).setView(point, zoom);

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' },
    ).addTo(m);

    return m;
  },
  createCluster: (iconCreateFunction) => L.markerClusterGroup({
    iconCreateFunction: (cluster) => {
      const properties = iconCreateFunction(cluster.getChildCount());

      return L.divIcon({
        className: `map-component__map__cluster map-component__map__cluster--${properties.style}`,
        iconSize: [properties.size, properties.size],
        html: `<span>${properties.text}<span class="govuk-visually-hidden"> vacancies</span></span>`,
      });
    },
    maxClusterRadius: 40,
  }),
  createPolygon: ({ coordinates }) => L.polygon(coordinates.map((point) => point.reverse()), { color: '#0b0c0c', weight: 1, smoothFactor: 2 }),
  createCircle: (radius, point) => L.circle(point, { radius, color: '#0b0c0c', weight: 1 }),
  layerBounds: (layer) => layer.getBounds(),
  createMarker: (point, variant, popupHandler) => {
    const marker = L.marker(point, { icon: map.markerIcon(variant) });

    if (popupHandler) {
      marker.bindPopup('', { className: 'map-component__map__popup' });
      marker.on('keydown', (e) => e.target.closePopup());
      marker.on('popupopen', () => popupHandler(marker));
    }

    return marker;
  },
  markerIcon: (variant) => L.divIcon({
    className: `icon icon--map-${variant} map-component__map__marker`,
    iconSize: [22, 30],
  }),
};

export default map;
