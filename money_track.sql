--
-- PostgreSQL database dump
--

-- Dumped from database version 14.18 (Ubuntu 14.18-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.18 (Ubuntu 14.18-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE money_track;
--
-- Name: money_track; Type: DATABASE; Schema: -; Owner: diksha
--

CREATE DATABASE money_track WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE = 'en_GB.UTF-8';


ALTER DATABASE money_track OWNER TO diksha;

\connect money_track

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: categories; Type: TABLE; Schema: public; Owner: diksha
--

CREATE TABLE public.categories (
    category_id integer NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(10) NOT NULL,
    CONSTRAINT category_type_check CHECK (((type)::text = ANY ((ARRAY['Income'::character varying, 'Expense'::character varying])::text[])))
);


ALTER TABLE public.categories OWNER TO diksha;

--
-- Name: category_category_id_seq; Type: SEQUENCE; Schema: public; Owner: diksha
--

CREATE SEQUENCE public.category_category_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.category_category_id_seq OWNER TO diksha;

--
-- Name: category_category_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diksha
--

ALTER SEQUENCE public.category_category_id_seq OWNED BY public.categories.category_id;


--
-- Name: transactions; Type: TABLE; Schema: public; Owner: diksha
--

CREATE TABLE public.transactions (
    transaction_id integer NOT NULL,
    description text,
    type character varying(10) NOT NULL,
    category_id integer,
    transaction_date date DEFAULT CURRENT_DATE NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT transactions_type_check CHECK (((type)::text = ANY ((ARRAY['Income'::character varying, 'Expense'::character varying])::text[])))
);


ALTER TABLE public.transactions OWNER TO diksha;

--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE; Schema: public; Owner: diksha
--

CREATE SEQUENCE public.transactions_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.transactions_transaction_id_seq OWNER TO diksha;

--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: diksha
--

ALTER SEQUENCE public.transactions_transaction_id_seq OWNED BY public.transactions.transaction_id;


--
-- Name: categories category_id; Type: DEFAULT; Schema: public; Owner: diksha
--

ALTER TABLE ONLY public.categories ALTER COLUMN category_id SET DEFAULT nextval('public.category_category_id_seq'::regclass);


--
-- Name: transactions transaction_id; Type: DEFAULT; Schema: public; Owner: diksha
--

ALTER TABLE ONLY public.transactions ALTER COLUMN transaction_id SET DEFAULT nextval('public.transactions_transaction_id_seq'::regclass);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: diksha
--



--
-- Data for Name: transactions; Type: TABLE DATA; Schema: public; Owner: diksha
--



--
-- Name: category_category_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diksha
--

SELECT pg_catalog.setval('public.category_category_id_seq', 1, false);


--
-- Name: transactions_transaction_id_seq; Type: SEQUENCE SET; Schema: public; Owner: diksha
--

SELECT pg_catalog.setval('public.transactions_transaction_id_seq', 1, false);


--
-- Name: categories category_pkey; Type: CONSTRAINT; Schema: public; Owner: diksha
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT category_pkey PRIMARY KEY (category_id);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: public; Owner: diksha
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (transaction_id);


--
-- Name: transactions transactions_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: diksha
--

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(category_id) ON DELETE SET NULL;


--
-- PostgreSQL database dump complete
--

