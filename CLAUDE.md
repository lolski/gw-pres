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

- neo4j and property graph: illustrate using diagram depicting the ecommerce domain
- ecommerce example in neo4j (happy path)
  - modeling the schema using graph types
  - inserting new user, transaction
  - inserting good
- ecommerce example in neo4j (unhappy path)
  - inserting two email addresses
  - querying for all goods
  - querying for a user, of which its phone may be 'null'
- ecommerce example in typedb
  - modeling the schema (add cardinality and inheritance)
  - inserting new user, transaction
  - inserting good
- ecommerce example in typedb
  - modeling the schema
  - inserting new user, transaction
  - inserting good
- ecommerce example in typedb (demonstrate type safety)
  - inserting two email addresses - rejected
  - querying for a user, of which its phone may be 'null' using 'try' / optionals
  - querying for just electronic, just book, and all goods

# Examples: Ecommerce
Whenever show off a feature and making a comparison vs neo4j, use these e-commerce examples. Here are the "entities" and how they're related to others:
- user (has email, address, and optionally phone)
- transaction (associated with a user and goods. has amount, date)
- good (has price), which can either be a book (has an isbn) or electronic (has warranty-expired-date)

# Sources
Here are sources you can reference
- two blogs that you should reference
  - https://typedb.com/blog/how-strict-should-your-schema-be
  - https://typedb.com/blog/benchmarking-llm-query-generation-across-sql-cypher-and-typeql

Here are neo4j doc you can reference
  - https://neo4j.com/docs/cypher-manual/current/
  - focus on schema: https://neo4j.com/docs/cypher-manual/current/schema/

  And make sure to validate typeql query syntax with `typeql-check` CLI tool
