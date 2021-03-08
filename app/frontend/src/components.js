function importAll(r) {
  r.keys().forEach(r);
}

importAll(require.context('../../components/shared', true, /[_/]component\.(js|scss)$/));
