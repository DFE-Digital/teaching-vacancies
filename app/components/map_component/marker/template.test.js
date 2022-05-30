import template from './template';
import Service from './service';

jest.mock('./service');

describe('when a tracked organisation popup is created', () => {
  let response;

  beforeAll(async () => {
    response = await Service.getMetaData({
      markerType: 'organisation',
      tracked: true,
    });

    document.body.innerHTML = '';
    document.body.appendChild(template.popup(response));
  });

  test('it displays heading link', () => {
    expect(document.querySelector('h4').innerHTML).toEqual(expect.stringContaining(response.heading_text));
    expect(document.querySelector('h4 a').href).toEqual(expect.stringContaining(response.heading_url));
  });

  test('heading link has tracking data', () => {
    expect(document.querySelector('.tracked').dataset.controller).toEqual('tracked-link');
    expect(document.querySelector('.tracked').dataset.action).toEqual(expect.any(String));
    expect(document.querySelector('.tracked').dataset.linkSubject).toEqual(expect.any(String));
  });

  test('it displays address', () => {
    expect(document.querySelector('.govuk-list').innerHTML).toEqual(expect.stringContaining(response.address));
  });
});

describe('when an untracked vacancy popup is created', () => {
  let response;

  beforeAll(async () => {
    response = await Service.getMetaData({
      markerType: 'vacancy',
      tracked: false,
    });

    document.body.innerHTML = '';
    document.body.appendChild(template.popup(response));
  });

  test('it displays heading link', () => {
    expect(document.querySelector('h4').innerHTML).toEqual(expect.stringContaining(response.heading_text));
    expect(document.querySelector('h4 a').href).toEqual(expect.stringContaining(response.heading_url));
  });

  test('heading link has no tracking data', () => {
    expect(document.querySelector('.tracked').dataset.controller).toBeFalsy();
    expect(document.querySelector('.tracked').dataset.action).toBeFalsy();
    expect(document.querySelector('.tracked').dataset.linkSubject).toBeFalsy();
  });

  test('it displays address', () => {
    expect(document.querySelector('.govuk-list').innerHTML).toEqual(expect.stringContaining(response.address));
  });
});
