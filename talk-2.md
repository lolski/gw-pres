# 1
- good afternoon everyone
- so excited to be here, special thanks to Stenli and the Graph Week team
- we were in contact a few months ago unfortunately due to location remote presentation is the only. typedb and i are based in london.
- otherwise I would love to do it in person together with you guys
- shout out to the graph crowd in south east asia

- my name is ganesh, the head of architecture @ typedb, meaning i am in charge of leading product. the last one of which being adding vector search capabilities to typedb.

- moving on to the main topic, today's talk is about graph database and type theory. and why they complement one another

# 2
- graph: we like it because it's intuitive. in a way that's how we think

#3
- neo4j one of the biggest graph database. based on property graph which is where you can add add properties to the nodes and edges
- here's a simplified ecommerce example modeled in cypher

#4
- now we want to add safety constraints so that the developers won't shoot themself in the foot.
- there's no way to do this unfortunately unless you upgrade to the most recent version of enterprise
- if you have enough money to do so then here's how it's gonna look like

#5
- explain inserting user and transaction

#6
- explain inserting goods

#7
- email address is for login and it doesn't make much sense to have two login ids
- creating a list
- not good. not strict. error prone

#8
- goods - TODO: show schema. have to redeclare price
- when querying, has to query both (book, electronic)

#9
- null safety: TODO: check

#10
- enter typedb

#11
- schema: baseline quite like neo4j. declare attributes and entities
- declare cardinalities for all attributes and relations
  - a user to transaction is a zero to many
  - a transaction to good is one to many
  - and so on

- declare subtype

#12
- inserting goods

#13
- inserting a user and transaction

# 14

# 15
- inserting two email address failed. TODO: show the schema constraint

# 16
- optionals

# 17

# 18
- declare price once. imagine if you have to copy lots of variables

# 19
- if you declare type = good, only price attr is available. otherwise 
- use: operate on 'good', only price can be manipulated. operate on a specific type, then you have access to the specific variables
