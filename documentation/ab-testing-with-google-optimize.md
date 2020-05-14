# A/B testing with Google Optimize

## Setting up a new redirect experiment

- Open the [Google Optimize console](https://optimize.google.com/optimize/home/?authuser=1#/accounts), make sure you
- have access to the TVS Google Optimize Account as a first step
 
- Select a container for the environment you wish to run an experiment on. You can choose container by clicking on the
- button in the top left-hand corner.

- Click on the `Create Experience` button to create a new `Redirect Test` - Fill in the name of the experience and the
- URL you intended to perform redirect tests on.  Make sure `Redirect Test` is selected before clicking on create

- Click on `Add Variant` and add the URL variants to define redirect destinations e.g `?example=1` and `?example=2`. Use
- these to display different behaviours for your application, such as rendering a different [button
- placement.](https://github.com/DFE-Digital/teacher-vacancy-service/pull/995/files#diff-b81767a3120491f5a50cd03239811480)

- To edit the weights click on the `%WEIGHT` button next to each variant

- To setup a page you want variations for, click on `ADD URL RULE` in the Page targeting section. Any URL that matches
- the targeting rules, will be redirected to one of the variants. More details about targeting rules
- [here](https://support.google.com/optimize/answer/6283424?hl=en]). 

- Link the experiment to Google Analytics

- Add an experiment objective, this could either be a new custom objective or an existing event, 

- If you are using a new custom objective, make sure to add the relevant JS to your codebase e.g.: `vacancy_applied`

```bash $(document).on('click', '.vacancy-apply-link', function() { gtag('event', 'vacancy_applied'); }); ```

- Set the `Activation event` at the bottom of the console the custom `optimize.activate` event. 
