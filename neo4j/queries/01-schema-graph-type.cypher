// Graph Types - available for Enterprise only
ALTER CURRENT GRAPH TYPE SET {
  (:User => {email :: STRING IS KEY,
             address :: STRING NOT NULL,
             phone :: STRING}),
  (:Book => :Good {price :: FLOAT NOT NULL,
                   isbn :: STRING NOT NULL}),
  (:Electronic => :Good {price :: FLOAT NOT NULL,
                         warrantyExpiredDate :: DATE NOT NULL}),
  (:Transaction => {amount :: FLOAT NOT NULL,
                    date :: DATE NOT NULL}),
  (:Transaction)-[:BUYER =>]->(:User),
  (:Transaction)-[:CONTAINS =>]->(:Good)
};
