import { Controller } from '@hotwired/stimulus';
import map from './map';
import MarkerData from './marker_service';
import popup from './marker_popup';
import './map.scss';

const MapController = class extends Controller {
  static targets = ['marker'];

  static DEFAULT_ZOOM = 13;

  static CLUSTER_THRESHOLDS = [5, 20];

  connect() {
    this.clusterGroup = map.createCluster(MapController.clusterIconProperties);

    this.markerTargets.forEach((markerTarget, index) => {
      const point = {
        lat: markerTarget.dataset.lat,
        lon: markerTarget.dataset.lon,
      };

      if (index === 0) {
        this.map = map.create(point, MapController.DEFAULT_ZOOM);

        if (this.element.dataset.radius && this.element.dataset.point) {
          const locationMarker = map.createMarker(JSON.parse(this.element.dataset.point), 'location');
          this.addToMap(locationMarker);
          this.addCircle();
        }
      }

      const marker = map.createMarker(point, 'pin', (m) => {
        MarkerData.getMetaData(markerTarget.dataset.id, markerTarget.dataset.parentId, markerTarget.dataset.markerType).then((markerData) => {
          m.setPopupContent(popup(markerData));
        });
      });

      if (this.markerTargets.length > 1) {
        this.addMarkerToCluster(marker);

        if (!this.bounds) {
          this.setMapBounds(this.markerTargets.map((m) => ({ lat: m.dataset.lat, lon: m.dataset.lon })));
        }
      } else if (marker) {
        this.addToMap(marker);
        marker.openPopup();
      }
    });

    this.addPolygons();

    this.addToMap(this.clusterGroup);
  }

  addCircle() {
    const circle = map.createCircle(this.element.dataset.radius, JSON.parse(this.element.dataset.point));
    this.addToMap(circle);
    this.setMapBounds(map.layerBounds(circle));
  }

  addPolygons() {
    if (this.element.dataset.polygons) {
      const coordinates = [];
      JSON.parse(this.element.dataset.polygons).forEach((data) => {
        coordinates.push(data);
        const polygon = map.createPolygon({ coordinates: data });
        this.addToMap(polygon);
      });

      this.setMapBounds(coordinates);
    }
  }

  static clusterIconProperties(numberMarkers) {
    const properties = {
      text: numberMarkers,
      size: 30,
      style: 'default',
    };

    const styles = ['medium', 'large'];

    MapController.CLUSTER_THRESHOLDS.forEach((threshold, i) => {
      if (numberMarkers >= threshold) {
        properties.style = styles[i];
      }
    });

    return properties;
  }

  addToMap(layer) {
    this.map.addLayer(layer);
  }

  addMarkerToCluster(marker) {
    this.clusterGroup.addLayer(marker);
  }

  setMapBounds(bounds) {
    this.bounds = bounds;
    this.map.fitBounds(bounds);
  }
};

export default MapController;
