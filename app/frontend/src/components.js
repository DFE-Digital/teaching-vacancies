const importAll = (r) => r.keys().forEach(r);

importAll(require.context('../../components', true, /[_/]component\.(js|scss)$/));

importAll(require.context('./components', true, /\.scss$/));
