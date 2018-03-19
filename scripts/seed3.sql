--
-- PostgreSQL database dump
--

-- Dumped from database version 10.3
-- Dumped by pg_dump version 10.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

CREATE TABLE public.json_test (
    id integer NOT NULL,
    data json
);


CREATE TABLE public.jsonb_test (
    id integer NOT NULL,
    data jsonb
);

ALTER TABLE public.json_test OWNER TO user;
ALTER TABLE public.jsonb_test OWNER TO user;

COPY public.json_test (id, data) FROM stdin;
1	{"type": "articles",  "attributes": { "title": "Title1", "body": "Some string data here", "count": 5, "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z" }}
2	{"type": "articles",  "attributes": { "title": "Title2", "body": "Some string data here", "count": 10, "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z" }}
3	{"type": "articles",  "attributes": { "title": "Title3", "body": "Some string data here", "count": 5, "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z" }}
4	{"type": "articles",  "attributes": { "title": "Title4", "body": "Some string data here", "count": 20, "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z" }}
5	{"type": "articles",  "attributes": { "title": "Title5", "body": "Some string data here", "count": 5, "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z" }}
6	{"type": "articles",  "attributes": { "title": "Title6", "body": "Some string data here", "count": 30, "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z" }}
7	{"type": "articles",  "attributes": { "title": "Title7", "body": "Some string data here", "count": 5, "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z" }}
8	{"type": "articles",  "attributes": { "title": "Title8", "body": "Some string data here", "count": 40, "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z" }}
9	{"type": "articles",  "attributes": { "title": "Title9", "body": "Some string data here", "count": 5, "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z" }}
10	{"type": "articles",  "attributes": { "title": "Title10", "body": "Some string data here", "count": 50, "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z" }}
\.

COPY public.jsonb_test (id, data) FROM stdin;
1	{"type": "articles", "attributes": {"body": "Some string data here", "count": 5, "title": "Title1", "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z"}}
2	{"type": "articles", "attributes": {"body": "Some string data here", "count": 10, "title": "Title2", "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z"}}
3	{"type": "articles", "attributes": {"body": "Some string data here", "count": 5, "title": "Title3", "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z"}}
4	{"type": "articles", "attributes": {"body": "Some string data here", "count": 20, "title": "Title4", "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z"}}
5	{"type": "articles", "attributes": {"body": "Some string data here", "count": 5, "title": "Title5", "created": "2015-05-22T14:56:29.000Z", "updated": "2015-05-22T14:56:28.000Z"}}
6	{"type": "articles", "attributes": {"body": "Some string data here", "count": 30, "title": "Title6", "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z"}}
7	{"type": "articles", "attributes": {"body": "Some string data here", "count": 5, "title": "Title7", "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z"}}
8	{"type": "articles", "attributes": {"body": "Some string data here", "count": 40, "title": "Title8", "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z"}}
9	{"type": "articles", "attributes": {"body": "Some string data here", "count": 5, "title": "Title9", "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z"}}
10	{"type": "articles", "attributes": {"body": "Some string data here", "count": 50, "title": "Title10", "created": "2015-05-25T14:56:29.000Z", "updated": "2015-05-25T14:56:28.000Z"}}
\.

ALTER TABLE ONLY public.json_test
    ADD CONSTRAINT json_test_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.jsonb_test
    ADD CONSTRAINT jsonb_test_pkey PRIMARY KEY (id);

