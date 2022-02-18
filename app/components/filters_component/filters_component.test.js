/* global page:readonly */
describe('filters view component', () => {
  beforeAll(async () => {
    await page.goto('http://localhost:3000/components/filters_component/preview');
  });

  describe('clear all filters control', () => {
    it('should uncheck all filters', async () => {
      await page.evaluate(() => {
        document.getElementById('new_filters_component_preview_options_form').addEventListener('submit', (e) => {
          e.preventDefault();
        });
      });

      await page.evaluate(() => {
        document.querySelector('.govuk-checkboxes__input').click();
      });
      let [checkboxChecked] = await page.$$eval('.govuk-checkboxes__input', (el) => el.map((cb) => cb.checked));
      expect(checkboxChecked).toBe(true);

      await page.evaluate(() => {
        document.querySelector('.filters-component__link-button').click();
      });

      [checkboxChecked] = await page.$$eval('.govuk-checkboxes__input', (el) => el.map((cb) => cb.checked));
      expect(checkboxChecked).toBe(false);
    });
  });

  describe('remove button for specific filter control', () => {
    it('should uncheck corresponding filter', async () => {
      await page.evaluate(() => {
        document.getElementById('new_filters_component_preview_options_form').addEventListener('submit', (e) => {
          e.preventDefault();
        });
      });

      await page.evaluate(() => {
        document.querySelectorAll('.govuk-checkboxes__input')[1].click();
      });
      let checkboxesChecked = await page.$$eval('.govuk-checkboxes__input', (el) => el.map((cb) => cb.checked));
      expect(checkboxesChecked[0]).toBe(false);
      expect(checkboxesChecked[1]).toBe(true);

      await page.evaluate(() => {
        document.querySelector('.filters-component__link-button').click();
      });

      checkboxesChecked = await page.$$eval('.govuk-checkboxes__input', (el) => el.map((cb) => cb.checked));
      expect(checkboxesChecked[0]).toBe(false);
      expect(checkboxesChecked[1]).toBe(false);
    });
  });
});
