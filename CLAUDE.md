# Talk

## Description

Below is the description i gave to the organiser. The presentation should expand on these topics.

Title: Bringing Type Systems into the Graph World

Description:
Traditional graph databases excel at representing complex connections, but raw nodes and edges offer virtually no structural enforcement. Even property graphs, despite adding labels and key-value properties, struggle to guarantee data integrity at scale.

TypeDB lets one declare constraints on graphs by borrowing various concepts from type systems as commonly found in programming languages. By bringing concepts such as inheritance and type inference, TypeDB enables you to enforce strong structure whilst maintaining flexibility and expressiveness of graph data structures, thus improving the reliability of services and AI agents that interface with the database.

## Talk Content

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
- transition slide: typedb logo
- ecommerce example in typedb
  - modeling the schema
  - inserting new user, transaction
  - inserting good
- ecommerce example in typedb (demonstrate type safety)
  - inserting two email addresses - insert a new user with an email, followed by match insert on said user. second query should be rejected
  - querying for a user, of which its phone may be 'null' using 'try' / optionals. compare it side by side with neo4j
  - querying for just electronic, just book, and all goods
    - price is a shared field, declared exactly once at 'good'. compare it with neo4j side by side where in neo4j price has to be redeclared for both electronic and book.
    - when querying for goods, can't access isbn and warranty field. when querying specifically for electronic, price and warranty is available
  - type safety without verbosity: type inference. using the ecommerce domain, show one query fully annotated with its type, and side by side the same query where the type can be omitted
- type safety of modern databases: mongodb, postgresql, typedb, amazon neptune, neo4j, tigergraph, janusgraph, stardog
  - axis 1: not typesafe <----> typesafe
  - axis 2: verbose <----> not verbose
- arc 7: benefits
  - for developers
    - easier to review
    - verify correctness simply by looking at types
  - for AI agents, guardrails and the likes
    - LLM generates query, databases validates the query
    - the stricter the type system the more reliable it is

# Examples: Ecommerce
Whenever show off a feature and making a comparison vs neo4j, use these e-commerce examples. Here are the "entities" and how they're related to others:
- user (has email, address, and optionally phone)
- transaction (associated with a user and goods. has amount, date)
- good (has price), which can either be a book (has an isbn) or electronic (has warranty-expired-date)

# Distribution / deliverables
- the talk will be 35 mins in length
- reveal.js slides
  - visual style:
    - adopt style from typedb.com website (logo, colour scheme, font etc)
    - no slide transition animation
  - figures:
    - code snippets with syntax highlighting
    - graph visualised using graph notation (w edge directionality)
    - property graph visualised using property graph notation
  - code blocks:
    - python, typedb, and cypher code blocks must syntax highlighted
- talking points md file (which will guide me giving the talk)
- neo4j and typedb query files which will be embedded into presentation slides. the queries are put into files so they can be tested against against real typedb and neo4j server for correctness. they will be stored into the `neo4j` and `typedb` folder respectively

- presentation slides should be as minimal as possible, and the content be put into "talking points" md file. because not everything i want to say has to be in the slide. the slide can show the figure and code blocks. but the explanation should be in talking points md file.
- there are multiple arcs in the presentation. the arc should be displayed to provide context to listeners as to where we are

# Docs / References
Here are sources you can reference
- two blogs that you should reference
  - https://typedb.com/blog/how-strict-should-your-schema-be
  - https://typedb.com/blog/benchmarking-llm-query-generation-across-sql-cypher-and-typeql

Here are neo4j doc you can reference
  - https://neo4j.com/docs/cypher-manual/current/
  - focus on schema: https://neo4j.com/docs/cypher-manual/current/schema/

  And make sure to validate typeql query syntax with `typeql-check` CLI tool
