# Rails view components
JS and SCSS files are optional
```
/app
  /assets
    /stylesheets
      /components
        my_widget_component.scss
  /components
    /my_widget_component
      my_widget_component.html.slim
    my_widget_component.rb
  /frontend
    /src
      /components
        /my_widget_component
          my_widget_component.js
          my_widget_component.test.js
```

The `_component` postfix is integral to how view components work and is essential to include this.

### Slim usage
`= render(MyWidgetComponent.new()`

### SCSS usage
Component SASS files should import `base_component.scss`. This currently makes the settings, tools and helpers of GovUK-frontend available so the familiar mixins and variables can be used e.g `$govuk-border-colour` or `$govuk-border-colour`. It also makes it bit more flexible and easy if other dependencies are needed in future.

It should be pointed out also that Settings/Tools/Helpers/Base all output no CSS and so this can be eplicitly imported anywhere without bloating the CSS bundle size.

Components should have outermost CSS class namespaced to `my-widget-component` and then all internal styles for the component contained within the SASS block for the namespace, e.g

```scss
.my-widget-component {
  .my-widget-component__header {
    // header styles
  }
}
```

or better still

```scss
.my-widget-component {
  &__header {
    // header styles
  }
}
```
