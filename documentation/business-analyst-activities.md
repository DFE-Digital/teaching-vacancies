# Business Analyst Activities

You must have a GitHub account and access to the Teaching Vacancies repository to be able to make any changes to the code base, or to edit/create files (e.g, .yml or .md text files)
<Insert link here to new page> This file explains the process by which new team members can get the access they require on GitHub.

## Updating Polygon Mappings in the mapped_locations.yml file
This section details the process for updating the search mappings so that a polygon search is used in place of a point search.

1. Navigate to the "Code" tab within github and press "go to file"
2. Search for [mapped_locations.yml](https://github.com/DFE-Digital/teaching-vacancies/blob/master/lib/tasks/data/mapped_locations.yml) and click on the file.
  * This file contains a list of all of the mappings that have been applied, in alphabetical order.
3. Navigate to the desired row, and input your new mapping in the following format:
  * -['location that is searched by user', 'name of polygon we want to return']
  * The automated tests are useful for confirming that all rows have been entered correctly. If one of these tests fails check that all "'" and "," have been entered correctly.
  * The polygon names can be found (here)[https://github.com/DFE-Digital/teaching-vacancies/tree/master/lib/tasks/data]
4. Once all desired mappings have been added, scroll to the bottom of the page and update the fields in the "Commit changes" box. This should include a concise title for the change, and further details of what you have done in the extended desription field.
  * Once you have added this information ensure that the "Create a new branch for this commit and start a pull request." radio button is selected and press "Commit changes".
5. Before the change can commited to >master. it must be approved by another member of the team and pass a set of automated tests. Once these steps have been completed press "Merge pull request" and your change will be committed to the production environment.
6. You can verify that your change is working as expected by searching for the new mapping(s) on production. If the location has been successfully mapped to the polygon, then the search results title will be: "[number of] jobs in 'location' " and the search radius option will not be displayed. If the mapping has been unsuccessful, then the search results title will be: "[number of] jobs near 'location' " and the search radius option will be displayed.
