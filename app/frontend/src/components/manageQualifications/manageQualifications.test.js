/**
 * @jest-environment jsdom
 */

import { Application } from 'stimulus';
import ManageQualificationsController from './manageQualifications';

Application.start().register('manage-qualifications', ManageQualificationsController);

describe('manageQualifications', () => {
  const originalMarkup = `<fieldset data-controller="manage-qualifications">
      <div class="row" data-manage-qualifications-target="row">
        <div class="govuk-form-group">
          <label for="subject1">Subject 1</label>
          <input class="govuk-input" value="Maths" />
        </div>
        <div class="govuk-form-group">
          <a class="delete-row" href="#" data-action="manage-qualifications#deleteRow">delete subject</a>
        </div>
      </div>
      <div class="row" data-manage-qualifications-target="row">
        <div class="govuk-form-group">
          <label for="subject2">Subject 2</label>
          <input class="govuk-input govuk-input--error" value="Music" />
        </div>
        <div class="govuk-form-group">
          <a class="delete-row" href="#" data-action="manage-qualifications#deleteRow">delete subject</a>
        </div>
      </div>
      <div class="row js-hidden" data-manage-qualifications-target="row">
        <div class="govuk-form-group">
          <label for="subject3">Subject 3</label>
          <input class="govuk-input" />
        </div>
        <div class="govuk-form-group">
          <a class="delete-row" href="#" data-action="manage-qualifications#deleteRow">delete subject</a>
        </div>
      </div>
      <div class="row js-hidden" data-manage-qualifications-target="row">
        <div class="govuk-form-group">
          <label for="subject4">Subject 4</label>
          <input class="govuk-input" />
        </div>
        <div class="govuk-form-group">
          <a class="delete-row" href="#" data-action="manage-qualifications#deleteRow">delete subject</a>
        </div>
      </div>
      <a id="add-row" href="#" data-action="manage-qualifications#addRow">Add subject</a>
    </fieldset>`;

  beforeEach(() => {
    document.body.innerHTML = originalMarkup;
  });

  describe('Adding a row', () => {
    let addButton;

    beforeEach(() => {
      addButton = document.getElementById('add-row');
    });

    test('it adds a row', () => {
      expect(document.getElementsByClassName('row').length).toBe(4);

      addButton.click();

      expect(document.getElementsByClassName('row').length).toBe(5);
    });

    test('it renumbers the rows', () => {
      addButton.click();

      const rows = Array.from(document.getElementsByClassName('row'));
      rows.forEach((row, index) => expect(row.children[0].children[0].innerHTML).toBe(`Subject ${index + 1}`));
    });

    test('it keeps values', () => {
      const rows = Array.from(document.getElementsByClassName('row'));
      const valueRow = rows[0];
      expect(valueRow.children[0].children[1].value).toBe('Maths');

      addButton.click();
      expect(valueRow.children[0].children[1].value).toBe('Maths');
    });

    test('it puts the new subject input in focus', () => {
      addButton.click();

      const rows = Array.from(document.getElementsByClassName('row'));
      const visibleRows = rows.filter((row) => !row.classList.contains('js-hidden'));
      const newRow = visibleRows[visibleRows.length - 1];

      expect(newRow.getElementsByClassName('govuk-input')[0] === document.activeElement).toBe(true);
    });
  });

  describe('Deleting a row', () => {
    let deletedRow;
    let deleteButton;

    beforeEach(() => {
      const rows = Array.from(document.getElementsByClassName('row'));

      [, deletedRow] = rows;
      deleteButton = deletedRow.querySelector('.delete-row');
    });

    test('it deletes the row', () => {
      expect(document.getElementsByClassName('row').length).toBe(4);

      deleteButton.click();

      expect(document.getElementsByClassName('row').length).toBe(3);
    });

    test('it renumbers the rows', () => {
      deleteButton.click();

      const rows = Array.from(document.getElementsByClassName('row'));
      rows.forEach((row, index) => expect(row.children[0].children[0].innerHTML).toBe(`Subject ${index + 1}`));
    });

    test('it keeps values', () => {
      const rows = Array.from(document.getElementsByClassName('row'));
      const valueRow = rows[0];
      expect(valueRow.children[0].children[1].value).toBe('Maths');

      document.getElementById('add-row').click();
      expect(valueRow.children[0].children[1].value).toBe('Maths');
    });
  });
});
