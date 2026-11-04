import * as esbuild from 'esbuild';
import fs from 'fs';
import { transformAsync } from '@babel/core';

const watch = process.argv[process.argv.length - 1] == '--watch';

// Custom `esbuild` configuration to enable Babel plugin for IE11-compatible transpilation
// TODO: When we decide we are happy to target ES6 and don't need Babel anymore, this file can be
//       removed and the `build` task in `package.json` can be replaced with a simple command
//       line invocation of `esbuild`, e.g.:
//
//          esbuild app/assets/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds \
//          --public-path=assets --target=es6

// Inline esbuild plugin that runs each JS file through Babel. Replaces `esbuild-plugin-babel`,
// which is unmaintained and incompatible with the ESM-only Babel 8.
const babel = ({ filter = /\.m?js$/, ...options } = {}) => ({
  name: 'babel',
  setup(build) {
    build.onLoad({ filter }, async (args) => {
      const source = await fs.promises.readFile(args.path, 'utf8');
      const result = await transformAsync(source, {
        ...options,
        filename: args.path,
        caller: { name: 'esbuild-babel', supportsStaticESM: true }
      });
      return { contents: result.code, loader: 'js' };
    });
  }
});

const config = {
  bundle: true,
  entryPoints: ['app/assets/javascript/application.js'],
  minify: true,
  outdir: 'app/assets/builds',
  plugins: [
    babel({
      presets: ['@babel/preset-env'],
      targets: '> 0.25%, not dead, IE 11'
    })
  ],
  publicPath: 'assets',
  target: ['ie11']
};

if (watch) {
  let ctx = await esbuild.context(config);
  await ctx.watch();
} else {
  await esbuild.build(config);
}
