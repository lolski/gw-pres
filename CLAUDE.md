# Description

Below is the description i gave to the organiser. The presentation should expand on these topics.

Title: Bringing Type Systems into the Graph World

Description:
Traditional graph databases excel at representing complex connections, but raw nodes and edges offer virtually no structural enforcement. Even property graphs, despite adding labels and key-value properties, struggle to guarantee data integrity at scale.

TypeDB lets one declare constraints on graphs by borrowing various concepts from type systems as commonly found in programming languages. By bringing concepts such as inheritance and type inference, TypeDB enables you to enforce strong structure whilst maintaining flexibility and expressiveness of graph data structures, thus improving the reliability of services and AI agents that interface with the database.

# Presentation Format
- presentation slides
- figures:
  - code snippets with syntax highlighting
  - graph visualised using graph notation (w edge directionality)
  - property graph visualised using property graph notation
- 35 mins in length
- code blocks:
  - python, typedb, and cypher code blocks must syntax highlighted
- there are multiple arcs in the presentation. the arc should be displayed to provide context to listeners as to where we are

# Style guide
- adopt style from typedb.com website (logo, colour scheme, font etc)
- no slide transition animation

# Presentation

- graph: a node and edges
- neo4j's graph: what does it add on top of plain graph. show using the ecommerce domain
- ecommerce example in neo4j
  - modeling the schema (if such a thing exist in neo4j)
  - inserting new user, transaction
  - inserting good
- can we model the following in neo4j? if we can't show a slide doing so:
  - NULL-safe query to retrieve user's phone
  - cardinality
  - the fact that good can either be book or electronic, each of which has different

# Examples: Ecommerce
Whenever show off a feature and making a comparison vs neo4j, use these e-commerce examples. Here are the "entities" and how they're related to others:
- user (has email, address, and optionally phone)
- transaction (associated with a user and goods. has amount, payment-method, date)
- good (has price), which can either be a book (has an isbn) or electronic (has warranty-expired-date)

# Sources
Here are sources you can reference
- two blogs that you should reference
  - https://typedb.com/blog/how-strict-should-your-schema-be
  - https://typedb.com/blog/benchmarking-llm-query-generation-across-sql-cypher-and-typeql

And make sure to validate typeql query syntax with `typeql-check` CLI tool
