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
-- Name: feeds; Type: TABLE; Schema: public; Owner: sim; Tablespace: 
--

CREATE TABLE feeds (
    feed_id bigint DEFAULT nextval('serial'::regclass) NOT NULL,
    link character varying(512) NOT NULL,
    link_id bigint,
    create_time timestamp with time zone DEFAULT now() NOT NULL,
    name character varying(512),
    news_limit smallint DEFAULT 1 NOT NULL
);


ALTER TABLE public.feeds OWNER TO sim;

--
-- Name: links; Type: TABLE; Schema: public; Owner: sim; Tablespace: 
--

CREATE TABLE links (
    link_id bigint DEFAULT nextval('serial'::regclass) NOT NULL,
    href character varying(512) NOT NULL,
    name character varying(512) NOT NULL,
    comment text,
    create_time timestamp with time zone DEFAULT now() NOT NULL,
    last_mod timestamp with time zone DEFAULT now() NOT NULL,
    tag_id character varying(256) DEFAULT 'generic'::character varying NOT NULL
);


ALTER TABLE public.links OWNER TO sim;

--
-- Name: feeds_link_key; Type: CONSTRAINT; Schema: public; Owner: sim; Tablespace: 
--

ALTER TABLE ONLY feeds
    ADD CONSTRAINT feeds_link_key UNIQUE (link);


--
-- Name: feeds_pkey; Type: CONSTRAINT; Schema: public; Owner: sim; Tablespace: 
--

ALTER TABLE ONLY feeds
    ADD CONSTRAINT feeds_pkey PRIMARY KEY (feed_id);


--
-- Name: links_pkey; Type: CONSTRAINT; Schema: public; Owner: sim; Tablespace: 
--

ALTER TABLE ONLY links
    ADD CONSTRAINT links_pkey PRIMARY KEY (link_id);


--
-- Name: feeds_link_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: sim
--

ALTER TABLE ONLY feeds
    ADD CONSTRAINT feeds_link_id_fkey FOREIGN KEY (link_id) REFERENCES links(link_id);


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

