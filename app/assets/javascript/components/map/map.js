import { Controller } from '@hotwired/stimulus';
import Map from './leaflet';
import Cluster from './cluster';
import MarkerData from './marker/service';
import template from './marker/template';

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
    fillOpacity: '0.4',
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

    let tracking;
    let markerOptions;

    if (this.markersTarget.dataset.markerTracking) {
      tracking = JSON.parse(this.markersTarget.dataset.markerTracking);
    }

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
              open: MapController.MARKER_OPTIONS[marker.dataset.markerType].ui === 'custom'
                ? (markerData) => {
                  this.dispatch('sidebar:update', {
                    detail: { ...markerData, ...{ trackingType: tracking.link, id: marker.dataset.id } },
                  });
                }
                : (markerData) => template.popup({ ...markerData, ...{ trackingType: tracking.link } }),
              focus: () => this.dispatch('sidebar:focus'),
              interaction: () => this.dispatch('interaction'),
            },
          },
        },
        addToLayer: this.cluster.group,
      };

      if (tracking) markerOptions.trackingType = tracking.marker;

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
    const markerType = MapController.MARKER_OPTIONS[this.markerTargets[0].dataset.markerType].ui;
    this.map = new Map(this.point, MapController.DEFAULT_ZOOM);
    this.cluster = new Cluster({
      eventHandlers: {
        focus: () => this.dispatch('interaction'),
        enter: ({ detail }) => {
          if (markerType === 'custom') {
            this.dispatch('sidebar:update', { detail: { id: detail.id } });
          }
        },
        leave: () => this.dispatch('interaction'),
      },
    });
  }

  addMarker(options) {
    this.map.createMarker(options);
  }

  centerCluster({ detail }) {
    const point = this.map.container.latLngToContainerPoint(detail.latlng);
    this.map.positionToPoint(point);
  }

  focusMarker({ detail }) {
    this.map.focusMarker(detail.id, detail.offset);
  }

  blurMarker() {
    this.map.blurMarker();
  }

  addLayer(layer) {
    this.map.container.addLayer(layer);

    this.map.container.fitBounds(layer.getBounds(), { maxZoom: 12 });
  }
};

export default MapController;
