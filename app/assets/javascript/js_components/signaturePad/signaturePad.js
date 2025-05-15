import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['canvas', 'signatureField'];

  initialize() {
    this.ctx = this.canvasTarget.getContext('2d');
    this.drawing = false;

    this.canvasTarget.addEventListener('mousedown', (e) => { this.startDrawing(e); });
    this.canvasTarget.addEventListener('mousemove', (e) => { this.draw(e); });
    this.canvasTarget.addEventListener('mouseup', () => { this.stopDrawing(); });
    this.canvasTarget.addEventListener('mouseout', () => { this.stopDrawing(); });
    this.canvasTarget.addEventListener('touchstart', (e) => { this.startDrawing(e); });
    this.canvasTarget.addEventListener('touchmove', (e) => { this.draw(e); });
    this.canvasTarget.addEventListener('touchend', () => { this.stopDrawing(); });

    // const event = new Event('click');
    // this.clear(event);
    if (this.hasSignature()) {
      const signature = new Image();
      signature.src = this.signatureFieldTarget.value;
      this.ctx.drawImage(signature, 0, 0);
    }
  }

  hasSignature() {
    const input = this.signatureFieldTarget.value;
    const token = 'data';
    return typeof input === 'string' && input.startsWith(token);
  }

  // Canvas actions
  getPosition(event) {
    const rect = this.canvasTarget.getBoundingClientRect();
    return {
      x: (event.clientX || event.touches[0].clientX) - rect.left,
      y: (event.clientY || event.touches[0].clientY) - rect.top,
    };
  }

  startDrawing(event) {
    event.preventDefault();
    this.drawing = true;
    const { x, y } = this.getPosition(event);
    this.ctx.beginPath();
    this.ctx.moveTo(x, y);
  }

  draw(event) {
    event.preventDefault();
    if (!this.drawing) return;
    const { x, y } = this.getPosition(event);
    this.ctx.lineTo(x, y);
    this.ctx.strokeStyle = 'black';
    this.ctx.lineWidth = 2;
    this.ctx.lineCap = 'round';
    this.ctx.stroke();
  }

  stopDrawing() {
    this.drawing = false;
    this.ctx.closePath();
  }

  // Buttons actions
  clear(event) {
    event.preventDefault();
    this.ctx.clearRect(0, 0, this.canvasTarget.width, this.canvasTarget.height);
    this.ctx.fillStyle = 'white';
    this.ctx.fillRect(0, 0, this.canvasTarget.width, this.canvasTarget.height);
    this.signatureFieldTarget.setAttribute('value', '');
  }

  save(event) {
    event.preventDefault();
    const sigUrl = this.canvasTarget.toDataURL('image/png', 0.5);
    this.signatureFieldTarget.setAttribute('value', sigUrl);
  }
}
