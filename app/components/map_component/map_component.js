import { Controller } from '@hotwired/stimulus';
import Map from './map';
import Cluster from './cluster';
import MarkerData from './marker/service';
import template from './marker/template';
import './map.scss';

const MARKER_OPTIONS = {
  vacancy: {
    ui: 'custom',
    title: 'Vacancy',
    variant: 'pin',
  },
  organisation: {
    ui: 'default',
    title: 'Vacancy location',
    variant: 'pin',
  },
  location: {
    title: 'Search location',
    variant: 'location',
  },
};

const MapController = class extends Controller {
  static targets = ['marker', 'markers'];

  static DEFAULT_ZOOM = 13;

  static SHAPE_STYLES = {
    color: '#0b0c0c',
    fillOpacity: '0.6',
    fillColor: '#b1b4b6',
    weight: 1,
    opacity: 1,
  };

  static MARKER_OPTIONS = MARKER_OPTIONS;

  connect() {
    if (this.markerTargets.length === 0) return;

    this.createMap();

    if (this.element.dataset.radius) {
      this.addMarker({
        point: this.point,
        variant: MapController.MARKER_OPTIONS.location.variant,
        title: MapController.MARKER_OPTIONS.location.title,
      });
      this.addLayer(Map.createCircle(this.radius, this.point, MapController.SHAPE_STYLES));
    }

    let markerOptions;

    this.markerTargets.forEach((marker) => {
      markerOptions = {
        point: JSON.parse(marker.dataset.point),
        variant: MapController.MARKER_OPTIONS[marker.dataset.markerType].variant,
        id: marker.dataset.id,
        title: MapController.MARKER_OPTIONS[marker.dataset.markerType].title,
        details: {
          open: this.markerTargets.length === 1,
          target: {
            data: () => MarkerData.getMetaData(marker.dataset),
            ui: MapController.MARKER_OPTIONS[marker.dataset.markerType].ui,
            eventHandlers: {
              opened: MapController.MARKER_OPTIONS[marker.dataset.markerType].ui === 'custom'
                ? (markerData) => {
                  this.dispatch('marker:click', {
                    detail: { ...markerData, ...{ id: marker.dataset.id } },
                  });
                }
                : (markerData) => template.popup(markerData),
              close: () => this.dispatch('user:interaction'),
            },
          },
        },
        addToLayer: this.cluster.group,
      };

      this.addMarker(markerOptions);
    });

    if (this.polygons) this.addLayer(Map.createPolygon(this.polygons, MapController.SHAPE_STYLES));

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

  centerMarker() {
    this.map.centerActiveMarker();
  }

  addLayer(layer) {
    this.map.container.addLayer(layer);

    if (this.markerTargets.length > 1) this.map.container.fitBounds(layer.getBounds());
  }
};

export default MapController;
