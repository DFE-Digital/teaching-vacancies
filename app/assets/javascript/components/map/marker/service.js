import axios from 'axios';

import logger from '../../../lib/logging';

const Service = class {
  static async getMetaData({ id, parentId, markerType }) {
    if (!id) return false;

    const request = await axios.get(`/api/v1/markers/${id}`, {
      params: {
        parent_id: parentId,
        format: 'json',
        marker_type: markerType,
      },
    })
      .then((response) => response.data)
      .catch((error) => {
        logger.warn(error.message);
      });

    return request;
  }
};

export default Service;
