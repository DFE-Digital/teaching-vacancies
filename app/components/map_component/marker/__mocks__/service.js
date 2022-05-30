const Service = class {
  static async getMetaData({ markerType, tracked }) {
    let response;

    if (markerType === 'organisation') {
      response = {
        heading_text: 'organisation-text',
        heading_url: '/organisation-url',
        address: 'organisation-address',
        details: null,
      };
    }

    if (markerType === 'vacancy') {
      response = {
        heading_text: 'vacancy-text',
        heading_url: '/vacancy-url',
        address: 'vacancy-address',
        details: [
          {
            label: 'Salary',
            value: '20000',
          },
        ],
      };
    }

    if (tracked) {
      response.anonymised_id = 'xicav-lafyb-guduc-didyl';
    }
    return Promise.resolve(response);
  }
};

export default Service;
