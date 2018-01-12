drop view if exists cur_tunnus;

CREATE OR REPLACE VIEW cur_tunnus AS 
select id, kood, nimetus, rekvid
            from libs.library l
            where l.library = 'TUNNUS'
            and status <> 3;

GRANT SELECT ON TABLE cur_tunnus TO dbpeakasutaja;
GRANT SELECT ON TABLE cur_tunnus TO dbkasutaja;
GRANT SELECT ON TABLE cur_tunnus TO dbadmin;
GRANT SELECT ON TABLE cur_tunnus TO dbvaatleja;
            


