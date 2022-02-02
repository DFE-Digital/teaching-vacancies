import { Controller } from 'stimulus';

export default class extends Controller {
  /* eslint-disable class-methods-use-this */
  print() {
    window.print();
  }
  /* eslint-enable */
}
