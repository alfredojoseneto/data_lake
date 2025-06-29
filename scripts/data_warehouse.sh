#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER}" --password "${POSTGRES_PASSWORD}" << EOSQL

CREATE DATABASE data_warehouse OWNER postgres;

\c data_warehouse;

-- DROP TABLE IF EXISTS public.dim_municipios;

CREATE TABLE IF NOT EXISTS public.dim_municipios(
     cod_ibge bigserial NOT NULL
    ,nom_municipio_ibge character varying(100)
    ,cod_uf integer NOT NULL
    ,dsc_uf character varying(80) NOT NULL
    ,sgl_uf character(2) NOT NULL
    ,sgl_regiao_br character(2) NOT NULL
    ,dsc_regiao_bg character varying(40) NOT NULL
    ,dsc_micro_regiao character varying(100) NOT NULL
    ,dsc_meso_regiao character varying(40) NOT NULL
    ,cod_latitute bigint NOT NULL
    ,cod_longitude bigint NOT NULL
    ,CONSTRAINT dim_municipios_pkey PRIMARY KEY (cod_ibge)
);

ALTER TABLE IF EXISTS public.dim_municipios
    OWNER to postgres;

---------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.operadoras;

CREATE TABLE IF NOT EXISTS public.dim_operadoras(
     operadora character varying(7) NOT NULL
    ,CONSTRAINT pk_operadora PRIMARY KEY(operadora)
);


ALTER TABLE IF EXISTS public.dim_operadoras
    OWNER TO postgres;

---------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.fato_telefonia_movel;

CREATE TABLE IF NOT EXISTS public.fato_telefonia_movel(
     cod_ibge bigserial NOT NULL
    ,operadora character varying(7) NOT NULL
    ,tecnologia character(2) NOT NULL
    ,"data" date NOT NULL
    ,CONSTRAINT pk_cod_ibge PRIMARY KEY(cod_ibge)
    ,CONSTRAINT fk_tel_movel_operadora FOREIGN KEY (operadora)
        REFERENCES public.dim_operadoras(operadora)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
    ,CONSTRAINT fk_tel_movel_municipio FOREIGN KEY (cod_ibge)
        REFERENCES public.dim_municipios(cod_ibge)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
);

ALTER TABLE public.fato_telefonia_movel
    OWNER TO postgres;

---------------------------------------------------------------------------------------------------

-- DROP TABLE IF EXISTS public.fato_acessos_banda_larga;

CREATE TABLE IF NOT EXISTS public.fato_acessos_banda_larga(
     "data" date NOT NULL
    ,cod_ibge bigint NOT NULL
    ,operadora CHARACTER VARYING(7) NOT NULL
    ,tipo_uso CHARACTER varying(15) NOT NULL
    ,meio_acesso CHARACTER varying(15) NOT NULL
    ,total_acessos integer NOT NULL
    ,CONSTRAINT fk_cod_ibge_fato_acessos_banda_larga_municipios FOREIGN KEY(cod_ibge)
        REFERENCES public.dim_municipios(cod_ibge)
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
    ,CONSTRAINT fk_operadora_fato_acessos_banda_larga_municipios_operatora FOREIGN KEY(operadora)
        REFERENCES public.dim_operadoras(operadora)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION
) PARTITION BY RANGE ("data");

ALTER TABLE public.fato_acessos_banda_larga
    OWNER TO postgres;

CREATE INDEX idx_fato_banda_larga_cod_ibge
    ON public.fato_acessos_banda_larga(cod_ibge);

CREATE INDEX idx_fato_banda_larga_data
    ON public.fato_acessos_banda_larga("data");

CREATE TABLE public.fato_acessos_banda_larga_y2021 PARTITION OF public.fato_acessos_banda_larga
    FOR VALUES FROM ('2021-01-01') TO ('2021-12-31');

CREATE TABLE public.fato_acessos_banda_larga_y2022 PARTITION OF public.fato_acessos_banda_larga
    FOR VALUES FROM ('2022-01-01') TO ('2022-12-31');

CREATE TABLE public.fato_acessos_banda_larga_y2023 PARTITION OF public.fato_acessos_banda_larga
    FOR VALUES FROM ('2023-01-01') TO ('2023-12-31');

CREATE TABLE public.fato_acessos_banda_larga_y2024 PARTITION OF public.fato_acessos_banda_larga
    FOR VALUES FROM ('2024-01-01') TO ('2024-12-31');

CREATE TABLE public.fato_acessos_banda_larga_y2025 PARTITION OF public.fato_acessos_banda_larga
    FOR VALUES FROM ('2025-01-01') TO ('2025-12-31');

EOSQL
