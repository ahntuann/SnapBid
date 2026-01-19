--
-- PostgreSQL database dump
--

-- \restrict geQ32cRgAafsUBjAD4kFjMpLp2RZmPlLAxQ2uNAQVIQcWtyCaEiH1UOM55rxrfN

-- Dumped from database version 16.11 (Homebrew)
-- Dumped by pg_dump version 16.11 (Homebrew)

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
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.active_storage_attachments OWNER TO thieuphong;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_storage_attachments_id_seq OWNER TO thieuphong;

--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.active_storage_blobs OWNER TO thieuphong;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_storage_blobs_id_seq OWNER TO thieuphong;

--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


ALTER TABLE public.active_storage_variant_records OWNER TO thieuphong;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNER TO thieuphong;

--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: ai_verifications; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.ai_verifications (
    id bigint NOT NULL,
    listing_id bigint NOT NULL,
    status integer,
    confidence numeric,
    reason text,
    raw_response jsonb,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ai_verifications OWNER TO thieuphong;

--
-- Name: ai_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.ai_verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ai_verifications_id_seq OWNER TO thieuphong;

--
-- Name: ai_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.ai_verifications_id_seq OWNED BY public.ai_verifications.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.ar_internal_metadata OWNER TO thieuphong;

--
-- Name: bids; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.bids (
    id bigint NOT NULL,
    listing_id bigint NOT NULL,
    user_id bigint NOT NULL,
    amount numeric(12,0) NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.bids OWNER TO thieuphong;

--
-- Name: bids_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.bids_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.bids_id_seq OWNER TO thieuphong;

--
-- Name: bids_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.bids_id_seq OWNED BY public.bids.id;


--
-- Name: listings; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.listings (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    title character varying,
    category character varying,
    condition character varying,
    seller_note text,
    status integer,
    ai_note text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    start_price numeric,
    published_at timestamp(6) without time zone,
    reserve_price numeric,
    bid_increment numeric,
    auction_ends_at timestamp(6) without time zone,
    buy_now_price numeric(12,0)
);


ALTER TABLE public.listings OWNER TO thieuphong;

--
-- Name: listings_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.listings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.listings_id_seq OWNER TO thieuphong;

--
-- Name: listings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.listings_id_seq OWNED BY public.listings.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    recipient_id bigint NOT NULL,
    actor_id bigint,
    action integer NOT NULL,
    notifiable_type character varying,
    notifiable_id bigint,
    message text NOT NULL,
    url character varying,
    read_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.notifications OWNER TO thieuphong;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO thieuphong;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.orders (
    id bigint NOT NULL,
    listing_id bigint NOT NULL,
    buyer_id bigint NOT NULL,
    price numeric,
    kind integer,
    status integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    total numeric,
    buyer_marked_paid_at timestamp(6) without time zone,
    admin_confirmed_paid_at timestamp(6) without time zone,
    recipient_name character varying,
    recipient_phone character varying,
    shipping_address text
);


ALTER TABLE public.orders OWNER TO thieuphong;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.orders_id_seq OWNER TO thieuphong;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.orders_id_seq OWNED BY public.orders.id;


--
-- Name: otps; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.otps (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    purpose character varying,
    code_digest character varying,
    expires_at timestamp(6) without time zone,
    used_at timestamp(6) without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.otps OWNER TO thieuphong;

--
-- Name: otps_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.otps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.otps_id_seq OWNER TO thieuphong;

--
-- Name: otps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.otps_id_seq OWNED BY public.otps.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


ALTER TABLE public.schema_migrations OWNER TO thieuphong;

--
-- Name: system_settings; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.system_settings (
    id bigint NOT NULL,
    ai_threshold numeric,
    commission_percent numeric,
    min_bid_step numeric,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


ALTER TABLE public.system_settings OWNER TO thieuphong;

--
-- Name: system_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.system_settings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.system_settings_id_seq OWNER TO thieuphong;

--
-- Name: system_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.system_settings_id_seq OWNED BY public.system_settings.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: thieuphong
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp(6) without time zone,
    remember_created_at timestamp(6) without time zone,
    name character varying,
    role integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    provider character varying,
    uid character varying,
    email_verified_at timestamp(6) without time zone
);


ALTER TABLE public.users OWNER TO thieuphong;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: thieuphong
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO thieuphong;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: thieuphong
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: ai_verifications id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.ai_verifications ALTER COLUMN id SET DEFAULT nextval('public.ai_verifications_id_seq'::regclass);


--
-- Name: bids id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.bids ALTER COLUMN id SET DEFAULT nextval('public.bids_id_seq'::regclass);


--
-- Name: listings id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.listings ALTER COLUMN id SET DEFAULT nextval('public.listings_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: orders id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.orders ALTER COLUMN id SET DEFAULT nextval('public.orders_id_seq'::regclass);


--
-- Name: otps id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.otps ALTER COLUMN id SET DEFAULT nextval('public.otps_id_seq'::regclass);


--
-- Name: system_settings id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.system_settings ALTER COLUMN id SET DEFAULT nextval('public.system_settings_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: active_storage_attachments; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.active_storage_attachments (id, name, record_type, record_id, blob_id, created_at) FROM stdin;
2	images	Listing	22	2	2026-01-18 18:10:53.627462
3	images	Listing	23	3	2026-01-18 18:29:15.136266
4	images	Listing	32	4	2026-01-18 20:08:56.206276
5	images	Listing	32	5	2026-01-18 20:08:56.251391
6	images	Listing	33	6	2026-01-18 20:11:23.296804
12	images	Listing	34	12	2026-01-18 20:35:59.525609
13	images	Listing	35	13	2026-01-18 20:44:32.244659
14	images	Listing	35	14	2026-01-18 20:44:32.24832
15	images	Listing	36	15	2026-01-18 20:49:53.027568
16	images	Listing	36	16	2026-01-18 20:49:53.03548
17	images	Listing	36	17	2026-01-18 20:49:53.037552
18	images	Listing	37	18	2026-01-18 20:53:29.341009
19	images	Listing	37	19	2026-01-18 20:53:29.347934
20	images	Listing	37	20	2026-01-18 20:53:29.351341
22	images	Listing	38	22	2026-01-18 20:56:55.809691
23	images	Listing	38	23	2026-01-18 20:56:55.821005
24	image	ActiveStorage::VariantRecord	3	26	2026-01-19 02:46:36.307895
25	image	ActiveStorage::VariantRecord	1	25	2026-01-19 02:46:36.305044
26	image	ActiveStorage::VariantRecord	2	24	2026-01-19 02:46:36.307006
27	image	ActiveStorage::VariantRecord	4	27	2026-01-19 02:46:54.767426
28	image	ActiveStorage::VariantRecord	5	28	2026-01-19 02:46:54.958547
29	image	ActiveStorage::VariantRecord	6	29	2026-01-19 02:46:55.782799
30	image	ActiveStorage::VariantRecord	7	30	2026-01-19 02:46:56.704349
31	image	ActiveStorage::VariantRecord	8	31	2026-01-19 02:47:04.034754
32	images	Listing	39	32	2026-01-19 02:55:06.38853
33	images	Listing	39	33	2026-01-19 02:55:06.392129
34	images	Listing	39	34	2026-01-19 02:55:06.394015
35	images	Listing	39	35	2026-01-19 02:55:06.395707
36	images	Listing	39	36	2026-01-19 02:55:06.397457
37	image	ActiveStorage::VariantRecord	9	37	2026-01-19 02:55:36.205251
38	images	Listing	40	38	2026-01-19 02:58:02.76449
39	images	Listing	40	39	2026-01-19 02:58:02.767185
40	images	Listing	40	40	2026-01-19 02:58:02.771348
41	image	ActiveStorage::VariantRecord	10	41	2026-01-19 02:58:12.158449
42	images	Listing	41	42	2026-01-19 02:59:18.854788
43	images	Listing	41	43	2026-01-19 02:59:18.863599
44	images	Listing	41	44	2026-01-19 02:59:18.896739
45	images	Listing	41	45	2026-01-19 02:59:18.90874
46	images	Listing	41	46	2026-01-19 02:59:18.911594
47	image	ActiveStorage::VariantRecord	11	47	2026-01-19 02:59:26.215876
48	images	Listing	42	48	2026-01-19 03:00:15.168281
49	images	Listing	42	49	2026-01-19 03:00:15.17072
50	images	Listing	42	50	2026-01-19 03:00:15.175798
51	images	Listing	42	51	2026-01-19 03:00:15.179533
52	images	Listing	42	52	2026-01-19 03:00:15.181093
53	image	ActiveStorage::VariantRecord	12	53	2026-01-19 03:00:24.456113
54	image	ActiveStorage::VariantRecord	13	54	2026-01-19 03:05:26.671466
55	image	ActiveStorage::VariantRecord	14	55	2026-01-19 06:29:37.914498
56	images	Listing	43	56	2026-01-19 11:50:52.075301
57	images	Listing	43	57	2026-01-19 11:50:52.081241
58	images	Listing	43	58	2026-01-19 11:50:52.086631
59	image	ActiveStorage::VariantRecord	15	59	2026-01-19 11:52:03.606347
60	image	ActiveStorage::VariantRecord	16	60	2026-01-19 11:59:22.702988
\.


--
-- Data for Name: active_storage_blobs; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.active_storage_blobs (id, key, filename, content_type, metadata, service_name, byte_size, checksum, created_at) FROM stdin;
32	u1yi5zlwkoaqhis579rwvtvy2wlr	hina1.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	65242	7oiIpSbOCqmTeKa2Xy3+lQ==	2026-01-19 02:55:06.386053
2	2phs78t7h1qs0k074cf9h19nlcfo	giuc_nua_thi_vao_ma_lam.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	22184	/5raBVMLCdfpcmyh6riJ7g==	2026-01-18 18:10:53.593719
3	cbtirsrpkxgijufqu9c3yvmbeu1n	giuc_nua_thi_vao_ma_lam.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	22184	/5raBVMLCdfpcmyh6riJ7g==	2026-01-18 18:29:15.132925
4	bpmynrsmzbbfjts9b98das4vctqn	giuc_nua_thi_vao_ma_lam.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	22184	/5raBVMLCdfpcmyh6riJ7g==	2026-01-18 20:08:56.197456
5	p3xen9h4g872jaloxdrbbb1vyzpj	IMG_756DF4E140A6-1.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	1356249	I3JkYgUDCzsZcGVUWYBtuA==	2026-01-18 20:08:56.246854
6	ffb2xjsw2fzxld8a8lmm66q9ehln	giuc_nua_thi_vao_ma_lam.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	22184	/5raBVMLCdfpcmyh6riJ7g==	2026-01-18 20:11:23.292453
22	6ifnkqmticfnpnfjodoxikkzui7g	IMG_3886.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	668229	Nk0d3Xs4V6OZqimjhV6j1w==	2026-01-18 20:56:55.80191
23	5zva1c8upa2m6cko97oboktucgfj	IMG_9213.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	1485979	/zDfzPnB7t/CyhfQBfRs0w==	2026-01-18 20:56:55.815838
12	mkj7npe5wm112upp6dgkmz2tr0ei	giuc_nua_thi_vao_ma_lam.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	22184	/5raBVMLCdfpcmyh6riJ7g==	2026-01-18 20:35:59.522626
14	u1vwv3alh23ifrn387unaqbcqbzy	8ebe0cdea00cde085c64d4223064d5e3.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	16418	OqRfasvNG4jPo1NuMPI65g==	2026-01-18 20:44:32.247148
13	rwpkrcj2ekp4b044iybb8v6zfhk1	giuc_nua_thi_vao_ma_lam.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	22184	/5raBVMLCdfpcmyh6riJ7g==	2026-01-18 20:44:32.242613
15	h2v54j2o6e06oqpwb04xank8unoz	IMG_9263.png	image/png	{"identified":true,"analyzed":true}	local	287554	+LS8lNODM7JGwGnffzdF3A==	2026-01-18 20:49:53.024444
16	upz22r74r4soddnozex6556yv3l8	IMG_9255.png	image/png	{"identified":true,"analyzed":true}	local	1065418	uIvNzlEVIjyU1IgbLboUDg==	2026-01-18 20:49:53.033757
17	vqtj6l6krg7p9q20bal2756085o2	IMG_9218.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	941838	bfzlAonV5O4BMLT+CgMirg==	2026-01-18 20:49:53.036721
20	udpvh08xrguxazhmu3sllapnqofa	IMG_9213.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	1485979	/zDfzPnB7t/CyhfQBfRs0w==	2026-01-18 20:53:29.349864
18	g0gny0ud6lp7324l5d4adgrd5xtu	IMG_3886.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	668229	Nk0d3Xs4V6OZqimjhV6j1w==	2026-01-18 20:53:29.338376
19	mpnwnhsyta6pk38m288l6kz9o32g	IMG_9214.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	1488682	ZWc5JE63mOkaefNIlQVFcg==	2026-01-18 20:53:29.346411
25	7pb90vx6g3ivbukdubihhlg9p5o3	giuc_nua_thi_vao_ma_lam.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	4084	PB+KUBQ3Y7hYye3hdDUtVQ==	2026-01-19 02:46:36.301391
26	2uxlyaysls6k81f6vxdv200tphf7	IMG_3886.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	3275	hmCVmZ0ryix3lZIoQOF5Eg==	2026-01-19 02:46:36.302656
24	j8hte6ho48coa7s6ianykeqlwcyi	IMG_3886.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	3275	hmCVmZ0ryix3lZIoQOF5Eg==	2026-01-19 02:46:36.295551
29	ff3gpm7vgzjk0ua35bb1ctd0275g	IMG_9263.png	image/png	{"identified":true,"analyzed":true}	local	397245	ryyCUx5IQ2jiRb7kLbQpwg==	2026-01-19 02:46:55.708966
27	cufuq5aqb4t6zghcsfr403re6sd3	IMG_3886.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	44896	h2dpxLCbNKz2zZAUgfYArw==	2026-01-19 02:46:54.750302
28	08ui2o4tt96h3htofyv4l1rmyf1g	IMG_3886.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	44896	h2dpxLCbNKz2zZAUgfYArw==	2026-01-19 02:46:54.93764
30	qs1vis9x893g8rirqjq3zjyase6i	giuc_nua_thi_vao_ma_lam.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	61504	zPmhFQpl7XnFWoyv76D39A==	2026-01-19 02:46:56.702068
31	5kn2jcxer1612kd2rugp0unn4a7j	giuc_nua_thi_vao_ma_lam.jpg	image/jpeg	{"identified":true,"analyzed":true}	local	61504	zPmhFQpl7XnFWoyv76D39A==	2026-01-19 02:47:04.031152
34	to3xv8qb1sfzjvzevmq4vy34iszb	hina3.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	66072	GnbgS8N1aWLvoQxuOk/8pg==	2026-01-19 02:55:06.39302
33	uhwo9np0sl5hqbc5iry7654u1iiv	hina2.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	71910	Y13Hl7vRsPDXtxi3w8vciA==	2026-01-19 02:55:06.391095
35	ie89xsuw7qikt6qj1ujy3ygcoc94	hina4.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	71965	rgTofNfrwopDEyBM6y62sw==	2026-01-19 02:55:06.394934
36	ss5r8ucqwsvwyv4zuwmehbluurlc	hina5.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	61481	+REFiMDwBCFiUTCcb5rtmg==	2026-01-19 02:55:06.396603
37	nz9uknapdij3p27qksoy91a1u6s8	hina1.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	68118	LDJtMzPickXB+YoVbDqcxQ==	2026-01-19 02:55:36.20159
38	vuvjoo7v15q8eo06b59as7lvwca2	IMG_3859.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	365604	3NfC7IbBbf/4a8ox9ZRKaA==	2026-01-19 02:58:02.763039
39	d7kpc6ov8ln8sphyn4hd7icatg02	IMG_9159.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	16433	ia73nQimz5jgnVFxGoWHMQ==	2026-01-19 02:58:02.766058
40	hn3yw90d9j3u5bziusn4ctbot03h	IMG_9148.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	59891	f8s9DKrKLXzFHUktoktHmg==	2026-01-19 02:58:02.770319
41	21k2n93y0tnhk6g39573sbzpusdc	IMG_3859.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	108469	Mhp2AG1viSUCwXAB7VcGWw==	2026-01-19 02:58:12.156328
44	b4pkigudddruqnbxhn0b99rzpj8k	IMG_9047.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	2116798	etTaxlveupR5XsTpn3xn+w==	2026-01-19 02:59:18.875695
42	6gopspq66hfkjk8dtvztm6h15cx6	IMG_3799.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	22571	dlu9jK1i5fDQ/tn6rRdqSw==	2026-01-19 02:59:18.852144
43	rq4ku8qmre4y4ixazcm345sccur2	IMG_9042.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	85665	OyY/GG88IISqfxhWrtcnew==	2026-01-19 02:59:18.861202
45	qbxvsz9w5y89b502xkodfmo4ucu5	IMG_9046.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	1913821	Uhj4LB+Vtg816WuSFo98bQ==	2026-01-19 02:59:18.904487
46	amaslrtopq5osgcclcr0aw8o3lmb	IMG_9045.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	2135952	nQN7RDdsk5sjKJj2wy2ULg==	2026-01-19 02:59:18.910395
47	k13uyddmxt0kt17w4a5t8x49xxik	IMG_3799.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	65284	5bqNZFyr5sweOfVzTn0ooA==	2026-01-19 02:59:26.212022
49	o21m0fz73asx38yjyutqnzoophsa	hina2.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	71910	Y13Hl7vRsPDXtxi3w8vciA==	2026-01-19 03:00:15.169806
53	4v1w4g81pa0ouenvg3l0flnedqx0	hina3.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	64655	gd3fPLvdKsyo5ZYs0C2Gmg==	2026-01-19 03:00:24.453427
48	wzkzfyvb92rtme3mju7qjklzb1r5	hina3.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	66072	GnbgS8N1aWLvoQxuOk/8pg==	2026-01-19 03:00:15.166969
51	op0drwzkptf40gt74c1s09u7dyah	hina4.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	71965	rgTofNfrwopDEyBM6y62sw==	2026-01-19 03:00:15.17676
50	spcza7ljy1g78u4qwreedznblr6o	hina1.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	65242	7oiIpSbOCqmTeKa2Xy3+lQ==	2026-01-19 03:00:15.174843
52	ofhjesj83qyg1g1f1ih14c1jzb1i	hina5.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	61481	+REFiMDwBCFiUTCcb5rtmg==	2026-01-19 03:00:15.180364
54	5b8x3omlf9r6dsq3kl8xjsq1xpid	hina1.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	3328	28M4x9ps412/3P4vMCWyDg==	2026-01-19 03:05:26.659938
55	dwq1j8dzrezn7rdpviupekajer98	hina3.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	3592	blRQ4kP+blCkLqySwozCtg==	2026-01-19 06:29:37.908851
56	69cx08ggm8ksm82ctud2e2n9lt93	hina1.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	65242	7oiIpSbOCqmTeKa2Xy3+lQ==	2026-01-19 11:50:52.068119
58	j2q8i0s8ay2txgnqin5ef2ttuiy7	hina3.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	66072	GnbgS8N1aWLvoQxuOk/8pg==	2026-01-19 11:50:52.082489
57	b9cr78506y10z87ll1xz70fgj6zw	hina2.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	71910	Y13Hl7vRsPDXtxi3w8vciA==	2026-01-19 11:50:52.08033
59	h48cq5ynaf5mkonp1v3depm5rhe3	hina1.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	68118	LDJtMzPickXB+YoVbDqcxQ==	2026-01-19 11:52:03.604844
60	b6cqbpnoqd959fm7irt7ou4ypngj	hina1.jpeg	image/jpeg	{"identified":true,"analyzed":true}	local	3328	28M4x9ps412/3P4vMCWyDg==	2026-01-19 11:59:22.700277
\.


--
-- Data for Name: active_storage_variant_records; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.active_storage_variant_records (id, blob_id, variation_digest) FROM stdin;
2	22	Tj08cL+Rw9KmVHzjLZZjW3RIRbU=
1	13	sRwnICKrsvdwPuW4njmG5yVzGO0=
3	18	Tj08cL+Rw9KmVHzjLZZjW3RIRbU=
4	22	iGS1QWP13SrPvxAuVTsZfxz697s=
5	18	iGS1QWP13SrPvxAuVTsZfxz697s=
6	15	K700nSrWvbvx/Gacr6vEHG9xrYw=
7	13	gFb5s4wsMqx++TKtyBoqntkgxwU=
8	12	gFb5s4wsMqx++TKtyBoqntkgxwU=
9	32	iGS1QWP13SrPvxAuVTsZfxz697s=
10	38	iGS1QWP13SrPvxAuVTsZfxz697s=
11	42	iGS1QWP13SrPvxAuVTsZfxz697s=
12	48	iGS1QWP13SrPvxAuVTsZfxz697s=
13	32	Tj08cL+Rw9KmVHzjLZZjW3RIRbU=
14	48	Tj08cL+Rw9KmVHzjLZZjW3RIRbU=
15	56	iGS1QWP13SrPvxAuVTsZfxz697s=
16	56	Tj08cL+Rw9KmVHzjLZZjW3RIRbU=
\.


--
-- Data for Name: ai_verifications; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.ai_verifications (id, listing_id, status, confidence, reason, raw_response, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: ar_internal_metadata; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.ar_internal_metadata (key, value, created_at, updated_at) FROM stdin;
environment	development	2026-01-11 04:40:02.599014	2026-01-11 04:40:02.599016
schema_sha1	b2ffa16900639fbb1cf759621c2aaff402056bc3	2026-01-16 01:55:08.854824	2026-01-16 01:55:08.854826
\.


--
-- Data for Name: bids; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.bids (id, listing_id, user_id, amount, created_at, updated_at) FROM stdin;
1	2	2	1200	2026-01-16 02:26:07.822653	2026-01-16 02:26:07.822653
2	2	3	2000	2026-01-16 02:26:07.866173	2026-01-16 02:26:07.866173
3	3	2	1200	2026-01-16 02:41:25.86759	2026-01-16 02:41:25.86759
4	3	3	1500	2026-01-16 02:42:16.072871	2026-01-16 02:42:16.072871
5	3	2	1700	2026-01-16 02:42:22.491248	2026-01-16 02:42:22.491248
6	6	3	1200	2026-01-16 10:12:32.849354	2026-01-16 10:12:32.849354
7	6	2	1300	2026-01-16 10:12:39.354797	2026-01-16 10:12:39.354797
8	6	2	1400	2026-01-16 10:12:46.96256	2026-01-16 10:12:46.96256
9	6	3	1500	2026-01-16 10:12:52.139422	2026-01-16 10:12:52.139422
10	6	3	3000	2026-01-16 10:12:59.108651	2026-01-16 10:12:59.108651
11	6	2	4100	2026-01-16 10:14:00.726313	2026-01-16 10:14:00.726313
12	11	2	1200	2026-01-16 17:39:26.647923	2026-01-16 17:39:26.647923
13	13	2	1100	2026-01-16 18:35:07.285857	2026-01-16 18:35:07.285857
14	13	2	1200	2026-01-16 18:35:11.181114	2026-01-16 18:35:11.181114
15	13	2	1300	2026-01-16 18:35:15.064378	2026-01-16 18:35:15.064378
16	15	2	1500	2026-01-16 18:41:05.144963	2026-01-16 18:41:05.144963
17	15	2	1800	2026-01-16 18:41:11.012766	2026-01-16 18:41:11.012766
18	16	2	1200	2026-01-16 19:52:56.569514	2026-01-16 19:52:56.569514
19	16	4	1500	2026-01-16 19:53:04.639375	2026-01-16 19:53:04.639375
20	16	2	2000	2026-01-16 19:53:47.808783	2026-01-16 19:53:47.808783
21	16	4	2200	2026-01-16 19:54:03.117025	2026-01-16 19:54:03.117025
22	16	2	2300	2026-01-16 19:54:22.355585	2026-01-16 19:54:22.355585
23	16	2	2400	2026-01-16 19:54:30.464687	2026-01-16 19:54:30.464687
24	16	4	2500	2026-01-16 19:54:38.537926	2026-01-16 19:54:38.537926
25	17	2	1100	2026-01-16 20:01:57.632746	2026-01-16 20:01:57.632746
26	17	3	1200	2026-01-16 20:02:02.564665	2026-01-16 20:02:02.564665
27	17	2	1300	2026-01-16 20:02:08.695503	2026-01-16 20:02:08.695503
28	17	3	1400	2026-01-16 20:02:15.457054	2026-01-16 20:02:15.457054
29	18	2	1200	2026-01-16 20:19:19.792392	2026-01-16 20:19:19.792392
30	18	3	1300	2026-01-16 20:19:23.524494	2026-01-16 20:19:23.524494
31	18	2	1400	2026-01-16 20:19:28.546684	2026-01-16 20:19:28.546684
32	18	3	1500	2026-01-16 20:19:32.943687	2026-01-16 20:19:32.943687
33	18	2	1600	2026-01-16 20:19:37.001631	2026-01-16 20:19:37.001631
34	18	3	1700	2026-01-16 20:20:52.527735	2026-01-16 20:20:52.527735
35	18	2	1800	2026-01-16 20:21:02.17517	2026-01-16 20:21:02.17517
36	19	2	1200	2026-01-16 20:44:23.744318	2026-01-16 20:44:23.744318
37	19	3	1300	2026-01-16 20:44:27.873595	2026-01-16 20:44:27.873595
38	19	2	2000	2026-01-16 20:45:17.12872	2026-01-16 20:45:17.12872
39	20	2	1200	2026-01-16 20:50:14.897001	2026-01-16 20:50:14.897001
40	20	3	1300	2026-01-16 20:50:27.620534	2026-01-16 20:50:27.620534
41	21	2	1200	2026-01-16 21:39:51.439982	2026-01-16 21:39:51.439982
42	21	3	1300	2026-01-16 21:40:00.137549	2026-01-16 21:40:00.137549
43	21	2	1400	2026-01-16 21:40:05.553671	2026-01-16 21:40:05.553671
44	21	3	1500	2026-01-16 21:40:11.537721	2026-01-16 21:40:11.537721
45	21	2	1600	2026-01-16 21:59:42.597035	2026-01-16 21:59:42.597035
46	21	3	1800	2026-01-16 22:00:42.32225	2026-01-16 22:00:42.32225
47	21	3	1900	2026-01-16 22:00:48.673467	2026-01-16 22:00:48.673467
48	21	2	2000	2026-01-16 22:00:57.359569	2026-01-16 22:00:57.359569
49	21	3	2100	2026-01-16 22:11:35.136561	2026-01-16 22:11:35.136561
50	21	2	2200	2026-01-16 22:11:40.944416	2026-01-16 22:11:40.944416
51	21	2	2300	2026-01-16 22:11:49.303238	2026-01-16 22:11:49.303238
52	34	4	1050000	2026-01-18 20:40:05.608353	2026-01-18 20:40:05.608353
53	38	10	1000000	2026-01-18 20:57:24.153928	2026-01-18 20:57:24.153928
54	38	10	10001000	2026-01-18 20:57:53.54105	2026-01-18 20:57:53.54105
55	38	4	10001000	2026-01-18 20:58:12.805071	2026-01-18 20:58:12.805071
56	37	4	1050000	2026-01-18 20:59:38.365345	2026-01-18 20:59:38.365345
57	37	4	1100000	2026-01-18 21:00:27.674902	2026-01-18 21:00:27.674902
58	37	3	1200000	2026-01-18 21:00:47.652862	2026-01-18 21:00:47.652862
59	37	4	1250000	2026-01-18 21:24:31.345446	2026-01-18 21:24:31.345446
60	37	3	1300000	2026-01-18 21:24:56.18382	2026-01-18 21:24:56.18382
61	37	3	1350000	2026-01-18 21:25:12.395695	2026-01-18 21:25:12.395695
62	37	4	1400000	2026-01-18 21:25:27.207529	2026-01-18 21:25:27.207529
63	39	3	1000500	2026-01-19 02:56:21.771231	2026-01-19 02:56:21.771231
64	39	4	2000000	2026-01-19 02:56:52.61549	2026-01-19 02:56:52.61549
65	42	10	11000000	2026-01-19 05:43:38.741482	2026-01-19 05:43:38.741482
66	42	3	12000000	2026-01-19 05:44:02.600095	2026-01-19 05:44:02.600095
67	42	10	13000000	2026-01-19 05:44:15.05344	2026-01-19 05:44:15.05344
68	42	3	14000000	2026-01-19 06:14:17.747261	2026-01-19 06:14:17.747261
69	42	10	15000000	2026-01-19 06:24:39.436309	2026-01-19 06:24:39.436309
70	42	3	16000000	2026-01-19 06:24:55.418423	2026-01-19 06:24:55.418423
71	42	3	17000000	2026-01-19 06:25:00.822724	2026-01-19 06:25:00.822724
72	43	3	1050000	2026-01-19 11:52:51.467983	2026-01-19 11:52:51.467983
\.


--
-- Data for Name: listings; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.listings (id, user_id, title, category, condition, seller_note, status, ai_note, created_at, updated_at, start_price, published_at, reserve_price, bid_increment, auction_ends_at, buy_now_price) FROM stdin;
2	1	Test Auction	\N	\N	test	0	\N	2026-01-16 02:25:57.347928	2026-01-16 02:25:57.347928	1000.0	2026-01-16 02:25:57.340454	\N	100.0	2026-01-16 02:26:27.340863	5000
3	1	Test Auction-3	\N	\N	test	0	\N	2026-01-16 02:39:34.307261	2026-01-16 02:39:34.307261	1000.0	2026-01-16 02:39:34.223893	\N	100.0	2026-01-16 02:42:34.224087	5000
4	1	Test Auction-4\n  	\N	\N	test	0	\N	2026-01-16 02:53:00.824679	2026-01-16 02:53:00.824679	1000.0	2026-01-16 02:53:00.818026	\N	100.0	2026-01-16 02:56:00.818492	5000
5	1	Test Auction-5\n  \n  	\N	\N	test	0	\N	2026-01-16 02:56:41.110694	2026-01-16 02:56:41.110694	1000.0	2026-01-16 02:56:41.104748	\N	100.0	2026-01-16 02:59:41.105037	5000
6	1	Test Auction-6\n  \n  \n  	\N	\N	test	0	\N	2026-01-16 10:11:27.836024	2026-01-16 10:11:27.836024	1000.0	2026-01-16 10:11:27.758093	\N	100.0	2026-01-16 10:14:27.759479	5000
7	1	Test Auction-7\n  	\N	\N	test	0	\N	2026-01-16 10:12:02.293555	2026-01-16 10:12:02.293555	1000.0	2026-01-16 10:12:02.27265	\N	100.0	2026-01-16 10:15:02.274532	5000
8	1	Test Auction-8\n  \n  	\N	\N	test	0	\N	2026-01-16 16:57:11.555444	2026-01-16 16:57:11.555444	1000.0	2026-01-16 16:57:11.408267	\N	100.0	2026-01-16 17:00:11.410564	5000
9	1	Test Auction-8	\N	\N	test	0	\N	2026-01-16 17:14:37.040778	2026-01-16 17:14:37.040778	1000.0	2026-01-16 17:14:37.015293	\N	100.0	2026-01-16 17:17:37.016032	5000
10	1	Test Auction-9\n  	\N	\N	test	0	\N	2026-01-16 17:29:05.921894	2026-01-16 17:29:05.921894	1000.0	2026-01-16 17:29:05.255357	\N	100.0	2026-01-16 17:32:05.255624	5000
11	1	Test Auction-10\n  \n  	\N	\N	test	0	\N	2026-01-16 17:38:51.223341	2026-01-16 17:38:51.223341	1000.0	2026-01-16 17:38:51.14843	\N	100.0	2026-01-16 17:41:51.151963	5000
12	1	Test Auction-11  	\N	\N	test	0	\N	2026-01-16 18:31:23.127578	2026-01-16 18:31:23.127578	1000.0	2026-01-16 18:31:23.087446	\N	100.0	2026-01-16 18:34:23.088814	5000
14	1	Test Auction-11  	\N	\N	test	0	\N	2026-01-16 18:39:39.025767	2026-01-16 18:39:39.025767	1000.0	2026-01-16 18:39:39.010565	\N	100.0	2026-01-16 18:42:39.011751	5000
15	1	Test Auction-11  	\N	\N	test	0	\N	2026-01-16 18:40:41.633552	2026-01-16 18:40:41.633552	1000.0	2026-01-16 18:40:41.619149	\N	100.0	2026-01-16 18:43:41.619612	5000
16	1	Test Auction-15  	\N	\N	test	0	\N	2026-01-16 19:52:04.49966	2026-01-16 19:52:04.49966	1000.0	2026-01-16 19:52:04.44412	\N	100.0	2026-01-16 19:55:04.44503	5000
17	1	Test Auction-17  	\N	\N	test	0	\N	2026-01-16 20:01:20.234821	2026-01-16 20:01:20.234821	1000.0	2026-01-16 20:01:20.205157	\N	100.0	2026-01-16 20:04:20.206057	5000
18	1	Test Auction-18  	\N	\N	test	0	\N	2026-01-16 20:18:16.429833	2026-01-16 20:18:16.429833	1000.0	2026-01-16 20:18:16.420723	\N	100.0	2026-01-16 20:21:16.420773	5000
19	1	Test Auction-19  	\N	\N	test	0	\N	2026-01-16 20:43:53.876433	2026-01-16 20:43:53.876433	1000.0	2026-01-16 20:43:53.870372	\N	100.0	2026-01-16 20:46:53.870469	5000
20	1	Test Auction-19  	\N	\N	test	0	\N	2026-01-16 20:49:54.208374	2026-01-16 20:49:54.208374	1000.0	2026-01-16 20:49:54.19787	\N	100.0	2026-01-16 20:52:54.198321	5000
21	1	Test Auction-19  	\N	\N	test	0	\N	2026-01-16 21:39:08.046358	2026-01-16 21:39:08.046358	1000.0	2026-01-16 21:39:07.996558	\N	100.0	2026-01-17 00:39:07.99768	5000
27	10	aaa	aaa	new	aaa	4	Kết quả mô phỏng để demo. Trạng thái: uncertain, độ tin cậy: 0.8.	2026-01-18 19:37:23.983549	2026-01-18 19:37:33.366025	\N	\N	\N	\N	\N	\N
22	10	scscs	c	c	acndskcn	4	Lỗi khi gọi AI: undefined method `dig' for an instance of String	2026-01-18 18:06:56.166135	2026-01-18 18:10:54.005508	\N	\N	\N	\N	\N	\N
28	10	avsdv	vav	new	vvavv	4	Lỗi khi gọi AI: undefined local variable or method `verified' for class AiAuthenticationService	2026-01-18 19:40:34.82049	2026-01-18 19:40:43.042388	\N	\N	\N	\N	\N	\N
23	10	scscsác	c	cd	avavvav	4	Lỗi khi gọi AI: undefined method `ai_verifications' for an instance of Listing	2026-01-18 18:29:15.085976	2026-01-18 18:29:17.538997	\N	\N	\N	\N	\N	\N
24	4	cái cân	vật phẩm	tốt	accacac	4	Lỗi khi gọi AI: undefined method `ai_verifications' for an instance of Listing	2026-01-18 18:35:43.869852	2026-01-18 18:35:47.37269	\N	\N	\N	\N	\N	\N
25	10	scscs	c	c	svsdvf	4	Lỗi khi gọi AI: undefined method `ai_verifications' for an instance of Listing	2026-01-18 18:54:34.310041	2026-01-18 18:54:46.061454	\N	\N	\N	\N	\N	\N
29	10	aa	aaaa	new	aaaa	4	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.83.	2026-01-18 19:42:00.778731	2026-01-18 19:42:08.37409	\N	\N	\N	\N	\N	\N
13	1	Test Auction-11  	vật phẩm	tốt	test	4	Lỗi khi gọi AI: undefined method `ai_verifications' for an instance of Listing	2026-01-16 18:34:57.7047	2026-01-18 19:00:10.011589	1000.0	2026-01-16 18:34:57.697156	\N	100.0	2026-01-16 18:37:57.697403	5000
26	3	cái cân	a	new	ccc	4	Lỗi khi gọi AI: undefined method `ai_verifications' for an instance of Listing	2026-01-18 19:10:07.567019	2026-01-18 19:12:50.636991	\N	\N	\N	\N	\N	\N
30	10	jj	gggg	new	ggggg	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.85.	2026-01-18 19:47:37.713717	2026-01-18 19:47:45.026862	\N	\N	\N	\N	\N	\N
31	10	aa	aa	new	aaa	4	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.74.	2026-01-18 20:02:52.324041	2026-01-18 20:02:57.474907	\N	\N	\N	\N	\N	\N
36	10	test3	cân	new	cân xịn	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.74.	2026-01-18 20:49:53.00856	2026-01-18 20:49:58.072424	100000.0	2026-01-19 03:49:00	\N	50000.0	2026-01-16 03:49:00	5000000
32	10	aaa	cdcdc	used	ccdcd	4	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.74.	2026-01-18 20:08:56.181794	2026-01-18 20:09:02.772047	10000.0	\N	\N	0.03	2026-01-24 03:08:00	50000000
39	10	hina	thời trang	new	hinayo	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.96.	2026-01-19 02:55:06.36277	2026-01-19 02:55:09.90914	1000000.0	2026-01-19 09:54:00	\N	\N	2026-01-24 09:54:00	50000000
33	10	aaa	c	used	cccc	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.92.	2026-01-18 20:11:23.279077	2026-01-18 20:11:25.443585	1000000.0	\N	\N	50000.0	2026-01-18 08:11:00	5000000
35	10	con lười	animal	new	lười thôi	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.72.	2026-01-18 20:44:32.220164	2026-01-18 20:44:37.642798	10000.0	2026-01-19 03:44:00	\N	1000.0	2026-01-23 03:44:00	100000
34	10	túi sách vitual	thời trang	new	đây là cái túi sách	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.89.	2026-01-18 20:34:06.577718	2026-01-18 20:36:04.460542	1000000.0	2026-01-19 03:33:00	\N	50000.0	2026-01-21 03:33:00	10000000
37	10	test4	test	new	test	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.86.	2026-01-18 20:53:29.329926	2026-01-18 20:53:35.338167	1000000.0	2026-01-19 03:53:00	\N	50000.0	2026-01-23 03:53:00	5000000
38	10	hhhhh	test	used	test	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.74.	2026-01-18 20:55:21.024111	2026-01-18 20:56:56.241537	1000000.0	2026-01-19 03:55:00	\N	\N	2026-01-24 03:58:00	50000000
40	3	test	test	used	test	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.8.	2026-01-19 02:58:02.758031	2026-01-19 02:58:05.063738	1000000.0	2026-01-19 09:57:00	\N	\N	2026-01-23 09:57:00	5000000
41	3	gấu	gấu	new	gấu	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.72.	2026-01-19 02:59:18.842557	2026-01-19 02:59:22.020282	1100000.0	2026-01-19 09:58:00	\N	50000.0	2026-01-23 09:59:00	5000000
42	3	Hinayo1	hina	new	hinayo	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.97.	2026-01-19 03:00:15.155536	2026-01-19 06:09:12.395726	10000000.0	2026-01-19 09:59:00	\N	1000000.0	2026-01-22 10:00:00	50000000
43	11	túi sách	thời trang	new	sản phẩm túi	2	Kết quả mô phỏng để demo. Trạng thái: verified, độ tin cậy: 0.79.	2026-01-19 11:50:52.052675	2026-01-19 11:50:59.176045	1000000.0	2026-01-19 18:50:00	\N	50000.0	2026-01-21 22:54:00	5000000
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.notifications (id, recipient_id, actor_id, action, notifiable_type, notifiable_id, message, url, read_at, created_at, updated_at) FROM stdin;
4	4	2	0	Listing	16	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-15  ”.	/listings/16	2026-01-16 19:54:54.787936	2026-01-16 19:54:22.39524	2026-01-16 19:54:54.794178
1	2	4	0	Listing	16	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-15  ”.	/listings/16	2026-01-16 20:01:45.676128	2026-01-16 19:53:04.687653	2026-01-16 20:01:45.67916
3	2	4	0	Listing	16	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-15  ”.	/listings/16	2026-01-16 20:01:46.302137	2026-01-16 19:54:03.14834	2026-01-16 20:01:46.302372
5	2	4	0	Listing	16	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-15  ”.	/listings/16	2026-01-16 20:01:47.328941	2026-01-16 19:54:38.573538	2026-01-16 20:01:47.329726
2	4	2	0	Listing	16	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-15  ”.	/listings/16	2026-01-16 20:07:55.264053	2026-01-16 19:53:47.866931	2026-01-16 19:53:47.866931
6	4	1	1	Listing	16	Bạn đã thắng đấu giá sản phẩm “Test Auction-15  ”. Vui lòng vào đơn hàng để thanh toán.	/orders/13	2026-01-16 20:07:55.264053	2026-01-16 19:55:05.179807	2026-01-16 19:55:05.179807
7	4	\N	3	Order	13	Admin đã xác nhận thanh toán cho đơn #13. Đơn hàng đã hoàn tất.	/orders/13	2026-01-16 20:07:55.264053	2026-01-16 19:56:06.984233	2026-01-16 19:56:06.984233
9	3	2	0	Listing	17	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-17  ”.	/listings/17	2026-01-16 20:19:09.20832	2026-01-16 20:02:08.723668	2026-01-16 20:02:08.723668
11	3	1	1	Listing	17	Bạn đã thắng đấu giá sản phẩm “Test Auction-17  ”. Vui lòng vào đơn hàng để thanh toán.	/orders/14	2026-01-16 20:19:09.20832	2026-01-16 20:04:21.429617	2026-01-16 20:04:21.429617
8	2	3	0	Listing	17	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-17  ”.	/listings/17	2026-01-16 20:19:15.159465	2026-01-16 20:02:02.576223	2026-01-16 20:02:02.576223
10	2	3	0	Listing	17	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-17  ”.	/listings/17	2026-01-16 20:19:15.159465	2026-01-16 20:02:15.499825	2026-01-16 20:02:15.499825
12	2	3	0	Listing	18	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-18  ”.	/listings/18	2026-01-16 20:44:11.451178	2026-01-16 20:19:23.557179	2026-01-16 20:19:23.557179
14	2	3	0	Listing	18	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-18  ”.	/listings/18	2026-01-16 20:44:11.451178	2026-01-16 20:19:32.969017	2026-01-16 20:19:32.969017
16	2	3	0	Listing	18	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-18  ”.	/listings/18	2026-01-16 20:44:11.451178	2026-01-16 20:20:52.558756	2026-01-16 20:20:52.558756
18	2	1	1	Listing	18	Bạn đã thắng đấu giá sản phẩm “Test Auction-18  ”. Vui lòng vào đơn hàng để thanh toán.	/orders/15	2026-01-16 20:44:11.451178	2026-01-16 20:21:18.01604	2026-01-16 20:21:18.01604
13	3	2	0	Listing	18	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-18  ”.	/listings/18	2026-01-16 20:44:18.811939	2026-01-16 20:19:28.607282	2026-01-16 20:19:28.607282
15	3	2	0	Listing	18	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-18  ”.	/listings/18	2026-01-16 20:44:18.811939	2026-01-16 20:19:37.025275	2026-01-16 20:19:37.025275
17	3	2	0	Listing	18	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-18  ”.	/listings/18	2026-01-16 20:44:18.811939	2026-01-16 20:21:02.191652	2026-01-16 20:21:02.191652
19	2	3	0	Listing	19	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/19	\N	2026-01-16 20:44:27.940582	2026-01-16 20:44:27.940582
21	2	1	1	Listing	19	Bạn đã thắng đấu giá sản phẩm “Test Auction-19  ”. Vui lòng vào đơn hàng để thanh toán.	/orders/16	\N	2026-01-16 20:46:55.344154	2026-01-16 20:46:55.344154
22	2	3	0	Listing	20	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/20	\N	2026-01-16 20:50:27.629583	2026-01-16 20:50:27.629583
24	2	3	0	Listing	21	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/21	\N	2026-01-16 21:40:00.199602	2026-01-16 21:40:00.199602
26	2	3	0	Listing	21	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/21	\N	2026-01-16 21:40:11.557061	2026-01-16 21:40:11.557061
28	2	3	0	Listing	21	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/21	\N	2026-01-16 22:00:42.391267	2026-01-16 22:00:42.391267
30	2	3	0	Listing	21	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/21	\N	2026-01-16 22:11:35.211566	2026-01-16 22:11:35.211566
32	2	1	1	Listing	21	Bạn đã thắng đấu giá sản phẩm “Test Auction-19  ”. Vui lòng vào đơn hàng để thanh toán.	/orders/18	\N	2026-01-18 17:25:12.278148	2026-01-18 17:25:12.278148
33	2	1	1	Listing	13	Bạn đã thắng đấu giá sản phẩm “Test Auction-11  ”. Vui lòng vào đơn hàng để thanh toán.	/orders/19	\N	2026-01-18 18:59:09.885676	2026-01-18 18:59:09.885676
34	4	10	2	Listing	34	Bạn đã mua ngay sản phẩm “túi sách vitual”. Vui lòng vào đơn hàng để thanh toán.	/orders/20	\N	2026-01-18 20:40:30.154919	2026-01-18 20:40:30.154919
36	4	3	0	Listing	37	Có người đã trả giá cao hơn bạn cho sản phẩm “test4”.	/listings/37	\N	2026-01-18 21:00:47.664967	2026-01-18 21:00:47.664967
38	4	3	0	Listing	37	Có người đã trả giá cao hơn bạn cho sản phẩm “test4”.	/listings/37	\N	2026-01-18 21:24:56.195645	2026-01-18 21:24:56.195645
20	3	2	0	Listing	19	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/19	2026-01-19 03:31:59.388295	2026-01-16 20:45:17.159707	2026-01-16 20:45:17.159707
23	3	1	1	Listing	20	Bạn đã thắng đấu giá sản phẩm “Test Auction-19  ”. Vui lòng vào đơn hàng để thanh toán.	/orders/17	2026-01-19 03:31:59.388295	2026-01-16 20:52:54.95636	2026-01-16 20:52:54.95636
25	3	2	0	Listing	21	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/21	2026-01-19 03:31:59.388295	2026-01-16 21:40:05.640962	2026-01-16 21:40:05.640962
27	3	2	0	Listing	21	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/21	2026-01-19 03:31:59.388295	2026-01-16 21:59:42.719409	2026-01-16 21:59:42.719409
29	3	2	0	Listing	21	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/21	2026-01-19 03:31:59.388295	2026-01-16 22:00:57.394405	2026-01-16 22:00:57.394405
31	3	2	0	Listing	21	Có người đã trả giá cao hơn bạn cho sản phẩm “Test Auction-19  ”.	/listings/21	2026-01-19 03:31:59.388295	2026-01-16 22:11:40.970405	2026-01-16 22:11:40.970405
35	3	10	2	Listing	38	Bạn đã mua ngay sản phẩm “hhhhh”. Vui lòng vào đơn hàng để thanh toán.	/orders/21	2026-01-19 03:31:59.388295	2026-01-18 20:58:57.560205	2026-01-18 20:58:57.560205
37	3	4	0	Listing	37	Có người đã trả giá cao hơn bạn cho sản phẩm “test4”.	/listings/37	2026-01-19 03:31:59.388295	2026-01-18 21:24:31.412706	2026-01-18 21:24:31.412706
39	3	4	0	Listing	37	Có người đã trả giá cao hơn bạn cho sản phẩm “test4”.	/listings/37	2026-01-19 03:31:59.388295	2026-01-18 21:25:27.238484	2026-01-18 21:25:27.238484
40	3	10	2	Listing	37	Bạn đã mua ngay sản phẩm “test4”. Vui lòng vào đơn hàng để thanh toán.	/orders/22	2026-01-19 03:31:59.388295	2026-01-18 21:25:33.56226	2026-01-18 21:25:33.56226
41	3	\N	3	Order	22	Admin đã xác nhận thanh toán cho đơn #22. Đơn hàng đã hoàn tất.	/orders/22	2026-01-19 03:31:59.388295	2026-01-18 21:32:16.093761	2026-01-18 21:32:16.093761
42	3	10	2	Listing	35	Bạn đã mua ngay sản phẩm “con lười”. Vui lòng vào đơn hàng để thanh toán.	/orders/23	2026-01-19 03:31:59.388295	2026-01-18 21:40:35.398002	2026-01-18 21:40:35.398002
43	3	\N	3	Order	23	Admin đã xác nhận thanh toán cho đơn #23. Đơn hàng đã hoàn tất.	/orders/23	2026-01-19 03:31:59.388295	2026-01-18 21:47:05.608151	2026-01-18 21:47:05.608151
44	3	4	0	Listing	39	Có người đã trả giá cao hơn bạn cho sản phẩm “hina”.	/listings/39	2026-01-19 03:31:59.388295	2026-01-19 02:56:52.651445	2026-01-19 02:56:52.651445
45	3	\N	3	Order	21	Admin đã xác nhận thanh toán cho đơn #21. Đơn hàng đã hoàn tất.	/orders/21	\N	2026-01-19 05:39:51.814409	2026-01-19 05:39:51.814409
46	10	3	0	Listing	42	Có người đã trả giá cao hơn bạn cho sản phẩm “Hinayo”.	/listings/42	\N	2026-01-19 05:44:02.60753	2026-01-19 05:44:02.60753
47	10	3	0	Listing	42	Có người đã trả giá cao hơn bạn cho sản phẩm “Hinayo1”.	/listings/42	\N	2026-01-19 06:14:17.809768	2026-01-19 06:14:17.809768
48	10	3	0	Listing	42	Có người đã trả giá cao hơn bạn cho sản phẩm “Hinayo1”.	/listings/42	\N	2026-01-19 06:24:55.551804	2026-01-19 06:24:55.551804
49	3	11	2	Listing	43	Bạn đã mua ngay sản phẩm “túi sách”. Vui lòng vào đơn hàng để thanh toán.	/orders/24	\N	2026-01-19 11:53:47.889292	2026-01-19 11:53:47.889292
50	3	\N	3	Order	24	Admin đã xác nhận thanh toán cho đơn #24. Đơn hàng đã hoàn tất.	/orders/24	\N	2026-01-19 11:56:12.306096	2026-01-19 11:56:12.306096
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.orders (id, listing_id, buyer_id, price, kind, status, created_at, updated_at, total, buyer_marked_paid_at, admin_confirmed_paid_at, recipient_name, recipient_phone, shipping_address) FROM stdin;
2	3	2	1700.0	0	1	2026-01-16 02:42:35.196343	2026-01-16 02:49:20.001685	\N	2026-01-16 02:49:13.574226	2026-01-16 02:49:19.999196	\N	\N	\N
3	4	3	5000.0	1	1	2026-01-16 02:53:25.444087	2026-01-16 02:53:43.437689	\N	2026-01-16 02:53:35.956606	2026-01-16 02:53:43.4318	\N	\N	\N
4	5	3	5000.0	1	1	2026-01-16 02:56:52.93158	2026-01-16 02:58:38.347104	\N	2026-01-16 02:57:40.07457	2026-01-16 02:58:38.344921	\N	\N	\N
1	2	3	2000.0	0	1	2026-01-16 02:26:28.244489	2026-01-16 09:51:13.363919	\N	2026-01-16 09:50:56.900587	2026-01-16 09:51:13.36254	\N	\N	\N
5	7	3	5000.0	1	0	2026-01-16 10:13:12.885275	2026-01-16 10:16:18.914809	\N	2026-01-16 10:16:18.902923	\N	\N	\N	\N
6	6	2	4100.0	0	1	2026-01-16 10:14:29.38566	2026-01-16 16:54:41.850708	\N	2026-01-16 16:54:20.674814	2026-01-16 16:54:41.846475	\N	\N	\N
7	8	2	5000.0	1	1	2026-01-16 16:57:26.359647	2026-01-16 17:09:05.142505	\N	2026-01-16 16:59:19.160829	2026-01-16 17:09:05.137722	\N	\N	\N
8	9	2	5000.0	1	1	2026-01-16 17:15:13.179668	2026-01-16 17:28:22.152721	\N	2026-01-16 17:15:25.349654	2026-01-16 17:28:22.145698	\N	\N	\N
9	10	4	5000.0	1	1	2026-01-16 17:30:05.527616	2026-01-16 17:30:52.364532	\N	2026-01-16 17:30:21.033173	2026-01-16 17:30:52.357128	\N	\N	\N
10	11	2	5000.0	1	1	2026-01-16 17:39:31.093756	2026-01-16 17:41:28.037558	\N	2026-01-16 17:39:48.270279	2026-01-16 17:41:28.036481	\N	\N	\N
11	14	2	5000.0	1	1	2026-01-16 18:40:01.572881	2026-01-16 18:40:29.952069	\N	2026-01-16 18:40:22.168999	2026-01-16 18:40:29.946848	phong	01234567	scja
12	15	2	1800.0	0	0	2026-01-16 18:43:42.242914	2026-01-16 18:45:04.656359	\N	\N	\N	a		sdsđ
13	16	4	2500.0	0	1	2026-01-16 19:55:05.135527	2026-01-16 19:56:06.972773	\N	2026-01-16 19:55:50.117647	2026-01-16 19:56:06.970969	abc	2132	scasdc
14	17	3	1400.0	0	0	2026-01-16 20:04:21.422395	2026-01-16 20:04:21.422395	\N	\N	\N	\N	\N	\N
15	18	2	1800.0	0	0	2026-01-16 20:21:17.994868	2026-01-16 20:21:17.994868	\N	\N	\N	\N	\N	\N
16	19	2	2000.0	0	0	2026-01-16 20:46:55.32267	2026-01-16 20:46:55.32267	\N	\N	\N	\N	\N	\N
17	20	3	1300.0	0	0	2026-01-16 20:52:54.951174	2026-01-16 20:52:54.951174	\N	\N	\N	\N	\N	\N
18	21	2	2300.0	0	0	2026-01-18 17:25:12.253546	2026-01-18 17:25:12.253546	\N	\N	\N	\N	\N	\N
19	13	2	1300.0	0	0	2026-01-18 18:59:09.869757	2026-01-18 18:59:09.869757	\N	\N	\N	\N	\N	\N
20	34	4	10000000.0	1	0	2026-01-18 20:40:30.12215	2026-01-18 20:40:30.12215	\N	\N	\N	\N	\N	\N
22	37	3	5000000.0	1	1	2026-01-18 21:25:33.547392	2026-01-18 21:32:16.048018	\N	2026-01-18 21:32:07.649093	2026-01-18 21:32:16.044674	phong	01234567	aaaaaaa
23	35	3	100000.0	1	1	2026-01-18 21:40:35.386713	2026-01-18 21:47:05.56533	\N	2026-01-18 21:46:42.121836	2026-01-18 21:47:05.563801	aaaa	01234567	âccacac
21	38	3	50000000.0	1	1	2026-01-18 20:58:57.547267	2026-01-19 05:39:51.619208	\N	2026-01-19 05:39:46.28648	2026-01-19 05:39:51.61351	hina cute	0123456789	vn
24	43	3	5000000.0	1	1	2026-01-19 11:53:47.864193	2026-01-19 11:56:12.293045	\N	2026-01-19 11:56:02.839746	2026-01-19 11:56:12.284683	phong	012345	HN
\.


--
-- Data for Name: otps; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.otps (id, user_id, purpose, code_digest, expires_at, used_at, created_at, updated_at) FROM stdin;
1	2	verify_email	$2a$12$wS91HEZonzTjvqCXoEYKe.eth5o/IDCUNHCkHTORs7Pzf9Ojj52pG	2026-01-16 02:51:12.644755	2026-01-16 02:41:18.578491	2026-01-16 02:41:12.662769	2026-01-16 02:41:18.579964
2	3	verify_email	$2a$12$GWktGuWzCozRxuC9SwVzw.xLqRei7xSBQNAcFR34GUNEN7VkqrezO	2026-01-16 02:52:01.984017	2026-01-16 02:42:07.450709	2026-01-16 02:42:01.990303	2026-01-16 02:42:07.451546
3	4	verify_email	$2a$12$g9fJjdPWSQyDYZdRD2nZU.r9To1Njlzb/BuCd091VM4Vmo6zHS0t6	2026-01-16 02:57:40.072884	2026-01-16 02:47:49.922123	2026-01-16 02:47:40.150122	2026-01-16 02:47:49.924589
4	5	verify_email	$2a$12$l6XbtHNmmwvNg7iWSJUeMuI4Led.fgzfWmOXX6.RcsWCIve.AUnsW	2026-01-18 17:08:24.032671	2026-01-18 16:58:33.800543	2026-01-18 16:58:24.045317	2026-01-18 16:58:33.801283
5	6	verify_email	$2a$12$HjTl6CrpM9qDi8B1LwvtzOX./PNOqK8QGpHG5br8cdhU6B4GBxLuS	2026-01-18 17:30:17.010795	2026-01-18 17:20:24.985842	2026-01-18 17:20:17.017462	2026-01-18 17:20:24.986702
6	7	verify_email	$2a$12$s8/S4KYIhW/ejbE8yGPJQesBtg9lni2OkmAJ0wPy7YelAEqEb8dUK	2026-01-18 17:40:45.038851	2026-01-18 17:31:31.00258	2026-01-18 17:30:45.059862	2026-01-18 17:31:31.004785
7	9	verify_email	$2a$12$2AXXil.mrGMbGaY34PdhsufPc883nsnbAwOEpU4rY0rpGa8wnLbGm	2026-01-18 18:07:10.593305	\N	2026-01-18 17:57:10.601095	2026-01-18 17:57:10.601095
8	9	verify_email	$2a$12$t/ncH2IF1fHBJal7AIOV0OQBHw1WsQeLp5ac5XnyyQRwS2y5lOOUS	2026-01-18 18:12:27.557123	2026-01-18 18:03:06.208789	2026-01-18 18:02:27.569721	2026-01-18 18:03:06.209611
9	10	verify_email	$2a$12$3PErdpqRfjDQGfMqaStNvOolIB/R/im8bak25ej.DLOvAmOlPmriG	2026-01-18 18:13:58.4222	2026-01-18 18:04:05.458795	2026-01-18 18:03:58.434361	2026-01-18 18:04:05.459855
10	1	verify_email	$2a$12$XTmYBPWdnKKy8fE/3JE7iOIQCEc322PrH/tXo08thSJNTSQUeY60O	2026-01-18 19:08:45.651707	2026-01-18 18:58:52.762956	2026-01-18 18:58:45.665008	2026-01-18 18:58:52.763914
11	11	verify_email	$2a$12$DhXCJ8elhzqhbhkkTueDGeATZ52tqaRyfMwh/8D0DF05cVnSlnBUS	2026-01-19 11:57:38.083196	2026-01-19 11:47:47.961855	2026-01-19 11:47:38.111803	2026-01-19 11:47:47.963908
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.schema_migrations (version) FROM stdin;
20260111102259
20260111181935
20260111184409
20260111193933
20260111195804
20260111211338
20260111213501
20260111213509
20260113093159
20260113173519
20260113173852
20260113174550
20260113181843
20260113182135
20260113235716
20260115213540
20260116182655
20260116191613
\.


--
-- Data for Name: system_settings; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.system_settings (id, ai_threshold, commission_percent, min_bid_step, created_at, updated_at) FROM stdin;
1	0.85	5.0	10.0	2026-01-19 12:11:47.638916	2026-01-19 12:11:47.638916
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: thieuphong
--

COPY public.users (id, email, encrypted_password, reset_password_token, reset_password_sent_at, remember_created_at, name, role, created_at, updated_at, provider, uid, email_verified_at) FROM stdin;
2	buyer1@test.com	$2a$12$qdm/0WOzkMWB4igkZjEukezSTR9E0Fwm2Z7g/xqFNNEbMdTwoGqyu	\N	\N	\N	Buyer 1	0	2026-01-16 02:23:21.085258	2026-01-16 02:41:18.612823	\N	\N	2026-01-16 02:41:18.609604
5	buyer3@gmail.com	$2a$12$C17hQ4w8jqh9qFqNTYl9I.MX2zFQgIXLpeFM9Ihl8unCdFiSep1iy	\N	\N	\N	\N	0	2026-01-18 16:58:23.711082	2026-01-18 16:58:33.813005	\N	\N	2026-01-18 16:58:33.812224
6	buyertest@mail.com	$2a$12$tp8OeknhnWTdBhJbemICeeUpFfjWanAZH1twbOnZ/t3DlZ5rt.YiS	\N	\N	\N	\N	0	2026-01-18 17:20:16.729227	2026-01-18 17:20:24.994552	\N	\N	2026-01-18 17:20:24.994179
3	buyer2@test.com	$2a$12$z1S.lg1HxR3D61lcUZ1h0.RQe4QHMk2L.9SzAFKwDV2lV.xPFcf5y	\N	\N	\N	Buyer 2	0	2026-01-16 02:23:21.343067	2026-01-18 17:29:37.541499	\N	\N	2026-01-16 02:42:07.456276
7	testu2@test.com	$2a$12$zPzCm75c899ayM6U38P4ueYufqyjp1Sp7zKUG3Zcotb7UEWO228mC	\N	\N	\N	\N	0	2026-01-18 17:30:44.769162	2026-01-18 17:31:31.010694	\N	\N	2026-01-18 17:31:31.00967
8	thieuphong0011@gmail.com	$2a$12$cAVxk8K7.CRlZfGaJDdtiuipHUYZGnNMwTJ9tLVj0AZ.5IptvvaaO	\N	\N	\N	Thiều Quang Phong	0	2026-01-18 17:56:33.308784	2026-01-18 17:56:33.308784	google_oauth2	109566905873986921923	2026-01-18 17:56:33.304212
9	buyer5@test.com	$2a$12$JRSkYvDxK9WyB/gegiJ.P.uFj2cqzp7/oowwjf0RjkcOmrHgHKfby	\N	\N	\N	\N	0	2026-01-18 17:57:10.321477	2026-01-18 18:03:06.214466	\N	\N	2026-01-18 18:03:06.213946
1	seller@test.com	$2a$12$FvoUi4X8.V6YVV6tGeGvXeL7dk5U/bHv5f0fmH7YPtuKpym4AaEg6	\N	\N	\N	Seller	0	2026-01-16 02:23:20.82276	2026-01-18 18:58:52.773416	\N	\N	2026-01-18 18:58:52.772605
10	tesdk@test.com	$2a$12$4OeXB5CFDZtvv5sstUJuIew.5mPqFtYccCYQX3O.wxrGvja1tATqK	\N	\N	\N	tesk_DK1	0	2026-01-18 18:03:58.147207	2026-01-19 06:10:20.779902	\N	\N	2026-01-18 18:04:05.471354
4	admin@test.com	$2a$12$JRYTUKMEh3/Qb7Gjl7lV8O4nsJhd5Pgy//cX3FRMLz1.z3JSO386i	\N	\N	\N	admin	2	2026-01-16 02:47:17.204559	2026-01-19 06:10:51.840331	\N	\N	2026-01-16 02:47:49.953827
11	test_user@mail.com	$2a$12$LzMcb6YCBt5cx4qJoKa27ugLc0hVl4xGg9cDaLmVIN8ZVezEu9xwS	\N	\N	\N	phong	0	2026-01-19 11:47:37.7256	2026-01-19 11:47:47.969328	\N	\N	2026-01-19 11:47:47.968305
12	admin@snapbid.local	$2a$12$9/5QGFtOmfywKlCOYcY0m.TcjxRT74tdMxhuPjQWDzeaxQSaXCLxu	\N	\N	\N	Admin	2	2026-01-19 12:11:47.949655	2026-01-19 12:11:47.949655	\N	\N	2026-01-19 12:11:47.948049
13	cs@snapbid.local	$2a$12$Qklk6TlRllCZk/1l29XCB.L06GX2.Ad0aBwYyk9S8TizVqzxcwIsm	\N	\N	\N	Customer Support	1	2026-01-19 12:11:48.22524	2026-01-19 12:11:48.22524	\N	\N	2026-01-19 12:11:48.215302
\.


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.active_storage_attachments_id_seq', 60, true);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.active_storage_blobs_id_seq', 60, true);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.active_storage_variant_records_id_seq', 16, true);


--
-- Name: ai_verifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.ai_verifications_id_seq', 1, false);


--
-- Name: bids_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.bids_id_seq', 72, true);


--
-- Name: listings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.listings_id_seq', 43, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.notifications_id_seq', 50, true);


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.orders_id_seq', 24, true);


--
-- Name: otps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.otps_id_seq', 11, true);


--
-- Name: system_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.system_settings_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: thieuphong
--

SELECT pg_catalog.setval('public.users_id_seq', 13, true);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: ai_verifications ai_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.ai_verifications
    ADD CONSTRAINT ai_verifications_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: bids bids_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT bids_pkey PRIMARY KEY (id);


--
-- Name: listings listings_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT listings_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: otps otps_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.otps
    ADD CONSTRAINT otps_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: system_settings system_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.system_settings
    ADD CONSTRAINT system_settings_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_ai_verifications_on_listing_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_ai_verifications_on_listing_id ON public.ai_verifications USING btree (listing_id);


--
-- Name: index_bids_on_listing_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_bids_on_listing_id ON public.bids USING btree (listing_id);


--
-- Name: index_bids_on_listing_id_and_amount; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_bids_on_listing_id_and_amount ON public.bids USING btree (listing_id, amount);


--
-- Name: index_bids_on_user_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_bids_on_user_id ON public.bids USING btree (user_id);


--
-- Name: index_listings_on_published_at; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_listings_on_published_at ON public.listings USING btree (published_at);


--
-- Name: index_listings_on_status; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_listings_on_status ON public.listings USING btree (status);


--
-- Name: index_listings_on_user_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_listings_on_user_id ON public.listings USING btree (user_id);


--
-- Name: index_notifications_on_actor_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_notifications_on_actor_id ON public.notifications USING btree (actor_id);


--
-- Name: index_notifications_on_notifiable; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_notifications_on_notifiable ON public.notifications USING btree (notifiable_type, notifiable_id);


--
-- Name: index_notifications_on_recipient_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_notifications_on_recipient_id ON public.notifications USING btree (recipient_id);


--
-- Name: index_notifications_on_recipient_id_and_created_at; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_notifications_on_recipient_id_and_created_at ON public.notifications USING btree (recipient_id, created_at);


--
-- Name: index_notifications_on_recipient_id_and_read_at; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_notifications_on_recipient_id_and_read_at ON public.notifications USING btree (recipient_id, read_at);


--
-- Name: index_orders_on_buyer_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_orders_on_buyer_id ON public.orders USING btree (buyer_id);


--
-- Name: index_orders_on_listing_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE UNIQUE INDEX index_orders_on_listing_id ON public.orders USING btree (listing_id);


--
-- Name: index_otps_on_user_id; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE INDEX index_otps_on_user_id ON public.otps USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: thieuphong
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: notifications fk_rails_06a39bb8cc; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_06a39bb8cc FOREIGN KEY (actor_id) REFERENCES public.users(id);


--
-- Name: otps fk_rails_18565c823d; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.otps
    ADD CONSTRAINT fk_rails_18565c823d FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: ai_verifications fk_rails_2b886331cf; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.ai_verifications
    ADD CONSTRAINT fk_rails_2b886331cf FOREIGN KEY (listing_id) REFERENCES public.listings(id);


--
-- Name: bids fk_rails_448996d4c5; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT fk_rails_448996d4c5 FOREIGN KEY (listing_id) REFERENCES public.listings(id);


--
-- Name: notifications fk_rails_4aea6afa11; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT fk_rails_4aea6afa11 FOREIGN KEY (recipient_id) REFERENCES public.users(id);


--
-- Name: orders fk_rails_62f2818489; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_62f2818489 FOREIGN KEY (listing_id) REFERENCES public.listings(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: listings fk_rails_baa008bfd2; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.listings
    ADD CONSTRAINT fk_rails_baa008bfd2 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: orders fk_rails_d3775977e3; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_rails_d3775977e3 FOREIGN KEY (buyer_id) REFERENCES public.users(id);


--
-- Name: bids fk_rails_e173de2ed3; Type: FK CONSTRAINT; Schema: public; Owner: thieuphong
--

ALTER TABLE ONLY public.bids
    ADD CONSTRAINT fk_rails_e173de2ed3 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

\unrestrict geQ32cRgAafsUBjAD4kFjMpLp2RZmPlLAxQ2uNAQVIQcWtyCaEiH1UOM55rxrfN

