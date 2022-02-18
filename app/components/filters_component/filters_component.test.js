/* global page:readonly */
import FiltersComponent from './filters_component';

describe('filters view component', () => {
  beforeAll(async () => {
    await page.goto('http://localhost:3000/components/filters_component/preview');
  });

  describe('clear all filters control', () => {
    it('should uncheck all filters', async () => {
      await page.evaluate(() => {
        document.getElementById('new_filters_component_preview_form').addEventListener('submit', (e) => {
          e.preventDefault();
        });
      });

      await page.$$eval(`.${FiltersComponent.CHECKBOX_CLASS_SELECTOR}`, (el) => el[0].click());
      let [checkboxChecked] = await page.$$eval(`.${FiltersComponent.CHECKBOX_CLASS_SELECTOR}`, (el) => el.map((cb) => cb.checked));

      expect(checkboxChecked).toBe(true);

      await page.$$eval(`.${FiltersComponent.CHECKBOX_CLASS_SELECTOR}`, (el) => el[0].click());
      [checkboxChecked] = await page.$$eval(`.${FiltersComponent.CHECKBOX_CLASS_SELECTOR}`, (el) => el.map((cb) => cb.checked));

      expect(checkboxChecked).toBe(false);
    });
  });

  describe('remove button for specific filter control', () => {
    it('should uncheck corresponding filter', async () => {
      await page.evaluate(() => {
        document.getElementById('new_filters_component_preview_form').addEventListener('submit', (e) => {
          e.preventDefault();
        });
      });

      await page.$$eval(`.${FiltersComponent.CHECKBOX_CLASS_SELECTOR}`, (el) => el[1].click());
      let checkboxesChecked = await page.$$eval(`.${FiltersComponent.CHECKBOX_CLASS_SELECTOR}`, (el) => el.map((cb) => cb.checked));

      expect(checkboxesChecked[0]).toBe(false);
      expect(checkboxesChecked[1]).toBe(true);

      await page.$$eval(FiltersComponent.CLEAR_BUTTON_SELECTOR, (el) => el[0].click());

      checkboxesChecked = await page.$$eval(`.${FiltersComponent.CHECKBOX_CLASS_SELECTOR}`, (el) => el.map((cb) => cb.checked));
      expect(checkboxesChecked[0]).toBe(false);
      expect(checkboxesChecked[1]).toBe(false);
    });
  });
});
