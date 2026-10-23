MATCH (u:User) RETURN u.email, u.phone;
// user without phone  → null
// (and a typo'd  u.phoen  → ALSO null, no error)

MATCH (u:User) WHERE u.phone = "+44 20 7946 0000" RETURN u;
// null: row silently dropped

MATCH (u:User) WHERE NOT u.phone = "+44 20 7946 0000" RETURN u;
// null: ALSO silently dropped — the no-phone user appears in
// neither query, violating excluded middle
