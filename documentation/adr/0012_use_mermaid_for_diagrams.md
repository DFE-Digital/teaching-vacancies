# Use Mermaid for diagrams

**Date: 2025-11-17**

## Status

**Discussing**

## Parties Involved

 * Marc Sardón

## Context and Problem Statement

Creating and maintaining diagrams is a recurrent painpoint.
Diagrams tend to quickly become outdated, the access to update are lost, others than their original author cannot update them, their location is distributed across a collection of services, exported images cannot be updated...

While visual tools like LucidChart allow us to individually quickly create a diagram for personal use. Team sharing our diagrams, keeping them updated and keeping them close/within the service documentation has proved to be a challenge.

We have successfully integrated some Mermaid diagrams as part of our technical documentation.

Should we stablish it as "the way to go" forward?

## Decision Drivers

- Difficulty keeping the diagrams close to /combined with the rest of our service documenation.

- Recurrent user access isues when trying to access/update diagrams created in cloud based solutions like Lucidchart.

- Diagrams become quickly outdated. Allowing to introduce and update them as part of the code encourages better documentation/diagram maintenance.

## Considered Options

- LucidChart
- Mermaid

## Decision Outcome

-

### Positive Consequences

- Diagrams as a code. Our diagrams are contained and mantained within our codebase.
- Github turns the code into a diagram. No need for us to export the resulting image.
- Easier collaboration. Anyone can edit the diagram as can edit any code.
- Diagram change history kept in Git/Github.

### Negative Consequences

- Drawing diagrams is slower/less intuitive than with visual tools.
- Output not as polished as with visual tools (EG: relation lines crossing over entities).
- Mermaid has some learning curve. Is not as easy as drag and drop.

