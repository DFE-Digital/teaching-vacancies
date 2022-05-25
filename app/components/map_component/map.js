import 'leaflet';
import 'leaflet.markercluster/dist/leaflet.markercluster';
import { GestureHandling } from 'leaflet-gesture-handling';

const Map = class {
  static MOBILE_BREAKPOINT = 768;

  static MARKER_OFFSET = {
    mobile: { x: 0, y: 150 },
    desktop: { x: 100, y: 0 },
  };

  constructor(point, zoom) {
    L.Map.addInitHook('addHandler', 'gestureHandling', GestureHandling);
    this.container = L.map('map', { tap: false, gestureHandling: true }).setView(point.coordinates.reverse(), zoom);

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' },
    ).addTo(this.container);

    if (document.documentElement.clientWidth <= Map.MOBILE_BREAKPOINT) {
      this.markerOffset = Map.MARKER_OFFSET.mobile;
    } else {
      this.markerOffset = Map.MARKER_OFFSET.desktop;
    }

    if (window.matchMedia) {
      const mediaQuery = `(max-width: ${Map.MOBILE_BREAKPOINT}px)`;
      const mediaQueryList = window.matchMedia(mediaQuery);

      if (mediaQueryList.addEventListener) {
        mediaQueryList.addEventListener('change', (e) => {
          if (e.matches) {
            this.markerOffset = Map.MARKER_OFFSET.mobile;
          } else {
            this.markerOffset = Map.MARKER_OFFSET.desktop;
          }
        });
      }
    }
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

        if (details.target && details.target.ui === 'custom') {
          this.initMarkerSidebar(marker, details);
        } else {
          Map.createMarkerPopup(marker, details);
        }

        addToLayer ? addToLayer.addLayer(marker) : this.container.addLayer(marker);

        marker.on('add', () => marker.getElement().setAttribute('aria-controls', 'sidebar-content'));
        marker.on('add', () => marker.getElement().setAttribute('id', id));
      },
    });
  }

  initMarkerSidebar(marker, { target }) {
    marker.on('keydown', async (e) => {
      if (['Enter'].includes(e.originalEvent.key)) {
        const markerData = await target.data();
        target.eventHandlers.opened(markerData);
        this.positionActiveMarker(marker);
      }

      if (['Tab'].includes(e.originalEvent.key)) {
        target.eventHandlers.close();
        Map.activeMarker();
      }
    });

    marker.on('click', async () => {
      const markerData = await target.data();
      target.eventHandlers.opened(markerData);

      this.positionActiveMarker(marker);

      this.container.on('preclick zoomstart', (e) => {
        if (e.originalEvent.target.classList.contains('map-component__map')) {
          target.eventHandlers.close();
          marker.getElement().blur();
        }
      });
    });
  }

  static createMarkerPopup(marker, { open, target }) {
    if (target) {
      marker.bindPopup('', { className: 'map-component__map__popup' });
      marker.on('keydown', (e) => e.target.closePopup());
      marker.on('popupopen', async () => {
        const markerData = await target.data();
        marker.setPopupContent(target.eventHandlers.opened(markerData));
      });
      if (open) marker.on('add', () => marker.openPopup());
    }
  }

  positionActiveMarker(marker) {
    const point = this.container.latLngToContainerPoint(marker.getLatLng());
    const newPoint = L.point([point.x - this.markerOffset.x, point.y - this.markerOffset.y]);
    this.positionToPoint(newPoint);
    Map.activeMarker(marker);
  }

  centerActiveMarker() {
    const point = this.container.latLngToContainerPoint(this.container.getCenter());
    const newPoint = L.point([point.x + this.markerOffset.x, point.y + this.markerOffset.y]);
    this.positionToPoint(newPoint);
  }

  positionToPoint(point) {
    this.container.setView(this.container.containerPointToLatLng(point));
  }

  static activeMarker(marker) {
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
