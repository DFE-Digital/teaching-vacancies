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
        html: `<span>${properties.text}<span class="govuk-visually-hidden">vacancies</span></span>`,
      });
    },
    maxClusterRadius: 40,
  }),
  createPolygon: ({ coordinates }) => L.polygon(coordinates.map((point) => point.reverse()), { color: '#0b0c0c', weight: 1, smoothFactor: 2 }),
  createCircle: (radius, point) => L.circle(point, { radius, color: '#0b0c0c', weight: 1 }),
  createMarker: (point, variant, popup) => {
    const marker = L.marker(point, {
      icon: map.markerIcon(popup.title, variant),
      riseOnHover: true,
    });

    if (popup) {
      marker.bindPopup(
        popup.html,
        { className: 'map-component__map__popup' },
      );

      marker.on('keydown', map.closeMarkerPopup);
    }

    return marker;
  },
  closeMarkerPopup: (e) => {
    e.target.closePopup();
  },
  markerIcon: (title, variant) => L.divIcon({
    className: `icon icon--map-${variant} map-component__map__marker`,
    iconSize: [22, 30],
    html: `<span class="govuk-visually-hidden">${title}</span>`,
  }),
};

export default map;
