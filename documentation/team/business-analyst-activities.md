# Business Analyst Activities

You must have a GitHub account and access to the Teaching Vacancies repository to be able to make any changes to the code base.

The [onboarding](/documentation/team/developer_onboarding.md) document explains the process by which new team members can get the access they require on GitHub.

## Markdown files

We use [Markdown](https://www.markdownguide.org/cheat-sheet) to write this file and the others in the [documentation](./documentation) directory.

Go to [Hedgedoc](https://hedgedoc.teacherservices.cloud/) which is hosted on AKS, and click `New guest note`. You can then learn Markdown while writing a document:
- enter some text, highlight it
- press `B` to make it bold
- press `H` to create headings (press `H` again to change from an H1 to an H2 heading)

You'll see an instant preview of your document in the right-hand pane.

## YAML files

We use [YAML](https://rollout.io/blog/yaml-tutorial-everything-you-need-get-started/) for data files.

Go to [yamlchecker.com](https://yamlchecker.com/), and start typing YAML, e.g. the first two lines of [mapped_locations.yml](../config/data/ons_mappings/mapped_locations.yml):
```
"barking": "barking and dagenham"
```
You'll get instant feedback - either `Valid YAML!` or a useful error

## Git Feature Branch Workflow

Read [this Atlassian tutorial](https://www.atlassian.com/git/tutorials/comparing-workflows/feature-branch-workflow) for details on using feature branches, and working with Pull Requests:

> The core idea behind the Feature Branch Workflow is that all feature development should take place in a dedicated branch instead of the main branch. This encapsulation makes it easy for multiple developers to work on a particular feature without disturbing the main codebase. It also means the main branch will never contain broken code, which is a huge advantage for continuous integration environments.

## Updating Polygon Mappings in the `mapped_locations.yml` file

This section details the process for updating the search mappings to point a user-inputted search term to a defined polygon.

1. Go to the [mapped_locations.yml](../config/data/ons_mappings/mapped_locations.yml) file which contains a list of all of the mappings that have been applied, in alphabetical order.
2. Click the pencil icon which will allow you to [edit the file](https://github.com/DFE-Digital/teaching-vacancies/edit/master/config/data/ons_mappings/mapped_locations.yml). Navigate to the desired row, and input your new mapping in YAML format. The format is
  ```
  "location that is searched by user": "name of polygon we want to return"
  ```
  e.g.
  ```
  "barking": "barking and dagenham"
  ```
  * The polygon names can be found in the directory [config/data/ons_mappings](../config/data/ons_mappings)
3. Once all desired mappings have been added, scroll to the bottom of the page and update the fields in the "Commit changes" box. This should include a concise title for the change, and further details of what you have done in the extended description field.
  * Once you have added this information ensure that the "Create a new branch for this commit and start a pull request." radio button is selected and press "Commit changes".
4. Automated tests will run on your new branch to confirm that all rows have been entered correctly. If one of these tests fails check that all `"` and `:` have been entered correctly. On the PR, in the merging section at the bottom of the page there is a section dedicated to automated checks. This will show any checks that may have failed as part of the changes. ![Automated tests screenshot](https://user-images.githubusercontent.com/72141/103927287-0d570500-5112-11eb-902d-5d36a1c7e10a.png)
5. Before the change can be committed to the `main` branch it must be approved by another member of the team and pass a set of automated tests. Once these steps have been completed press "Merge pull request" and your change will be:
  * merged to the `main` branch
  * deployed to the `staging` environment
  * smoke-tested on the `staging` environment
  * deployed to the `production` environment
