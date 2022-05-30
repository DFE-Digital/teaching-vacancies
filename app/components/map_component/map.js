import 'leaflet';
import 'leaflet.markercluster/dist/leaflet.markercluster';
import { GestureHandling } from 'leaflet-gesture-handling';

const Map = class {
  constructor(point, zoom) {
    L.Map.addInitHook('addHandler', 'gestureHandling', GestureHandling);
    this.centerPoint = point.coordinates.reverse();
    this.container = L.map('map', { tap: false, gestureHandling: true }).setView(this.centerPoint, zoom);

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' },
    ).addTo(this.container);

    this.markerOffset = { x: 0, y: 0 };
  }

  createMarker({
    point,
    id,
    title,
    variant,
    details = {},
    addToLayer,
  }) {
    L.geoJSON(point, {
      pointToLayer: (feature, latlng) => {
        const marker = L.marker(latlng, { icon: Map.markerIcon(variant), zIndexOffset: 100, title });

        if (details.target && details.target.ui === 'default') {
          Map.createMarkerPopup(marker, details);
        }

        addToLayer ? addToLayer.addLayer(marker) : this.container.addLayer(marker);

        marker.on('add', () => {
          marker.on('add', () => marker.getElement().setAttribute('aria-controls', 'sidebar-content'));
          marker.getElement().setAttribute('id', id);
          if (details.target && details.target.ui === 'custom') {
            this.markerCustomUIEvents(marker, details);
          }
        });
      },
    });
  }

  markerCustomUIEvents(marker, { target }) {
    marker.getElement().addEventListener('focus', async () => {
      const markerData = await target.data();
      target.eventHandlers.open(markerData);
      this.activeMarker(marker);
    });

    marker.getElement().addEventListener('blur', () => Map.markerStyle(marker));

    marker.on('keydown', (e) => {
      if (['Enter'].includes(e.originalEvent.key)) {
        target.eventHandlers.focus();
        this.activeMarker(marker);
      }

      if (['Escape', 'Esc'].includes(e.originalEvent.key)) {
        target.eventHandlers.close();
        this.activeMarker(marker);
      }
    });
  }

  static createMarkerPopup(marker, { open, target }) {
    if (target) {
      marker.bindPopup('', { className: 'map-component__map__popup' });
      marker.on('keydown', (e) => e.target.closePopup());
      marker.on('popupopen', async () => {
        const markerData = await target.data();
        marker.setPopupContent(target.eventHandlers.open(markerData));
      });
      if (open) marker.on('add', () => marker.openPopup());
    }
  }

  activeMarker(marker) {
    const point = this.container.latLngToContainerPoint(marker.getLatLng());
    const newPoint = L.point([point.x - this.markerOffset.x, point.y - this.markerOffset.y]);
    this.positionToPoint(newPoint);
    Map.markerStyle(marker);
  }

  positionToPoint(point) {
    this.container.setView(this.container.containerPointToLatLng(point));
    Map.markerStyle();
  }

  focusMarker(id, offset) {
    this.markerOffset = offset;
    document.getElementById(id).focus();
  }

  /* eslint-disable class-methods-use-this */
  blurMarker() {
    Map.markerStyle();
  }

  static markerStyle(marker) {
    Array.from(document.querySelectorAll('.map-component__map__marker')).forEach((m) => {
      m.classList.add('icon--map-pin');
      m.classList.remove('icon--map-pin--active');
    });

    if (marker) {
      marker.getElement().classList.remove('icon--map-pin');
      marker.getElement().classList.add('icon--map-pin--active');
    }
  }

  static createPolygon(polygon, styles) {
    return L.geoJSON(polygon, { ...styles, ...{ smoothFactor: 2 } });
  }

  static createCircle(radius, point, styles) {
    return L.geoJSON(point, {
      pointToLayer: (feature, latlng) => L.circle(latlng, { ...styles, ...{ radius } }),
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
