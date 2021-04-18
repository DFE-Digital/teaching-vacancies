import './uploadDocuments/uploadDocuments';
import './deleteDocument';
import '../../components/form/form';
import { initTriggerElements } from '../../components/printPage/printPage';

document.addEventListener('DOMContentLoaded', () => {
  initTriggerElements('.print-application');
});
