import popup from './popup';
import Service from './service';

jest.mock('./service');

describe('when an organisation popup is created', () => {
  let response;

  beforeAll(async () => {
    response = await Service.getMetaData({
      markerType: 'organisation',
    });

    document.body.insertAdjacentHTML('afterbegin', popup(response));
  });

  test('it displays heading link', () => {
    expect(document.querySelector('.popup-title').innerHTML).toEqual(expect.stringContaining(response.heading_text));
    expect(document.querySelector('.popup-title a').href).toEqual(expect.stringContaining(response.heading_url));
  });

  test('heading link has tracking data', () => {
    expect(document.querySelector('.popup-link').dataset.controller).toEqual('tracked-link');
    expect(document.querySelector('.popup-link').dataset.action).toEqual(expect.any(String));
    expect(document.querySelector('.popup-link').dataset.linkSubject).toEqual(expect.any(String));
  });

  test('it displays address', () => {
    expect(document.querySelector('.govuk-list').innerHTML).toEqual(expect.stringContaining(response.address));
  });
});

describe('when a vacancy popup is created', () => {
  let response;

  beforeAll(async () => {
    response = await Service.getMetaData({
      markerType: 'vacancy',
    });

    document.body.insertAdjacentHTML('afterbegin', popup(response));
  });

  test('it displays heading link', () => {
    expect(document.querySelector('.popup-title').innerHTML).toEqual(expect.stringContaining(response.heading_text));
    expect(document.querySelector('.popup-title a').href).toEqual(expect.stringContaining(response.heading_url));
  });

  test('heading link has no tracking data', () => {
    expect(document.querySelector('.popup-link').dataset.controller).toBeFalsy();
    expect(document.querySelector('.popup-link').dataset.action).toBeFalsy();
    expect(document.querySelector('.popup-link').dataset.linkSubject).toBeFalsy();
  });

  test('it displays address', () => {
    expect(document.querySelector('.govuk-list').innerHTML).toEqual(expect.stringContaining(response.address));
  });
});
