import 'leaflet';
import 'leaflet.markercluster/dist/leaflet.markercluster';
import { GestureHandling } from 'leaflet-gesture-handling';

const SHAPE_STYLES = {
  color: '#505a5f',
  weight: 2,
  opacity: 0.4,
};

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
  createCluster: (clusterIcon) => L.markerClusterGroup({
    iconCreateFunction: (cluster) => {
      const properties = clusterIcon(cluster.getChildCount());

      return L.divIcon({
        className: `map-component__map__cluster map-component__map__cluster--${properties.style}`,
        iconSize: [properties.size, properties.size],
        html: `<span>${properties.text}<span class="govuk-visually-hidden"> vacancies</span></span>`,
      });
    },
    maxClusterRadius: 40,
  }),
  createPolygon: ({ coordinates }) => L.polygon(coordinates.map((point) => point.reverse()), Object.assign(SHAPE_STYLES, { smoothFactor: 2 })),
  createCircle: (radius, point) => L.circle(point, Object.assign(SHAPE_STYLES, { radius })),
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
