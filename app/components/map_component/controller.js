import { Controller } from '@hotwired/stimulus';
import map from './map';
import './map.scss';

const MapController = class extends Controller {
  static targets = ['markersTextList', 'marker'];

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
          this.addToMap(map.createMarker(JSON.parse(this.element.dataset.point), 'location', {
            html: '<span class="govuk-body">Search location<span>',
          }));

          const circle = map.createCircle(this.element.dataset.radius, JSON.parse(this.element.dataset.point));

          this.addToMap(circle);
          this.setMapBounds(map.layerBounds(circle));
        }
      }

      const marker = map.createMarker(point, 'pin', MapController.getTargetPopup(markerTarget));

      if (this.markerTargets.length > 1) {
        this.addMarkerToCluster(marker);
      } else if (marker) {
        this.addToMap(marker);
        marker.openPopup();
      }
    });

    if (this.element.dataset.polygon) {
      const [data] = JSON.parse(this.element.dataset.polygon);
      const polygon = map.createPolygon({ coordinates: data });
      this.setMapBounds(map.layerBounds(polygon));
      this.addToMap(polygon);
    }

    this.addToMap(this.clusterGroup);

    if (this.markerTargets.length > 1 && !this.bounds) {
      this.setMapBounds(this.markerTargets.map((m) => ({ lat: m.dataset.lat, lon: m.dataset.lon })));
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
        properties.text = `${threshold}+`;
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

  static getTargetPopup(target) {
    const popupHTML = target.querySelector('.pop-up');
    popupHTML.parentNode.removeChild(popupHTML);
    popupHTML.hidden = false;

    return {
      title: popupHTML.querySelector('.marker-title').textContent,
      html: popupHTML.outerHTML,
    };
  }
};

export default MapController;
