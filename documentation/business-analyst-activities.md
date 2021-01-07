# Business Analyst Activities

**How much detail should we go into with regards to setting up GITHUB account?


## Updating Polygon Mappings in the mapped_locations.yml file
This section details the process for updating the search mappings so that a polygon search is used in place of a point search.

1. Navigate to the "Code" tab within github and press "go to file"
2. Search for "mapped_locations.yml" and click on the file.
  * This file contains a list of all of the mappings that have been applied, in alphabetical order.
3. Navigate to the desired row, and input your new mapping in the following format:
  * -['location that is searched by user', 'name of polygon we want to return']
  * The automated tests are useful for confirming that all rows have been entered correctly. If one of these tests fails check that all "'" and "," have been entered correctly.
4. Once all desired mappings have been added, scroll to the bottom of the page and update the fields in the "Commit changes" box. This should include a concise title for the change, and further details of what you have done in the extended desription field.
  * Once you have added this information ensure that the "Create a new branch for this commit and start a pull request." radio button is selected and press "Commit changes".
5. Before the change can commited to >master. it must be approved by another memeber of the team and pass a set of automated tests. Once these steps have been completed press "Merge pull request" and your change will be commited to the production environment.
