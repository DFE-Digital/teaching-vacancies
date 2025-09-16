# Maintenance mode

The application has a github action to enable maintenance mode in 'actions/workflows/maintenance.yml'

### Enable Maintenance mode

- Run the 'Set maintenance mode' workflow from https://github.com/DFE-Digital/teaching-vacancies/actions/workflows/maintenance.yml
    choosing the environment (production, qa or staging) and enable

- The pods will get automatically restarted with the new value. 

- Check that the page is in maintenance mode.

### Disable Maintenance mode

- Run the worflow, choosing the environment (production, qa or staging) and disable

- Check that the page is no longer in maintenance mode.

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
