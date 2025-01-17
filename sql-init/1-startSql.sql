DROP TABLE IF EXISTS public.pfm_transaction_data;
DROP TABLE IF EXISTS public.pfm_refresh_token;
DROP TABLE IF EXISTS public.pfm_roles_user_entities;
DROP TABLE IF EXISTS public.pfm_user_entity;
DROP TABLE IF EXISTS public.pfm_role;
DROP TABLE IF EXISTS public.pfm_products_of_bank;
DROP TABLE IF EXISTS public.pfm_our_mcc;
DROP TABLE IF EXISTS public.pfm_mcc;


-- Table: public.pfm_mcc ------------------------------------------------------



CREATE TABLE IF NOT EXISTS public.pfm_mcc
(
    code SERIAL PRIMARY KEY,
    group_code character varying(255) COLLATE pg_catalog."default",
    info character varying(255) COLLATE pg_catalog."default"
    )
    TABLESPACE pg_default;
ALTER TABLE public.pfm_mcc
    OWNER to postgres;


-- Table: public.pfm_our_mcc ---------------------------------------------------



CREATE TABLE IF NOT EXISTS public.pfm_our_mcc
(
    code SERIAL PRIMARY KEY,
    group_code character varying(255) COLLATE pg_catalog."default",
    group_code_rus character varying(255) COLLATE pg_catalog."default",
    info character varying(255) COLLATE pg_catalog."default"
    )
    TABLESPACE pg_default;
ALTER TABLE public.pfm_our_mcc
    OWNER to postgres;



-- Table: public.pfm_products_of_bank -----------------------------------------------!!!!!!!!!!!!!!!


CREATE TABLE IF NOT EXISTS public.pfm_products_of_bank
(
    id SERIAL PRIMARY KEY,
    description character varying(255) COLLATE pg_catalog."default",
    link character varying(255) COLLATE pg_catalog."default",
    title character varying(255) COLLATE pg_catalog."default"
    )
    TABLESPACE pg_default;
ALTER TABLE public.pfm_products_of_bank
    OWNER to postgres;


-- Table: public.pfm_user_entity --------------------------------------------------!!!!!!!!!!!!!!!!!



CREATE TABLE IF NOT EXISTS public.pfm_user_entity
(
    id serial primary key,
    login character varying(255) COLLATE pg_catalog."default",
    password character varying(255) COLLATE pg_catalog."default"
    )
    TABLESPACE pg_default;
ALTER TABLE public.pfm_user_entity
    OWNER to postgres;



-- Table: public.pfm_refresh_token ----------------------------------------------------- !!!!!!!!!!

CREATE TABLE IF NOT EXISTS public.pfm_refresh_token
(
    id SERIAL PRIMARY KEY,
    expiry_date bigint NOT NULL,
    token character varying(255) COLLATE pg_catalog."default" NOT NULL,
    user_id bigint,
    CONSTRAINT fk517dw32dbov8pi4k83x5djxlx FOREIGN KEY (user_id)
    REFERENCES public.pfm_user_entity (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    )
    TABLESPACE pg_default;
ALTER TABLE public.pfm_refresh_token
    OWNER to postgres;



-- Table: public.pfm_role --------------------------------------------------------------!!!!!!!!!!

CREATE TABLE IF NOT EXISTS public.pfm_role
(
    id SERIAL PRIMARY KEY,
    role character varying(255) COLLATE pg_catalog."default"
    )
    TABLESPACE pg_default;
ALTER TABLE public.pfm_role
    OWNER to postgres;



-- Table: public.pfm_roles_user_entities -------------------------------------------!!!!!!!!!!!!!!!!



CREATE TABLE IF NOT EXISTS public.pfm_roles_user_entities
(
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    CONSTRAINT fk4cauqh5tivnxrhnb9sof0ywh6 FOREIGN KEY (role_id)
    REFERENCES public.pfm_role (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION,
    CONSTRAINT fkgr3kolg78my1p9p3a6tk9hdfw FOREIGN KEY (user_id)
    REFERENCES public.pfm_user_entity (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    )
    TABLESPACE pg_default;
ALTER TABLE public.pfm_roles_user_entities
    OWNER to postgres;


-- Table: public.pfm_transaction_data ----------------------------------------------!!!!!!!!!!!!!!!!



CREATE TABLE IF NOT EXISTS public.pfm_transaction_data
(
    id serial primary key,
    card_id bigint,
    currency character varying(255) COLLATE pg_catalog."default",
    date character varying(255) COLLATE pg_catalog."default",
    info character varying(255) COLLATE pg_catalog."default",
    mcc_info character varying(255) COLLATE pg_catalog."default",
    score_of_card character varying(255) COLLATE pg_catalog."default",
    sum character varying(255) COLLATE pg_catalog."default",
    client_id bigint,
    mcc_code bigint,
    mcc_code_rus bigint,
    CONSTRAINT fk20cylya0kv9r896puc89e6hea FOREIGN KEY (mcc_code)
    REFERENCES public.pfm_mcc (code) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION,
    CONSTRAINT fknoj9s3bb7lsijssjvsb20hx0b FOREIGN KEY (client_id)
    REFERENCES public.pfm_user_entity (id) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION,
    CONSTRAINT fkq1co23amkmi5f74palvyfb7m0 FOREIGN KEY (mcc_code_rus)
    REFERENCES public.pfm_our_mcc (code) MATCH SIMPLE
    ON UPDATE NO ACTION
    ON DELETE NO ACTION
    )
    TABLESPACE pg_default;
ALTER TABLE public.pfm_transaction_data
    OWNER to postgres;

---------------------------------------------------------------------------------------------------


INSERT INTO public.pfm_user_entity(login, password)
    (SELECT generate_series(1,479), '$2a$12$4oXol.yq7X/dTcoJ0BTzwOMTRP8xM2PSi0wWrc18Fg3Jf7iCCaplm');

INSERT INTO public.pfm_role(role)
VALUES ('USER');
INSERT INTO public.pfm_role(role)
VALUES ('ADMIN');

INSERT INTO public.pfm_roles_user_entities(user_id, role_id)
    (select generate_series(1,479), 1);

INSERT INTO public.pfm_products_of_bank(description, link, title)
VALUES ('Прибыльная кредитная карта c кешбэком до 11%', 'https://ib.psbank.ru/store/products/double-cashback','Двойной кешбэк');
INSERT INTO public.pfm_products_of_bank(description, link, title)
VALUES ('Не думайте о процентах более трёх месяцев', 'https://ib.psbank.ru/store/products/sto-credit','Кредитная карта «100+»');
INSERT INTO public.pfm_products_of_bank(description, link, title)
VALUES ('Карта с бесплатным обслуживание при покупках по карте от 5000 ₽ в месяц', 'https://ib.psbank.ru/store/products/your-cashback-new','Дебетовая карта "Твой кешбэк"');


