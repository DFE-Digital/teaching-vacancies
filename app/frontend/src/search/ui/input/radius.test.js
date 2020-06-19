import { getRadius } from './radius';

describe('getRadius', () => {
  test('to be truthy when radius data attribute is present', () => {
    document.body.innerHTML = `<select name="radius" id="radius" data-radius="10"><option value="1">1 mile</option>
    <option value="5">5 miles</option>
</select>`;
    expect(getRadius()).toBe(16094);
  });

  test('to be false when radius data attribute is not present', () => {
    document.body.innerHTML = `<select name="radius" id="radius"><option value="1">1 mile</option>
    <option value="5">5 miles</option>
</select>`;
    expect(getRadius()).toBe(false);
  });

  test('to be false when radius element is not present', () => {
    document.body.innerHTML = `<select name="radius" id="wrong-id"><option value="1">1 mile</option>
    <option value="5">5 miles</option>
</select>`;
    expect(getRadius()).toBe(false);
  });
});
