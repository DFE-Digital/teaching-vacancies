import { Application } from "@hotwired/stimulus";
import MarketingTrackingController from "./marketingTracking";

describe("MarketingTrackingController", () => {
  let application, element;

  beforeEach(() => {
    document.body.innerHTML = `
      <button
        data-controller="marketing-tracking"
        data-action="click->marketing-tracking#applyForJob"
        id="apply-btn"
      >Apply for this job</button>
    `;
    application = Application.start();
    application.register("marketing-tracking", MarketingTrackingController);
    element = document.getElementById("apply-btn");
  });

  afterEach(() => {
    application.stop();
    document.body.innerHTML = "";
    jest.restoreAllMocks();
  });

  it("calls fbq, lintrk, and rdt if present", () => {
    window.fbq = jest.fn();
    window.lintrk = jest.fn();
    window.rdt = jest.fn();

    element.click();

    expect(window.fbq).toHaveBeenCalledWith("trackCustom", "Apply for Job");
    expect(window.lintrk).toHaveBeenCalledWith("track", { conversion_id: 23034978 });
    expect(window.rdt).toHaveBeenCalledWith("track", "Lead");
  });

  it("does not throw if fbq, lintrk, or rdt are missing", () => {
    delete window.fbq;
    delete window.lintrk;
    delete window.rdt;
    expect(() => element.click()).not.toThrow();
  });
});
