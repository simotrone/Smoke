--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE OR REPLACE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- Name: serial; Type: SEQUENCE; Schema: public; Owner: sim
--

CREATE SEQUENCE serial
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.serial OWNER TO sim;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: citations; Type: TABLE; Schema: public; Owner: sim; Tablespace: 
--

CREATE TABLE citations (
    cite_id integer DEFAULT nextval('serial'::regclass) NOT NULL,
    source character varying(512),
    text text NOT NULL,
    genre_id integer DEFAULT 1 NOT NULL,
    create_time timestamp without time zone DEFAULT now() NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.citations OWNER TO sim;

--
-- Name: genres; Type: TABLE; Schema: public; Owner: sim; Tablespace: 
--

CREATE TABLE genres (
    genre_id integer DEFAULT nextval('serial'::regclass) NOT NULL,
    name character varying(80) NOT NULL,
    create_time timestamp without time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.genres OWNER TO sim;

--
-- Name: citations_view; Type: VIEW; Schema: public; Owner: sim
--

CREATE VIEW citations_view AS
    SELECT citations.cite_id AS id, citations.text, citations.source, genres.name AS genre FROM (citations LEFT JOIN genres ON ((citations.genre_id = genres.genre_id))) WHERE (citations.active = true);


ALTER TABLE public.citations_view OWNER TO sim;

--
-- Name: citations_pkey; Type: CONSTRAINT; Schema: public; Owner: sim; Tablespace: 
--

ALTER TABLE ONLY citations
    ADD CONSTRAINT citations_pkey PRIMARY KEY (cite_id);


--
-- Name: genres_name_key; Type: CONSTRAINT; Schema: public; Owner: sim; Tablespace: 
--

ALTER TABLE ONLY genres
    ADD CONSTRAINT genres_name_key UNIQUE (name);


--
-- Name: genres_pkey; Type: CONSTRAINT; Schema: public; Owner: sim; Tablespace: 
--

ALTER TABLE ONLY genres
    ADD CONSTRAINT genres_pkey PRIMARY KEY (genre_id);


--
-- Name: citations_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sim
--

ALTER TABLE ONLY citations
    ADD CONSTRAINT citations_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES genres(genre_id);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

