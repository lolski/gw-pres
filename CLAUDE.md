# Description

Below is the description i gave to the organiser. The presentation should expand on these topics.

Title: Bringing Type Systems into the Graph World

Description:
Traditional graph databases excel at representing complex connections, but raw nodes and edges offer virtually no structural enforcement. Even property graphs, despite adding labels and key-value properties, struggle to guarantee data integrity at scale.

TypeDB lets one declare constraints on graphs by borrowing various concepts from type systems as commonly found in programming languages. By bringing concepts such as inheritance and type inference, TypeDB enables you to enforce strong structure whilst maintaining flexibility and expressiveness of graph data structures, thus improving the reliability of services and AI agents that interface with the database.

# Format
- presentation slides containing code snippets
- 35 mins in length
- no slide transition animation
- code blocks:
  - python, typedb, and cypher code blocks must syntax highlighted
- there are multiple arcs in the presentation. the arc should be displayed to provide context to listeners as to where we are

# What i want covered, and in this particular order
- arc 1: programming is moving to type safe languages
  - problem: contract
  - solution: type safety
    - examples:
      - frontend is moving from javascript to typescript.
      - backend is moving from plain python to python with type hints
      - modern languages with modern type systems: scala, haskell, rust
    - cover the benefits briefly. one for developers and next for autonomous ai agents
- arc 2: programming languages have evolved. now it's time for database!
- arc 3: null-safety in graph database with typedb's optionals
- arc 4: cardinality in graph database: show how typedb cardinality makes it more type safe vs cypher
  - show typeql vs cypher queries
  - show what's the benefit that typeql has
  - typeql and cypher has to be shown side by side for clarity
- arc 5: show how typedb inheritance makes it more type safe vs cypher
  - show typeql vs cypher queries
  - show what's the benefit that typeql has
  - - typeql and cypher has to be shown side by side for clarity
- arc 6: show how complicated queries can be extracted into a function
  - extract an entire query into a single function call `transactions_by_user_email(user_email)` (show list of transactions for a given user)
  - make the entire query be a single function call. something like `match transactions_by_user_email(...); fetch ...`
  - show python code serving a backend using it. what we want to demonstrate is the backend code becomes so short since the match query is just a call to a function

# Examples: Ecommerce
Whenever show off a feature and making a comparison vs neo4j, use these e-commerce examples. Here are the "entities" and how they're related to others:
- user (has email, name, address)
- transaction (associated with a user and goods. has amount, payment-method, date)
- good (has price)

# Sources
Here are sources you can reference
- two blogs that you should reference
  - https://typedb.com/blog/how-strict-should-your-schema-be
  - https://typedb.com/blog/benchmarking-llm-query-generation-across-sql-cypher-and-typeql

And make sure to validate typeql query syntax with `typeql-check` CLI tool
