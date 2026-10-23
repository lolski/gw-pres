(:Book => :Good {price :: FLOAT NOT NULL,     // price: declared here…
                 isbn :: STRING NOT NULL}),
(:Electronic => :Good {price :: FLOAT NOT NULL,   // …and again here
                       warrantyExpiredDate :: DATE NOT NULL})
// no abstract supertype, no shared attribute
