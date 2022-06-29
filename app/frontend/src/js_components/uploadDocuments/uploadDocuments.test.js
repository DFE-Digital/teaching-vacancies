/**
 * @jest-environment jsdom
 */

import { Application } from '@hotwired/stimulus';
import UploadDocumentsController from './uploadDocuments';

const initialiseStimulus = () => {
  const application = Application.start();
  application.register('upload-documents', UploadDocumentsController);
};

let targetsHTML = '';

UploadDocumentsController.targets.forEach((target) => {
  targetsHTML += `<input data-upload-documents-target="${target}" id="${target}" />`;
});

const markup = `<div data-controller="upload-documents" id="upload-documents">${targetsHTML}</div>`;

describe('when upload documents is active', () => {
  beforeEach(() => {
    document.body.innerHTML = markup;
    document.getElementById('upload-documents').setAttribute('data-upload-documents-inactive-value', false);
    initialiseStimulus();
  });

  test('the upload controls are visible to the user', () => {
    expect(document.getElementById('inputFileUpload').classList.contains('govuk-!-display-none')).toBe(true);
    expect(document.getElementById('uploadFilesButton').classList.contains('govuk-!-display-none')).toBe(true);
    expect(document.getElementById('selectFileButton').classList.contains('govuk-!-display-none')).toBe(false);
  });
});

describe('when upload documents is inactive', () => {
  beforeEach(() => {
    document.body.innerHTML = markup;
    document.getElementById('upload-documents').setAttribute('data-upload-documents-inactive-value', true);
    initialiseStimulus();
  });

  test('the upload controls are not visible to the user', () => {
    expect(document.getElementById('inputFileUpload').classList.contains('govuk-!-display-none')).toBe(false);
    expect(document.getElementById('uploadFilesButton').classList.contains('govuk-!-display-none')).toBe(false);
    expect(document.getElementById('selectFileButton').classList.contains('govuk-!-display-none')).toBe(false);
  });
});
