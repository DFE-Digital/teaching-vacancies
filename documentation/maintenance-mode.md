# Maintenance mode

The application has a simple routing-level maintenance mode triggered by the `MAINTENANCE_MODE`
environment variable. This needs the app to be restarted to enable maintenance mode, e.g. via
a deploy or a `cf restage`. This is handy in case of a critical bug being discovered where we need
to take the service offline, or in case of maintenance where we want to avoid users interacting
with the service.

When enabled, all requests of all types will be routed to the maintenance page (found under
`app/views/errors/maintenance.html.erb`).

### Enable Maintenance mode

Login to PaaS: `cf login --sso`

set maintenance mode environment variable: `cf set-env teaching-vacancies-dev MAINTENANCE_MODE 1`

restage app: cf restage: `cf restage teaching-vacancies-dev`


### Let users know a for future maintenance

We can let users know in advance about a future maintenance period for the service through the 
[Scheduled Maintenance Banner Component](/app/components/scheduled_maintenance_banner_component.rb).

Rendering this component above the header layout in the [application layout](/app/views/layouts/application.html.slim) will
display the banner on top of the website on production environment.

Remember to remove this component from the layout once the maintenance has been finished.

EG:
```
= render ScheduledMaintenanceBannerComponent.new(date: "5th October 2023", start_time: "8:00", end_time: "9:30")
= render "layouts/header"
```
