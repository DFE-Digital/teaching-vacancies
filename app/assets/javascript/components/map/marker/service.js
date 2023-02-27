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
        if (error.response && (error.response.status !== 200 || error.response.status !== 204)) {
          logger.warn(error.message);
        } else {
          logger.log(error.message);
        }
      });

    return request;
  }
};

export default Service;
