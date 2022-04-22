import 'leaflet';
import 'leaflet.markercluster/dist/leaflet.markercluster';
import { GestureHandling } from 'leaflet-gesture-handling';

import { Controller } from '@hotwired/stimulus';

import './map.scss';

const MapController = class extends Controller {
  static targets = ['markersTextList', 'marker'];

  connect() {
    const singleMarker = this.markerTargets.length <= 1;
    const polygonData = this.element.dataset.polygon ? JSON.parse(this.element.dataset.polygon) : [];

    if (!singleMarker) {
      this.createCluster();
    }

    this.markerTargets.forEach((marker, index) => {
      const point = {
        lat: marker.dataset.lat,
        lon: marker.dataset.lon,
      };

      if (index === 0) {
        this.create(point, this.element.dataset.zoom);

        polygonData.forEach((polygon) => {
          const polygonLayer = MapController.createPolygon({ coordinates: polygon });
          this.addMapLayer(polygonLayer);
        });

        if (this.element.dataset.radius && this.element.dataset.point) {
          MapController.createMarker({
            lat: JSON.parse(this.element.dataset.point)[0],
            lon: JSON.parse(this.element.dataset.point)[1],
          }, 'location', 'location').addTo(this.map);
          this.addMapLayer(MapController.createCircle(this.element.dataset.radius, JSON.parse(this.element.dataset.point)));
        }
      }

      const leafletMarker = MapController.createPopupMarker(point, marker, 'pin');

      if (!singleMarker) {
        this.addMarkerToCluster(leafletMarker);
      } else if (leafletMarker) {
        leafletMarker.addTo(this.map);
        leafletMarker.openPopup();
      }
    });

    if (!singleMarker) {
      this.addMapLayer(this.clusterGroup);
    }

    if (this.markerTargets.length > 1) {
      this.setMapBounds();
    }
  }

  create(point, zoom) {
    L.Map.addInitHook('addHandler', 'gestureHandling', GestureHandling);
    this.map = L.map('map', { tap: false, gestureHandling: true }).setView(point, zoom);

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' },
    ).addTo(this.map);
  }

  createCluster() {
    this.clusterGroup = L.markerClusterGroup({
      iconCreateFunction: (cluster) => {
        const properties = MapController.clusterIconProperties(cluster.getChildCount(), [5, 20]);

        return L.divIcon({
          className: `map-component__map__cluster map-component__map__cluster--${properties.style}`,
          iconSize: [properties.size, properties.size],
          html: `<span>${properties.text}<span class="govuk-visually-hidden">vacancies</span></span>`,
        });
      },
      maxClusterRadius: 32,
    });
  }

  static clusterIconProperties(numberMarkers, thresholds = []) {
    const properties = {
      text: numberMarkers,
      size: 30,
      style: 'default',
    };

    const styles = ['medium', 'large'];

    thresholds.forEach((threshold, i) => {
      if (numberMarkers >= threshold) {
        properties.text = `${threshold}+`;
        properties.style = styles[i];
      }
    });

    return properties;
  }

  addMapLayer(layer) {
    this.map.addLayer(layer);
  }

  addMarkerToCluster(marker) {
    this.clusterGroup.addLayer(marker);
  }

  setMapBounds() {
    this.map.fitBounds(
      this.markerTargets.map((m) => ({ lat: m.dataset.lat, lon: m.dataset.lon })),
    );
  }

  static createPolygon({ coordinates }) {
    return L.polygon(coordinates.map((point) => point.reverse()), { color: '#0b0c0c', weight: 1, smoothFactor: 2 });
  }

  static createCircle(radius, point) {
    return L.circle(point, { radius, color: '#0b0c0c', weight: 1 });
  }

  static createPopupMarker(point, marker, variant) {
    const popupHTML = marker.querySelector('.pop-up');
    popupHTML.parentNode.removeChild(popupHTML);
    popupHTML.hidden = false;

    const markerTitle = popupHTML.querySelector('.marker-title').textContent;

    const leafletMarker = MapController.createMarker(point, markerTitle, variant);

    leafletMarker.bindPopup(
      popupHTML.outerHTML,
      { className: 'map-component__map__popup' },
    );

    leafletMarker.on('keydown', MapController.closeMarkerPopup);

    return leafletMarker;
  }

  static createMarker(point, markerTitle, variant) {
    return L.marker(point, {
      icon: MapController.markerIcon(markerTitle, variant),
      riseOnHover: true,
    });
  }

  static markerIcon(title, variant) {
    return L.divIcon({
      className: `icon icon--map-${variant} map-component__map__marker`,
      iconSize: [22, 30],
      html: `<span class="govuk-visually-hidden">${title}</span>`,
    });
  }

  static closeMarkerPopup(e) {
    e.target.closePopup();
  }
};

export default MapController;
