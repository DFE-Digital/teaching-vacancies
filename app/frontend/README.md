## Front end SCSS/JS
```
/frontend
  /src
    /components
        myComponent.js
        myComponent.test.js
        myComponent.scss
    /application (these can be pages)
      /search
        search.scss
        init.js
      /dashboard
    /lib
      /polyfill
      utils.js
      logging.js
      testSetup.js
    /styles
      /application
      /base
        utilities.scss
        mixins.scss
        frontend.scss
      /global
        ie.scss
        variables.scss
      application.scss
```

## Notes
- application folder contains domain specific code
  - all JS should be self initialising, using namespaced conditions in markup (id, data attributes)
- components folder contains reusable peices of functionality that are instantiated from application code. The JS imports any styles needed so that the component in self contained
