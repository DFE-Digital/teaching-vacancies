import Cluster from './cluster';

describe('when a cluster icon is created', () => {
  beforeAll(() => {
    Cluster.CLUSTER_BOUNDRIES = [
      {
        threshold: 5,
        style: 'medium',
      },
      {
        threshold: 8,
        style: 'large',
      },
    ];

    Cluster.CLUSTER_LIMIT = 10;
  });

  test('the icon has default properties when below first threshold', () => {
    expect(Cluster.icon(1)).toEqual({
      size: expect.any(Number),
      style: 'default',
      text: 1,
    });
  });

  test('the icon has correct properties when a threshold is met', () => {
    expect(Cluster.icon(5)).toEqual({
      size: expect.any(Number),
      style: 'medium',
      text: 5,
    });
  });

  test('the icon has correct properties when the limit is met', () => {
    expect(Cluster.icon(10)).toEqual({
      size: expect.any(Number),
      style: 'large',
      text: `${Cluster.CLUSTER_LIMIT}+`,
    });
  });
});
