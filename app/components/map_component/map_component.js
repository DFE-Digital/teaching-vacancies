import { Controller } from '@hotwired/stimulus';
import Map from './map';
import Cluster from './cluster';
import MarkerData from './marker/service';
import popup from './marker/popup';
import './map.scss';

const MapController = class extends Controller {
  static targets = ['marker'];

  static DEFAULT_ZOOM = 13;

  static SHAPE_STYLES = {
    color: '#505a5f',
    weight: 2,
    opacity: 0.4,
  };

  connect() {
    if (this.markerTargets.length === 0) {
      return;
    }

    this.createMap();

    if (this.element.dataset.radius) {
      this.addMarker({ point: this.point, variant: 'location' });
      this.addLayer(Map.createCircle(this.radius, this.point, MapController.SHAPE_STYLES));
    }

    this.markerTargets.forEach((markerTarget) => {
      this.addMarker({
        point: JSON.parse(markerTarget.dataset.point),
        variant: 'pin',
        popup: {
          data: (marker) => MarkerData.getMetaData(markerTarget.dataset).then((markerData) => marker.setPopupContent(popup(markerData))),
          open: this.markerTargets.length === 1,
        },
        addToLayer: this.cluster.group,
      });
    });

    if (this.polygons) {
      this.addLayer(Map.createPolygon(this.polygons, MapController.SHAPE_STYLES));
    }

    this.addLayer(this.cluster.group);
  }

  get radius() {
    return this.element.dataset.radius;
  }

  get point() {
    return this.element.dataset.point ? JSON.parse(this.element.dataset.point) : JSON.parse(this.markerTargets[0].dataset.point);
  }

  get polygons() {
    return this.element.dataset.polygons ? JSON.parse(this.element.dataset.polygons) : false;
  }

  createMap() {
    this.map = new Map(this.point, MapController.DEFAULT_ZOOM);
    this.cluster = new Cluster();
  }

  addMarker(options) {
    this.map.createMarker(options);
  }

  addLayer(layer) {
    this.map.container.addLayer(layer);

    if (this.markerTargets.length > 1) {
      this.map.container.fitBounds(layer.getBounds());
    }
  }
};

export default MapController;
