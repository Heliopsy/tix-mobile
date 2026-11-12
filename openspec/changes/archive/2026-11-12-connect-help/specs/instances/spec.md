# instances

## ADDED Requirements

### Requirement: Saved addresses are tidied on start

On start the app SHALL rewrite each saved remote instance's address the way a typed one is normalised. Instances
that then share an address SHALL become the first of them, with every connection of the others moved to it and no
secret touched. Finding a saved instance by address SHALL compare normalised addresses.

#### Scenario: A trailing slash no longer makes a second instance

- **WHEN** an instance was saved at `https://tix.example.com/` and another at `https://tix.example.com`, and the app starts
- **THEN** one instance remains at `https://tix.example.com`, holding the connections of both
