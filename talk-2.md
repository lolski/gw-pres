# 1
- thank you to stenli and graph week organiser for inviting us
- apa gw presentasi bahasa indonesia aja ya. my name's ganesh, i am the head of architecture, so responsible for techincal stuff
- shout out to the graph crowd

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
