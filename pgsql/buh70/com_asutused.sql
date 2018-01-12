DROP VIEW IF EXISTS public.com_asutused;
CREATE OR REPLACE VIEW public.com_asutused AS
  SELECT *
  FROM (
         SELECT
           0                  AS id,
           '' :: VARCHAR(20)  AS regkood,
           '' :: VARCHAR(254) AS nimetus,
           NULL :: DATE       AS kehtivus
         UNION
         SELECT
           id,
           trim(regkood)                       AS regkood,
           trim(nimetus) :: VARCHAR(254)       AS nimetus,
           (properties ->> 'kehtivus') :: DATE AS kehtivus
         FROM libs.asutus
         WHERE staatus <> 3 -- deleted
       ) qry
  ORDER BY nimetus;

GRANT SELECT ON TABLE public.com_asutused TO dbpeakasutaja;
GRANT SELECT ON TABLE public.com_asutused TO dbkasutaja;
GRANT SELECT ON TABLE public.com_asutused TO dbadmin;
GRANT SELECT ON TABLE public.com_asutused TO dbvaatleja;
