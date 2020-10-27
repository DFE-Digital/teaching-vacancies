## Front end SCSS/JS
```
/frontend
  /src
    /patterns
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
    /base
      utilities.scss
    /global
      variables.scss
      mixins.scss
      frontend.scss
    application.scss
    ie.scss
```

## Notes
- all JS should be self initialising using namespaced conditions in markup (id, data attributes) https://dfedigital.atlassian.net/browse/TEVA-1403
- *all* application styles imported (not defined unless they are truly application wide) in `styles/application.scss` https://dfedigital.atlassian.net/browse/TEVA-1404
- remove old `styles/base/controllers.scss` (relocate whats in current file) https://dfedigital.atlassian.net/browse/TEVA-1404