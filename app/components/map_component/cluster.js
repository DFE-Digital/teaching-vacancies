import 'leaflet.markercluster/dist/leaflet.markercluster';

const Cluster = class {
  static CLUSTER_THRESHOLDS = [5, 20];

  constructor() {
    this.group = L.markerClusterGroup({
      iconCreateFunction: (cluster) => {
        const properties = Cluster.icon(cluster.getChildCount());

        return L.divIcon({
          className: `map-component__map__cluster map-component__map__cluster--${properties.style}`,
          iconSize: [properties.size, properties.size],
          html: `<span>${properties.text}<span class="govuk-visually-hidden"> vacancies</span></span>`,
        });
      },
      maxClusterRadius: 40,
    });
  }

  static icon(numberMarkers) {
    const properties = {
      text: numberMarkers,
      size: 30,
      style: 'default',
    };

    const styles = ['medium', 'large'];

    Cluster.CLUSTER_THRESHOLDS.forEach((threshold, i) => {
      if (numberMarkers >= threshold) {
        properties.style = styles[i];
      }
    });

    return properties;
  }
};

export default Cluster;
