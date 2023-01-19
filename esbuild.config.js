import * as esbuild from 'esbuild';
import babel from 'esbuild-plugin-babel';

const watch = process.argv[process.argv.length - 1] == '--watch';

// Custom `esbuild` configuration to enable Babel plugin for IE11-compatible transpilation
// TODO: When we decide we are happy to target ES6 and don't need Babel anymore, this file can be
//       removed and the `build` task in `package.json` can be replaced with a simple command
//       line invocation of `esbuild`, e.g.:
//
//          esbuild app/assets/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds \
//          --public-path=assets --target=es6

const config = {
  bundle: true,
  entryPoints: ['app/assets/javascript/application.js'],
  minify: true,
  outdir: 'app/assets/builds',
  plugins: [
    babel({
      config: {
        presets: ['@babel/preset-env'],
        targets: '> 0.25%, not dead, IE 11'
      }
    })
  ],
  publicPath: 'assets',
  target: ['ie11']
};

if (watch) {
  await esbuild.context(config);
  await ctx.watch();
} else {
  await esbuild.build(config);
}
