# Development Agreed Practices

Our team regularly meets to discuss and agree on development practices and technical approaches.
This document records those decisions so every developer can stay aligned with our shared agreements.

## Pull Requests

### Reviews
- When reviewing a PR, if another developer has key context on it, tag them to request their input.

### Deployment
- Avoid deploying on Fridays when possible. Friday morning releases are acceptable only for minor, easily reversible changes when we have time to monitor throughout the day.

## Data

### Data vs Schema Migrations
- Use migration files exclusively for database schema changes.
- Execute data migrations through tested rake tasks instead.

## Wizards
- Use the "Wicked" gem for all new wizards.

## Testing

### Code Coverage
- All new logic must be test-covered and not trigger coverage alerts.
- When touching a file raises coverage alerts, it's acceptable to add `#nocov` directives to existing uncovered code.
- Set the minimum coverage threshold in `.simplecov` to 0.02 below the reported coverage to account for rounding and minor fluctuations.

**Known coverage fluctuation issues to avoid:**
- Random values in test factories
- Ruby logic in Slim templates

## Rails
- Follow Rails conventions whenever possible.
