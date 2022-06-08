const Cluster = class {
  static CLUSTER_BOUNDRIES = [
    {
      threshold: 10,
      style: 'medium',
    },
    {
      threshold: 50,
      style: 'large',
    },
  ];

  static CLUSTER_LIMIT = 50;

  constructor({ eventHandlers }) {
    this.group = L.markerClusterGroup({
      iconCreateFunction: (cluster) => {
        cluster.on('add', () => {
          cluster.getElement().addEventListener('focus', eventHandlers.focus);
        });

        cluster.on('click keydown', (c) => {
          if (c.target.getAllChildMarkers().length) {
            const [marker] = c.target.getAllChildMarkers();

            marker.once('add', () => {
              eventHandlers.enter({
                detail: {
                  id: marker.getElement().id,
                },
              });
            });

            marker.once('remove', eventHandlers.leave);
          }
        });

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

    Cluster.CLUSTER_BOUNDRIES.forEach((boundray) => {
      if (numberMarkers >= boundray.threshold) {
        properties.style = boundray.style;
      }

      if (numberMarkers >= Cluster.CLUSTER_LIMIT) {
        properties.text = `${Cluster.CLUSTER_LIMIT}+`;
      }
    });

    return properties;
  }
};

export default Cluster;

