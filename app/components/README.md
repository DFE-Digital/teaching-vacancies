## Rails view components
JS and SCSS files are optional
```
/app
  /components
    /my_component
      my_component.js
      my_component.test.js
      my_component.scss
      my_component.html.haml
    my_component.rb
```
### HAML usage
`= render(MyComponent.new()`

### SCSS usage
import in styles/application.scss

`@import 'my_component/my_component';`
