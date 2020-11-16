# Task Documentation

## update_subscriptions.rake

This task was created to convert any subscriptions in the database with the old working pattern format to the new working pattern format as the format in which the subscriptions were stored were changed by this [Pull Request](https://github.com/DFE-Digital/teaching-vacancies/pull/1268). This was necessary as users would fail to recieve daily alert emails if their subscription included a working pattern.

The old format for subscriptions meant the the working pattern in the search criteria was stored in a string format:
`{"subject"=>"english", "working_pattern"=>"full_time"}`

But the pull request referenced above changed the search criteria to be stored in an array format like the below:
`{"subject"=>"english", "working_patterns"=>["full_time"]}`

Notice that the key also changed from `working_pattern` to `working_patterns` to reflect the fact that users would be able to select multiple working patterns.

The task is intended to only be run once when the pull request referenced above is merged in to Production.
