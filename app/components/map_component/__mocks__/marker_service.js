export const getMetaData = (latitude, longitude) => {
  if (latitude && longitude) {
    return Promise.resolve({
      heading_text: 'Class Teacher',
      heading_url: '/jobs/class-teacher-c1bd5e1c-6733-4e8f-9535-64761378ca7c',
      address: 'Rose Avenue, HIGH WYCOMBE, Buckinghamshire, HP15 7PH',
      details: [
        {
          label: 'Salary',
          value: 'MPS / UPS £25,714 - £41,604 depending on experience',
        },
        {
          label: 'School type',
          value: 'Local authority maintained school, ages 7 to 11',
        },
        {
          label: 'Working pattern',
          value: 'Full time',
        },
        {
          label: 'Closing date',
          value: '12 May 2022 at 9:00am',
        },
      ],
    });
  }
  return Promise.reject(new Error());
};

const api = {
  getMetaData,
};

export default api;
