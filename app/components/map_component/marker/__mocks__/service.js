const Service = class {
  static async getMetaData({ markerType }) {
    let response;

    if (markerType === 'organisation') {
      response = {
        heading_text: 'organisation-text',
        heading_url: '/organisation-url',
        anonymised_id: 'xicav-lafyb-guduc-didyl',
        address: 'organisation-address',
        details: null,
      };
    }

    if (markerType === 'vacancy') {
      response = {
        heading_text: 'vacancy-text',
        heading_url: '/vacancy-url',
        anonymised_id: null,
        address: 'vacancy-address',
        details: [
          {
            label: 'Salary',
            value: '20000',
          },
        ],
      };
    }
    return Promise.resolve(response);
  }
};

export default Service;
