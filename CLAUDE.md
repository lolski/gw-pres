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

# What i want covered
- type safety benefits
  - we're not the only one. python started adding type hints. people adopt typescript over javascript. why do we move to more strictly-typed languages?
  - what are type safety benefit for developers?
  - what are type safety benefit for ai agents?
- programming languages have evolved. now it's time for database!
- show how typedb do null-safety with optionals
- show how typedb cardinality makes it more type safe vs cypher
  - show typeql vs cypher queries
  - show what's the benefit that typeql has
- show how typedb inheritance makes it more type safe vs cypher
  - show typeql vs cypher queries
  - show what's the benefit that typeql has
- show how complicated queries can be extracted into a function

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
