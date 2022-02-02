const importAll = (r) => r.keys().forEach(r);

try {
importAll(require.context('../../components', true, /[_/]component\.(js|scss)$/));

} catch (e) {
  console.log('components', e);
}
