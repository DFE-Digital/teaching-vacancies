import axios from 'axios';

const Service = class {
  static async getMetaData({ id, parentId, markerType }) {
    const response = await axios.get(`/api/v1/markers/${id}`, {
      params: {
        parent_id: parentId,
        format: 'json',
        marker_type: markerType,
      },
    });
    return response.data;
  }
};

export default Service;
