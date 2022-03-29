# SCSS example folder stucture

```
/styles
  /base
    _typography.scss
    _mixins.scss
    _utilities.scss
    _icons.scss
    _global.scss
  /layouts
    _header.scss
    _footer.scss
    /home
      index.scss
    /vacancies
      index.scss
      show.scss
      _similar_jobs.scss
    /jobseekers
      /job_applications
        index.scss
        _banner.scss
```

## base folder

Contains global styles and reusable utility class definitions and mixins.

## layouts folder

Contains styles for partials (denoted by preceeding _) and pages (without preceeding underscore). This means styles should be able to be found easily by mirroring the structure of the views folders.
