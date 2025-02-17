# Front-end

Our service runs with the following setup:
- Rails 7.
- `jsbundling-rails` gem for building and transpiling JavaScript.
- `cssbundling-rails` gem for building and transpiling CSS.
    - They both depend on:
      - `node`
      - `yarn`
    - And use:
      - `esbuild` as a bundler.
      - `babel` with `corejs` as transpiler.
- `sass` for CSS.
- `propshaft` gem for asset pipeline.
- `stimulus` as JavaScript framework.
- `govuk-components` gem for providing Gov.UK Design System components.
- `govuk-frontend` node package.

## How to make HTML elements only visible for JS-enabled browsers.

If you want to display a HTML element only for JavaScript-enabled browsers, you only need to tag the element
(Eg: a link or a button) with the `.js-action` css class.

This way, it will be hidden by default unless loaded by a browser that supports Javascript.

### Long explanation
Our system adds `.js-enabled` css class to the html body [when the page loads on a JS-enabled browser](../app/views/layouts/_add_js_enabled_class_to_body.html.slim).

If the HTML element is tagged with the `.js-action` css class, it will be hidden by default using a `display: none` property.
- If the browser has JS enabled:
  - when loading the page it will add the `.js-enabled` class to the page body.
  - the `.js-enabled` css overrides the `.js-action` `display: none` property, that will cause the element to display.
- If the browser does not have JS enabled:
  - Not having `.js-enabled` added, the element will keep the `display: none` property. So it will stay hidden.

[This is where the magic happens](../app/assets/stylesheets/base/_utilities.scss).
