module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  console.log('SCENARIO ON READY > ', scenario.label, viewport.label);
  await require('./clickAndHoverHelper')(page, scenario);

  // add more ready handlers here...
};
