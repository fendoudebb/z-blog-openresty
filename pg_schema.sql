--
-- PostgreSQL database dump
--

-- Dumped from database version 12.2
-- Dumped by pg_dump version 12.2

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

--
-- Roles
--

DROP ROLE IF EXISTS "z-blog";

CREATE ROLE "z-blog";
ALTER ROLE "z-blog" WITH NOSUPERUSER INHERIT NOCREATEROLE NOCREATEDB LOGIN NOREPLICATION NOBYPASSRLS;

DROP DATABASE IF EXISTS "z-blog";

--
-- Name: z-blog; Type: DATABASE; Schema: -; Owner: z-blog
--

CREATE DATABASE "z-blog" WITH TEMPLATE = template0 ENCODING = 'UTF8';


ALTER DATABASE "z-blog" OWNER TO "z-blog";

\connect -reuse-previous=on "dbname='z-blog'"

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
-- Name: dashboard_user; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.dashboard_user (
    id integer NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    roles text[] NOT NULL,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.dashboard_user OWNER TO "z-blog";

--
-- Name: TABLE dashboard_user; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.dashboard_user IS '管理系统用户';


--
-- Name: dashboard_user_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.dashboard_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dashboard_user_id_seq OWNER TO "z-blog";

--
-- Name: dashboard_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: z-blog
--

ALTER SEQUENCE public.dashboard_user_id_seq OWNED BY public.dashboard_user.id;


--
-- Name: english; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.english (
    id integer NOT NULL,
    word text NOT NULL,
    english_phonetic text,
    american_phonetic text,
    translation jsonb NOT NULL,
    example_sentence text,
    sentence_translation text,
    source text,
    synonyms text,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.english OWNER TO "z-blog";

--
-- Name: TABLE english; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.english IS '英语角';


--
-- Name: english_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.english_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.english_id_seq OWNER TO "z-blog";

--
-- Name: english_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: z-blog
--

ALTER SEQUENCE public.english_id_seq OWNED BY public.english.id;


--
-- Name: ip_pool; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.ip_pool (
    id integer NOT NULL,
    ip inet NOT NULL,
    country text,
    region text,
    city text,
    isp text,
    country_id text,
    region_id text,
    city_id text,
    isp_id text,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.ip_pool OWNER TO "z-blog";

--
-- Name: TABLE ip_pool; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.ip_pool IS 'IP池';


--
-- Name: COLUMN ip_pool.ip; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.ip IS 'IP地址';


--
-- Name: COLUMN ip_pool.country; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.country IS '国家';


--
-- Name: COLUMN ip_pool.region; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.region IS '地区';


--
-- Name: COLUMN ip_pool.city; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.city IS '城市';


--
-- Name: COLUMN ip_pool.isp; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.isp IS 'ip服务商';


--
-- Name: COLUMN ip_pool.country_id; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.country_id IS '国家id';


--
-- Name: COLUMN ip_pool.region_id; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.region_id IS '地区id';


--
-- Name: COLUMN ip_pool.city_id; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.city_id IS '城市码';


--
-- Name: COLUMN ip_pool.isp_id; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.isp_id IS 'ip服务商id';


--
-- Name: COLUMN ip_pool.create_ts; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.create_ts IS '创建时间';


--
-- Name: COLUMN ip_pool.update_ts; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.ip_pool.update_ts IS '更新时间';


--
-- Name: ip_pool_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.ip_pool_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ip_pool_id_seq OWNER TO "z-blog";

--
-- Name: ip_pool_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: z-blog
--

ALTER SEQUENCE public.ip_pool_id_seq OWNED BY public.ip_pool.id;


--
-- Name: ip_unknown; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.ip_unknown (
    ip text NOT NULL,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.ip_unknown OWNER TO "z-blog";

--
-- Name: TABLE ip_unknown; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.ip_unknown IS '未知IP';


--
-- Name: link; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.link (
    id integer NOT NULL,
    website text NOT NULL,
    url text NOT NULL,
    webmaster text NOT NULL,
    webmaster_email text,
    status smallint DEFAULT 0 NOT NULL,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    sort smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.link OWNER TO "z-blog";

--
-- Name: TABLE link; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.link IS '友链';


--
-- Name: COLUMN link.webmaster; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.link.webmaster IS '站长';


--
-- Name: COLUMN link.status; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.link.status IS '友链状态（0：普通，1：下线）';


--
-- Name: COLUMN link.sort; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.link.sort IS '排序';


--
-- Name: link_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.link_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.link_id_seq OWNER TO "z-blog";

--
-- Name: link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: z-blog
--

ALTER SEQUENCE public.link_id_seq OWNED BY public.link.id;


--
-- Name: message_board; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.message_board (
    id integer NOT NULL,
    nickname text NOT NULL,
    content text NOT NULL,
    floor integer,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    status smallint DEFAULT 0 NOT NULL,
    ua text NOT NULL,
    os text NOT NULL,
    browser text NOT NULL,
    replies jsonb,
    ip_id bigint DEFAULT 0 NOT NULL,
    reply_id integer,
    root_id integer,
    like_count integer DEFAULT 0 NOT NULL,
    reply_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.message_board OWNER TO "z-blog";

--
-- Name: TABLE message_board; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.message_board IS '留言板';


--
-- Name: COLUMN message_board.status; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.message_board.status IS '评论状态（0：正常，1：删除）';


--
-- Name: message_board_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.message_board_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.message_board_id_seq OWNER TO "z-blog";

--
-- Name: message_board_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: z-blog
--

ALTER SEQUENCE public.message_board_id_seq OWNED BY public.message_board.id;


--
-- Name: post; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.post (
    id integer NOT NULL,
    uid integer DEFAULT 0 NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    topics text[],
    content text NOT NULL,
    content_html text NOT NULL,
    word_count integer DEFAULT 0 NOT NULL,
    prop smallint DEFAULT 0 NOT NULL,
    post_status smallint DEFAULT 0 NOT NULL,
    pv integer DEFAULT 0 NOT NULL,
    like_count integer DEFAULT 0 NOT NULL,
    comment_count integer DEFAULT 0 NOT NULL,
    comment_status smallint DEFAULT 0 NOT NULL,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    post_comment jsonb,
    post_like jsonb,
    keywords text
);


ALTER TABLE public.post OWNER TO "z-blog";

--
-- Name: TABLE post; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.post IS '文章';


--
-- Name: COLUMN post.id; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.id IS '文章id';


--
-- Name: COLUMN post.uid; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.uid IS '文章所属用户id';


--
-- Name: COLUMN post.title; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.title IS '文章标题';


--
-- Name: COLUMN post.description; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.description IS '文章描述';


--
-- Name: COLUMN post.topics; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.topics IS '标签数组';


--
-- Name: COLUMN post.content; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.content IS '文章内容（Markdown）';


--
-- Name: COLUMN post.content_html; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.content_html IS '文章内容（HTML）';


--
-- Name: COLUMN post.word_count; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.word_count IS '文章字数';


--
-- Name: COLUMN post.prop; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.prop IS '是否转载（0：原创，1：转载）';


--
-- Name: COLUMN post.post_status; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.post_status IS '文章状态（0：普通，1：下线，2：私有）';


--
-- Name: COLUMN post.pv; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.pv IS '浏览量';


--
-- Name: COLUMN post.like_count; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.like_count IS '点赞数';


--
-- Name: COLUMN post.comment_count; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.comment_count IS '评论总数';


--
-- Name: COLUMN post.comment_status; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.comment_status IS '可否评论（0：打开，1：关闭）';


--
-- Name: COLUMN post.create_ts; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.create_ts IS '发布时间';


--
-- Name: COLUMN post.update_ts; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.update_ts IS '更新时间';


--
-- Name: COLUMN post.keywords; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.post.keywords IS '关键词';


--
-- Name: post_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.post_comment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_comment_id_seq OWNER TO "z-blog";

--
-- Name: post_like_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.post_like_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.post_like_id_seq OWNER TO "z-blog";

--
-- Name: record_invalid_request_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.record_invalid_request_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.record_invalid_request_id_seq OWNER TO "z-blog";

--
-- Name: record_invalid_request; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.record_invalid_request (
    id bigint DEFAULT nextval('public.record_invalid_request_id_seq'::regclass) NOT NULL,
    url text NOT NULL,
    req_method smallint,
    req_param text,
    ua text NOT NULL,
    browser text,
    browser_platform text,
    browser_version text,
    browser_vendor text,
    os text,
    os_version text,
    referer text,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    cost_time numeric(6,2),
    ip_id bigint,
    source smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.record_invalid_request OWNER TO "z-blog";

--
-- Name: TABLE record_invalid_request; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.record_invalid_request IS '不合法请求记录';


--
-- Name: COLUMN record_invalid_request.req_method; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.record_invalid_request.req_method IS '请求方法（0：GET，1：POST，2：PUT，3：DELETE，4：OPTION）';


--
-- Name: COLUMN record_invalid_request.browser_vendor; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.record_invalid_request.browser_vendor IS '浏览器-制造商';


--
-- Name: COLUMN record_invalid_request.source; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.record_invalid_request.source IS '0：网站，1：微信小程序';


--
-- Name: record_page_view_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.record_page_view_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.record_page_view_id_seq OWNER TO "z-blog";

--
-- Name: record_page_view; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.record_page_view (
    id bigint DEFAULT nextval('public.record_page_view_id_seq'::regclass) NOT NULL,
    url text NOT NULL,
    req_method smallint,
    req_param text,
    ua text NOT NULL,
    browser text,
    browser_platform text,
    browser_version text,
    browser_vendor text,
    os text,
    os_version text,
    referer text,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    cost_time numeric(6,2),
    ip_id bigint,
    source smallint DEFAULT 0 NOT NULL
);


ALTER TABLE public.record_page_view OWNER TO "z-blog";

--
-- Name: TABLE record_page_view; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.record_page_view IS '访问记录';


--
-- Name: COLUMN record_page_view.req_method; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.record_page_view.req_method IS '请求方法（0：GET，1：POST，2：PUT，3：DELETE，4：OPTION）';


--
-- Name: COLUMN record_page_view.browser_vendor; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.record_page_view.browser_vendor IS '浏览器-制造商';


--
-- Name: COLUMN record_page_view.source; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON COLUMN public.record_page_view.source IS '0：网站，1：微信小程序';


--
-- Name: record_search; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.record_search (
    id integer NOT NULL,
    keywords text NOT NULL,
    took integer DEFAULT 0 NOT NULL,
    hits integer DEFAULT 0 NOT NULL,
    referer text,
    browser text NOT NULL,
    os text NOT NULL,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    ip_id bigint,
    ua text
);


ALTER TABLE public.record_search OWNER TO "z-blog";

--
-- Name: TABLE record_search; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.record_search IS '搜索记录';


--
-- Name: record_search_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.record_search_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.record_search_id_seq OWNER TO "z-blog";

--
-- Name: record_search_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: z-blog
--

ALTER SEQUENCE public.record_search_id_seq OWNED BY public.record_search.id;


--
-- Name: topic; Type: TABLE; Schema: public; Owner: z-blog
--

CREATE TABLE public.topic (
    id integer NOT NULL,
    name text NOT NULL,
    sort integer DEFAULT 0 NOT NULL,
    create_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    update_ts timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.topic OWNER TO "z-blog";

--
-- Name: TABLE topic; Type: COMMENT; Schema: public; Owner: z-blog
--

COMMENT ON TABLE public.topic IS '标签';


--
-- Name: topic_id_seq; Type: SEQUENCE; Schema: public; Owner: z-blog
--

CREATE SEQUENCE public.topic_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.topic_id_seq OWNER TO "z-blog";

--
-- Name: topic_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: z-blog
--

ALTER SEQUENCE public.topic_id_seq OWNED BY public.topic.id;


--
-- Name: dashboard_user id; Type: DEFAULT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.dashboard_user ALTER COLUMN id SET DEFAULT nextval('public.dashboard_user_id_seq'::regclass);


--
-- Name: english id; Type: DEFAULT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.english ALTER COLUMN id SET DEFAULT nextval('public.english_id_seq'::regclass);


--
-- Name: ip_pool id; Type: DEFAULT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.ip_pool ALTER COLUMN id SET DEFAULT nextval('public.ip_pool_id_seq'::regclass);


--
-- Name: link id; Type: DEFAULT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.link ALTER COLUMN id SET DEFAULT nextval('public.link_id_seq'::regclass);


--
-- Name: message_board id; Type: DEFAULT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.message_board ALTER COLUMN id SET DEFAULT nextval('public.message_board_id_seq'::regclass);


--
-- Name: record_search id; Type: DEFAULT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.record_search ALTER COLUMN id SET DEFAULT nextval('public.record_search_id_seq'::regclass);


--
-- Name: topic id; Type: DEFAULT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.topic ALTER COLUMN id SET DEFAULT nextval('public.topic_id_seq'::regclass);


--
-- Name: message_board comment_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.message_board
    ADD CONSTRAINT comment_pkey PRIMARY KEY (id);


--
-- Name: english english_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.english
    ADD CONSTRAINT english_pkey PRIMARY KEY (id);


--
-- Name: ip_pool ip_pool_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.ip_pool
    ADD CONSTRAINT ip_pool_pkey PRIMARY KEY (id);


--
-- Name: ip_unknown ip_unknown_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.ip_unknown
    ADD CONSTRAINT ip_unknown_pkey PRIMARY KEY (ip);


--
-- Name: link link_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_pkey PRIMARY KEY (id);


--
-- Name: post post_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.post
    ADD CONSTRAINT post_pkey PRIMARY KEY (id);


--
-- Name: record_invalid_request record_invalid_request_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.record_invalid_request
    ADD CONSTRAINT record_invalid_request_pkey PRIMARY KEY (id);


--
-- Name: record_page_view record_page_view_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.record_page_view
    ADD CONSTRAINT record_page_view_pkey PRIMARY KEY (id);


--
-- Name: record_search record_search_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.record_search
    ADD CONSTRAINT record_search_pkey PRIMARY KEY (id);


--
-- Name: topic topic_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.topic
    ADD CONSTRAINT topic_pkey PRIMARY KEY (id);


--
-- Name: english unique; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.english
    ADD CONSTRAINT "unique" UNIQUE (word);


--
-- Name: topic unique_topic_name; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.topic
    ADD CONSTRAINT unique_topic_name UNIQUE (name);


--
-- Name: dashboard_user user_pkey; Type: CONSTRAINT; Schema: public; Owner: z-blog
--

ALTER TABLE ONLY public.dashboard_user
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: gin_index_topics; Type: INDEX; Schema: public; Owner: z-blog
--

CREATE INDEX gin_index_topics ON public.post USING gin (topics);


--
-- Name: unique_ip; Type: INDEX; Schema: public; Owner: z-blog
--

CREATE UNIQUE INDEX unique_ip ON public.ip_pool USING btree (ip);


--
-- Name: unique_username_index; Type: INDEX; Schema: public; Owner: z-blog
--

CREATE UNIQUE INDEX unique_username_index ON public.dashboard_user USING btree (username);


--
-- PostgreSQL database dump complete
--

