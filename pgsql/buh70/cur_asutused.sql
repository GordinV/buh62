DROP VIEW IF EXISTS cur_asutused;

CREATE OR REPLACE VIEW cur_asutused AS
  SELECT
    id,
    regkood,
    nimetus,
    omvorm,
    aadress,
    tp,
    email,
    mark,
    (properties ->> 'kehtivus') :: DATE AS kehtivus
  FROM libs.asutus a
  WHERE staatus <> 3;

GRANT SELECT ON TABLE cur_asutused TO dbpeakasutaja;
GRANT SELECT ON TABLE cur_asutused TO dbkasutaja;
GRANT SELECT ON TABLE cur_asutused TO dbadmin;
GRANT SELECT ON TABLE cur_asutused TO dbvaatleja;
            