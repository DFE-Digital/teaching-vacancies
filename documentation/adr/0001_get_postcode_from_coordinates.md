# Use postcodes.io to get postcode from coordinates
Date: 10/10/2019

## Status
approved

## Context
We need to get a postcode from the coordinates we get from the browser.

## Decision
To use postcodes.io instead of geocoder gem and just make a simple AJAX call from the browser.

# Consequences
We avoid creating an endpoint on the server, therefore reducing the load we have to manage. On the other side we rely on a service that is less trusted than Google Maps, but open source and based on Open Data.
