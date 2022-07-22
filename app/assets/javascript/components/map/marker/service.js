import axios from 'axios';

const Service = class {
  static async getMetaData({ id, parentId, markerType }) {
    const request = await axios.get(`/api/v1/markers/${id}`, {
      params: {
        parent_id: parentId,
        format: 'json',
        marker_type: markerType,
      },
    })
      .then((response) => response.data)
      .catch(() => {
        // could log debug info to sentry but would provide little value
      });

    return request;
  }
};

export default Service;
