## Rails view components
JS and SCSS files are optional
```
/app
  /components
    /my_widget_component
      my_widget_component.js
      my_widget_component.test.js
      my_widget_component.scss
      my_widget_component.html.slim
    my_widget_component.rb
```

The `_component` postfix is integral to how view components work and is essential.

### Slim usage
`= render(MyWidgetComponent.new()`

### SCSS usage
import in styles/application.scss

`@import 'my_widget_component/my_widget_component';`

Components should have outermost CSS class namespaced to `my-widget-component` and then all internal styles for the component contained within the SCSS block for the namespace, i.e

```scss
.my-widget-component {
  .my-widget-component__header {
    // header styles
  }
}
```
