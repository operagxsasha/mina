--
-- PostgreSQL database dump
--

-- Dumped from database version 14.13
-- Dumped by pg_dump version 15.6

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
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: authorization_kind_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.authorization_kind_type AS ENUM (
    'None_given',
    'Signature',
    'Proof'
);


ALTER TYPE public.authorization_kind_type OWNER TO postgres;

--
-- Name: chain_status_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.chain_status_type AS ENUM (
    'canonical',
    'orphaned',
    'pending'
);


ALTER TYPE public.chain_status_type OWNER TO postgres;

--
-- Name: internal_command_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.internal_command_type AS ENUM (
    'fee_transfer_via_coinbase',
    'fee_transfer',
    'coinbase'
);


ALTER TYPE public.internal_command_type OWNER TO postgres;

--
-- Name: may_use_token; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.may_use_token AS ENUM (
    'No',
    'ParentsOwnToken',
    'InheritFromParent'
);


ALTER TYPE public.may_use_token OWNER TO postgres;

--
-- Name: transaction_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.transaction_status AS ENUM (
    'applied',
    'failed'
);


ALTER TYPE public.transaction_status OWNER TO postgres;

--
-- Name: user_command_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.user_command_type AS ENUM (
    'payment',
    'delegation'
);


ALTER TYPE public.user_command_type OWNER TO postgres;

--
-- Name: zkapp_auth_required_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.zkapp_auth_required_type AS ENUM (
    'none',
    'either',
    'proof',
    'signature',
    'both',
    'impossible'
);


ALTER TYPE public.zkapp_auth_required_type OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_identifiers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_identifiers (
    id integer NOT NULL,
    public_key_id integer NOT NULL,
    token_id integer NOT NULL
);


ALTER TABLE public.account_identifiers OWNER TO postgres;

--
-- Name: account_identifiers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.account_identifiers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.account_identifiers_id_seq OWNER TO postgres;

--
-- Name: account_identifiers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.account_identifiers_id_seq OWNED BY public.account_identifiers.id;


--
-- Name: accounts_accessed; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts_accessed (
    ledger_index integer NOT NULL,
    block_id integer NOT NULL,
    account_identifier_id integer NOT NULL,
    token_symbol_id integer NOT NULL,
    balance text NOT NULL,
    nonce bigint NOT NULL,
    receipt_chain_hash text NOT NULL,
    delegate_id integer,
    voting_for_id integer NOT NULL,
    timing_id integer,
    permissions_id integer NOT NULL,
    zkapp_id integer
);


ALTER TABLE public.accounts_accessed OWNER TO postgres;

--
-- Name: accounts_created; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.accounts_created (
    block_id integer NOT NULL,
    account_identifier_id integer NOT NULL,
    creation_fee text NOT NULL
);


ALTER TABLE public.accounts_created OWNER TO postgres;

--
-- Name: blocks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.blocks (
    id integer NOT NULL,
    state_hash text NOT NULL,
    parent_id integer,
    parent_hash text NOT NULL,
    creator_id integer NOT NULL,
    block_winner_id integer NOT NULL,
    last_vrf_output text NOT NULL,
    snarked_ledger_hash_id integer NOT NULL,
    staking_epoch_data_id integer NOT NULL,
    next_epoch_data_id integer NOT NULL,
    min_window_density bigint NOT NULL,
    sub_window_densities bigint[] NOT NULL,
    total_currency text NOT NULL,
    ledger_hash text NOT NULL,
    height bigint NOT NULL,
    global_slot_since_hard_fork bigint NOT NULL,
    global_slot_since_genesis bigint NOT NULL,
    protocol_version_id integer NOT NULL,
    proposed_protocol_version_id integer,
    "timestamp" text NOT NULL,
    chain_status public.chain_status_type NOT NULL
);


ALTER TABLE public.blocks OWNER TO postgres;

--
-- Name: blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.blocks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.blocks_id_seq OWNER TO postgres;

--
-- Name: blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.blocks_id_seq OWNED BY public.blocks.id;


--
-- Name: blocks_internal_commands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.blocks_internal_commands (
    block_id integer NOT NULL,
    internal_command_id integer NOT NULL,
    sequence_no integer NOT NULL,
    secondary_sequence_no integer NOT NULL,
    status public.transaction_status NOT NULL,
    failure_reason text
);


ALTER TABLE public.blocks_internal_commands OWNER TO postgres;

--
-- Name: blocks_user_commands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.blocks_user_commands (
    block_id integer NOT NULL,
    user_command_id integer NOT NULL,
    sequence_no integer NOT NULL,
    status public.transaction_status NOT NULL,
    failure_reason text
);


ALTER TABLE public.blocks_user_commands OWNER TO postgres;

--
-- Name: blocks_zkapp_commands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.blocks_zkapp_commands (
    block_id integer NOT NULL,
    zkapp_command_id integer NOT NULL,
    sequence_no integer NOT NULL,
    status public.transaction_status NOT NULL,
    failure_reasons_ids integer[]
);


ALTER TABLE public.blocks_zkapp_commands OWNER TO postgres;

--
-- Name: epoch_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.epoch_data (
    id integer NOT NULL,
    seed text NOT NULL,
    ledger_hash_id integer NOT NULL,
    total_currency text NOT NULL,
    start_checkpoint text NOT NULL,
    lock_checkpoint text NOT NULL,
    epoch_length bigint NOT NULL
);


ALTER TABLE public.epoch_data OWNER TO postgres;

--
-- Name: epoch_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.epoch_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.epoch_data_id_seq OWNER TO postgres;

--
-- Name: epoch_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.epoch_data_id_seq OWNED BY public.epoch_data.id;


--
-- Name: internal_commands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.internal_commands (
    id integer NOT NULL,
    command_type public.internal_command_type NOT NULL,
    receiver_id integer NOT NULL,
    fee text NOT NULL,
    hash text NOT NULL
);


ALTER TABLE public.internal_commands OWNER TO postgres;

--
-- Name: internal_commands_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.internal_commands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.internal_commands_id_seq OWNER TO postgres;

--
-- Name: internal_commands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.internal_commands_id_seq OWNED BY public.internal_commands.id;


--
-- Name: protocol_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.protocol_versions (
    id integer NOT NULL,
    transaction integer NOT NULL,
    network integer NOT NULL,
    patch integer NOT NULL
);


ALTER TABLE public.protocol_versions OWNER TO postgres;

--
-- Name: protocol_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.protocol_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.protocol_versions_id_seq OWNER TO postgres;

--
-- Name: protocol_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.protocol_versions_id_seq OWNED BY public.protocol_versions.id;


--
-- Name: public_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.public_keys (
    id integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.public_keys OWNER TO postgres;

--
-- Name: public_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.public_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.public_keys_id_seq OWNER TO postgres;

--
-- Name: public_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.public_keys_id_seq OWNED BY public.public_keys.id;


--
-- Name: snarked_ledger_hashes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.snarked_ledger_hashes (
    id integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.snarked_ledger_hashes OWNER TO postgres;

--
-- Name: snarked_ledger_hashes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.snarked_ledger_hashes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.snarked_ledger_hashes_id_seq OWNER TO postgres;

--
-- Name: snarked_ledger_hashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.snarked_ledger_hashes_id_seq OWNED BY public.snarked_ledger_hashes.id;


--
-- Name: timing_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.timing_info (
    id integer NOT NULL,
    account_identifier_id integer NOT NULL,
    initial_minimum_balance text NOT NULL,
    cliff_time bigint NOT NULL,
    cliff_amount text NOT NULL,
    vesting_period bigint NOT NULL,
    vesting_increment text NOT NULL
);


ALTER TABLE public.timing_info OWNER TO postgres;

--
-- Name: timing_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.timing_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.timing_info_id_seq OWNER TO postgres;

--
-- Name: timing_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.timing_info_id_seq OWNED BY public.timing_info.id;


--
-- Name: token_symbols; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.token_symbols (
    id integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.token_symbols OWNER TO postgres;

--
-- Name: token_symbols_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.token_symbols_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.token_symbols_id_seq OWNER TO postgres;

--
-- Name: token_symbols_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.token_symbols_id_seq OWNED BY public.token_symbols.id;


--
-- Name: tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tokens (
    id integer NOT NULL,
    value text NOT NULL,
    owner_public_key_id integer,
    owner_token_id integer
);


ALTER TABLE public.tokens OWNER TO postgres;

--
-- Name: tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.tokens_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.tokens_id_seq OWNER TO postgres;

--
-- Name: tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.tokens_id_seq OWNED BY public.tokens.id;


--
-- Name: user_commands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_commands (
    id integer NOT NULL,
    command_type public.user_command_type NOT NULL,
    fee_payer_id integer NOT NULL,
    source_id integer NOT NULL,
    receiver_id integer NOT NULL,
    nonce bigint NOT NULL,
    amount text,
    fee text NOT NULL,
    valid_until bigint,
    memo text NOT NULL,
    hash text NOT NULL
);


ALTER TABLE public.user_commands OWNER TO postgres;

--
-- Name: user_commands_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_commands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_commands_id_seq OWNER TO postgres;

--
-- Name: user_commands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.user_commands_id_seq OWNED BY public.user_commands.id;


--
-- Name: voting_for; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.voting_for (
    id integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.voting_for OWNER TO postgres;

--
-- Name: voting_for_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.voting_for_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.voting_for_id_seq OWNER TO postgres;

--
-- Name: voting_for_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.voting_for_id_seq OWNED BY public.voting_for.id;


--
-- Name: zkapp_account_permissions_precondition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_account_permissions_precondition (
    id integer NOT NULL,
    edit_state public.zkapp_auth_required_type,
    send public.zkapp_auth_required_type,
    receive public.zkapp_auth_required_type,
    access public.zkapp_auth_required_type,
    set_delegate public.zkapp_auth_required_type,
    set_permissions public.zkapp_auth_required_type,
    set_verification_key public.zkapp_auth_required_type,
    set_zkapp_uri public.zkapp_auth_required_type,
    edit_action_state public.zkapp_auth_required_type,
    set_token_symbol public.zkapp_auth_required_type,
    increment_nonce public.zkapp_auth_required_type,
    set_voting_for public.zkapp_auth_required_type,
    set_timing public.zkapp_auth_required_type
);


ALTER TABLE public.zkapp_account_permissions_precondition OWNER TO postgres;

--
-- Name: zkapp_account_permissions_precondition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_account_permissions_precondition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_account_permissions_precondition_id_seq OWNER TO postgres;

--
-- Name: zkapp_account_permissions_precondition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_account_permissions_precondition_id_seq OWNED BY public.zkapp_account_permissions_precondition.id;


--
-- Name: zkapp_account_precondition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_account_precondition (
    id integer NOT NULL,
    balance_id integer,
    nonce_id integer,
    receipt_chain_hash text,
    delegate_id integer,
    state_id integer NOT NULL,
    action_state_id integer,
    proved_state boolean,
    is_new boolean,
    permissions_id integer
);


ALTER TABLE public.zkapp_account_precondition OWNER TO postgres;

--
-- Name: zkapp_account_precondition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_account_precondition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_account_precondition_id_seq OWNER TO postgres;

--
-- Name: zkapp_account_precondition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_account_precondition_id_seq OWNED BY public.zkapp_account_precondition.id;


--
-- Name: zkapp_account_update; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_account_update (
    id integer NOT NULL,
    body_id integer NOT NULL
);


ALTER TABLE public.zkapp_account_update OWNER TO postgres;

--
-- Name: zkapp_account_update_body; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_account_update_body (
    id integer NOT NULL,
    account_identifier_id integer NOT NULL,
    update_id integer NOT NULL,
    balance_change text NOT NULL,
    increment_nonce boolean NOT NULL,
    events_id integer NOT NULL,
    actions_id integer NOT NULL,
    call_data_id integer NOT NULL,
    call_depth integer NOT NULL,
    zkapp_network_precondition_id integer NOT NULL,
    zkapp_account_precondition_id integer NOT NULL,
    zkapp_valid_while_precondition_id integer,
    use_full_commitment boolean NOT NULL,
    implicit_account_creation_fee boolean NOT NULL,
    may_use_token public.may_use_token NOT NULL,
    authorization_kind public.authorization_kind_type NOT NULL,
    verification_key_hash_id integer
);


ALTER TABLE public.zkapp_account_update_body OWNER TO postgres;

--
-- Name: zkapp_account_update_body_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_account_update_body_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_account_update_body_id_seq OWNER TO postgres;

--
-- Name: zkapp_account_update_body_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_account_update_body_id_seq OWNED BY public.zkapp_account_update_body.id;


--
-- Name: zkapp_account_update_failures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_account_update_failures (
    id integer NOT NULL,
    index integer NOT NULL,
    failures text[] NOT NULL
);


ALTER TABLE public.zkapp_account_update_failures OWNER TO postgres;

--
-- Name: zkapp_account_update_failures_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_account_update_failures_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_account_update_failures_id_seq OWNER TO postgres;

--
-- Name: zkapp_account_update_failures_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_account_update_failures_id_seq OWNED BY public.zkapp_account_update_failures.id;


--
-- Name: zkapp_account_update_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_account_update_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_account_update_id_seq OWNER TO postgres;

--
-- Name: zkapp_account_update_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_account_update_id_seq OWNED BY public.zkapp_account_update.id;


--
-- Name: zkapp_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_accounts (
    id integer NOT NULL,
    app_state_id integer NOT NULL,
    verification_key_id integer,
    zkapp_version bigint NOT NULL,
    action_state_id integer NOT NULL,
    last_action_slot bigint NOT NULL,
    proved_state boolean NOT NULL,
    zkapp_uri_id integer NOT NULL
);


ALTER TABLE public.zkapp_accounts OWNER TO postgres;

--
-- Name: zkapp_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_accounts_id_seq OWNER TO postgres;

--
-- Name: zkapp_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_accounts_id_seq OWNED BY public.zkapp_accounts.id;


--
-- Name: zkapp_action_states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_action_states (
    id integer NOT NULL,
    element0 integer NOT NULL,
    element1 integer NOT NULL,
    element2 integer NOT NULL,
    element3 integer NOT NULL,
    element4 integer NOT NULL
);


ALTER TABLE public.zkapp_action_states OWNER TO postgres;

--
-- Name: zkapp_action_states_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_action_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_action_states_id_seq OWNER TO postgres;

--
-- Name: zkapp_action_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_action_states_id_seq OWNED BY public.zkapp_action_states.id;


--
-- Name: zkapp_amount_bounds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_amount_bounds (
    id integer NOT NULL,
    amount_lower_bound text NOT NULL,
    amount_upper_bound text NOT NULL
);


ALTER TABLE public.zkapp_amount_bounds OWNER TO postgres;

--
-- Name: zkapp_amount_bounds_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_amount_bounds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_amount_bounds_id_seq OWNER TO postgres;

--
-- Name: zkapp_amount_bounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_amount_bounds_id_seq OWNED BY public.zkapp_amount_bounds.id;


--
-- Name: zkapp_balance_bounds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_balance_bounds (
    id integer NOT NULL,
    balance_lower_bound text NOT NULL,
    balance_upper_bound text NOT NULL
);


ALTER TABLE public.zkapp_balance_bounds OWNER TO postgres;

--
-- Name: zkapp_balance_bounds_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_balance_bounds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_balance_bounds_id_seq OWNER TO postgres;

--
-- Name: zkapp_balance_bounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_balance_bounds_id_seq OWNED BY public.zkapp_balance_bounds.id;


--
-- Name: zkapp_commands; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_commands (
    id integer NOT NULL,
    zkapp_fee_payer_body_id integer NOT NULL,
    zkapp_account_updates_ids integer[] NOT NULL,
    memo text NOT NULL,
    hash text NOT NULL
);


ALTER TABLE public.zkapp_commands OWNER TO postgres;

--
-- Name: zkapp_commands_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_commands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_commands_id_seq OWNER TO postgres;

--
-- Name: zkapp_commands_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_commands_id_seq OWNED BY public.zkapp_commands.id;


--
-- Name: zkapp_epoch_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_epoch_data (
    id integer NOT NULL,
    epoch_ledger_id integer,
    epoch_seed text,
    start_checkpoint text,
    lock_checkpoint text,
    epoch_length_id integer
);


ALTER TABLE public.zkapp_epoch_data OWNER TO postgres;

--
-- Name: zkapp_epoch_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_epoch_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_epoch_data_id_seq OWNER TO postgres;

--
-- Name: zkapp_epoch_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_epoch_data_id_seq OWNED BY public.zkapp_epoch_data.id;


--
-- Name: zkapp_epoch_ledger; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_epoch_ledger (
    id integer NOT NULL,
    hash_id integer,
    total_currency_id integer
);


ALTER TABLE public.zkapp_epoch_ledger OWNER TO postgres;

--
-- Name: zkapp_epoch_ledger_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_epoch_ledger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_epoch_ledger_id_seq OWNER TO postgres;

--
-- Name: zkapp_epoch_ledger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_epoch_ledger_id_seq OWNED BY public.zkapp_epoch_ledger.id;


--
-- Name: zkapp_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_events (
    id integer NOT NULL,
    element_ids integer[] NOT NULL
);


ALTER TABLE public.zkapp_events OWNER TO postgres;

--
-- Name: zkapp_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_events_id_seq OWNER TO postgres;

--
-- Name: zkapp_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_events_id_seq OWNED BY public.zkapp_events.id;


--
-- Name: zkapp_fee_payer_body; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_fee_payer_body (
    id integer NOT NULL,
    public_key_id integer NOT NULL,
    fee text NOT NULL,
    valid_until bigint,
    nonce bigint NOT NULL
);


ALTER TABLE public.zkapp_fee_payer_body OWNER TO postgres;

--
-- Name: zkapp_fee_payer_body_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_fee_payer_body_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_fee_payer_body_id_seq OWNER TO postgres;

--
-- Name: zkapp_fee_payer_body_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_fee_payer_body_id_seq OWNED BY public.zkapp_fee_payer_body.id;


--
-- Name: zkapp_field; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_field (
    id integer NOT NULL,
    field text NOT NULL
);


ALTER TABLE public.zkapp_field OWNER TO postgres;

--
-- Name: zkapp_field_array; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_field_array (
    id integer NOT NULL,
    element_ids integer[] NOT NULL
);


ALTER TABLE public.zkapp_field_array OWNER TO postgres;

--
-- Name: zkapp_field_array_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_field_array_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_field_array_id_seq OWNER TO postgres;

--
-- Name: zkapp_field_array_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_field_array_id_seq OWNED BY public.zkapp_field_array.id;


--
-- Name: zkapp_field_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_field_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_field_id_seq OWNER TO postgres;

--
-- Name: zkapp_field_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_field_id_seq OWNED BY public.zkapp_field.id;


--
-- Name: zkapp_global_slot_bounds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_global_slot_bounds (
    id integer NOT NULL,
    global_slot_lower_bound bigint NOT NULL,
    global_slot_upper_bound bigint NOT NULL
);


ALTER TABLE public.zkapp_global_slot_bounds OWNER TO postgres;

--
-- Name: zkapp_global_slot_bounds_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_global_slot_bounds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_global_slot_bounds_id_seq OWNER TO postgres;

--
-- Name: zkapp_global_slot_bounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_global_slot_bounds_id_seq OWNED BY public.zkapp_global_slot_bounds.id;


--
-- Name: zkapp_length_bounds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_length_bounds (
    id integer NOT NULL,
    length_lower_bound bigint NOT NULL,
    length_upper_bound bigint NOT NULL
);


ALTER TABLE public.zkapp_length_bounds OWNER TO postgres;

--
-- Name: zkapp_length_bounds_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_length_bounds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_length_bounds_id_seq OWNER TO postgres;

--
-- Name: zkapp_length_bounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_length_bounds_id_seq OWNED BY public.zkapp_length_bounds.id;


--
-- Name: zkapp_network_precondition; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_network_precondition (
    id integer NOT NULL,
    snarked_ledger_hash_id integer,
    blockchain_length_id integer,
    min_window_density_id integer,
    total_currency_id integer,
    global_slot_since_genesis integer,
    staking_epoch_data_id integer,
    next_epoch_data_id integer
);


ALTER TABLE public.zkapp_network_precondition OWNER TO postgres;

--
-- Name: zkapp_network_precondition_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_network_precondition_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_network_precondition_id_seq OWNER TO postgres;

--
-- Name: zkapp_network_precondition_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_network_precondition_id_seq OWNED BY public.zkapp_network_precondition.id;


--
-- Name: zkapp_nonce_bounds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_nonce_bounds (
    id integer NOT NULL,
    nonce_lower_bound bigint NOT NULL,
    nonce_upper_bound bigint NOT NULL
);


ALTER TABLE public.zkapp_nonce_bounds OWNER TO postgres;

--
-- Name: zkapp_nonce_bounds_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_nonce_bounds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_nonce_bounds_id_seq OWNER TO postgres;

--
-- Name: zkapp_nonce_bounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_nonce_bounds_id_seq OWNED BY public.zkapp_nonce_bounds.id;


--
-- Name: zkapp_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_permissions (
    id integer NOT NULL,
    edit_state public.zkapp_auth_required_type NOT NULL,
    send public.zkapp_auth_required_type NOT NULL,
    receive public.zkapp_auth_required_type NOT NULL,
    access public.zkapp_auth_required_type NOT NULL,
    set_delegate public.zkapp_auth_required_type NOT NULL,
    set_permissions public.zkapp_auth_required_type NOT NULL,
    set_verification_key_auth public.zkapp_auth_required_type NOT NULL,
    set_verification_key_txn_version integer NOT NULL,
    set_zkapp_uri public.zkapp_auth_required_type NOT NULL,
    edit_action_state public.zkapp_auth_required_type NOT NULL,
    set_token_symbol public.zkapp_auth_required_type NOT NULL,
    increment_nonce public.zkapp_auth_required_type NOT NULL,
    set_voting_for public.zkapp_auth_required_type NOT NULL,
    set_timing public.zkapp_auth_required_type NOT NULL
);


ALTER TABLE public.zkapp_permissions OWNER TO postgres;

--
-- Name: zkapp_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_permissions_id_seq OWNER TO postgres;

--
-- Name: zkapp_permissions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_permissions_id_seq OWNED BY public.zkapp_permissions.id;


--
-- Name: zkapp_states; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_states (
    id integer NOT NULL,
    element0 integer NOT NULL,
    element1 integer NOT NULL,
    element2 integer NOT NULL,
    element3 integer NOT NULL,
    element4 integer NOT NULL,
    element5 integer NOT NULL,
    element6 integer NOT NULL,
    element7 integer NOT NULL
);


ALTER TABLE public.zkapp_states OWNER TO postgres;

--
-- Name: zkapp_states_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_states_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_states_id_seq OWNER TO postgres;

--
-- Name: zkapp_states_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_states_id_seq OWNED BY public.zkapp_states.id;


--
-- Name: zkapp_states_nullable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_states_nullable (
    id integer NOT NULL,
    element0 integer,
    element1 integer,
    element2 integer,
    element3 integer,
    element4 integer,
    element5 integer,
    element6 integer,
    element7 integer
);


ALTER TABLE public.zkapp_states_nullable OWNER TO postgres;

--
-- Name: zkapp_states_nullable_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_states_nullable_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_states_nullable_id_seq OWNER TO postgres;

--
-- Name: zkapp_states_nullable_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_states_nullable_id_seq OWNED BY public.zkapp_states_nullable.id;


--
-- Name: zkapp_timing_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_timing_info (
    id integer NOT NULL,
    initial_minimum_balance text NOT NULL,
    cliff_time bigint NOT NULL,
    cliff_amount text NOT NULL,
    vesting_period bigint NOT NULL,
    vesting_increment text NOT NULL
);


ALTER TABLE public.zkapp_timing_info OWNER TO postgres;

--
-- Name: zkapp_timing_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_timing_info_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_timing_info_id_seq OWNER TO postgres;

--
-- Name: zkapp_timing_info_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_timing_info_id_seq OWNED BY public.zkapp_timing_info.id;


--
-- Name: zkapp_token_id_bounds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_token_id_bounds (
    id integer NOT NULL,
    token_id_lower_bound text NOT NULL,
    token_id_upper_bound text NOT NULL
);


ALTER TABLE public.zkapp_token_id_bounds OWNER TO postgres;

--
-- Name: zkapp_token_id_bounds_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_token_id_bounds_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_token_id_bounds_id_seq OWNER TO postgres;

--
-- Name: zkapp_token_id_bounds_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_token_id_bounds_id_seq OWNED BY public.zkapp_token_id_bounds.id;


--
-- Name: zkapp_updates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_updates (
    id integer NOT NULL,
    app_state_id integer NOT NULL,
    delegate_id integer,
    verification_key_id integer,
    permissions_id integer,
    zkapp_uri_id integer,
    token_symbol_id integer,
    timing_id integer,
    voting_for_id integer
);


ALTER TABLE public.zkapp_updates OWNER TO postgres;

--
-- Name: zkapp_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_updates_id_seq OWNER TO postgres;

--
-- Name: zkapp_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_updates_id_seq OWNED BY public.zkapp_updates.id;


--
-- Name: zkapp_uris; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_uris (
    id integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.zkapp_uris OWNER TO postgres;

--
-- Name: zkapp_uris_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_uris_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_uris_id_seq OWNER TO postgres;

--
-- Name: zkapp_uris_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_uris_id_seq OWNED BY public.zkapp_uris.id;


--
-- Name: zkapp_verification_key_hashes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_verification_key_hashes (
    id integer NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.zkapp_verification_key_hashes OWNER TO postgres;

--
-- Name: zkapp_verification_key_hashes_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_verification_key_hashes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_verification_key_hashes_id_seq OWNER TO postgres;

--
-- Name: zkapp_verification_key_hashes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_verification_key_hashes_id_seq OWNED BY public.zkapp_verification_key_hashes.id;


--
-- Name: zkapp_verification_keys; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.zkapp_verification_keys (
    id integer NOT NULL,
    verification_key text NOT NULL,
    hash_id integer NOT NULL
);


ALTER TABLE public.zkapp_verification_keys OWNER TO postgres;

--
-- Name: zkapp_verification_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.zkapp_verification_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.zkapp_verification_keys_id_seq OWNER TO postgres;

--
-- Name: zkapp_verification_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.zkapp_verification_keys_id_seq OWNED BY public.zkapp_verification_keys.id;


--
-- Name: account_identifiers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_identifiers ALTER COLUMN id SET DEFAULT nextval('public.account_identifiers_id_seq'::regclass);


--
-- Name: blocks id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks ALTER COLUMN id SET DEFAULT nextval('public.blocks_id_seq'::regclass);


--
-- Name: epoch_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_data ALTER COLUMN id SET DEFAULT nextval('public.epoch_data_id_seq'::regclass);


--
-- Name: internal_commands id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internal_commands ALTER COLUMN id SET DEFAULT nextval('public.internal_commands_id_seq'::regclass);


--
-- Name: protocol_versions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocol_versions ALTER COLUMN id SET DEFAULT nextval('public.protocol_versions_id_seq'::regclass);


--
-- Name: public_keys id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.public_keys ALTER COLUMN id SET DEFAULT nextval('public.public_keys_id_seq'::regclass);


--
-- Name: snarked_ledger_hashes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.snarked_ledger_hashes ALTER COLUMN id SET DEFAULT nextval('public.snarked_ledger_hashes_id_seq'::regclass);


--
-- Name: timing_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timing_info ALTER COLUMN id SET DEFAULT nextval('public.timing_info_id_seq'::regclass);


--
-- Name: token_symbols id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.token_symbols ALTER COLUMN id SET DEFAULT nextval('public.token_symbols_id_seq'::regclass);


--
-- Name: tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens ALTER COLUMN id SET DEFAULT nextval('public.tokens_id_seq'::regclass);


--
-- Name: user_commands id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_commands ALTER COLUMN id SET DEFAULT nextval('public.user_commands_id_seq'::regclass);


--
-- Name: voting_for id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voting_for ALTER COLUMN id SET DEFAULT nextval('public.voting_for_id_seq'::regclass);


--
-- Name: zkapp_account_permissions_precondition id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_permissions_precondition ALTER COLUMN id SET DEFAULT nextval('public.zkapp_account_permissions_precondition_id_seq'::regclass);


--
-- Name: zkapp_account_precondition id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_precondition ALTER COLUMN id SET DEFAULT nextval('public.zkapp_account_precondition_id_seq'::regclass);


--
-- Name: zkapp_account_update id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update ALTER COLUMN id SET DEFAULT nextval('public.zkapp_account_update_id_seq'::regclass);


--
-- Name: zkapp_account_update_body id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body ALTER COLUMN id SET DEFAULT nextval('public.zkapp_account_update_body_id_seq'::regclass);


--
-- Name: zkapp_account_update_failures id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_failures ALTER COLUMN id SET DEFAULT nextval('public.zkapp_account_update_failures_id_seq'::regclass);


--
-- Name: zkapp_accounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_accounts ALTER COLUMN id SET DEFAULT nextval('public.zkapp_accounts_id_seq'::regclass);


--
-- Name: zkapp_action_states id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_action_states ALTER COLUMN id SET DEFAULT nextval('public.zkapp_action_states_id_seq'::regclass);


--
-- Name: zkapp_amount_bounds id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_amount_bounds ALTER COLUMN id SET DEFAULT nextval('public.zkapp_amount_bounds_id_seq'::regclass);


--
-- Name: zkapp_balance_bounds id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_balance_bounds ALTER COLUMN id SET DEFAULT nextval('public.zkapp_balance_bounds_id_seq'::regclass);


--
-- Name: zkapp_commands id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_commands ALTER COLUMN id SET DEFAULT nextval('public.zkapp_commands_id_seq'::regclass);


--
-- Name: zkapp_epoch_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_epoch_data ALTER COLUMN id SET DEFAULT nextval('public.zkapp_epoch_data_id_seq'::regclass);


--
-- Name: zkapp_epoch_ledger id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_epoch_ledger ALTER COLUMN id SET DEFAULT nextval('public.zkapp_epoch_ledger_id_seq'::regclass);


--
-- Name: zkapp_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_events ALTER COLUMN id SET DEFAULT nextval('public.zkapp_events_id_seq'::regclass);


--
-- Name: zkapp_fee_payer_body id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_fee_payer_body ALTER COLUMN id SET DEFAULT nextval('public.zkapp_fee_payer_body_id_seq'::regclass);


--
-- Name: zkapp_field id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_field ALTER COLUMN id SET DEFAULT nextval('public.zkapp_field_id_seq'::regclass);


--
-- Name: zkapp_field_array id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_field_array ALTER COLUMN id SET DEFAULT nextval('public.zkapp_field_array_id_seq'::regclass);


--
-- Name: zkapp_global_slot_bounds id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_global_slot_bounds ALTER COLUMN id SET DEFAULT nextval('public.zkapp_global_slot_bounds_id_seq'::regclass);


--
-- Name: zkapp_length_bounds id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_length_bounds ALTER COLUMN id SET DEFAULT nextval('public.zkapp_length_bounds_id_seq'::regclass);


--
-- Name: zkapp_network_precondition id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_network_precondition ALTER COLUMN id SET DEFAULT nextval('public.zkapp_network_precondition_id_seq'::regclass);


--
-- Name: zkapp_nonce_bounds id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_nonce_bounds ALTER COLUMN id SET DEFAULT nextval('public.zkapp_nonce_bounds_id_seq'::regclass);


--
-- Name: zkapp_permissions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_permissions ALTER COLUMN id SET DEFAULT nextval('public.zkapp_permissions_id_seq'::regclass);


--
-- Name: zkapp_states id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states ALTER COLUMN id SET DEFAULT nextval('public.zkapp_states_id_seq'::regclass);


--
-- Name: zkapp_states_nullable id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable ALTER COLUMN id SET DEFAULT nextval('public.zkapp_states_nullable_id_seq'::regclass);


--
-- Name: zkapp_timing_info id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_timing_info ALTER COLUMN id SET DEFAULT nextval('public.zkapp_timing_info_id_seq'::regclass);


--
-- Name: zkapp_token_id_bounds id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_token_id_bounds ALTER COLUMN id SET DEFAULT nextval('public.zkapp_token_id_bounds_id_seq'::regclass);


--
-- Name: zkapp_updates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates ALTER COLUMN id SET DEFAULT nextval('public.zkapp_updates_id_seq'::regclass);


--
-- Name: zkapp_uris id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_uris ALTER COLUMN id SET DEFAULT nextval('public.zkapp_uris_id_seq'::regclass);


--
-- Name: zkapp_verification_key_hashes id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_verification_key_hashes ALTER COLUMN id SET DEFAULT nextval('public.zkapp_verification_key_hashes_id_seq'::regclass);


--
-- Name: zkapp_verification_keys id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_verification_keys ALTER COLUMN id SET DEFAULT nextval('public.zkapp_verification_keys_id_seq'::regclass);


--
-- Data for Name: account_identifiers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_identifiers (id, public_key_id, token_id) FROM stdin;
1	2	1
2	3	1
3	4	1
4	5	1
5	6	1
6	7	1
7	8	1
8	9	1
9	10	1
10	11	1
11	12	1
12	13	1
13	14	1
14	15	1
15	16	1
16	17	1
17	18	1
18	19	1
19	20	1
20	21	1
21	22	1
22	23	1
23	24	1
24	25	1
25	26	1
26	27	1
27	28	1
28	29	1
29	30	1
30	31	1
31	32	1
32	33	1
33	34	1
34	35	1
35	36	1
36	37	1
37	38	1
38	39	1
39	40	1
40	41	1
41	42	1
42	43	1
43	44	1
44	45	1
45	46	1
46	47	1
47	48	1
48	49	1
49	50	1
50	51	1
51	52	1
52	53	1
53	54	1
54	55	1
55	56	1
56	57	1
57	58	1
58	59	1
59	60	1
60	61	1
61	62	1
62	63	1
63	64	1
64	65	1
65	66	1
66	68	1
67	69	1
68	70	1
69	71	1
70	72	1
71	73	1
72	74	1
73	75	1
74	76	1
75	77	1
76	78	1
77	79	1
78	80	1
79	81	1
80	82	1
81	83	1
82	84	1
83	85	1
84	86	1
85	87	1
86	88	1
87	89	1
88	90	1
89	91	1
90	92	1
91	93	1
92	94	1
93	95	1
94	97	1
95	98	1
96	99	1
97	100	1
98	101	1
99	102	1
100	103	1
101	104	1
102	105	1
103	106	1
104	107	1
105	108	1
106	109	1
107	110	1
108	111	1
109	112	1
110	113	1
111	114	1
112	116	1
113	117	1
114	118	1
115	119	1
116	120	1
117	121	1
118	122	1
119	123	1
120	124	1
121	125	1
122	126	1
123	127	1
124	128	1
125	129	1
126	130	1
127	131	1
128	132	1
129	133	1
130	134	1
131	135	1
132	136	1
133	137	1
134	138	1
135	139	1
136	140	1
137	141	1
138	142	1
139	143	1
140	144	1
141	145	1
142	146	1
143	147	1
144	148	1
145	149	1
146	150	1
147	151	1
148	152	1
149	153	1
150	154	1
151	155	1
152	156	1
153	157	1
154	158	1
155	159	1
156	160	1
157	96	1
158	161	1
159	162	1
160	163	1
161	164	1
162	165	1
163	166	1
164	167	1
165	168	1
166	169	1
167	170	1
168	67	1
169	171	1
170	172	1
171	173	1
172	174	1
173	175	1
174	176	1
175	177	1
176	178	1
177	179	1
178	180	1
179	181	1
180	182	1
181	183	1
182	184	1
183	185	1
184	186	1
185	187	1
186	188	1
187	189	1
188	190	1
189	191	1
190	192	1
191	193	1
192	194	1
193	195	1
194	196	1
195	197	1
196	198	1
197	199	1
198	200	1
199	201	1
200	202	1
201	203	1
202	115	1
203	204	1
204	205	1
205	206	1
206	207	1
207	208	1
208	209	1
209	210	1
210	211	1
211	212	1
212	213	1
213	214	1
214	215	1
215	216	1
216	217	1
217	218	1
218	219	1
219	220	1
220	221	1
221	222	1
222	223	1
223	224	1
224	225	1
225	226	1
226	227	1
227	228	1
228	229	1
229	230	1
230	231	1
231	232	1
232	233	1
233	234	1
234	235	1
235	236	1
236	237	1
237	238	1
238	239	1
239	240	1
240	241	1
241	242	1
242	243	1
243	244	1
\.


--
-- Data for Name: accounts_accessed; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts_accessed (ledger_index, block_id, account_identifier_id, token_symbol_id, balance, nonce, receipt_chain_hash, delegate_id, voting_for_id, timing_id, permissions_id, zkapp_id) FROM stdin;
8	1	1	1	285	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	2	1	1	1	\N
105	1	2	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	3	1	2	1	\N
79	1	3	1	331	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	4	1	3	1	\N
30	1	4	1	226	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	5	1	4	1	\N
10	1	5	1	123	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	6	1	5	1	\N
76	1	6	1	292	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	7	1	6	1	\N
119	1	7	1	104	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	8	1	7	1	\N
174	1	8	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	9	1	8	1	\N
234	1	9	1	488	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	10	1	9	1	\N
224	1	10	1	469	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	11	1	10	1	\N
17	1	11	1	242	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	12	1	11	1	\N
126	1	12	1	135	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	13	1	12	1	\N
92	1	13	1	196	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	14	1	13	1	\N
151	1	14	1	79	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	15	1	14	1	\N
164	1	15	1	206	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	16	1	15	1	\N
135	1	16	1	340	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	17	1	16	1	\N
103	1	17	1	382	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	18	1	17	1	\N
68	1	18	1	488	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	19	1	18	1	\N
25	1	19	1	135	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	20	1	19	1	\N
44	1	20	1	126	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	21	1	20	1	\N
41	1	21	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	22	1	21	1	\N
115	1	22	1	278	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	23	1	22	1	\N
202	1	23	1	46	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	24	1	23	1	\N
185	1	24	1	104	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	25	1	24	1	\N
70	1	25	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	26	1	25	1	\N
214	1	26	1	271	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	27	1	26	1	\N
208	1	27	1	315	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	28	1	27	1	\N
77	1	28	1	162	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	29	1	28	1	\N
165	1	29	1	86	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	30	1	29	1	\N
179	1	30	1	409	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	31	1	30	1	\N
154	1	31	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	32	1	31	1	\N
94	1	32	1	57	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	33	1	32	1	\N
189	1	33	1	204	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	34	1	33	1	\N
130	1	34	1	262	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	35	1	34	1	\N
109	1	35	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	36	1	35	1	\N
169	1	36	1	156	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	37	1	36	1	\N
62	1	37	1	417	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	38	1	37	1	\N
66	1	38	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	39	1	38	1	\N
49	1	39	1	85	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	40	1	39	1	\N
225	1	40	1	103	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	41	1	40	1	\N
139	1	41	1	67	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	42	1	41	1	\N
40	1	42	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	43	1	42	1	\N
131	1	43	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	44	1	43	1	\N
80	1	44	1	198	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	45	1	44	1	\N
93	1	45	1	489	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	46	1	45	1	\N
186	1	46	1	298	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	47	1	46	1	\N
28	1	47	1	36	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	48	1	47	1	\N
88	1	48	1	334	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	49	1	48	1	\N
12	1	49	1	344	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	50	1	49	1	\N
33	1	50	1	451	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	51	1	50	1	\N
83	1	51	1	371	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	52	1	51	1	\N
125	1	52	1	234	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	53	1	52	1	\N
220	1	53	1	345	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	54	1	53	1	\N
74	1	54	1	282	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	55	1	54	1	\N
229	1	55	1	339	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	56	1	55	1	\N
13	1	56	1	215	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	57	1	56	1	\N
241	1	57	1	131	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	58	1	57	1	\N
218	1	58	1	193	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	59	1	58	1	\N
14	1	59	1	60	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	60	1	59	1	\N
56	1	60	1	350	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	61	1	60	1	\N
144	1	61	1	223	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	62	1	61	1	\N
60	1	62	1	449	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	63	1	62	1	\N
183	1	63	1	142	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	64	1	63	1	\N
149	1	64	1	300	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	65	1	64	1	\N
5	1	65	1	11550000000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	65	1	\N
163	1	66	1	256	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	68	1	66	1	\N
101	1	67	1	125	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	69	1	67	1	\N
39	1	68	1	236	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	70	1	68	1	\N
237	1	69	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	71	1	69	1	\N
108	1	70	1	179	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	72	1	70	1	\N
11	1	71	1	194	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	73	1	71	1	\N
24	1	72	1	185	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	74	1	72	1	\N
96	1	73	1	342	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	75	1	73	1	\N
213	1	74	1	157	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	76	1	74	1	\N
89	1	75	1	135	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	77	1	75	1	\N
157	1	76	1	456	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	78	1	76	1	\N
206	1	77	1	336	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	79	1	77	1	\N
205	1	78	1	280	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	80	1	78	1	\N
180	1	79	1	187	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	81	1	79	1	\N
155	1	80	1	387	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	82	1	80	1	\N
31	1	81	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	83	1	81	1	\N
199	1	82	1	151	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	84	1	82	1	\N
7	1	83	1	202	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	85	1	83	1	\N
232	1	84	1	24	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	86	1	84	1	\N
38	1	85	1	152	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	87	1	85	1	\N
16	1	86	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	88	1	86	1	\N
227	1	87	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	89	1	87	1	\N
18	1	88	1	186	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	90	1	88	1	\N
182	1	89	1	266	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	91	1	89	1	\N
137	1	90	1	81	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	92	1	90	1	\N
162	1	91	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	93	1	91	1	\N
197	1	92	1	379	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	94	1	92	1	\N
3	1	93	1	11550000000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	93	1	\N
107	1	94	1	315	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	97	1	94	1	\N
45	1	95	1	226	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	98	1	95	1	\N
212	1	96	1	166	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	99	1	96	1	\N
110	1	97	1	302	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	100	1	97	1	\N
142	1	98	1	269	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	101	1	98	1	\N
176	1	99	1	172	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	102	1	99	1	\N
153	1	100	1	195	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	103	1	100	1	\N
36	1	101	1	243	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	104	1	101	1	\N
78	1	102	1	128	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	105	1	102	1	\N
145	1	103	1	349	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	106	1	103	1	\N
22	1	104	1	87	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	107	1	104	1	\N
124	1	105	1	424	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	108	1	105	1	\N
87	1	106	1	239	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	109	1	106	1	\N
133	1	107	1	316	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	110	1	107	1	\N
192	1	108	1	492	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	111	1	108	1	\N
188	1	109	1	294	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	112	1	109	1	\N
216	1	110	1	191	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	113	1	110	1	\N
1	1	111	1	65500000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	115	1	111	1	\N
91	1	112	1	380	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	116	1	112	1	\N
160	1	113	1	331	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	117	1	113	1	\N
219	1	114	1	459	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	118	1	114	1	\N
203	1	115	1	28	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	119	1	115	1	\N
193	1	116	1	472	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	120	1	116	1	\N
32	1	117	1	119	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	121	1	117	1	\N
211	1	118	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	122	1	118	1	\N
194	1	119	1	41	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	123	1	119	1	\N
102	1	120	1	27	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	124	1	120	1	\N
42	1	121	1	70	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	125	1	121	1	\N
50	1	122	1	337	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	126	1	122	1	\N
112	1	123	1	210	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	127	1	123	1	\N
175	1	124	1	495	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	128	1	124	1	\N
146	1	125	1	144	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	129	1	125	1	\N
98	1	126	1	148	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	130	1	126	1	\N
204	1	127	1	376	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	131	1	127	1	\N
26	1	128	1	329	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	132	1	128	1	\N
171	1	129	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	133	1	129	1	\N
128	1	130	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	134	1	130	1	\N
37	1	131	1	181	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	135	1	131	1	\N
210	1	132	1	200	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	136	1	132	1	\N
114	1	133	1	159	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	137	1	133	1	\N
46	1	134	1	319	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	138	1	134	1	\N
99	1	135	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	139	1	135	1	\N
201	1	136	1	365	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	140	1	136	1	\N
48	1	137	1	342	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	141	1	137	1	\N
57	1	138	1	237	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	142	1	138	1	\N
148	1	139	1	427	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	143	1	139	1	\N
178	1	140	1	315	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	144	1	140	1	\N
140	1	141	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	145	1	141	1	\N
21	1	142	1	378	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	146	1	142	1	\N
120	1	143	1	420	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	147	1	143	1	\N
113	1	144	1	411	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	148	1	144	1	\N
73	1	145	1	172	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	149	1	145	1	\N
75	1	146	1	309	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	150	1	146	1	\N
150	1	147	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	151	1	147	1	\N
118	1	148	1	154	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	152	1	148	1	\N
116	1	149	1	153	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	153	1	149	1	\N
35	1	150	1	47	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	154	1	150	1	\N
166	1	151	1	87	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	155	1	151	1	\N
147	1	152	1	398	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	156	1	152	1	\N
27	1	153	1	452	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	157	1	153	1	\N
86	1	154	1	291	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	158	1	154	1	\N
231	1	155	1	367	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	159	1	155	1	\N
81	1	156	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	160	1	156	1	\N
4	1	157	1	0	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
152	1	158	1	311	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	161	1	158	1	\N
173	1	159	1	258	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	162	1	159	1	\N
67	1	160	1	323	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	163	1	160	1	\N
61	1	161	1	405	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	164	1	161	1	\N
187	1	162	1	32	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	165	1	162	1	\N
90	1	163	1	130	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	166	1	163	1	\N
138	1	164	1	234	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	167	1	164	1	\N
15	1	165	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	168	1	165	1	\N
85	1	166	1	481	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	169	1	166	1	\N
181	1	167	1	240	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	170	1	167	1	\N
6	1	168	1	0	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
127	1	169	1	314	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	171	1	169	1	\N
191	1	170	1	183	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	172	1	170	1	\N
172	1	171	1	486	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	173	1	171	1	\N
55	1	172	1	178	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	174	1	172	1	\N
222	1	173	1	65	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	175	1	173	1	\N
230	1	174	1	277	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	176	1	174	1	\N
117	1	175	1	433	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	177	1	175	1	\N
53	1	176	1	100	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	178	1	176	1	\N
167	1	177	1	272	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	179	1	177	1	\N
123	1	178	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	180	1	178	1	\N
43	1	179	1	212	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	181	1	179	1	\N
58	1	180	1	151	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	182	1	180	1	\N
97	1	181	1	387	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	183	1	181	1	\N
177	1	182	1	158	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	184	1	182	1	\N
47	1	183	1	440	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	185	1	183	1	\N
228	1	184	1	438	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	186	1	184	1	\N
129	1	185	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	187	1	185	1	\N
184	1	186	1	290	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	188	1	186	1	\N
196	1	187	1	417	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	189	1	187	1	\N
200	1	188	1	375	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	190	1	188	1	\N
20	1	189	1	178	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	191	1	189	1	\N
100	1	190	1	59	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	192	1	190	1	\N
122	1	191	1	95	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	193	1	191	1	\N
198	1	192	1	394	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	194	1	192	1	\N
240	1	193	1	486	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	195	1	193	1	\N
52	1	194	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	196	1	194	1	\N
223	1	195	1	256	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	197	1	195	1	\N
132	1	196	1	128	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	198	1	196	1	\N
95	1	197	1	199	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	199	1	197	1	\N
82	1	198	1	22	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	200	1	198	1	\N
159	1	199	1	276	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	201	1	199	1	\N
226	1	200	1	451	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	202	1	200	1	\N
236	1	201	1	133	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	203	1	201	1	\N
2	1	202	1	500000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	115	1	202	1	\N
63	1	203	1	460	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	204	1	203	1	\N
217	1	204	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	205	1	204	1	\N
54	1	205	1	489	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	206	1	205	1	\N
161	1	206	1	190	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	207	1	206	1	\N
190	1	207	1	221	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	208	1	207	1	\N
141	1	208	1	464	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	209	1	208	1	\N
59	1	209	1	10	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	210	1	209	1	\N
134	1	210	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	211	1	210	1	\N
69	1	211	1	353	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	212	1	211	1	\N
143	1	212	1	396	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	213	1	212	1	\N
104	1	213	1	417	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	214	1	213	1	\N
136	1	214	1	46	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	215	1	214	1	\N
156	1	215	1	305	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	216	1	215	1	\N
121	1	216	1	337	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	217	1	216	1	\N
23	1	217	1	444	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	218	1	217	1	\N
238	1	218	1	479	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	219	1	218	1	\N
209	1	219	1	344	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	220	1	219	1	\N
239	1	220	1	113	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	221	1	220	1	\N
195	1	221	1	236	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	222	1	221	1	\N
168	1	222	1	480	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	223	1	222	1	\N
29	1	223	1	160	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	224	1	223	1	\N
158	1	224	1	318	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	225	1	224	1	\N
19	1	225	1	214	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	226	1	225	1	\N
242	1	226	1	22	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	227	1	226	1	\N
65	1	227	1	163	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	228	1	227	1	\N
64	1	228	1	500	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	229	1	228	1	\N
106	1	229	1	366	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	230	1	229	1	\N
84	1	230	1	320	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	231	1	230	1	\N
235	1	231	1	407	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	232	1	231	1	\N
72	1	232	1	204	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	233	1	232	1	\N
71	1	233	1	341	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	234	1	233	1	\N
215	1	234	1	18	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	235	1	234	1	\N
34	1	235	1	229	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	236	1	235	1	\N
170	1	236	1	477	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	237	1	236	1	\N
51	1	237	1	94	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	238	1	237	1	\N
233	1	238	1	126	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	239	1	238	1	\N
111	1	239	1	112	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	240	1	239	1	\N
221	1	240	1	387	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	241	1	240	1	\N
0	1	241	1	5000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
207	1	242	1	265	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	243	1	242	1	\N
9	1	243	1	269	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	244	1	243	1	\N
5	3	157	1	720500000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	3	202	1	499500000000	2	2n19XubkbrKxhcM1Ue3Le7UHoXCUGf8q5vEknHney431VEFYjxS7	115	1	202	1	\N
5	4	157	1	1443250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	4	202	1	496750000000	13	2n1jbj9Z5FnfN1p8opQETXMcD8Ls2nqYg2VhjBCirUjjmKDwaRhe	115	1	202	1	\N
7	5	168	1	723000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	5	202	1	493750000000	25	2n2KJ44XxZ6JRP23RhEAVDMcXvCYmEUA4Z8P43Vmgwgt8CdzC79w	115	1	202	1	\N
5	6	157	1	2166250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	6	202	1	490750000000	37	2n1Boj5LSbm9TFFwjTwXuK6PWonCDcdDj9bRbLH7iQf7mRNHfp24	115	1	202	1	\N
7	7	168	1	1446000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	7	202	1	490750000000	37	2n1Boj5LSbm9TFFwjTwXuK6PWonCDcdDj9bRbLH7iQf7mRNHfp24	115	1	202	1	\N
7	8	168	1	1446000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	8	202	1	487750000000	49	2n19aXVwC6X6vX7aHMVNSYbFpST4G7uQ3m1bNLo2Z6SGCbpusWkP	115	1	202	1	\N
5	9	157	1	2889250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	9	202	1	484750000000	61	2n1M8Sj9pedrpz26R6rtH56i93YkuWZms75FDTJzgieSjRXMLFXD	115	1	202	1	\N
7	10	168	1	2169000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	10	202	1	484750000000	61	2n1M8Sj9pedrpz26R6rtH56i93YkuWZms75FDTJzgieSjRXMLFXD	115	1	202	1	\N
7	11	168	1	2898500000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	11	202	1	475250000000	99	2mzemGbQgNQUCjEbpqXHdCvNfmivnEs7QwjKVchxcS6rowhWrunK	115	1	202	1	\N
5	12	157	1	2889000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	12	202	1	472500000000	110	2n27Ltm7EULq6fRnvvLcaXJYHHeGewwTyLt3K4tJZHtriTQW49NX	115	1	202	1	\N
7	13	168	1	3621250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	13	202	1	472500000000	110	2n27Ltm7EULq6fRnvvLcaXJYHHeGewwTyLt3K4tJZHtriTQW49NX	115	1	202	1	\N
5	14	157	1	3612000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	14	202	1	469500000000	122	2n2APYxDWFqB2d8QBqdKDsYJGdi3g4vrrwTnFKSS6avFt8febtai	115	1	202	1	\N
7	15	168	1	3621750000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	15	202	1	466250000000	135	2n1AWQT6VE6b6mJSiHNxcAwzvSEywUBT2Z85BMAvmYx9a4Eowz9Q	115	1	202	1	\N
5	16	157	1	4335250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	16	202	1	466250000000	135	2n1AWQT6VE6b6mJSiHNxcAwzvSEywUBT2Z85BMAvmYx9a4Eowz9Q	115	1	202	1	\N
7	17	168	1	4344750000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	17	202	1	463250000000	147	2n12eYruPQHrDDwdjx6A4XSueFL5Z3muHCUMb9wwbGK1RWDxBYmK	115	1	202	1	\N
7	18	168	1	5067750000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	18	202	1	460250000000	159	2n1SwX1vWSP1XUigkzQQ26crX2QDcGpbizLri5s8ri5Zj6ENz9KT	115	1	202	1	\N
7	19	168	1	5790750000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	19	202	1	457250000000	171	2n1FasDyZhz8UxcCNrR9ecumNJrFmL3TBK4r2abdD4tFoQmH1czR	115	1	202	1	\N
5	20	157	1	4335000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	20	202	1	454250000000	183	2n2LWqK3HwLzQpvgh4K6fgvvxaGrwvV4mHH41wVUhFyay1pJ2vTE	115	1	202	1	\N
7	21	168	1	6514000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	21	202	1	451000000000	196	2n1MsmZ9LgYt56UoNaFHA761hJUUXMiecrpseke7ee5qodZkzNJ4	115	1	202	1	\N
5	22	157	1	5058250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	22	202	1	451000000000	196	2n1MsmZ9LgYt56UoNaFHA761hJUUXMiecrpseke7ee5qodZkzNJ4	115	1	202	1	\N
7	23	168	1	7240000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	23	202	1	445000000000	220	2mzuQkgvvqFyvRmeL1s3zTTdHZuX7STaiqRrgp6JtMDMTxikjhPP	115	1	202	1	\N
5	24	157	1	5061000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	24	202	1	445000000000	220	2mzuQkgvvqFyvRmeL1s3zTTdHZuX7STaiqRrgp6JtMDMTxikjhPP	115	1	202	1	\N
5	25	157	1	5784000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	25	202	1	442000000000	232	2n27dgZkjB3jZryjNcwjg4YqqYjaLLGGDrGtjeyme3Td1Mu3Mfqc	115	1	202	1	\N
7	27	168	1	7240250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	27	202	1	435750000000	257	2n26uRntJ5D2vLDmLCVF9ETF9WkLSfWc8ntLxQ6zLZPDEd7NRvpF	115	1	202	1	\N
5	29	157	1	7230000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	29	202	1	429750000000	281	2mzcv83t6Liia1zsq6KpT4fTGeQuVP11NJE5TKD14gyVG2VPRsy2	115	1	202	1	\N
5	31	157	1	7953000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	31	202	1	426750000000	293	2n21kBWNGw7zs55S3cczQkPJrz2UhXBHvjLUqGfYMRf7P4hN25tm	115	1	202	1	\N
5	33	157	1	8676000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	33	202	1	420750000000	317	2n1S7UJ2yVwg4P5eBLQeRZVjgjnhkBEtgRe4CRDZL8MBDxtw9Gix	115	1	202	1	\N
5	35	157	1	8679186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	35	202	1	414500000000	342	2mzeRUdu1V9WiZHik4ksC4MAobFpnUWySENEYwYrdh9uc9PSsfs2	115	1	202	1	\N
1	35	241	1	5064000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	37	168	1	10135436000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	37	202	1	411500000000	354	2n1kH75SAtWWu8upsiMUEjiYEid2Lr1DyCUDAsMgmYZCGtsq3Fru	115	1	202	1	\N
5	39	157	1	9398750000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	39	202	1	405750000000	377	2n2BFRc2m7menxmfvwWuPRvCk3dJjgfCZHmpzxvJSAJpifZyquXo	115	1	202	1	\N
5	26	157	1	6510250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	26	202	1	435750000000	257	2n26uRntJ5D2vLDmLCVF9ETF9WkLSfWc8ntLxQ6zLZPDEd7NRvpF	115	1	202	1	\N
5	28	157	1	6507000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	28	202	1	432750000000	269	2mzpSn5waoopNFqRGLodQ8bYHyHnTiUDrP92vhLkLe841knu8Z5r	115	1	202	1	\N
7	30	168	1	7963250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	30	202	1	426750000000	293	2n21kBWNGw7zs55S3cczQkPJrz2UhXBHvjLUqGfYMRf7P4hN25tm	115	1	202	1	\N
7	32	168	1	7963250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	32	202	1	423750000000	305	2n13MQ8QPfebDgmqkThjM1H9WYFc3U6pHyzvLJxSKT9vamSURqS7	115	1	202	1	\N
7	34	168	1	8686250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	34	202	1	420750000000	317	2n1S7UJ2yVwg4P5eBLQeRZVjgjnhkBEtgRe4CRDZL8MBDxtw9Gix	115	1	202	1	\N
7	36	168	1	9412436000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	36	202	1	414500000000	342	2mzeRUdu1V9WiZHik4ksC4MAobFpnUWySENEYwYrdh9uc9PSsfs2	115	1	202	1	\N
1	36	241	1	5064000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	38	157	1	8676000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	38	202	1	408500000000	366	2n1FSwbxYn67HyqB5hbUinqPZMr22btmA8vJh9Hj6kTujA3GgjAT	115	1	202	1	\N
7	40	168	1	10857186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	40	202	1	404000000000	384	2n2HzGvC6WeZozpn295Fssrx6hVJj946bNXGHo1ddmEipx5Euwbe	115	1	202	1	\N
5	41	157	1	10120500000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	41	202	1	404000000000	384	2n2HzGvC6WeZozpn295Fssrx6hVJj946bNXGHo1ddmEipx5Euwbe	115	1	202	1	\N
5	42	157	1	10120500000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	42	202	1	402250000000	391	2n1yu4QfPmWxYjqRAFFxfNU1gjaHDfXDr2CDf2Dd5jni8Lm1FY7p	115	1	202	1	\N
5	43	157	1	10842250000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	43	202	1	400500000000	398	2mznKeGTEwWjzK73WNyfZNHBbWmRgN3C8pG4Gm8pfcbHmbqR7478	115	1	202	1	\N
5	44	157	1	11568000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	44	202	1	394750000000	421	2n2N9cn6Yfjx62uP3y12dTccswMWz378bE14SdKWbAxb14GBimvv	115	1	202	1	\N
7	45	168	1	11579936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	45	202	1	392000000000	432	2n1DgWsnS7bvUfX4vzZtTRt9jh9bB18dvKY6BCam2bCFrnuSAbJt	115	1	202	1	\N
7	46	168	1	12303122000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	46	202	1	388750000000	445	2n28pBayc353UfrwehDX3Bf1KFR948D9EWL1j4DaDCRRPNtZUBRd	115	1	202	1	\N
1	46	241	1	5128000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	47	157	1	12291186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	47	202	1	388750000000	445	2n28pBayc353UfrwehDX3Bf1KFR948D9EWL1j4DaDCRRPNtZUBRd	115	1	202	1	\N
1	47	241	1	5128000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	48	168	1	13025872000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	48	202	1	386000000000	456	2n187mNJEXWgojeFwRo27M3rgvzm6ZngeQSNLj83hRgeftdvwPpD	115	1	202	1	\N
7	49	168	1	13748872000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	49	202	1	383000000000	468	2n1aAQU9nm8WtPkiHpYfHa3VpQTp6qXzG2Vgt7TsiAa8aqNhmCtp	115	1	202	1	\N
5	50	157	1	12291000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	50	202	1	383000000000	468	2n1aAQU9nm8WtPkiHpYfHa3VpQTp6qXzG2Vgt7TsiAa8aqNhmCtp	115	1	202	1	\N
7	51	168	1	14477872000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	51	202	1	374000000000	504	2mznXskwQwaiDbQu8JTvw7mVY7U81N14sPSeZF3vZbp15zB7LzT7	115	1	202	1	\N
5	52	157	1	12297000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	52	202	1	374000000000	504	2mznXskwQwaiDbQu8JTvw7mVY7U81N14sPSeZF3vZbp15zB7LzT7	115	1	202	1	\N
5	53	157	1	13023000000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	53	202	1	368000000000	528	2mzqzmKNXmKCy1pEF6qtGQuS5y9vZtQw73QmHkSVZnCaYkpvSHX7	115	1	202	1	\N
5	54	157	1	13752186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	54	202	1	358750000000	565	2n18xNjs8e1ALNSiVqeiQ5bGCZETTVUYyzFJ5ebm4SUDPPPtYWBD	115	1	202	1	\N
1	54	241	1	5192000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	55	168	1	14471872000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	55	202	1	355750000000	577	2n1PqRTsAj5aNszZXVK89H4dXjs2m147Gm7kvWaWAi9puqyJHEPv	115	1	202	1	\N
5	56	157	1	14475186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	56	202	1	352750000000	589	2mztWoac7dz9WKSJ6pikY5cp4Vw1LUCfnVDucCT5MugZBxVNASWn	115	1	202	1	\N
5	57	157	1	15198186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	57	202	1	349750000000	601	2n2B1MF45CCz3tvf8WPxDP6TaNu2EWw621ue5rn8aDbf6WeA9EHR	115	1	202	1	\N
5	58	157	1	15920936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	58	202	1	347000000000	612	2mzuYE6WZpCdoWM6BPQy7bnYZVLGP6Vua1DgU819RvWSzpF5spqp	115	1	202	1	\N
7	60	168	1	15194872000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	60	202	1	341000000000	636	2mzdPHNQfBv1FxqVkniXeAKFPy4DdxcoW2TGceyTJmUJKtMx8wHe	115	1	202	1	\N
7	62	168	1	15920776000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	62	202	1	325750000000	697	2n274G7VRyGNwAAkhid86g3vVbSN1yiryVYCacxJBYET3wJVD1cS	115	1	202	1	\N
1	62	241	1	5288000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	64	168	1	16643776000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	64	202	1	319750000000	721	2mzzhUm8j3RR1RXRMLhpNh72TX8N4VK4TG1oMPAWhx6XgPAeVFPD	115	1	202	1	\N
5	66	157	1	18818936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	66	202	1	317000000000	732	2mzgeGrwVHzQKJEtcT4k6sXPw26UxGVCtRusCJmr2FUYbTThQAj5	115	1	202	1	\N
5	68	157	1	19545186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	68	202	1	308000000000	768	2mzsnxPfUoVN1gd2W3MmCRRjPEGA5s1DFRoqR9rkGkNfA2stzaXu	115	1	202	1	\N
7	70	168	1	18812180000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	70	202	1	302250000000	791	2n1ggABuj5W5E8ZEEiPX7JKBHUrVvroEH6eqUJevFVQen2pBPhaU	115	1	202	1	\N
1	70	241	1	5384000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	72	157	1	20268186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	72	202	1	299250000000	803	2n1vCvkxxbSrfkotBQczmSmVS87aU2Dc8dD1kN4PjU7QQBB7vHQ6	115	1	202	1	\N
7	74	168	1	20258180000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	74	202	1	296250000000	815	2mziztgmNz1gSTrJ4ckUTa3RPexxCKLHwr38U4Mb8Y3UzbqNuaNV	115	1	202	1	\N
5	76	157	1	20267936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	76	202	1	293500000000	826	2n2EZHytGAHsGcHWVo2rY8uEY7YUSMjsHWduwrgRQkM9LDJ8mrVB	115	1	202	1	\N
5	59	157	1	16643936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	59	202	1	344000000000	624	2n1n14eqpfeT1VNrEeryYMcz7vnBq1r2X88AQhLiFrWqc5XtMXqV	115	1	202	1	\N
5	61	157	1	17373186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	61	202	1	331750000000	673	2n1fw5sakiak4yp2fko1a51SPcUTjoLbox1yWUTQ1139r8E7nts7	115	1	202	1	\N
5	63	157	1	18096186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	63	202	1	322750000000	709	2mzoaawr8nRxWqm6tk9mokBX7rcfEbhxRBXycakrVDVx2d2kAFHy	115	1	202	1	\N
7	65	168	1	17366526000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	65	202	1	317000000000	732	2mzgeGrwVHzQKJEtcT4k6sXPw26UxGVCtRusCJmr2FUYbTThQAj5	115	1	202	1	\N
5	67	157	1	18822186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	67	202	1	311000000000	756	2mzkUXTpFKzim95zN8CPqNL9ZvJcFRc4FfgPGGsvhnvaGd5kDVVv	115	1	202	1	\N
7	69	168	1	18089276000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	69	202	1	305250000000	779	2mzq5tp4oTLH22AigCu7QDv9n1MxBviXtsQkfhkdbCKLG9eyJmnE	115	1	202	1	\N
5	71	157	1	20268090000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	71	202	1	302250000000	791	2n1ggABuj5W5E8ZEEiPX7JKBHUrVvroEH6eqUJevFVQen2pBPhaU	115	1	202	1	\N
1	71	241	1	5384000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	73	168	1	19535180000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	73	202	1	299250000000	803	2n1vCvkxxbSrfkotBQczmSmVS87aU2Dc8dD1kN4PjU7QQBB7vHQ6	115	1	202	1	\N
5	75	157	1	20268186000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	75	202	1	296250000000	815	2mziztgmNz1gSTrJ4ckUTa3RPexxCKLHwr38U4Mb8Y3UzbqNuaNV	115	1	202	1	\N
5	77	157	1	20990936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	77	202	1	290500000000	838	2mzgczKjryufJFgqUJKnfCitM819JcnN29XKXuk4LHyEMJ53hExz	115	1	202	1	\N
7	78	168	1	20981180000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	78	202	1	287500000000	850	2mzomSJ2ihHWEpHPkuhg9BEaew3pGtKbSJxkS9vVAP73UxyMnbz2	115	1	202	1	\N
5	79	157	1	21713936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	79	202	1	284500000000	862	2n1ZFsFDUpdxcd5XVoD92mJeQwKkfFZyq9AcvTvoAkQxYZEEHfM6	115	1	202	1	\N
5	80	157	1	22442936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	80	202	1	275500000000	898	2n1LVsw8Nbo7kfQo75uQEpEc8Am8XFqBg3rmk8TGKf4UqjhPiBnp	115	1	202	1	\N
7	81	168	1	21704084000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	81	202	1	272500000000	910	2n1fcpPXnoFrmPSMKzLSuEXhePvMyb8oWG5PQRA6uq1bhNPdUDys	115	1	202	1	\N
1	81	241	1	5480000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	82	157	1	23165840000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	82	202	1	272500000000	910	2n1fcpPXnoFrmPSMKzLSuEXhePvMyb8oWG5PQRA6uq1bhNPdUDys	115	1	202	1	\N
1	82	241	1	5480000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	83	168	1	22427084000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	83	202	1	269500000000	922	2n23HxLy3veUsxE2QpEHevfwQB21Dr7AFCwZcNMtwUbdfh7ejjYD	115	1	202	1	\N
5	84	157	1	23165686000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	84	202	1	266750000000	933	2n268KpdKvJoQwUKuAjq3cDXogBwabwcRdjp1wDwyvvw4BmEaY45	115	1	202	1	\N
7	85	168	1	23149834000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	85	202	1	266750000000	933	2n268KpdKvJoQwUKuAjq3cDXogBwabwcRdjp1wDwyvvw4BmEaY45	115	1	202	1	\N
5	86	157	1	23171936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	86	202	1	257750000000	969	2mzikPskaJCp5vcVd8UVRf8ub1JnAK4m6FCMQBwzJdLQDoYLQzzj	115	1	202	1	\N
7	87	168	1	23878834000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	87	202	1	257750000000	969	2mzikPskaJCp5vcVd8UVRf8ub1JnAK4m6FCMQBwzJdLQDoYLQzzj	115	1	202	1	\N
7	88	168	1	24601584000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	88	202	1	255000000000	980	2mzZu5Ch7CzawR5YfzfRkEXfkRLEH51DGVAVsmREqh3msJaimhTf	115	1	202	1	\N
7	89	168	1	25324584000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	89	202	1	252000000000	992	2mzXeS3EWVm4s1hxVEtNwGRRnUvAGSyKYmp4hkjvSHdTv156uyuQ	115	1	202	1	\N
5	90	157	1	23165936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	90	202	1	249000000000	1004	2n1E5HFqHQtgNzzrXYwtat1oMKoUNtnC7indv1SpjffYKFCuZDcX	115	1	202	1	\N
7	91	168	1	26047584000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	91	202	1	249000000000	1004	2n1E5HFqHQtgNzzrXYwtat1oMKoUNtnC7indv1SpjffYKFCuZDcX	115	1	202	1	\N
5	92	157	1	23888824000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	92	202	1	246000000000	1016	2n1vmqRg4ejgNDtwVRMshokB4pTyqQmKnN31ikVd23Qpfskr5Apy	115	1	202	1	\N
1	92	241	1	5592000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	93	168	1	26047472000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	93	202	1	246000000000	1016	2n1vmqRg4ejgNDtwVRMshokB4pTyqQmKnN31ikVd23Qpfskr5Apy	115	1	202	1	\N
1	93	241	1	5592000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	95	157	1	24614686000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	95	202	1	237250000000	1051	2mzsAGzBGk88vYoaBrVFPMWVATP7p4Z9KmK1X86Pxd7m3ou5eRSd	115	1	202	1	\N
7	97	168	1	27496222000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	97	202	1	228500000000	1086	2n1Gqiczo1e4puda87BtsbHJhjuo9rPQqRUMNz6rMEmREY1p5uRW	115	1	202	1	\N
7	99	168	1	28218972000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	99	202	1	222750000000	1109	2n1FyQzpc6pTtDVfLByP8pxfT3HFb8u87KL7SecR5PFu8EbpBoLy	115	1	202	1	\N
7	101	168	1	28941972000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	101	202	1	219750000000	1121	2n1SsHsPNTTRH63X5r6aFKArbh6bL2hZYjYZyrMzYH1Q1fHZDURr	115	1	202	1	\N
5	103	157	1	26783574000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	103	202	1	216750000000	1133	2n2T54EchQzrtTCktFM2vWfTUuArBT2z8xqi8LuUuPWixzyDYoL4	115	1	202	1	\N
1	103	241	1	5704000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	105	168	1	28941972000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	105	202	1	213750000000	1145	2n14RkbQxB9hcQ4mjCMKg2PsEcoY8V61i6Av28tacPkxyprEgM7f	115	1	202	1	\N
7	107	168	1	29670722000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	107	202	1	205000000000	1180	2n1wkvBQEjK9rsJkyeDLqBxfDNqgo7uTbYWJEe2kfxGTNJhf9gYX	115	1	202	1	\N
5	109	157	1	27506574000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	109	202	1	202000000000	1192	2n1XDniwSKktgRXbWmuyWKvdtD8LhfYZYoTUJFnCo11SDGFFt2tu	115	1	202	1	\N
7	111	168	1	30396722000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	111	202	1	196000000000	1216	2n29Nm5oTAcRUQ5Zr55AbHwCupxRZJnuYAT5CPZPbyQqWppCKSYk	115	1	202	1	\N
7	113	168	1	31116360000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	113	202	1	190250000000	1239	2n244bdpdyt4hDwuuvSWSwTreVHU2qwPgteTQcCb5YWnNKc4RCzM	115	1	202	1	\N
1	113	241	1	5816000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	115	157	1	28955574000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	115	202	1	187250000000	1251	2n1iAo2xtoCfjgWGN9s5hNjLjsJWfVgo1pvM51P3BcQfCacLqeHP	115	1	202	1	\N
5	117	157	1	29678324000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	117	202	1	181500000000	1274	2n23jmDPUbDMCMRMAmAU7cmjozYG9oobXBiR7EfwmfgBmQTxpTSa	115	1	202	1	\N
7	119	168	1	32562360000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	119	202	1	178500000000	1286	2n1oAYhMyDKMZktV3sYhN13m7Qc6DcQc1c4kg8rmzj4umLGAwTbH	115	1	202	1	\N
5	94	157	1	23891686000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	94	202	1	240250000000	1039	2n1omrDKWvDcGbiZQfDjmVAQK4b5aAjNMBBsXUbRARA6cQUAsuri	115	1	202	1	\N
7	96	168	1	26773222000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	96	202	1	231500000000	1074	2n1TBYaQsbjBGxMFkdU1gkyTpeegayAejFE7DRVNsmFXbMitF6fC	115	1	202	1	\N
5	98	157	1	25337686000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	98	202	1	225500000000	1098	2n183nu6hoD3ojL5TNtLTP1EtMqxTWE852gVNLcBydZXepvo2Cga	115	1	202	1	\N
5	100	157	1	26060436000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	100	202	1	222750000000	1109	2n1FyQzpc6pTtDVfLByP8pxfT3HFb8u87KL7SecR5PFu8EbpBoLy	115	1	202	1	\N
5	102	157	1	26060686000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	102	202	1	219750000000	1121	2n1SsHsPNTTRH63X5r6aFKArbh6bL2hZYjYZyrMzYH1Q1fHZDURr	115	1	202	1	\N
7	104	168	1	28941860000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	104	202	1	216750000000	1133	2n2T54EchQzrtTCktFM2vWfTUuArBT2z8xqi8LuUuPWixzyDYoL4	115	1	202	1	\N
1	104	241	1	5704000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	106	157	1	27512324000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	106	202	1	205000000000	1180	2n1wkvBQEjK9rsJkyeDLqBxfDNqgo7uTbYWJEe2kfxGTNJhf9gYX	115	1	202	1	\N
7	108	168	1	30393722000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	108	202	1	202000000000	1192	2n1XDniwSKktgRXbWmuyWKvdtD8LhfYZYoTUJFnCo11SDGFFt2tu	115	1	202	1	\N
5	110	157	1	28232574000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	110	202	1	196000000000	1216	2n29Nm5oTAcRUQ5Zr55AbHwCupxRZJnuYAT5CPZPbyQqWppCKSYk	115	1	202	1	\N
7	112	168	1	30393472000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	112	202	1	193250000000	1227	2n1GxFj9bdjZguqU1A92BBY5TbEXv9T5VpWK2THjvggZ2usKnpoY	115	1	202	1	\N
7	114	168	1	31839360000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	114	202	1	187250000000	1251	2n1iAo2xtoCfjgWGN9s5hNjLjsJWfVgo1pvM51P3BcQfCacLqeHP	115	1	202	1	\N
5	116	157	1	28955324000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	116	202	1	184500000000	1262	2n1LMBKo4dCuhHi8oMX3LYtVWWGoxUKqkrdgqWrPPv9cMXqMVD7L	115	1	202	1	\N
7	118	168	1	32562360000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	118	202	1	181500000000	1274	2n23jmDPUbDMCMRMAmAU7cmjozYG9oobXBiR7EfwmfgBmQTxpTSa	115	1	202	1	\N
7	120	168	1	33285110000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	120	202	1	175750000000	1297	2n2A32trbym6ZFm67P4LXjQNegTn1mwHoXvq5tUaL5tgJ6qETcMb	115	1	202	1	\N
5	121	157	1	30401074000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	121	202	1	175750000000	1297	2n2A32trbym6ZFm67P4LXjQNegTn1mwHoXvq5tUaL5tgJ6qETcMb	115	1	202	1	\N
7	122	168	1	33285360000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	122	202	1	172750000000	1309	2n2BWdzQfmMGZuqfSXfQFtjdLqUKTvxBVMsbusWYj8FbHawkKrf3	115	1	202	1	\N
5	123	157	1	31124074000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	123	202	1	172750000000	1309	2n2BWdzQfmMGZuqfSXfQFtjdLqUKTvxBVMsbusWYj8FbHawkKrf3	115	1	202	1	\N
5	124	157	1	31124074000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	124	202	1	169750000000	1321	2n1AGyJG94qYbWh2T5bFF3Rb37Cj5iBZpaa6MHj3gpXitnSpg8wS	115	1	202	1	\N
7	125	168	1	34008360000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	125	202	1	169750000000	1321	2n1AGyJG94qYbWh2T5bFF3Rb37Cj5iBZpaa6MHj3gpXitnSpg8wS	115	1	202	1	\N
7	126	168	1	34011110000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	126	202	1	164000000000	1344	2n1uiT6XqBcpjtkHhQ53Qo6caNK196UK8a48wE9hvvnCXU9vzH1T	115	1	202	1	\N
5	127	157	1	31849824000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	127	202	1	164000000000	1344	2n1uiT6XqBcpjtkHhQ53Qo6caNK196UK8a48wE9hvvnCXU9vzH1T	115	1	202	1	\N
7	128	168	1	34008240000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	128	202	1	161000000000	1356	2n1wQQBfCFLZDx7jdU1CrnefU96b54Ef6HMtkt1cBaACuPrVn68z	115	1	202	1	\N
1	128	241	1	5936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	129	157	1	32572824000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	129	202	1	158000000000	1368	2mzajeY1KucXRBxt8RE7Z5nrJ4jfP3UUxeDUJhVca921w7Ndt4Lz	115	1	202	1	\N
7	130	168	1	34731240000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	130	202	1	158000000000	1368	2mzajeY1KucXRBxt8RE7Z5nrJ4jfP3UUxeDUJhVca921w7Ndt4Lz	115	1	202	1	\N
5	131	157	1	33295574000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	131	202	1	155250000000	1379	2n1fAUyawHReeBLkKsX1n1BnHhFsYsbranAmssL4GAPnJFqd47Pw	115	1	202	1	\N
7	132	168	1	34730990000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	132	202	1	155250000000	1379	2n1fAUyawHReeBLkKsX1n1BnHhFsYsbranAmssL4GAPnJFqd47Pw	115	1	202	1	\N
5	133	157	1	34018574000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	133	202	1	152250000000	1391	2n1vPG93FLhigA68XoCyanPFLzhxYQ3PDyaxAyuCabjaJt6Uwgtd	115	1	202	1	\N
7	135	168	1	35454240000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	135	202	1	149250000000	1403	2n2Ey12hmhZzpyS2cwKUNp1qKLM8heyf8PRaAf6CFWt8sPz1qUiE	115	1	202	1	\N
7	137	168	1	35453990000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	137	202	1	146500000000	1414	2n1Z2Te4ebW1EVsNq8w3Fd2ApaN9XhGhBW3EsjkpyheV36pyzvsf	115	1	202	1	\N
7	139	168	1	36176990000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	139	202	1	143500000000	1426	2n1mS45YVXA5kLqpz3aZADfGFFASv6QiAXBaLjksXwtiATcaYKWr	115	1	202	1	\N
7	141	168	1	36899990000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	141	202	1	137750000000	1449	2n1g5NHrcSYeNdNsmNGojQFYioweaAyw5fTEwLnhnQY4tk44ECiz	115	1	202	1	\N
5	143	157	1	35467324000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	143	202	1	128750000000	1485	2n1qtggTTGL2eCNftFGuJyhsb1QtHzMEmfGtJeXEi8fn1nuQ2Nep	115	1	202	1	\N
5	145	157	1	36916074000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	145	202	1	120000000000	1520	2mzZykDLsnPVycnYLHg6PSMP7tsJ62YUu2XazsH2VcEqoLXPkW85	115	1	202	1	\N
5	147	157	1	38362074000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	147	202	1	114000000000	1544	2n1wzjG7z4xbUsvntTF5Jsv9pgxnvPd1Vrd1Z5RiFHi28kVFkBid	115	1	202	1	\N
7	149	168	1	38351519000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	149	202	1	105250000000	1579	2n2QbRD8kwjr1jNZJr68ApEa7TjXKc1a6YBfvJqSS9tUUeeYAPGK	115	1	202	1	\N
1	149	241	1	6157000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	151	168	1	39074601000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	151	202	1	93500000000	1626	2n1Qj8TetXirhPqU3yEMcysgrCnZ6EutTEsmCcZ69beNLdpozY9X	115	1	202	1	\N
5	153	157	1	39813723000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	153	202	1	90500000000	1638	2mzcxydbt7XnMaRLqUZLan27H2JFsjTv7GbUTMJyb4riCcUYvZ5n	115	1	202	1	\N
5	155	157	1	40536473000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	155	202	1	87750000000	1649	2mzpHJayN98jYFcby2N3xdjrHhfsta4dL13uju2x9TwaW2UihRwF	115	1	202	1	\N
5	157	157	1	40536723000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	157	202	1	84750000000	1661	2n1TLcipFE2JiZzcEdPS7S1dBRieBZaLGo9opwFZLia63wQWXvTK	115	1	202	1	\N
7	159	168	1	40523101000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	159	202	1	79000000000	1684	2mzxc5EkaPyKygez2QhqriHKpJf4j2sufmbkaVPSxWSMTZiY1xcp	115	1	202	1	\N
7	161	168	1	41974977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	161	202	1	67000000000	1732	2n28V7dLMjbsFMD1tKQi7KYnHiScVj6eTTU2ywC8ahGtQK5UNNvV	115	1	202	1	\N
7	163	168	1	43420727000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	163	202	1	61250000000	1755	2n2AgbCAAdz8q1Ji9AJERBM88Wbd7w72DJXp4HrZqagCVQ5aEW32	115	1	202	1	\N
5	165	157	1	41259723000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	165	202	1	58250000000	1767	2n1UmSxMYUrWQ42pxdoruMpg23X1HdNsLdT3r2G3ToNKTB4iPKRK	115	1	202	1	\N
5	167	157	1	41268130000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	167	202	1	46750000000	1813	2n12ruBsjiXEMTGYziBDEXq2LNxbSYgv2gepzF8C5oS98wNFf5EU	115	1	202	1	\N
1	167	241	1	6393000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	134	168	1	34731240000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	134	202	1	152250000000	1391	2n1vPG93FLhigA68XoCyanPFLzhxYQ3PDyaxAyuCabjaJt6Uwgtd	115	1	202	1	\N
5	136	157	1	34018574000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	136	202	1	149250000000	1403	2n2Ey12hmhZzpyS2cwKUNp1qKLM8heyf8PRaAf6CFWt8sPz1qUiE	115	1	202	1	\N
5	138	157	1	34741574000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	138	202	1	143500000000	1426	2n1mS45YVXA5kLqpz3aZADfGFFASv6QiAXBaLjksXwtiATcaYKWr	115	1	202	1	\N
5	140	157	1	34741324000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	140	202	1	140750000000	1437	2mzkhmqVJM9Ddb6vbpXLEAyJu8yQKiDkVwpzV49mAHunF5VeHETZ	115	1	202	1	\N
7	142	168	1	37622870000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	142	202	1	134750000000	1461	2n25U9shDUgbSpcuYE1iAAcuq9tdjg62H6dM6YkR1hg6zBbuLJjC	115	1	202	1	\N
1	142	241	1	6056000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	144	157	1	36190324000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	144	202	1	125750000000	1497	2n2DYWzAuVzv2Ty3ZsuAFU3juxQ3SKwY9yBNbwrz3DJ6psKhKps6	115	1	202	1	\N
5	146	157	1	37639074000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	146	202	1	117000000000	1532	2mzwqsfayQbDtp4XjJ8KPJUy6tG3awWmr39bgERim65yexetpTF9	115	1	202	1	\N
5	148	157	1	39090723000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	148	202	1	105250000000	1579	2n2QbRD8kwjr1jNZJr68ApEa7TjXKc1a6YBfvJqSS9tUUeeYAPGK	115	1	202	1	\N
1	148	241	1	6157000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	150	168	1	38345851000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	150	202	1	102250000000	1591	2n1q8ExUsA1ZJUfV8BoFqTpwNS1DpdBJ9eJULR1753UMTbkuKGeP	115	1	202	1	\N
1	150	241	1	6176000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	152	168	1	39797601000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	152	202	1	90500000000	1638	2mzcxydbt7XnMaRLqUZLan27H2JFsjTv7GbUTMJyb4riCcUYvZ5n	115	1	202	1	\N
7	154	168	1	39797351000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	154	202	1	87750000000	1649	2mzpHJayN98jYFcby2N3xdjrHhfsta4dL13uju2x9TwaW2UihRwF	115	1	202	1	\N
7	156	168	1	40520351000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	156	202	1	84750000000	1661	2n1TLcipFE2JiZzcEdPS7S1dBRieBZaLGo9opwFZLia63wQWXvTK	115	1	202	1	\N
5	158	157	1	41262473000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	158	202	1	79000000000	1684	2mzxc5EkaPyKygez2QhqriHKpJf4j2sufmbkaVPSxWSMTZiY1xcp	115	1	202	1	\N
7	160	168	1	41248977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	160	202	1	73000000000	1708	2n2H42tk25mS6e4Q5uynN5J2vJG8H2H38GuYSotsDgMXPmz6ouzf	115	1	202	1	\N
1	160	241	1	6300000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	162	168	1	42697977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	162	202	1	64000000000	1744	2mzvtSygajNK8CSefgUTBD3HWdMAg5WbhH2xcJkTbSZ2CpoVjado	115	1	202	1	\N
7	164	168	1	44143727000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	164	202	1	58250000000	1767	2n1UmSxMYUrWQ42pxdoruMpg23X1HdNsLdT3r2G3ToNKTB4iPKRK	115	1	202	1	\N
7	166	168	1	44875134000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	166	202	1	46750000000	1813	2n12ruBsjiXEMTGYziBDEXq2LNxbSYgv2gepzF8C5oS98wNFf5EU	115	1	202	1	\N
1	166	241	1	6393000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	168	157	1	41990849000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	168	202	1	44000000000	1824	2n175iCxATWP5DPZ8u9Ukqu5YRNS2SCs2cFgg7QFoHNnGST1GpF6	115	1	202	1	\N
1	168	241	1	6424000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	169	168	1	44866477000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	169	202	1	41250000000	1835	2n1K4wwZFSc4tBjLnKxASEfBN5XQaVNfzgqGFSq5bQP9D75geM4A	115	1	202	1	\N
5	170	157	1	42713849000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	170	202	1	38250000000	1847	2n1xYfFrf2yAPrG1qdUgo4X15ZGtjW6dX2kvbZp8Pko2jkhjj5Su	115	1	202	1	\N
7	171	168	1	45589477000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	171	202	1	35250000000	1859	2n1k15TvEMy1w4j7sWb95iud8YSrwsP2XVE8KFVeGnFa4YXDZ7UH	115	1	202	1	\N
7	172	168	1	46312477000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	172	202	1	32250000000	1871	2n29MMTDhTUWVBDyvr96F1hczx5udsvGxz5C22ccyQRa8sJcVmXo	115	1	202	1	\N
5	173	157	1	43436599000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	173	202	1	29500000000	1882	2n1k2zcigJcuDaZaopuEDHZvHBmsFadgdo9qUcsLMPaj2M8xUFSk	115	1	202	1	\N
7	174	168	1	47035477000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	174	202	1	26500000000	1894	2n25AXZ9EUKp77PvSHec4mW2JQecZ2LEThoaBCrtdY8yCSYFAhoW	115	1	202	1	\N
5	175	157	1	44159599000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	175	202	1	26500000000	1894	2n25AXZ9EUKp77PvSHec4mW2JQecZ2LEThoaBCrtdY8yCSYFAhoW	115	1	202	1	\N
5	177	157	1	44159476000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	177	202	1	20500000000	1918	2mziQsqkgay1ahCjefxtx6havcgJCE2nnDSJQsSmDq9k2Au4ijCc	115	1	202	1	\N
1	177	241	1	6547000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	179	157	1	45605225000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	179	202	1	14750000000	1941	2n21sQHK8FUaWRYeCexm8Bx2C94E6WEEoYP4Ys32xUkrwwrKPqGR	115	1	202	1	\N
7	181	168	1	48480727000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	181	202	1	9750000000	1961	2n2EoMYpJti72DNJHnNurLZsJVi8mN8AJUoaHGSetmzMJsJGynVb	115	1	202	1	\N
7	183	168	1	49202477000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	183	202	1	8000000000	1968	2mzxQnVWVqE1c73Gx4L7rsg5KqbQ6Nke5Zy9d8bK8PKi3t2qjsBU	115	1	202	1	\N
7	185	168	1	49923727000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	185	202	1	5250000000	1979	2n1Cq7WqrnCbZ3Y9Wq6wEjrCrJdrQZw8SASWBa9ASG4YTJTe1eGC	115	1	202	1	\N
5	187	157	1	47770225000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	187	202	1	3500000000	1986	2n1yirhWjna51i9Tzcc8ZhnKxAaccaKembagyMydVUYDP5nhMKWz	115	1	202	1	\N
5	189	157	1	48490725000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	189	202	1	3000000000	1988	2n1rpfqhFrDb7QpZvr6jn8TDza3iazoeqozJw5Un39k8kr9TLU71	115	1	202	1	\N
5	191	157	1	48490725000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	191	202	1	2500000000	1990	2n2FTSyJPUxjkLE8MhF3xPYCYfXoYWp4ZomxNPYkGikYKmtBLKbQ	115	1	202	1	\N
7	193	168	1	52805977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	193	202	1	1750000000	1993	2n1PGutxnBxbTVPNsfdvCQstLzfXsCUwyC77zqu1dT1UxBPQSGAW	115	1	202	1	\N
5	195	157	1	49210975000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	195	202	1	1500000000	1994	2mzbKtFeHjsHT89ibH3mCDjMF6wF5cBnCyqJGUuQ7mV5X1WFi7MQ	115	1	202	1	\N
7	197	168	1	53526227000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	197	202	1	1250000000	1995	2mzXq9VqowWaLt5TYEUHyxKzqwFARcQmMGCk66VYxX5fEmLdk8Bm	115	1	202	1	\N
5	199	157	1	51371475000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
5	201	157	1	52811475000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
5	203	157	1	53531475000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
7	205	168	1	53525977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
5	207	157	1	54251475000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
7	209	168	1	55685977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
5	211	157	1	54251474000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	211	241	1	6549000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	213	157	1	54971473000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	213	241	1	6551000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	215	157	1	56411471000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	215	241	1	6553000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	217	157	1	56411471000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	217	241	1	6554000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	219	168	1	57845974000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	219	241	1	6556000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	221	157	1	57851469000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	221	241	1	6557000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	223	168	1	58565973000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	223	241	1	6559000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	225	157	1	59291467000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	225	241	1	6560000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	176	168	1	47758477000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	176	202	1	23500000000	1906	2n18Y2nxNT8Hr77PwnyjxMLxQRDeKvT5XqSLT1Bdh9uv81apse36	115	1	202	1	\N
5	178	157	1	44882225000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	178	202	1	17750000000	1929	2n1JA12C8owvMceqHC5SGLngm4zLWSLhgjMKDDSJwGYw3aJEfp8E	115	1	202	1	\N
1	178	241	1	6548000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	180	157	1	46327975000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	180	202	1	12000000000	1952	2mzgXjH86iSxgWkeNe1qBnZ8SLMF6Nts2F7YBHqW5sgrdVpWaJKj	115	1	202	1	\N
5	182	157	1	47050225000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	182	202	1	9750000000	1961	2n2EoMYpJti72DNJHnNurLZsJVi8mN8AJUoaHGSetmzMJsJGynVb	115	1	202	1	\N
5	184	157	1	47049475000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	184	202	1	6500000000	1974	2n1UomEVQiyhVzEZrvXB78HTLAoMw85f6dPJEX1cZp3FV3Qotomd	115	1	202	1	\N
7	186	168	1	50644727000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	186	202	1	4250000000	1983	2n1y26G3CNHWEAjXhMNq7hFpLEJFZoCJmGWfpHjqbETMH59sZDmF	115	1	202	1	\N
7	188	168	1	51365227000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	188	202	1	3000000000	1988	2n1rpfqhFrDb7QpZvr6jn8TDza3iazoeqozJw5Un39k8kr9TLU71	115	1	202	1	\N
7	190	168	1	52085727000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	190	202	1	2500000000	1990	2n2FTSyJPUxjkLE8MhF3xPYCYfXoYWp4ZomxNPYkGikYKmtBLKbQ	115	1	202	1	\N
5	192	157	1	48490725000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	192	202	1	2000000000	1992	2n1U7tWBuwdxJ78MDhbMh9SgkhU3h826arWjqkBVFnK4UvX4oHSY	115	1	202	1	\N
7	194	168	1	53526227000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
3	194	202	1	1500000000	1994	2mzbKtFeHjsHT89ibH3mCDjMF6wF5cBnCyqJGUuQ7mV5X1WFi7MQ	115	1	202	1	\N
5	196	157	1	49931225000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	196	202	1	1250000000	1995	2mzXq9VqowWaLt5TYEUHyxKzqwFARcQmMGCk66VYxX5fEmLdk8Bm	115	1	202	1	\N
5	198	157	1	50651475000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
3	198	202	1	1000000000	1996	2n27kHqyePg23K5GkihNpfBajwFJESb73wn12Wk6tmNMLsWfHfS1	115	1	202	1	\N
5	200	157	1	52091475000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
7	202	168	1	53525977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
7	204	168	1	53525977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
7	206	168	1	54245977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
7	208	168	1	54965977000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
7	210	168	1	56405976000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	210	241	1	6549000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	212	168	1	56405976000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	212	241	1	6550000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	214	157	1	55691472000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	214	241	1	6552000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	216	168	1	57125975000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	216	241	1	6553000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	218	157	1	57131470000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	218	241	1	6555000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	220	157	1	57851469000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	220	241	1	6556000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	222	157	1	58571468000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	222	241	1	6558000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	224	157	1	59291467000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	224	241	1	6559000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	226	168	1	59285972000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	226	241	1	6560000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	227	168	1	59285972000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	227	241	1	6561000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	228	157	1	60011466000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	228	241	1	6561000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	229	168	1	59285972000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	229	241	1	6562000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	230	157	1	60731465000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	230	241	1	6563000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	232	168	1	60005971000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	232	241	1	6565000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	234	168	1	60005971000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	234	241	1	6566000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	236	168	1	60725970000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	236	241	1	6567000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	238	157	1	63611461000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	238	241	1	6569000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	240	157	1	64331460000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	240	241	1	6570000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	242	157	1	64331460000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	242	241	1	6571000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	244	157	1	65771458000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	244	241	1	6573000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	246	157	1	65771458000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	246	241	1	6574000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	248	157	1	66491457000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	248	241	1	6576000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	250	168	1	64325965000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	250	241	1	6577000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	252	168	1	65765963000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	252	241	1	6579000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	254	168	1	66485962000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	254	241	1	6580000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	256	168	1	67925960000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	256	241	1	6582000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	258	168	1	67925960000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	258	241	1	6583000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	260	168	1	68645959000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	260	241	1	6584000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	262	168	1	68645959000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	262	241	1	6586000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	264	168	1	69365958000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	264	241	1	6587000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	266	168	1	70085957000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	266	241	1	6589000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	268	168	1	71525955000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	268	241	1	6591000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	270	168	1	71525955000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	270	241	1	6592000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	272	157	1	70091452000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	272	241	1	6594000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	274	157	1	70091452000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	274	241	1	6595000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	276	157	1	70811451000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	276	241	1	6596000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	278	157	1	71531450000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	278	241	1	6597000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	280	157	1	71531450000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	280	241	1	6598000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	282	168	1	74405951000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	282	241	1	6599000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	284	157	1	72251449000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	284	241	1	6601000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	231	157	1	61451464000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	231	241	1	6564000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	233	157	1	62171463000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	233	241	1	6565000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	235	157	1	62891462000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	235	241	1	6566000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	237	157	1	62891462000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	237	241	1	6568000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	239	168	1	61445969000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	239	241	1	6569000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	241	168	1	61445969000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	241	241	1	6570000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	243	157	1	65051459000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	243	241	1	6572000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	245	168	1	62165968000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	245	241	1	6573000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	247	168	1	62885967000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	247	241	1	6575000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	249	168	1	63605966000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	249	241	1	6576000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	251	168	1	65045964000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	251	241	1	6578000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	253	157	1	66491457000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	253	241	1	6579000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	255	168	1	67205961000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	255	241	1	6581000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	257	157	1	66491457000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	257	241	1	6582000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	259	157	1	67211456000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	259	241	1	6584000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	261	157	1	67931455000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	261	241	1	6585000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	263	157	1	68651454000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	263	241	1	6586000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	265	157	1	68651454000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	265	241	1	6588000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	267	168	1	70805956000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	267	241	1	6590000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	269	157	1	69371453000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	269	241	1	6591000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	271	168	1	72245954000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	271	241	1	6593000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	273	168	1	72965953000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	273	241	1	6594000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	275	168	1	73685952000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	275	241	1	6595000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	277	168	1	73685952000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	277	241	1	6597000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	279	168	1	74405951000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	279	241	1	6598000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	281	157	1	72251449000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	281	241	1	6599000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	283	168	1	75125950000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	283	241	1	6600000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	285	168	1	75845949000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	285	241	1	6601000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	287	168	1	76565948000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	287	241	1	6603000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	286	168	1	75845949000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	286	241	1	6602000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	288	157	1	72971448000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	288	241	1	6603000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	289	168	1	76565948000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	289	241	1	6604000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	290	168	1	77285947000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	290	241	1	6605000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	291	168	1	78005946000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	291	241	1	6606000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	292	157	1	73691447000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	292	241	1	6606000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	293	168	1	78005946000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	293	241	1	6607000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	294	168	1	78725945000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	294	241	1	6608000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	295	157	1	74411446000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	295	241	1	6609000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	296	168	1	79445944000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	296	241	1	6610000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	297	157	1	75131445000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	297	241	1	6610000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	298	157	1	75851444000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	298	241	1	6611000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	299	157	1	76571443000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	299	241	1	6612000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	300	168	1	79445944000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	300	241	1	6613000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	301	157	1	77291442000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	301	241	1	6613000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	302	168	1	80165943000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	302	241	1	6614000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	303	157	1	77291442000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	303	241	1	6614000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	304	157	1	77291442000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	304	241	1	6615000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	305	168	1	80885942000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	305	241	1	6615000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	306	157	1	77291442000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	306	241	1	6616000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	307	168	1	81605941000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	307	241	1	6616000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	308	157	1	77291442000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	308	241	1	6617000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	309	168	1	82325940000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	309	241	1	6617000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	310	168	1	83045939000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	310	241	1	6618000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	311	157	1	77291442000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	311	241	1	6619000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	312	157	1	78011441000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	312	241	1	6620000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	313	168	1	83765938000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	313	241	1	6621000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	314	157	1	78731440000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	314	241	1	6622000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	316	157	1	80171438000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	316	241	1	6624000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	318	168	1	84485937000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	318	241	1	6625000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	320	168	1	85925935000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	320	241	1	6627000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	322	157	1	81611436000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	322	241	1	6628000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	324	168	1	85925935000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	324	241	1	6629000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	326	157	1	83771433000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	326	241	1	6631000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	328	168	1	86645934000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	328	241	1	6633000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	330	168	1	87365933000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	330	241	1	6635000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	332	157	1	85931430000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	332	241	1	6637000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	334	168	1	88085932000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	334	241	1	6639000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	336	157	1	88091427000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	336	241	1	6641000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	338	168	1	88805931000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	338	241	1	6642000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	340	157	1	89531425000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	340	241	1	6644000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	342	157	1	89531425000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	342	241	1	6645000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	344	157	1	90251424000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	344	241	1	6647000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	346	157	1	90971423000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	346	241	1	6649000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	348	168	1	91685927000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	348	241	1	6650000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	350	168	1	92405926000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	350	241	1	6651000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	352	168	1	93125925000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	352	241	1	6652000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	354	168	1	93125925000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	354	241	1	6653000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	315	157	1	79451439000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	315	241	1	6623000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	317	157	1	80891437000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	317	241	1	6625000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	319	168	1	85205936000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	319	241	1	6626000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	321	157	1	80891437000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	321	241	1	6627000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	323	157	1	82331435000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	323	241	1	6629000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	325	157	1	83051434000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	325	241	1	6630000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	327	168	1	85925935000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	327	241	1	6632000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	329	157	1	84491432000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	329	241	1	6634000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	331	157	1	85211431000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	331	241	1	6636000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	333	157	1	86651429000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	333	241	1	6638000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	335	157	1	87371428000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	335	241	1	6640000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	337	157	1	88811426000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	337	241	1	6642000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	339	157	1	88811426000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	339	241	1	6643000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	341	168	1	89525930000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	341	241	1	6644000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	343	168	1	90245929000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	343	241	1	6646000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	345	168	1	90965928000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	345	241	1	6648000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	347	168	1	91685927000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	347	241	1	6649000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	349	157	1	91691422000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	349	241	1	6650000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	351	157	1	91691422000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	351	241	1	6651000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	353	157	1	91691422000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	353	241	1	6652000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	355	157	1	92411421000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	355	241	1	6654000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	356	157	1	93131420000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	356	241	1	6655000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	357	157	1	93851419000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	357	241	1	6656000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	358	168	1	93845924000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	358	241	1	6657000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	359	157	1	94571418000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	359	241	1	6658000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	360	168	1	94565923000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	360	241	1	6659000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	361	168	1	95285922000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	361	241	1	6660000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	362	157	1	95291417000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	362	241	1	6661000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	364	168	1	96005921000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	364	241	1	6662000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	366	157	1	96011416000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	366	241	1	6663000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	368	157	1	96731415000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	368	241	1	6665000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	370	168	1	98165918000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	370	241	1	6667000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	372	168	1	98885917000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	372	241	1	6669000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	374	157	1	98171413000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	374	241	1	6670000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	376	168	1	100325915000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	376	241	1	6672000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	378	168	1	101045914000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	378	241	1	6673000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	380	157	1	99611412000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
5	382	157	1	101051411000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	382	241	1	6675000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	384	168	1	101765913000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	384	241	1	6676000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	386	168	1	102485912000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	386	241	1	6677000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	388	168	1	102485912000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	388	241	1	6678000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	390	157	1	102491409000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	390	241	1	6679000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	392	168	1	103925910000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	392	241	1	6680000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	394	168	1	103925910000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	394	241	1	6681000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	396	168	1	104645909000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	396	241	1	6682000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	398	157	1	103211408000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	398	241	1	6683000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	400	168	1	106085907000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	400	241	1	6685000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	402	168	1	106805906000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	402	241	1	6686000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	404	168	1	106805906000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	404	241	1	6687000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	406	157	1	104651406000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	406	241	1	6688000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	408	168	1	107525905000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	408	241	1	6689000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	410	157	1	105371405000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	410	241	1	6690000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	412	157	1	106091404000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	412	241	1	6692000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	414	168	1	108965903000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	414	241	1	6694000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	416	157	1	107531402000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	416	241	1	6695000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	418	168	1	111125900000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
5	363	157	1	96011416000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	363	241	1	6662000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	365	168	1	96725920000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	365	241	1	6663000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	367	157	1	96011416000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	367	241	1	6664000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	369	168	1	97445919000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	369	241	1	6666000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	371	157	1	97451414000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	371	241	1	6668000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	373	168	1	99605916000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	373	241	1	6670000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	375	168	1	99605916000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	375	241	1	6671000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	377	157	1	98891412000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	377	241	1	6673000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	379	157	1	98891412000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	379	241	1	6674000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	381	157	1	100331412000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
5	383	157	1	101771410000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	383	241	1	6676000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	385	157	1	101771410000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	385	241	1	6677000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
3	387	202	1	720999000000	1996	2n27kHqyePg23K5GkihNpfBajwFJESb73wn12Wk6tmNMLsWfHfS1	115	1	202	1	\N
1	387	241	1	6677000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	389	157	1	102491409000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	389	241	1	6678000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	391	168	1	103205911000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	391	241	1	6679000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	393	157	1	102491409000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	393	241	1	6680000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	395	157	1	103211408000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	395	241	1	6682000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	397	168	1	105365908000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	397	241	1	6683000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	399	157	1	103211408000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	399	241	1	6684000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	401	157	1	103931407000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	401	241	1	6685000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	403	157	1	103931407000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	403	241	1	6686000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	405	168	1	107525905000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	405	241	1	6688000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	407	157	1	105371405000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	407	241	1	6689000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	409	168	1	108245904000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	409	241	1	6690000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	411	157	1	105371405000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	411	241	1	6691000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	413	157	1	106811403000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	413	241	1	6693000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	415	168	1	109685902000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	415	241	1	6695000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	417	168	1	110405901000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	417	241	1	6696000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
1	418	241	1	6697000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	420	157	1	107531402000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	420	241	1	6699000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	422	168	1	112565898000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	422	241	1	6701000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	424	168	1	113285897000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	424	241	1	6702000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	426	157	1	109691399000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	426	241	1	6704000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	428	157	1	110411398000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	428	241	1	6705000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	430	157	1	111131397000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	430	241	1	6707000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	419	168	1	111845899000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	419	241	1	6698000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	421	157	1	108251401000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	421	241	1	6700000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	423	157	1	108971400000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	423	241	1	6701000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	425	157	1	108971400000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	425	241	1	6703000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	427	168	1	114005896000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	427	241	1	6705000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	429	157	1	110411398000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	429	241	1	6706000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	431	157	1	111851396000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	431	241	1	6708000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	432	168	1	114725895000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	432	241	1	6709000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	433	157	1	112571395000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	433	241	1	6710000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	434	157	1	113291394000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	434	241	1	6711000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	435	168	1	115445894000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	435	241	1	6712000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	436	157	1	114011393000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	436	241	1	6713000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	437	168	1	116165893000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	437	241	1	6713000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	438	168	1	116885892000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	438	241	1	6714000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	439	157	1	114011393000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	439	241	1	6715000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	440	168	1	117605891000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	440	241	1	6716000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	441	157	1	114731392000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	441	241	1	6716000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	442	168	1	117605891000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	442	241	1	6717000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	443	157	1	115451391000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	443	241	1	6717000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	444	157	1	115451391000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	444	241	1	6718000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	445	168	1	118325890000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	445	241	1	6718000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
5	446	157	1	115451391000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	96	1	157	1	\N
1	446	241	1	6719000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
7	447	168	1	119045889000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	67	1	168	1	\N
1	447	241	1	6720000000	0	2mzbV7WevxLuchs2dAMY4vQBS6XttnCUF8Hvks4XNBQ5qiSGGBQe	242	1	241	1	\N
\.


--
-- Data for Name: accounts_created; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.accounts_created (block_id, account_identifier_id, creation_fee) FROM stdin;
\.


--
-- Data for Name: blocks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.blocks (id, state_hash, parent_id, parent_hash, creator_id, block_winner_id, last_vrf_output, snarked_ledger_hash_id, staking_epoch_data_id, next_epoch_data_id, min_window_density, sub_window_densities, total_currency, ledger_hash, height, global_slot_since_hard_fork, global_slot_since_genesis, protocol_version_id, proposed_protocol_version_id, "timestamp", chain_status) FROM stdin;
96	3NKL7eoAEEXRdEB2TtzwZLcawaS2VAsrgBgLzgUtstNCGRnMXY4V	95	3NKsXJERS4LiDDLJVjaPrPAfEVfnz9wH5o1S1JQbDomU3UUoLVNH	67	66	-xULufiJD6XxdBwJ-e7FsasOjJtuEM3L0FV2XQQ-8wk=	2	3	98	77	{4,6,2,6,6,6,3,6,4,6,6}	23166005000061388	jxPka1LHaV8vK7WLmTFvy55H9c8CgjapHsA9vGHxmGwzDXC9BKd	72	93	93	1	\N	1729643288000	canonical
98	3NKYVYjDTV1V2Ksq9vsBhBsVmGayVhhigKHuYZcgdnZFoa7DPxnR	97	3NLSCvaVhk9NUwuwGQMy95PahvheQGGNtT4toE5aNTaDtqXmpJH4	96	95	g5BgzreQvQOYh_Nqa_nA9GemjcEF-PYRGwCpV0CuEwA=	2	3	100	77	{4,6,4,6,6,6,3,6,4,6,6}	23166005000061388	jx1AVxPMQ6tKB1oGcZuEpkPu5mxnpVPPtret6CRn4k4DNeZ26mL	74	95	95	1	\N	1729643648000	canonical
4	3NKufDWrUwKDKuV5FjbgcuKcJp7rgyPwXwtwd8PmXCNLkFs22kQd	3	3NLcDfYH9Vri9z3hA1QmB8QF2BcMtxNk3pmuNH4aRaR41jPxWiJr	96	95	r_oeM4Frin6Xsl4nKz3xvlE3P5LIYXgVA2WzDvzcvQo=	2	3	6	77	{3,7,7,7,7,7,7,7,7,7,7}	23166005000061388	jwYxz99bksdpbx6ecwmiKruxhtsdw8PVAWH4Mkpsw5vV8sFjzhM	3	3	3	1	\N	1729627088000	canonical
5	3NLY71gpjYcdAspPEdjpJSEsVr2G3DZq2HCLkJyCrzhQ99Qr3vQu	4	3NKufDWrUwKDKuV5FjbgcuKcJp7rgyPwXwtwd8PmXCNLkFs22kQd	67	66	iuyCAuK42fvk9X3f1lJuNKrOWkAAsyVL2aj-q-D4mQc=	2	3	7	77	{4,7,7,7,7,7,7,7,7,7,7}	23166005000061388	jxRpVaGT6VhAuGKL4ZmsnHaYQwfK6WFwZqAoxmZWZTFsf2g2hFS	4	4	4	1	\N	1729627268000	canonical
6	3NKEJ1MgRBtLQncoqNvey8Tm25jy4pWiKAQkrSpja4h1q8GQDkEL	5	3NLY71gpjYcdAspPEdjpJSEsVr2G3DZq2HCLkJyCrzhQ99Qr3vQu	96	95	pY-YQckAEXTTlvJ46OOUrHlxB-e9UsBec2Ru9r95QAQ=	2	3	8	77	{5,7,7,7,7,7,7,7,7,7,7}	23166005000061388	jwZpUEX5sFiM9trcHBpxQCaGGo2N86kEJWqi2PTKJK1piNuEWt2	5	5	5	1	\N	1729627448000	canonical
7	3NKnSfFa73mgaZW4Cd6T1mUXbq37zY6YRXwYeZhEoevY1Xs8w5KR	5	3NLY71gpjYcdAspPEdjpJSEsVr2G3DZq2HCLkJyCrzhQ99Qr3vQu	67	66	C2hhSk6Qe85l1qFY7zUyV6PEXGStLIgEmz6PL4sFww4=	2	3	9	77	{5,7,7,7,7,7,7,7,7,7,7}	23166005000061388	jwCRX5BriSB7emenJsUvrw7NETAczRXfpJ4a8D58oZ5mAp2BBrJ	5	5	5	1	\N	1729627448000	orphaned
8	3NLuJJ5VayuHP249tDcD6fvNA4c4Z5woqmnLcwZ9RkXMQyD9r2wn	6	3NKEJ1MgRBtLQncoqNvey8Tm25jy4pWiKAQkrSpja4h1q8GQDkEL	67	66	3PkelmtWkLy9bshOC0PyruoGgLCaYqqF2Eep3Q7FkwE=	2	3	10	77	{6,7,7,7,7,7,7,7,7,7,7}	23166005000061388	jxk5tMkEiqF9P2oz57wc8N7JqtATySwnut7LULFH48Rkh92VKLx	6	6	6	1	\N	1729627628000	canonical
10	3NL6XpYnuHbMUbxu1sMEDpk5gwZdSDy16XwjuwLZPhmVafJkfNMV	8	3NLuJJ5VayuHP249tDcD6fvNA4c4Z5woqmnLcwZ9RkXMQyD9r2wn	67	66	ns-Ja77fUIKZfbAIGVRnCCy5JI1ygSc4qFYX4VmiYAA=	2	3	12	77	{6,1,7,7,7,7,7,7,7,7,7}	23166005000061388	jwcvZqprapvYs5PWGXt1KZYh7m3prQ6ybapLWSCvn1aZfdDUzcf	7	7	7	1	\N	1729627808000	canonical
9	3NKiCL8QC8oFG9otNGdKaMk4Hdx4RJiwVifV3qSNiX1AWD3soWEk	8	3NLuJJ5VayuHP249tDcD6fvNA4c4Z5woqmnLcwZ9RkXMQyD9r2wn	96	95	59MjOzNRsVraXu0Q7QvqN0mvz492xA2BcAOj8ZI_Hws=	2	3	11	77	{6,1,7,7,7,7,7,7,7,7,7}	23166005000061388	jwzDDD8sWPHe7imvetRARojq4ej66e8REMekkAypYeKG6DYBRxc	7	7	7	1	\N	1729627808000	orphaned
11	3NKpEmo7d6tfHYaHqJ6B8pvvb3EmV3GkguTooV1TGVh1jAJjZrpL	10	3NL6XpYnuHbMUbxu1sMEDpk5gwZdSDy16XwjuwLZPhmVafJkfNMV	67	66	iWFrZVPtrFxr6R4rgwIwwqVPYlozPoU5kVPwR9PsYwY=	2	3	13	77	{6,2,7,7,7,7,7,7,7,7,7}	23166005000061388	jwYNKUQJNTfsXuNEPXP1zQNfoD1FFprkuvWJErJtw5Mwym6neAg	8	10	10	1	\N	1729628348000	canonical
12	3NKztAk1ELqVngzW2PVy22FNKStWLJdryC4ghpBcdZNvAbyk2aJQ	11	3NKpEmo7d6tfHYaHqJ6B8pvvb3EmV3GkguTooV1TGVh1jAJjZrpL	96	95	KY8Gh3yzZThpic984pTowCZ_m5RYEqG1FW4BUXLSGgU=	2	3	14	77	{6,3,7,7,7,7,7,7,7,7,7}	23166005000061388	jxdyuKifpaW7xEkQ3nN4948UQcj4imUYQdW4e9ZNsCPUpHoWfqU	9	11	11	1	\N	1729628528000	canonical
13	3NK3DkfAMyvpS3EReVSHLZqZf5E7kVN3GY81YYSPzYcdQ9e4BPin	11	3NKpEmo7d6tfHYaHqJ6B8pvvb3EmV3GkguTooV1TGVh1jAJjZrpL	67	66	fmHjCVC3aHCKXI9yTv9talcD_2ja6wfTSKkytx0oCA0=	2	3	15	77	{6,3,7,7,7,7,7,7,7,7,7}	23166005000061388	jxXNQNHCmxviePzkSKCjVps7s9F2fkzfW1ugG9wfonKTugytKqo	9	11	11	1	\N	1729628528000	orphaned
14	3NLWv6pZFTHQT49ph415B9SFTFVvRX7gg6n1xHhar5BBAztj41gi	12	3NKztAk1ELqVngzW2PVy22FNKStWLJdryC4ghpBcdZNvAbyk2aJQ	96	95	d9Y-skkBZzZyLj6nnesN9tpn3D_bwBa-76vPU4FKWQE=	2	3	16	77	{6,4,7,7,7,7,7,7,7,7,7}	23166005000061388	jy1AdstvQ8zBma5h26TuWhyj7CTtjrRbkchUoit1yJZM4ZZEyZg	10	12	12	1	\N	1729628708000	canonical
15	3NK6WYVkC4kYiUmwnToiFKwoBoEM1dQUBiMX5P7DvAkuCCbdJRam	14	3NLWv6pZFTHQT49ph415B9SFTFVvRX7gg6n1xHhar5BBAztj41gi	67	66	GGpXyBnsBDVOWM0vuXNhzy1XBXua8lM504YmHXG9KAs=	2	3	17	77	{6,5,7,7,7,7,7,7,7,7,7}	23166005000061388	jxPjYzMF2ZewLvEBdurTnLW9cC6uwdmjg26KUYU63oaiKbxBEeU	11	13	13	1	\N	1729628888000	canonical
16	3NKgyuvdiWcBa9Kc7hFMfkDoGQ7nTo3dcLmFXYQiYbWJEe1bUuNU	14	3NLWv6pZFTHQT49ph415B9SFTFVvRX7gg6n1xHhar5BBAztj41gi	96	95	Hz8609gkKghq9dfzxGSilZVhJa0sMOhzIY9p1oTmVgg=	2	3	18	77	{6,5,7,7,7,7,7,7,7,7,7}	23166005000061388	jwmMG1YXpDQXoVD2Myn33zFeR8HHqteebQSS4KLDUS9oqj9a7qQ	11	13	13	1	\N	1729628888000	orphaned
17	3NKorEcgjL98MXxj8p7sPRafrTux3vi7aVun2ACLmLRPhB8JBiBZ	15	3NK6WYVkC4kYiUmwnToiFKwoBoEM1dQUBiMX5P7DvAkuCCbdJRam	67	66	EnBzeMaHMe-NT40Hxiv2W_Wfy_Hg9KIg6d1yAGCRLw8=	2	3	19	77	{6,5,1,7,7,7,7,7,7,7,7}	23166005000061388	jweF98rG76qACkxxqJ8QDYvjBsm3L2mGYwNafZKQaTTAzvaccZ8	12	14	14	1	\N	1729629068000	canonical
172	3NL97XTEAXxSVCVGazV8aDJNkAbLsGvqqBJRRbj2AdcWehLsi4mY	171	3NLrHi1LpwLoxUF2sTSP28xLMrsSsnVDgMkAWVSkJWEPtL2oSgKj	67	66	mJI-5ih4kxg9sHmRbyqBtbwZctN8pIv19QV7Ivv-Ugg=	2	3	174	77	{2,4,6,4,7,6,7,5,3,5,5}	23166005000061388	jwQep1NvMNsCXWrd5s6gJUc7Ecgf9tFBCwLmLqYfHxEdpCdoouf	124	164	164	1	\N	1729656068000	canonical
97	3NLSCvaVhk9NUwuwGQMy95PahvheQGGNtT4toE5aNTaDtqXmpJH4	96	3NKL7eoAEEXRdEB2TtzwZLcawaS2VAsrgBgLzgUtstNCGRnMXY4V	67	66	I9EPg59mVQ1s2YfNysbdHu8AqRRLKFJ3h4hi3KDLlQs=	2	3	99	77	{4,6,3,6,6,6,3,6,4,6,6}	23166005000061388	jwgkYx25fGs9uQHDrkz61SuRCGib1tDUR5AZfK2Sg7M41fXmBjR	73	94	94	1	\N	1729643468000	canonical
99	3NKSMBEkRJKQ29n586gss7GudMtqBH9HhqhVUPUxi4E8ioF1xk85	98	3NKYVYjDTV1V2Ksq9vsBhBsVmGayVhhigKHuYZcgdnZFoa7DPxnR	67	66	e6C4D-QUKEaY5y59WoUjmPgToJuL8SiFZ8IKF1y7Cgw=	2	3	101	77	{4,6,5,6,6,6,3,6,4,6,6}	23166005000061388	jwDy27UByDh8xGoLX8tXjKWhedZuo8UepZJPvwkFrpmn5azyTDL	75	96	96	1	\N	1729643828000	canonical
124	3NKMoHYXLuqfe2d95HYV1C4jiq2s6abCUHY4MbmBXPokwBR3t74h	122	3NLgAToowRQfjGFPGZzyXU4x3dkj9WVryRTbNixmBWzVMz1rkpNg	96	95	obYpYe9be4k3jlMwmjwSlqHs7EweXunMWqp4lDsRrg0=	2	3	126	77	{4,6,6,4,7,3,3,6,4,6,6}	23166005000061388	jxhhYBgHeia1eTdQ2BBoGt9fji7RzL9XY8tTTu92F8smtpe79AM	90	114	114	1	\N	1729647068000	canonical
18	3NKj41kDEyLbxFNoBLUXLePkXGeBkSs7p1h4sKqnNjSaygWZ6xu3	17	3NKorEcgjL98MXxj8p7sPRafrTux3vi7aVun2ACLmLRPhB8JBiBZ	67	66	zZBGiCxe9_mUOA3bcx-yzCpem8wUYOkrUS4hIlww9AA=	2	3	20	77	{6,5,2,7,7,7,7,7,7,7,7}	23166005000061388	jxG8V1BvDUB7BrJfcczZFkfpBaSkRu96be2gct7GSbao7VnopXj	13	15	15	1	\N	1729629248000	canonical
20	3NKrYGzURCtypvNocFigJ2ASMUgf8JB5PXG6YoX6hJEom1h2EDib	19	3NKNDSbmEkpEMrCr9n4DXDaCX3H8kpeEBvyukLkYtj6yKuiRiR1w	96	95	_SCfyycf_UBXRqk2gT_ZYSrTVooTosN2N2ubkuWIEAY=	2	3	22	77	{6,5,4,7,7,7,7,7,7,7,7}	23166005000061388	jw8nvyVuR1NPAcFiZwyxLvSb5GqUGi73rLbfZxoNUy4Fq39shv7	15	17	17	1	\N	1729629608000	canonical
22	3NLat7znyY6Maf7toM1J99VpPB7UPUPMCff83q4fbTR12sUFCMUZ	20	3NKrYGzURCtypvNocFigJ2ASMUgf8JB5PXG6YoX6hJEom1h2EDib	96	95	fGbVuRm-7R3-bEiK2UvtwZJGsmts3pn4Xqr20b6B5wc=	2	3	24	77	{6,5,5,7,7,7,7,7,7,7,7}	23166005000061388	jxMVTEKGCTZ5HUxFpPFmvDH6HRXsYbyuMxbcUAXP4P1QgJPUF4Q	16	18	18	1	\N	1729629788000	orphaned
24	3NLfEG2PnqVQcvwMEZmDNHGzSijoH9jyDLaAkrqyKDqQbRxAR2ru	21	3NKdTWpKMrG45oN5TTngfDfJYpKbF9be9RT3T4LZ7hK6fCkLcaWz	96	95	m3vW7xkghZih0L_iAR6Qo2LoFVp9u76bjq0UlodCyAg=	2	3	26	77	{6,5,6,7,7,7,7,7,7,7,7}	23166005000061388	jx4GJkHLHRKo91uXptpF7kEW1XGTNDKQyUNNXWhv9CCDHvszpgM	17	20	20	1	\N	1729630148000	canonical
26	3NKWAdjYJ9EzU9wgXAg39e5iTUridhB4zT5nyE1SHmtD1eTP7RNZ	25	3NKR2TYjo6Ytd2PjZySXgMTNSJHs3CgZP4rMMNnjSqWWVfbPD2aT	96	95	z2H5Qy6PbDFvqeZCKyJn689tAM8um7QtxPynLZl3_Qw=	2	3	28	77	{6,5,6,2,7,7,7,7,7,7,7}	23166005000061388	jwrsESj4w2ngkHKh7BrbpA6GppnkLLXtV4GGNZVJ6s4wSJjFY57	19	23	23	1	\N	1729630688000	orphaned
28	3NLQQCS5SoJZz8neUvRK9GTyFeMqU5ao4FjaHkSvGQgA2a2QooFP	27	3NK7PU2JH8UMjctt7H6TLtYs8dHqkFZniGQBWk8Grxip8EHcB1xv	96	95	f3LJ3qgNLBJLL86F5O5aPdBTWowpE2ju0gvn0Ox53Aw=	2	3	30	77	{6,5,6,3,7,7,7,7,7,7,7}	23166005000061388	jxM6iSAkb5ia4Q7Qdv2ktC8CT7ELQ513mYmpcAQ47MWKRKidMAm	20	24	24	1	\N	1729630868000	canonical
30	3NKNmdwYXcxqcxdwi9FjCQxvhub5QTP7zs6yoBiQhuGeWedWnnCf	29	3NKcycZV3Ze6mpb8qJSrsszjY7q2o5Q8xNzf8thU2tgVQeh2AQhr	67	66	1rajacZR01KbxEQd8kqd1p9zSmpT3EEa-vYU90AnQwM=	2	3	32	77	{6,5,6,5,7,7,7,7,7,7,7}	23166005000061388	jxjzCRiVkHXamTTHkjLBjUWQVYtxzoGFQYMsKYxpARoysiW7pr4	22	26	26	1	\N	1729631228000	orphaned
32	3NL5wGFLPU4o5NqMKjAWV75Ryu6pNpjX8wUJRPMSh9rQYWg8vmrt	31	3NL1LeZfKxoS8mwvv3dYGxwBfhrbu6K9x64XpsKNmBr8ENYWbmEt	67	66	jY0ngGVYDEKGqgltlElzwDfl44pjQYp2dE98lWVfTQ8=	2	3	34	77	{6,5,6,6,7,7,7,7,7,7,7}	23166005000061388	jxyzRqDrV3NauEDR6xeEweTrYmMjqvdf4L3hGyYhbVYWt9iww1q	23	27	27	1	\N	1729631408000	canonical
34	3NKEiJvoLnnoCxDhZDM5npu9LgHuCyYBiobP7BshkqYHZ5RxBLNy	32	3NL5wGFLPU4o5NqMKjAWV75Ryu6pNpjX8wUJRPMSh9rQYWg8vmrt	67	66	D7THhK0CxnpYn5tzuwW3hylKmxbZbWFfU5WSdbdUZwM=	2	3	36	77	{6,5,6,6,1,7,7,7,7,7,7}	23166005000061388	jwgGMKNjSTGNAaGw9UCXFjDMCER9ZaB5ePjQvLTgfmVUmddh1Ap	24	28	28	1	\N	1729631588000	canonical
36	3NL8vVF25CxR5tGTNMsyQhWb2aB4PyJtg6bPhzLKBFkxpCPnxRo9	34	3NKEiJvoLnnoCxDhZDM5npu9LgHuCyYBiobP7BshkqYHZ5RxBLNy	67	66	bd8VzuN-4VlDpTst4rukDTq3lo4Ct2cNhMSAKb_RWwA=	2	3	38	77	{6,5,6,6,2,7,7,7,7,7,7}	23166005000061388	jwbfPAKry5tVfZepyDPuoV2uBSLhacXbRmfgYrZsDexgHy8Q8tz	25	30	30	1	\N	1729631948000	canonical
38	3NKpVf5cZftJ1WztwhMuRZguF5WXC5ncQAqiX8N9bqTD35jpdirD	37	3NKyeXLfp1ku1SGPDyBNFMnQ4rqrJFRjgX7HHBgXVnaYQNNvGiHf	96	95	rIO4GejVKlvTJ5gPUh7wB2llt4uzotRHDuwu91sI-gs=	2	3	40	77	{6,5,6,6,4,7,7,7,7,7,7}	23166005000061388	jxZWHA8B6PH8L6G22sEADNv342cuKdXstTwEVhzp7BosAEHpW2q	27	32	32	1	\N	1729632308000	canonical
40	3NKpEwiqYsHb3uNawoATmxyhGUNq1Zbv8bVhty2QWagJbp4sGjft	39	3NLx5o8c1atdVaso3EPboA7tcDxMQhenGXoVp3wmtRhdTpojykYw	67	66	UAWNmUKjceT4Ner41Q6WqZPM4v-Q1-SCgLZVw_PMBAA=	2	3	42	77	{6,5,6,6,6,7,7,7,7,7,7}	23166005000061388	jx677Vou2zawhMNcpHCGiwjq6aYhEx7wb56N6DYARAoEdYSiLPX	29	34	34	1	\N	1729632668000	canonical
66	3NKxrB7no2kcd1wenzSBS7AjpputT6seK4RfpX3jdQeeVeWQdJ92	64	3NKutudiEDK7m6RZoMRHTCWAhUR1MLMWc64CJBhkAAhREURKCGoH	96	95	hx9rNRoY_DXD2h8WcgmKlrV_wrwrAyyUrjTWC_VMNQA=	2	3	68	77	{6,5,6,6,6,6,3,6,4,2,7}	23166005000061388	jxK2Ln8uQwBc1uimm1FfRDahB5X7H8ecqcW3XXUPX2v9KoG1oty	50	64	64	1	\N	1729638068000	orphaned
2	3NKMhhH48jsKBUkvBRUx2uSUTYdkPW3nrxcyxs5QC8bY6JupeAV5	\N	3NLKxXG3yCTXiyngU1vQmEFhys9FYRCqprgGv56i4PRqKHmEyPe4	1	1	39cyg4ZmMtnb_aFUIerNAoAJV8qtkfOpq0zFzPspjgM=	2	3	4	77	{1,7,7,7,7,7,7,7,7,7,7}	23166005000061388	jwM37UFsXLhedxf8XtCBZCNQCL49GdLQzqVuysP9Jkz8xuvYGqy	1	0	0	1	\N	1729626548000	canonical
1	3NK93bDCk2no8D7bND6uTqMHtCDkSL6r1GaauyHghfThU12wFinq	\N	3NKYJD5uqLAzaNw84ezoTkqtqoMUfahtJUwhhTPc2RZxppuWLbcY	1	1	39cyg4ZmMtnb_aFUIerNAoAJV8qtkfOpq0zFzPspjgM=	1	1	2	6	{1,2,2}	23166005000060590	jwhYGrqGPozYQH9ncWRJTNZwt9CY1yodauaD1hDSh7xdNb2fGo3	1	0	0	1	\N	1729626548000	orphaned
3	3NLcDfYH9Vri9z3hA1QmB8QF2BcMtxNk3pmuNH4aRaR41jPxWiJr	2	3NKMhhH48jsKBUkvBRUx2uSUTYdkPW3nrxcyxs5QC8bY6JupeAV5	96	95	4NYVCwPbNeScC4CHZQMj4u9AWwacA1Pyxi6oLlp6HAE=	2	3	5	77	{2,7,7,7,7,7,7,7,7,7,7}	23166005000061388	jxs9n5Ar6z3r8ZeqofGQCWQj4dWc3Vmk8N4u1BSXajxmzxzfZyk	2	2	2	1	\N	1729626908000	canonical
21	3NKdTWpKMrG45oN5TTngfDfJYpKbF9be9RT3T4LZ7hK6fCkLcaWz	20	3NKrYGzURCtypvNocFigJ2ASMUgf8JB5PXG6YoX6hJEom1h2EDib	67	66	4Um8k9v5zYB28MJBZ40Rw_t3urIOmPWWJYUHs-nbWw0=	2	3	23	77	{6,5,5,7,7,7,7,7,7,7,7}	23166005000061388	jxJkVWu5THykDypYpLPz9yJPZEX2tdWMC42frU6xpvUP77Ku3KQ	16	18	18	1	\N	1729629788000	canonical
25	3NKR2TYjo6Ytd2PjZySXgMTNSJHs3CgZP4rMMNnjSqWWVfbPD2aT	24	3NLfEG2PnqVQcvwMEZmDNHGzSijoH9jyDLaAkrqyKDqQbRxAR2ru	96	95	H7iqUtoZfb2rA_VPfxJ2cXFtRcVJeuGG5eMteNhgSgA=	2	3	27	77	{6,5,6,1,7,7,7,7,7,7,7}	23166005000061388	jwMa8S3gHsHotcD65ANV8J5dYYatu79vAZvVw6LiJuyke91miwc	18	21	21	1	\N	1729630328000	canonical
27	3NK7PU2JH8UMjctt7H6TLtYs8dHqkFZniGQBWk8Grxip8EHcB1xv	25	3NKR2TYjo6Ytd2PjZySXgMTNSJHs3CgZP4rMMNnjSqWWVfbPD2aT	67	66	Cs5BWF2Q9T9eBhsvGzflTLyYysS56eZ7adc43DcG5QE=	2	3	29	77	{6,5,6,2,7,7,7,7,7,7,7}	23166005000061388	jxjPH1oYNY6oUZMD5aLd5EQA1MWeJcdMzefemL3pLXNYizsFQrE	19	23	23	1	\N	1729630688000	canonical
29	3NKcycZV3Ze6mpb8qJSrsszjY7q2o5Q8xNzf8thU2tgVQeh2AQhr	28	3NLQQCS5SoJZz8neUvRK9GTyFeMqU5ao4FjaHkSvGQgA2a2QooFP	96	95	lu7rI_ATZ0V9NuDuotjV0vLUI63zcMHOfOCvs7P8HQw=	2	3	31	77	{6,5,6,4,7,7,7,7,7,7,7}	23166005000061388	jxRftUEpyBUcR9ZcZUWGWSmpVzQ1vs4Mg4phBzEvEEjjEjfSmJW	21	25	25	1	\N	1729631048000	canonical
31	3NL1LeZfKxoS8mwvv3dYGxwBfhrbu6K9x64XpsKNmBr8ENYWbmEt	29	3NKcycZV3Ze6mpb8qJSrsszjY7q2o5Q8xNzf8thU2tgVQeh2AQhr	96	95	o_qrMxlLKtIFZso92bLNmFBiZO83ETkr9YHi5GH-NQg=	2	3	33	77	{6,5,6,5,7,7,7,7,7,7,7}	23166005000061388	jwReVTkYj1vqsvDHh2C4rsqfbFTjhXM4Lc9WeE8q7EMaHSWbgC3	22	26	26	1	\N	1729631228000	canonical
33	3NK6VT8fciFc8Z1pSLYp6oue4ViM1TX5DCrhvXBborwwuLzgjr1v	32	3NL5wGFLPU4o5NqMKjAWV75Ryu6pNpjX8wUJRPMSh9rQYWg8vmrt	96	95	hDI5DjKROULEFTN0O540-9_7nplgAY5yxLQdct-SuAU=	2	3	35	77	{6,5,6,6,1,7,7,7,7,7,7}	23166005000061388	jxaAeNuRCziw49x1j1iTLRoTUrS9QmVFqTTDngVBaReyok2ewCy	24	28	28	1	\N	1729631588000	orphaned
35	3NKFmTbnBYJw6g1Ddde9wh1zdPhm3LGAqLzaV18KP4LngoE1VigV	34	3NKEiJvoLnnoCxDhZDM5npu9LgHuCyYBiobP7BshkqYHZ5RxBLNy	96	95	G51PJ-TZzfpvgtlfEsmc6Ho7jiqhQgIMW4F-4UX6zwA=	2	3	37	77	{6,5,6,6,2,7,7,7,7,7,7}	23166005000061388	jxUG4EmM4yB7KeEEZ7y4ZaXsbzBUwTAHtkRTMzfJvpGSode3Mc4	25	30	30	1	\N	1729631948000	orphaned
37	3NKyeXLfp1ku1SGPDyBNFMnQ4rqrJFRjgX7HHBgXVnaYQNNvGiHf	36	3NL8vVF25CxR5tGTNMsyQhWb2aB4PyJtg6bPhzLKBFkxpCPnxRo9	67	66	ummU45Rg0k0kAKwPp9jw0yt8MtfTtHHTnhHFWlyFogs=	2	3	39	77	{6,5,6,6,3,7,7,7,7,7,7}	23166005000061388	jwrKg5vEaHhW3qfBTnciNSZGtX77MWxsAxoruXrgywqCEyWzqVD	26	31	31	1	\N	1729632128000	canonical
39	3NLx5o8c1atdVaso3EPboA7tcDxMQhenGXoVp3wmtRhdTpojykYw	38	3NKpVf5cZftJ1WztwhMuRZguF5WXC5ncQAqiX8N9bqTD35jpdirD	96	95	j91GXjuRUvUJ1THKmFjnRCF0ws1ydhfxLFqAae6GFQ0=	2	3	41	77	{6,5,6,6,5,7,7,7,7,7,7}	23166005000061388	jxbxgkNKpRHnZvVQzztPo8x4sNPCKPwcyTYLrY6etEkoyyLqTDe	28	33	33	1	\N	1729632488000	canonical
41	3NKbuvS65wm9Wivcbb5eG4joC7wTQugXCxnHU1yToDtNtvvnKQrb	39	3NLx5o8c1atdVaso3EPboA7tcDxMQhenGXoVp3wmtRhdTpojykYw	96	95	KXLeg1DaOA20p8aiKumgjLDvZnbR7h8fKY8sVfyScwU=	2	3	43	77	{6,5,6,6,6,7,7,7,7,7,7}	23166005000061388	jxaUAhd1vwP7AQvNQj11nc1utPJNrEnmd5tTgLYbopoEzDnBf59	29	34	34	1	\N	1729632668000	orphaned
42	3NLHahpxn8jMkSHc6kMjb5xUVx927FMVKeHwo8ki4Ts6yfoXqA9i	40	3NKpEwiqYsHb3uNawoATmxyhGUNq1Zbv8bVhty2QWagJbp4sGjft	96	95	OXGcKE60ejaKq8h3q9pMS1dnV-iOpkwmiJFXF5-r8QU=	2	3	44	77	{6,5,6,6,6,1,7,7,7,7,7}	23166005000061388	jwcxieoT9XDceEbGmg53xJbmTUu4WiWyCiqicXxwK8FZLVFJv8U	30	35	35	1	\N	1729632848000	canonical
43	3NL7ujjX3xNqrwmhNGZ8EicNe2Jx3x514q6KbwgNh8wWVzRE8oEX	42	3NLHahpxn8jMkSHc6kMjb5xUVx927FMVKeHwo8ki4Ts6yfoXqA9i	96	95	ONFGwPQ8Bt_0WA9blaYkUp6zxhmUWBlCxKgWGi3F3wk=	2	3	45	77	{6,5,6,6,6,2,7,7,7,7,7}	23166005000061388	jxkJcSWGmNHoVNeseGgTq8vVLQicxHZYZMB2sfJtnfijXJEF3Hi	31	36	36	1	\N	1729633028000	canonical
175	3NLU1taCQ8xZCoyVtb2pm1H8YLytonJ959prdZuVgUTrqrJWdSPy	173	3NLRVLsLUr2w782BHhm1zjfvs4fFMDAbw4qZxmnpffn7vmqsuBVQ	96	95	KxWU7n2e-I4WcaH8s8WmgcXpOBqANlGB9n-ITagxxAA=	2	3	177	77	{2,6,6,4,7,6,7,5,3,5,5}	23166005000061388	jxhbMGAEbit955EbM7pmtQanZkxcf1shGtWTt8YVqdW6LcK9DXx	126	166	166	1	\N	1729656428000	orphaned
23	3NKbkjKEUaU9BjpuZMEhPmJ3pymXFxJqa5fFZhWa1NcqszaFa6F4	21	3NKdTWpKMrG45oN5TTngfDfJYpKbF9be9RT3T4LZ7hK6fCkLcaWz	67	66	s84Xk7K4V2L9vZg6cxsfN0yOO3QvT72RVgCKxRdG4Aw=	2	3	25	77	{6,5,6,7,7,7,7,7,7,7,7}	23166005000061388	jxcoz3UJYhJWS3853dEVyLWBEStMo8U22B418cw66XnDoAWRoas	17	20	20	1	\N	1729630148000	orphaned
94	3NK361Mxk18yrvfvyQgvZHhKeeDSiHrFhebj95xF65f36dHnvZS9	93	3NLD3XBKTLoTBt54baqQceMUeHBYkKK9zHnoSdrYbKPgr2QrD451	96	95	AxSdrJsi1vefv6AwiMaq5-CzXd0o03idsNbeGxJ7igw=	2	3	96	77	{4,6,6,6,6,6,3,6,4,6,6}	23166005000061388	jxiP666djpzWR5YV6dv6Z956sxnz7FTHCU7Q2qZ21zj3gpEX1sH	70	90	90	1	\N	1729642748000	canonical
44	3NLRxXh7ZP7neRYK8KqXbDxKXqy8Tfuet15NrW7dEAbks2LNmyAW	43	3NL7ujjX3xNqrwmhNGZ8EicNe2Jx3x514q6KbwgNh8wWVzRE8oEX	96	95	DyPUxtTOeKRgVzgWPjqlPcUsp2Yh8M_D2r2hm5I5ZgQ=	2	3	46	77	{6,5,6,6,6,3,7,7,7,7,7}	23166005000061388	jxSd6PDZUPysb1W12SC5Hb1SPn5VTRZA8fSYJUvZMGoyfEqJUDc	32	38	38	1	\N	1729633388000	canonical
46	3NKwe21LacDRT9EY2kpfsbMwj9tM65owRhJMdwhJLAunLGAAHZ7n	45	3NL3ZXiZrm6c7S7srDDhzpBEne6drVukgcGLW9xe4HfWqE45gwxD	67	66	cRhRxJNNtuoEc9q2uVooVKG_TYF-e1AgK36SJe-bXAw=	2	3	48	77	{6,5,6,6,6,5,7,7,7,7,7}	23166005000061388	jxoS7b7CrbWvYzMtJch5wAdeeeutjJ4ffziyTjNNpcgnzHSakHD	34	40	40	1	\N	1729633748000	canonical
48	3NKuSjg1FjCCrWohZGC4bu9RMVQdHGKeoQLxTXu29xwoUCSSnfij	46	3NKwe21LacDRT9EY2kpfsbMwj9tM65owRhJMdwhJLAunLGAAHZ7n	67	66	TJniePfYUVShySJae2rrZFIHlX_iek-1avu7ZduUuQ0=	2	3	50	77	{6,5,6,6,6,6,7,7,7,7,7}	23166005000061388	jwzodrYtr9ZVArvSd9R7sYRcw7G5Dzx4oMcA41cWnjLSYq8Eax3	35	41	41	1	\N	1729633928000	canonical
50	3NKds15bHMwHqy6SjFktNAHHrgVq41avWdoAjrHuXBgDu2dCNM4p	48	3NKuSjg1FjCCrWohZGC4bu9RMVQdHGKeoQLxTXu29xwoUCSSnfij	96	95	I5kQ1VyUD1uTMuu44OVv93TZ-4c25L95MZinXaBzlAM=	2	3	52	77	{6,5,6,6,6,6,1,7,7,7,7}	23166005000061388	jxKbkShZaAzjBhhsUN8FSJzcoovKVa7FpD89x6w5gLrRHbtvctR	36	42	42	1	\N	1729634108000	orphaned
52	3NLaEht1ws1nvHXGYET8xzLdidnZgsW91BRiwcTfjq3DwrjhkaYL	49	3NKhpJNxkhRDmGx9cebCmEwQJX4M358UXxWhfc21oWHyrToANLFq	96	95	yS3Hl9Pij1E2IVGr3GROygiufyyufI775yKGx-48XAs=	2	3	54	77	{6,5,6,6,6,6,2,7,7,7,7}	23166005000061388	jxYNrc6kXnwhTkWjwW8PaeukHEeatCwSds1an3js2WeJ6DbrWVJ	37	45	45	1	\N	1729634648000	canonical
54	3NL8jkmV6GEWp9nY8H14A4EcJAwE9LLk6QJZf6f9bxNZeeLhVonk	53	3NKTizg6EwR9bfQyLKij74XXK7gAqTmGQsXRWbm2arsvVTxY4KTc	96	95	V9HPL7PxwWXkLiQA_5ZuULOueQ1_ZDFoWJrqzaRxzwA=	2	3	56	77	{6,5,6,6,6,6,3,1,7,7,7}	23166005000061388	jwVdtkPAuGYSa8AQJ7Kr1RJBPhmJN1cp7ZcD4zxia44iAysYtiJ	39	50	50	1	\N	1729635548000	canonical
56	3NL2xj23q9ZT4VcxRX12HLPq7L66hpe7EbgRUY8WYCK41DaMnEy2	55	3NKmueVN2e8jEMPuwfxe4LijYS7hW2GgkcBhBj5gtzW7vnxqiqLu	96	95	QdY3z8cqjqr3s4Zn8DeLoBXkG610k6GH2Kmh5NkYsAo=	2	3	58	77	{6,5,6,6,6,6,3,3,7,7,7}	23166005000061388	jxfLhpBTSCm9PTHc1rCAupDneexp5EiQYy18vngerAKWEiqzriK	41	52	52	1	\N	1729635908000	canonical
58	3NKz8FsMhN3BYshzMPvpPsBu3PBY8rKyD8xDfQxWKiXNNQDa3FCp	57	3NKswcMrYnafGdL6c8QyPSyChM75yM9RX2HaKH8n7ocjzTwEFNgB	96	95	cP06LdhCHQ_SbkntEei6CEMU61dEjtUTOg4a_dcwUQw=	2	3	60	77	{6,5,6,6,6,6,3,5,7,7,7}	23166005000061388	jwndmMeEdmpzWfsuMcUo2W9zePCTQmwD9yUKixt98gu2WNMmohV	43	54	54	1	\N	1729636268000	canonical
100	3NL7wA6mZTt4zP8j4td2zF71jmpRJoLam3JdtsW4DgdUvdbZq1dF	98	3NKYVYjDTV1V2Ksq9vsBhBsVmGayVhhigKHuYZcgdnZFoa7DPxnR	96	95	wLI5WHfTmF_Y-9jgoe0exYf96cSJZFniVVQDQ5D1_wE=	2	3	102	77	{4,6,5,6,6,6,3,6,4,6,6}	23166005000061388	jwYQfwgztENcVDEqMNaSrT3fJ1d4nRuozqKtvqR7fEVdr99u6Tx	75	96	96	1	\N	1729643828000	orphaned
125	3NLbUxNMe7KkX9MCoCExcRZzjhkucmkD9RruLVeihDgaARRP1vdY	122	3NLgAToowRQfjGFPGZzyXU4x3dkj9WVryRTbNixmBWzVMz1rkpNg	67	66	iYSbbAlXuzCWNTSZxrT5_gDS1I4SEGXlvXK55rRUeQA=	2	3	127	77	{4,6,6,4,7,3,3,6,4,6,6}	23166005000061388	jwdsshUZc7y4uFiADtjyQomdUKab5EdqXLLWe1uSr4JvUBYvzk7	90	114	114	1	\N	1729647068000	orphaned
129	3NLmgCxFd1Fh7SxoEMnWKDXL2cWbBZCoB2HE99FQuax3kPUuhoSH	128	3NKf6xteTgDJih1L8Av3ai2tpJFiAdQDWGSnt5bFbzKq8o2Co6Jp	96	95	hMkBhlj87-VWsoBsG4iluI1Z7Q3ojnYrVZLSxvtK7QA=	2	3	131	77	{4,6,6,4,7,6,3,6,4,6,6}	23166005000061388	jwggZ5iQJbFuezkzQDxC7jcN6DQLgiaCN5oRXw4pTJqLgaNj5PV	93	118	118	1	\N	1729647788000	canonical
131	3NKRvd9PW9GB6eVtHKyB5x1BVHqTw7QNazof9TvPxVX3kQuWebq8	129	3NLmgCxFd1Fh7SxoEMnWKDXL2cWbBZCoB2HE99FQuax3kPUuhoSH	96	95	vY_Jd2_D-aBwyW9NhzlGLNqFIl4GHguenx7GZ234Mws=	2	3	133	77	{4,6,6,4,7,6,1,6,4,6,6}	23166005000061388	jx1TxXf2e4pY9riGefTdgn6AxyibmvZ9jvBCbR7S8r9KXu2cgRT	94	119	119	1	\N	1729647968000	canonical
133	3NKh5UvJnX6hxJivkEyHuBeXVF8vKzcfyee1ATB6uMJNjD3Egq7M	131	3NKRvd9PW9GB6eVtHKyB5x1BVHqTw7QNazof9TvPxVX3kQuWebq8	96	95	U7n1QOxfIi52adFAvWeVTRPn9DLUgBhJspTomFaJTgo=	2	3	135	77	{4,6,6,4,7,6,2,6,4,6,6}	23166005000061388	jwrHGpNuCK4itJPQCyX7J4Q4uubyiAzpiVBvFWDMgTyHf6qsPvk	95	120	120	1	\N	1729648148000	orphaned
60	3NL4PNipRErZPUSJy1gQ7W5UFuC8QcXMmaQ4haJEju8bCirDFGNG	59	3NLWLEvdp5MAmDBUGMqWQrkCBv2L9jKcUWChDuuSXrDRRUZUo19Q	67	66	on6Oz9EOvKBSHP-oXV0RfoG7bv-7hAyRNzQYadZQQQ8=	2	3	62	77	{6,5,6,6,6,6,3,6,1,7,7}	23166005000061388	jxddYotu38MXnnPEPCixcSkyzaBdnBbJKMhgW99wu4xABqCbg2A	45	56	56	1	\N	1729636628000	canonical
61	3NKdFPAoXoRr93QtTebXXKyQJcVSD64jva7NriVBYe91YwaZMcAT	60	3NL4PNipRErZPUSJy1gQ7W5UFuC8QcXMmaQ4haJEju8bCirDFGNG	96	95	mbuzP-lqzJUtgS2OMEqv6eU70nSXeF-c9JgnbPIMugo=	2	3	63	77	{6,5,6,6,6,6,3,6,2,7,7}	23166005000061388	jwqPJfRqFGrfaF4Y1YLNEzmKP7oWbgT53ejqiLaxsEZYeWge5hA	46	59	59	1	\N	1729637168000	canonical
62	3NKE2Y33fTexFaYhXL5kdbo7zq7TMmPQUg9d7MFxwSQpBppo4VEG	61	3NKdFPAoXoRr93QtTebXXKyQJcVSD64jva7NriVBYe91YwaZMcAT	67	66	UJrkxDCJ4JhVZHVx7eJa983foHRbr98oMVbdZCof-gs=	2	3	64	77	{6,5,6,6,6,6,3,6,3,7,7}	23166005000061388	jwTaMkUFoeXwWYkkqmn9z7BK6s7FkrhD6BLx8eznEqN9J8ZBYJk	47	61	61	1	\N	1729637528000	canonical
19	3NKNDSbmEkpEMrCr9n4DXDaCX3H8kpeEBvyukLkYtj6yKuiRiR1w	18	3NKj41kDEyLbxFNoBLUXLePkXGeBkSs7p1h4sKqnNjSaygWZ6xu3	67	66	M8swjjlh8sF-up4Zj6_3lYfLj-7e3U2pQaED2cmZoAg=	2	3	21	77	{6,5,3,7,7,7,7,7,7,7,7}	23166005000061388	jwZ275xjcSCoPhA5qjjs48xbnMp2PABrwj7kcPVse4kouvSeQiK	14	16	16	1	\N	1729629428000	canonical
63	3NLitghzLv6neSQXNNy7dp21kskzQ6WBnYqw6HMnGYBsoALTwVXB	62	3NKE2Y33fTexFaYhXL5kdbo7zq7TMmPQUg9d7MFxwSQpBppo4VEG	96	95	2FXaVhbWN7P7EXxZkEPTcwb6t9vPy2f_I8SL1ReplQc=	2	3	65	77	{6,5,6,6,6,6,3,6,4,7,7}	23166005000061388	jwZGKBQC7TKn4oUNo34ACEGsSRdpDsvhvsXKnMVd1YJXVYmwSQS	48	62	62	1	\N	1729637708000	canonical
64	3NKutudiEDK7m6RZoMRHTCWAhUR1MLMWc64CJBhkAAhREURKCGoH	63	3NLitghzLv6neSQXNNy7dp21kskzQ6WBnYqw6HMnGYBsoALTwVXB	67	66	j3UoV7ZZuFScxARD0_Ejx4btZb-PnMN7ziDWv7PBAQk=	2	3	66	77	{6,5,6,6,6,6,3,6,4,1,7}	23166005000061388	jwqeQ2Bzguu6qQwgYw8G2X3npJcYoKWkzETDqenvPFk7ypmRc18	49	63	63	1	\N	1729637888000	canonical
176	3NK2vJj4NuroGWfcS4jcUasC7KGUz3tQkXyF2Y1Ej9w9gDv3FDxd	174	3NKBxUAEc9C6bPAdLGeUzq4VeV62S15mJoSiFFX1V9es2MMUz3XR	67	66	Dd6F_-znTmxXynO9Sss2iFKMyS3pqsXxqVj-CvKRJAY=	2	3	178	77	{2,7,6,4,7,6,7,5,3,5,5}	23166005000061388	jx9B7EHqGJAcvBGJjGPJpQS3SCSKYGJuZc6ceLm76mpRP4hyLq2	127	167	167	1	\N	1729656608000	canonical
47	3NKErLQUQRmSku7Hfr4bJgGYcRGXqme6PTkBvosF3F7De9m4R4DN	45	3NL3ZXiZrm6c7S7srDDhzpBEne6drVukgcGLW9xe4HfWqE45gwxD	96	95	BbBqLa_v60n4rqMlSucoNWDYF1PBMdG43X7fHP-K4Q0=	2	3	49	77	{6,5,6,6,6,5,7,7,7,7,7}	23166005000061388	jw9HapMFpweLHRwWjrVVVxU18h4HR2sZUpcWmopXJrNBbU9Ys7D	34	40	40	1	\N	1729633748000	orphaned
49	3NKhpJNxkhRDmGx9cebCmEwQJX4M358UXxWhfc21oWHyrToANLFq	48	3NKuSjg1FjCCrWohZGC4bu9RMVQdHGKeoQLxTXu29xwoUCSSnfij	67	66	xT_XUP7lxXysTVmRPNM5Ln4HBZn63H_FQ9CV0sX4BAA=	2	3	51	77	{6,5,6,6,6,6,1,7,7,7,7}	23166005000061388	jwpX6CrRQU6HPANTKd5f45yCbCXDoa1jpjyNHiRu9FoyAJ2sEyj	36	42	42	1	\N	1729634108000	canonical
53	3NKTizg6EwR9bfQyLKij74XXK7gAqTmGQsXRWbm2arsvVTxY4KTc	52	3NLaEht1ws1nvHXGYET8xzLdidnZgsW91BRiwcTfjq3DwrjhkaYL	96	95	5g6-vTpKBsTW00qI3KfSOSV7YolhLp-0j8Baqny7Qgc=	2	3	55	77	{6,5,6,6,6,6,3,7,7,7,7}	23166005000061388	jweuCF1FPeo7TnxKdLbp4jBWCCfgciDr86zM1Yby6D24vWcUbJY	38	47	47	1	\N	1729635008000	canonical
55	3NKmueVN2e8jEMPuwfxe4LijYS7hW2GgkcBhBj5gtzW7vnxqiqLu	54	3NL8jkmV6GEWp9nY8H14A4EcJAwE9LLk6QJZf6f9bxNZeeLhVonk	67	66	HdA9XeqDieW6A69M8CkOu-6eOOxmcvcnwLQCYclXBQk=	2	3	57	77	{6,5,6,6,6,6,3,2,7,7,7}	23166005000061388	jwD9NQ2bkXWwKMuYNwy1QVydX6n7wQsNUhASgEPY9iZFet5eVPK	40	51	51	1	\N	1729635728000	canonical
57	3NKswcMrYnafGdL6c8QyPSyChM75yM9RX2HaKH8n7ocjzTwEFNgB	56	3NL2xj23q9ZT4VcxRX12HLPq7L66hpe7EbgRUY8WYCK41DaMnEy2	96	95	pcnJKGdMkdV7-ZLhvCEq_xxq5LSOtTR7EYX5zAGCewo=	2	3	59	77	{6,5,6,6,6,6,3,4,7,7,7}	23166005000061388	jwezpLWAhMesqm4S1nhwgBE5EGEML4Ndd4BucB3boW968vnQPyh	42	53	53	1	\N	1729636088000	canonical
59	3NLWLEvdp5MAmDBUGMqWQrkCBv2L9jKcUWChDuuSXrDRRUZUo19Q	58	3NKz8FsMhN3BYshzMPvpPsBu3PBY8rKyD8xDfQxWKiXNNQDa3FCp	96	95	r_fMb576mYrXhWPCboksWsT7mA_W2Skbdowo9bNq5A0=	2	3	61	77	{6,5,6,6,6,6,3,6,7,7,7}	23166005000061388	jxvyoPsxWGo4sH7VgBubjn673SW3eAnrfzRcEgoKoYcvwuTPx9M	44	55	55	1	\N	1729636448000	canonical
65	3NLp5Waz1YTUPL1RvSNUpQR4oj1Cfkvdy4LcVqhJ7ix3nmeA52Za	64	3NKutudiEDK7m6RZoMRHTCWAhUR1MLMWc64CJBhkAAhREURKCGoH	67	66	ss6h-TillXMSJS3O08gava0ejy0m4w2F2Ns8U-B2DwM=	2	3	67	77	{6,5,6,6,6,6,3,6,4,2,7}	23166005000061388	jxCCFdbVWH883iYAAqD6ydyZPzbDtvvXBRzqTC2D7GsgA7pQn2t	50	64	64	1	\N	1729638068000	canonical
67	3NLSAaN8outZkdFsS5fy1xAC4bf6KprHwrtaGYJYHZHcsHg5Q4VD	65	3NLp5Waz1YTUPL1RvSNUpQR4oj1Cfkvdy4LcVqhJ7ix3nmeA52Za	96	95	YU0J9B8RzJ_Mk2nccYbn48JGkLvq0aZaC0ma7dlW3gc=	2	3	69	77	{6,5,6,6,6,6,3,6,4,3,7}	23166005000061388	jwjZNiLchsABULBZU2yvnKcGxdmMNXLKUKzwEqE7XfnV6dq4xLL	51	66	66	1	\N	1729638428000	canonical
101	3NKccnC7c6RZcYLNuDoFDoeJqPmLugryUsCydWGyJFwvGNzDvCgK	99	3NKSMBEkRJKQ29n586gss7GudMtqBH9HhqhVUPUxi4E8ioF1xk85	67	66	LL1BRVZ6JylN3IR2MH8StBoS8UU5EWjeX3TY9RBepQE=	2	3	103	77	{4,6,6,6,6,6,3,6,4,6,6}	23166005000061388	jxKMtBX5zE9SXnCW2kMy2fUDqAxnwkBZN1hTqTzErSVMAZcaePz	76	97	97	1	\N	1729644008000	orphaned
226	3NKBxU94dCMRKpFUpNGjojTY4FXTwaGfrKM9QY8xWEMnDmLaEkXt	223	3NL82mP66t6PNPSz5iKrzM3SUop7xS3tCEExYLUeHfgTVFM6Btjv	67	66	IehWMUYysPwC5FqQ18yKzf7yCL_eF6mtlUo8Brzwig4=	2	3	228	77	{2,7,6,6,6,6,4,6,3,5,5}	23166005000061388	jx5C8RNbzAwYVyzDNMBa3aRsB4HqdZYizozQz8JWyEkcNi7KtSW	164	212	212	1	\N	1729664708000	orphaned
179	3NL1YXShpKrhZNKe1um9nPPPKCXwzUxvu1pbdpjcnaMgExfgQ8HS	178	3NL4eyQwc9XkvkmDSUtvb9g5QKW3nxTar9yKSRtoadt777e82bJ2	96	95	83JLrhr3JJbcDd3Wybr-hB4NqOL6WFwfbjAwLI4L5g8=	2	3	181	77	{2,7,3,4,7,6,7,5,3,5,5}	23166005000061388	jx4saNpiCh5qFa94hnacct5t5sfsy9LhuBdQKS8rhxQ8qpNKUT3	130	170	170	1	\N	1729657148000	canonical
45	3NL3ZXiZrm6c7S7srDDhzpBEne6drVukgcGLW9xe4HfWqE45gwxD	44	3NLRxXh7ZP7neRYK8KqXbDxKXqy8Tfuet15NrW7dEAbks2LNmyAW	67	66	zZpTs6boupWGoP96meFlwtavJVUML6xsmQDaGi_CVQ0=	2	3	47	77	{6,5,6,6,6,4,7,7,7,7,7}	23166005000061388	jxwWNBhttaqSR3DgeEr18jXMEae1ogmSWemiT18HfBLd1LBuzHW	33	39	39	1	\N	1729633568000	canonical
68	3NLwnyfnyrLQokcWP2SpMSFHZqfrRg9NNAmey3yGeGzWLdhjizfe	67	3NLSAaN8outZkdFsS5fy1xAC4bf6KprHwrtaGYJYHZHcsHg5Q4VD	96	95	mLR03dtJ8sUT0MIknJR6-591WHMxdMDCipNhRuZbGws=	2	3	70	77	{6,5,6,6,6,6,3,6,4,4,7}	23166005000061388	jx5kHGG9sbqFy8BPzD2npdrPfgZc5kSpCYF2Y9kiAfczg2Y9K1W	52	67	67	1	\N	1729638608000	canonical
70	3NLxVXVSFx8P1trWVj8uXgQk1HQ3Cs1KDw6aCPGiDtfNnCerMoJh	69	3NK4tp26pCCDauzQoAoNdu1Btm2pAfpikpSVBTe9rgVxdwXmeWkn	67	66	m4K3Yv7ZknyKDFEK_dNAhSWicQJZPxxRykAYTtKW1wY=	2	3	72	77	{6,5,6,6,6,6,3,6,4,6,7}	23166005000061388	jxkNqsBBvtCgRthBXpepMuBYZZhWzZXj3F1enSCMypyuiAcjyTq	54	69	69	1	\N	1729638968000	canonical
73	3NKQ1Tjnb7oMqDk6f1QjDcmpiQGirGRe4zVqM4SaHQtyXYGg2KkP	70	3NLxVXVSFx8P1trWVj8uXgQk1HQ3Cs1KDw6aCPGiDtfNnCerMoJh	67	66	uZcssNo3x-7jZkmudeBySZQkWEOlOMA9h98pfZu2nwc=	2	3	75	77	{6,5,6,6,6,6,3,6,4,6,1}	23166005000061388	jx8Yz6MEnHBfbk9XwXD2WE9tETmZZV12EWbUhTRJv6ZAZArkYfB	55	70	70	1	\N	1729639148000	canonical
72	3NLcVzAUcvUhZFMSaS5Wn9GTxd7Ra45vFbmEk1Jumo5bwviT3FvQ	70	3NLxVXVSFx8P1trWVj8uXgQk1HQ3Cs1KDw6aCPGiDtfNnCerMoJh	96	95	7zyOEr6kqJN_FC1YqB-Y80WD8QrgZoNDLrk3UikEvgk=	2	3	74	77	{6,5,6,6,6,6,3,6,4,6,1}	23166005000061388	jwF82wbk7ZQ7rP8YrGtK9T9JEePD5kSiQqvsYRYFHAt25XpHrwJ	55	70	70	1	\N	1729639148000	orphaned
74	3NLwFAaqQ6FQf3WW6Wbs5gHYxkYfdGcmmdCSiBzj4MHCvxD5RrGA	73	3NKQ1Tjnb7oMqDk6f1QjDcmpiQGirGRe4zVqM4SaHQtyXYGg2KkP	67	66	FPQ6_DFCNGLI5PgrPzNhn7WOOQGTUpkX3pcTgaXJSg8=	2	3	76	77	{6,5,6,6,6,6,3,6,4,6,2}	23166005000061388	jxaLfej4MGzFXS9ePwL5ufXrrKk2XeaH75gtBExCN5dfa1qGfAd	56	71	71	1	\N	1729639328000	canonical
76	3NLQZSz4VWd5fk3PtzNZeXELipFH1KvLwzdJw7piYwf4i7vV569u	74	3NLwFAaqQ6FQf3WW6Wbs5gHYxkYfdGcmmdCSiBzj4MHCvxD5RrGA	96	95	1DGDz6pNuDM-I2lU0GcgpP_Hb-7AtrmT10CTXS7VWwE=	2	3	78	77	{6,5,6,6,6,6,3,6,4,6,3}	23166005000061388	jxc5EM3qv1YNZUVF3i1XwJU3tAnrtvz8PyFfV2bGet4Y4t1wRv6	57	72	72	1	\N	1729639508000	canonical
104	3NL1tY1Dp5u5Yyfx8q4qkBg5ufjhEQCDgEPt3qdRzdT6HUYe2Y9h	102	3NKbBdrUjkGBcrrtk9kvmyPRbLnLJd9jDqwhwREzHKK2qzi9X8sM	67	66	2OjPwxldibcco5DV1ZsiGFAvZxB2EsR511XLjDToVwM=	2	3	106	77	{4,6,6,1,6,6,3,6,4,6,6}	23166005000061388	jwa2Lo1gJp2etx5DfEUiFb1hFkSHqfCRr9YjBVzXTaoencMX4KW	77	98	98	1	\N	1729644188000	orphaned
106	3NKCvUihuzjaa9pmR3cAqXJPkTXW4T5MdWw1t18rohmZj2WjU2oz	105	3NLpY5M6mbhQHu4Q9TocYZmXU6424hGsj8gqeTxtoHc5LdvCaGKf	96	95	Q_xm7QH6rtsfXp2GJRD6hL89tf0kLg-tH3l1HnTtJwg=	2	3	108	77	{4,6,6,3,6,6,3,6,4,6,6}	23166005000061388	jxvkcNFbjuxoXnaFuXg6FJWR3rxVXK9MJifQAWZWqffjKDpCpJ3	79	102	102	1	\N	1729644908000	orphaned
110	3NL1GoqM48N4TR1cJj9Cvc1Us6wodsM7KSrnehFKpGCBryuYRkEz	109	3NL1dprTPmRjSNCEANWrZBhs1wYWXpzqh1GyqFDExdWoYf8zAupw	96	95	SdV5e_6v0veofyqBEqzbLu4f5CbVkHcTPORKStLkCgg=	2	3	112	77	{4,6,6,4,1,6,3,6,4,6,6}	23166005000061388	jxZ3zXjRbg5239w2vncRZ5ETWPsNhQ5JwvGkRHN1hu3XvGt2tQb	81	105	105	1	\N	1729645448000	canonical
112	3NK6MNgobMVJAUwkUvsTvkchimSfyxD2C55KnNDYiwkBH7vsLxgd	110	3NL1GoqM48N4TR1cJj9Cvc1Us6wodsM7KSrnehFKpGCBryuYRkEz	67	66	yNXlc3PXid8lK0Zon4hZLfF63BAnNa-3C7qFxIPBqwk=	2	3	114	77	{4,6,6,4,2,6,3,6,4,6,6}	23166005000061388	jwvt7ocfU8r8sr3KEBpWTDYg3Cpzeaa64JSihbiAEcZSUkoaEPc	82	106	106	1	\N	1729645628000	canonical
114	3NLJPxH4AVh135u4YFM6uXQEGNachLSS4h59eVnaUBdCMLoGmZm1	113	3NKhw7f4MPTU7GdkCAy3QvZRvC15d2Gds9rjcDmGbBujqNWBhCYf	67	66	w3kOGvfFBO7PmYmS3qgKDCy0bx3xoj8-bqw8ToZdgwI=	2	3	116	77	{4,6,6,4,4,6,3,6,4,6,6}	23166005000061388	jxaj5coMLPRMbmPFTxKHSLCkh5TgCCqGYC27xSkYhKDyrdheLRW	84	108	108	1	\N	1729645988000	canonical
116	3NLMSs4GyXxoXgEbmnTFekzPUmcsH3wxzru8Ei9BWW31u4W7ZSth	114	3NLJPxH4AVh135u4YFM6uXQEGNachLSS4h59eVnaUBdCMLoGmZm1	96	95	z0shBbdhQHg23g8ccdiYaeWqbHtmpQYRWj2YX8clQgQ=	2	3	118	77	{4,6,6,4,5,6,3,6,4,6,6}	23166005000061388	jwGHTi1cpMsYs3uSLCsgzzT8twbQTfCKM8kq51J87GSqmASQBNF	85	109	109	1	\N	1729646168000	canonical
118	3NKyamS1E8A7NdrpFfwKxAR2p6MCkq7BwsC4MXoVUnWtFq6uiwTN	116	3NLMSs4GyXxoXgEbmnTFekzPUmcsH3wxzru8Ei9BWW31u4W7ZSth	67	66	-i6B-IJBvkn0ialSI-12qj1YulCcky71kO6Sxz4M-g0=	2	3	120	77	{4,6,6,4,6,6,3,6,4,6,6}	23166005000061388	jwL8FsndkPuUBXS92oyTbDuoRmmD6B4zHCrnwmRC8rKBrFCJWCg	86	110	110	1	\N	1729646348000	orphaned
120	3NK3TCub5cd3ufcF6Qb3ZE5d5AP5rrtVryeTopcYNvFfJqEuZ8oc	119	3NKsLhnaY56wHLa1LKVQDXkVWHf4wKGNNsT3dytQ7nfPctihNZtx	67	66	oLa2B-aC89DPVDt-XMxrQ6j8uPYq90z77g3OWqHVWgY=	2	3	122	77	{4,6,6,4,7,1,3,6,4,6,6}	23166005000061388	jwNFi4SCa2BkUkkBzWcivBwChFUJKrmZSsuN6ZfMFXfPKM6j44z	88	112	112	1	\N	1729646708000	orphaned
145	3NKC7K5c9eJMu8HHMr9oWbKtcEdoVUPwgGHrMBXZkYdjaCGf6YrN	144	3NKsFyVwfox4BAT4Cz4ZFH4K5gYShDQezQKGp4gMn4FfZenpZFFv	96	95	Ykr7TWOq7-vtyo_vz1BtSvCvPTuEf8zwJx8IkNA_5w4=	2	3	147	77	{4,6,6,4,7,6,7,4,4,6,6}	23166005000061388	jxGwgwpxTg7FLkj81kriW2F2v1gHkoifDwN8gdbCUTcngSCfH8s	104	131	131	1	\N	1729650128000	canonical
180	3NLj7iHjnbFE8TbgjmBBjSoeYXESc7qUXMz3fnXThfrxsUSCxgCk	179	3NL1YXShpKrhZNKe1um9nPPPKCXwzUxvu1pbdpjcnaMgExfgQ8HS	96	95	lSuxpV6eXEzUDazAH_iCIVotTrFZum7WofF-eZUhzAY=	2	3	182	77	{2,7,4,4,7,6,7,5,3,5,5}	23166005000061388	jwmfaE2QbC2PREaBoKn1g4mowF3Yh7NUJECX7d4hbhvAgUum4bn	131	171	171	1	\N	1729657328000	canonical
291	3NKGmpBKh3ZXszn7kR77DC5KTHrBDuRrhkuKFtLjGLFCy8JhsGUc	290	3NLjdShnS1Po6PdpLkQDwzHjJsuAv6TrMfbKjfyC9kfLt77hLtZb	67	66	y_x-m77MnhX-2jI8yEoRo1NexCwurhnvdEIzOBxqlgg=	2	3	293	77	{7,3,4,5,6,6,5,6,5,5,3}	23166005000061388	jxhoSUxZX4sRUp1LMFtr1gdvWsULDdRGb7dwEtXE4Y7thRmFYA4	210	278	278	1	\N	1729676588000	orphaned
51	3NLBcYBfkJqHC4gUCVc4LwafWboCo1UkfuoBmxVp7siY8W5K8ivh	49	3NKhpJNxkhRDmGx9cebCmEwQJX4M358UXxWhfc21oWHyrToANLFq	67	66	Wh7adKyLNtmVKFiG4_GWBxlMvh4R9yCgWW1VUDxrGAI=	2	3	53	77	{6,5,6,6,6,6,2,7,7,7,7}	23166005000061388	jxCBj1JFfUXwMgD1o2MgvMG3aNNf1nfRddLTJKKETK595t5oQfn	37	45	45	1	\N	1729634648000	orphaned
71	3NKFHGwJvq5srYYcEw9hayUD7eQb8NqZ88Sv3zARDy1v17LYcWtV	69	3NK4tp26pCCDauzQoAoNdu1Btm2pAfpikpSVBTe9rgVxdwXmeWkn	96	95	qPLXEba0pvImL4Q8j73ZvS1-89qH3AdyDDtAS3WYSAg=	2	3	73	77	{6,5,6,6,6,6,3,6,4,6,7}	23166005000061388	jx8Rwndaug4AHZN1WFaJAs6NDDnFGcedqfFC5JAZt1mzKYqQc37	54	69	69	1	\N	1729638968000	orphaned
75	3NL4tcQf3hJ7bXA6hGd1rajKkhYnaf6sUJrvWW1CozX3upUjW9FK	73	3NKQ1Tjnb7oMqDk6f1QjDcmpiQGirGRe4zVqM4SaHQtyXYGg2KkP	96	95	GVjwDz19BjB4HtiqqesnY6HwoFTAid2tvVqin-Fn7wI=	2	3	77	77	{6,5,6,6,6,6,3,6,4,6,2}	23166005000061388	jwGKeHRWF5iQL8PBnwJtmUU8Tg8of6bQHniNGWDLCb9ssvx6WFe	56	71	71	1	\N	1729639328000	orphaned
77	3NLdynrmLjzAcgqFeE2P1hAg7SmdgNuHEWeCCgBotqQtMTPXfae1	76	3NLQZSz4VWd5fk3PtzNZeXELipFH1KvLwzdJw7piYwf4i7vV569u	96	95	AFjG0BbFtJNzUVRGVrMXnpR-Fhn2XsDCs70J1q9eYAI=	2	3	79	77	{6,5,6,6,6,6,3,6,4,6,4}	23166005000061388	jwup9T3c3KZkNDbfjw7r6XiHBWqkehAPArz96XUbsiA17aEKwAT	58	73	73	1	\N	1729639688000	canonical
78	3NKe2JHDtpodL3YnDq1o8FqG6ZieZSXRt93dYL9esAacoGA65YoN	77	3NLdynrmLjzAcgqFeE2P1hAg7SmdgNuHEWeCCgBotqQtMTPXfae1	67	66	1-FX7Ku3VIhlelBt7Z1r0eOtKabBvZWqATKhsL2t_QQ=	2	3	80	77	{6,5,6,6,6,6,3,6,4,6,5}	23166005000061388	jwZ6bdi4BBhm5keR6Ndaj6ii3xjJPiVuFedyFkiA8JuSZbs3f7A	59	74	74	1	\N	1729639868000	canonical
79	3NLayBmoNTyco638KvtjH9YATELgnp7AJZJDJpXwPZTrdRjeXmr2	78	3NKe2JHDtpodL3YnDq1o8FqG6ZieZSXRt93dYL9esAacoGA65YoN	96	95	ziXGB7Rh3j1Sgz-LpjN7-07_cki-Czte-jO7SUZF2g0=	2	3	81	77	{6,5,6,6,6,6,3,6,4,6,6}	23166005000061388	jwiVjampvNWQhq9LiAQjyW9BKeRyCxguCwAtuW8WuLzCW2y9JV8	60	75	75	1	\N	1729640048000	canonical
80	3NKGy62tQGj54RPWvAdAHvSdDKiQrLXFwGR9p6Wby4g5q6YX1YL2	79	3NLayBmoNTyco638KvtjH9YATELgnp7AJZJDJpXwPZTrdRjeXmr2	96	95	hv98wuFpPZ-JH-IJPXXfRu3yUglO6_d2CnwqkVnszAk=	2	3	82	77	{1,5,6,6,6,6,3,6,4,6,6}	23166005000061388	jwGGfef9cTtK5d3BUzsd3Bwc91tMaA4XKrtfihdZQpYvpq9vJnV	61	78	78	1	\N	1729640588000	canonical
81	3NKwgYNCZuViu3z3nmVF6dDR58CcLcbiuFP35oztUGd1LKy2bpgq	80	3NKGy62tQGj54RPWvAdAHvSdDKiQrLXFwGR9p6Wby4g5q6YX1YL2	67	66	cuN9rS1ic_zksbu-FpLNntpcjR8Mmol2vDbjPL1ptAU=	2	3	83	77	{2,5,6,6,6,6,3,6,4,6,6}	23166005000061388	jxRyWFEFZx2eRbTqGHvFB9s1FkVPUL8tEmPgg6HXpq3LcKtBs6k	62	79	79	1	\N	1729640768000	canonical
83	3NLpcao7SPnuBpqCzdgsxmPuvt9B5uTqzuXVFesp4qhznkUN7i7W	81	3NKwgYNCZuViu3z3nmVF6dDR58CcLcbiuFP35oztUGd1LKy2bpgq	67	66	dY0--L9K3sVIswV6ZDWD83QoHD3dkOhCbSSvvtzlMww=	2	3	85	77	{3,5,6,6,6,6,3,6,4,6,6}	23166005000061388	jwuZ29fEwthLN5hGj9WsN5vf7cenBfrTAMGsKSvCnsRauuS5ZQS	63	80	80	1	\N	1729640948000	canonical
85	3NLWgqvGBwkrwvjJq2GqxyuMT2xRfiGgz4nLm9AjzuAXmbsKwfwK	83	3NLpcao7SPnuBpqCzdgsxmPuvt9B5uTqzuXVFesp4qhznkUN7i7W	67	66	yqXn5msD0v96xT7_edUnPzrV8YDfbF53Tm3B2vArxgQ=	2	3	87	77	{4,5,6,6,6,6,3,6,4,6,6}	23166005000061388	jxeh6m2jKUeJUiFN6M5hqmUKN991eC9yZ7TZh86m1XbCnNU2jGv	64	81	81	1	\N	1729641128000	canonical
84	3NLNxBaF6VSnobnRawE9npkkywUk7vVDJWGFv2pFV6X52MNDcRvb	83	3NLpcao7SPnuBpqCzdgsxmPuvt9B5uTqzuXVFesp4qhznkUN7i7W	96	95	G7Q2aTmiU4xPliwPGMujlTmLCXrI_RSLTXXmxbxTxAE=	2	3	86	77	{4,5,6,6,6,6,3,6,4,6,6}	23166005000061388	jx3vjXWFwpJCQi9ACMdfHyUQxQqkfqVj78K989BRUfdLQuqkB2a	64	81	81	1	\N	1729641128000	orphaned
87	3NKLbi2uXWfZHfrrTmpbQxDMrxXQWPj6doLQ5JZ4cUCLxvfGuGJV	85	3NLWgqvGBwkrwvjJq2GqxyuMT2xRfiGgz4nLm9AjzuAXmbsKwfwK	67	66	PIGJaBUpoiGdBdoeq87WUWND4nsO7m0_Ngf4c2um0wM=	2	3	89	77	{4,1,6,6,6,6,3,6,4,6,6}	23166005000061388	jwydMg1v1zTeQw5uwrhWtfi6qx44BP4S7yMdKqe5g2Hbn64cWkB	65	84	84	1	\N	1729641668000	canonical
88	3NL1QsccNeqQHq4V7wqWDtAWXiPa9YeheXjFxc9DhAGvgkckAVa6	87	3NKLbi2uXWfZHfrrTmpbQxDMrxXQWPj6doLQ5JZ4cUCLxvfGuGJV	67	66	GJVDIkdKrkcLp0EctzPpdAgmBFimik8WXZ-pkaDu4Ak=	2	3	90	77	{4,2,6,6,6,6,3,6,4,6,6}	23166005000061388	jwH9FqUpxzd8enn84GkC9i4JMAks3RV97WEfaYuJjCYBtiJPGEA	66	85	85	1	\N	1729641848000	canonical
147	3NLYBQwXjwr2ixYHd3xiQ77UtVbTcX4FxoArSqxoMeUqc94oJsCd	146	3NKXkhpwr6pucBS7EdUMsybJbQHQEjWzzWdNtdeJ7fpdauT8m8qp	96	95	sw0tSuxNQ8Dwee1mV4b5u2FBwU2z0btYrYAWUcjObgw=	2	3	149	77	{4,6,6,4,7,6,7,5,1,6,6}	23166005000061388	jx96wCuvovqmqQ3YMa2xTPgwZ3bf1RFFgWAbNsY7BNexc8Lzaqj	106	133	133	1	\N	1729650488000	canonical
69	3NK4tp26pCCDauzQoAoNdu1Btm2pAfpikpSVBTe9rgVxdwXmeWkn	68	3NLwnyfnyrLQokcWP2SpMSFHZqfrRg9NNAmey3yGeGzWLdhjizfe	67	66	-0H2w8W1A2r3Qsn43pfofXjJtKzBLfKDV2QZ4njL4Qo=	2	3	71	77	{6,5,6,6,6,6,3,6,4,5,7}	23166005000061388	jwRvQ7gXzK6j7LpgRrHN2ubYgAuZPSymDtMVGV6vnErRr14oWEg	53	68	68	1	\N	1729638788000	canonical
82	3NLfV4uj53MWkiCEkb5i94hJ5NqSGd2PHvQajKmeb37BBPWetonC	80	3NKGy62tQGj54RPWvAdAHvSdDKiQrLXFwGR9p6Wby4g5q6YX1YL2	96	95	SAzNv83QfqjkQrnAsZ2xybGSa6JvG2wSU0AdVIyjBAI=	2	3	84	77	{2,5,6,6,6,6,3,6,4,6,6}	23166005000061388	jxAuW6ypkULh9CBcQX2PcxVNrV1wUTTCxqztmzAArGtWmjL6eA3	62	79	79	1	\N	1729640768000	orphaned
89	3NLYbos5rhZmn2eAF1XLnzWxBGrGQkkZQ7xkGLxYr4Yvu7wiBD83	88	3NL1QsccNeqQHq4V7wqWDtAWXiPa9YeheXjFxc9DhAGvgkckAVa6	67	66	Kvgwm6tAx2csl-7d9pODTusIWBdcrzR_NysVwMHiTAc=	2	3	91	77	{4,3,6,6,6,6,3,6,4,6,6}	23166005000061388	jxn4Sn1pgBLjWQs8aSZ1y3BSRTjmdfrESYPxhUjL5zX5MJpSp2b	67	86	86	1	\N	1729642028000	canonical
93	3NLD3XBKTLoTBt54baqQceMUeHBYkKK9zHnoSdrYbKPgr2QrD451	90	3NL5pTSeiFLabjrbemXxWFcixNoKdrSm1ZjeznuSwmBGrRtjgcFq	67	66	nArRrJIOKbfRfJagbWR47KdLAvDlraeKwQLA0zZ86w4=	2	3	95	77	{4,5,6,6,6,6,3,6,4,6,6}	23166005000061388	jwxZrGrMCvY5NNrGAt4KBW5mboJYBTsvRwQRF5tCTrEiKRdSd4K	69	88	88	1	\N	1729642388000	canonical
105	3NLpY5M6mbhQHu4Q9TocYZmXU6424hGsj8gqeTxtoHc5LdvCaGKf	103	3NLmAW4bEwUxn6FMiftRXxXQbY2eB9ZRGu5Fo8H5YBKsykgVNyb3	67	66	R6dgxHOJyBY2FBbJ8tkcefi3WBQ8lN2jk8J_HcayZw4=	2	3	107	77	{4,6,6,2,6,6,3,6,4,6,6}	23166005000061388	jwSAJbcJXwnfBrE2P4LsVbguo3b72Todz2HCyVK7xJjGXkxpFTv	78	99	99	1	\N	1729644368000	canonical
107	3NLWch8xAVpdjkPL9UzRPA4HyiYjeNvREDftuqxRCQWvEweSkUas	105	3NLpY5M6mbhQHu4Q9TocYZmXU6424hGsj8gqeTxtoHc5LdvCaGKf	67	66	5gQY1f5U8l_Rg4z6yE2fLwOKg7phmjiae_oBpuf61Ac=	2	3	109	77	{4,6,6,3,6,6,3,6,4,6,6}	23166005000061388	jxwG1ijuUc2NafEPSkZiNQYuX1379EUxKnk8HBw1LqTvyPK4eSC	79	102	102	1	\N	1729644908000	canonical
109	3NL1dprTPmRjSNCEANWrZBhs1wYWXpzqh1GyqFDExdWoYf8zAupw	107	3NLWch8xAVpdjkPL9UzRPA4HyiYjeNvREDftuqxRCQWvEweSkUas	96	95	2jxO4DIYRLGvBaPtZBliqEj6UI3GjPHzKOPICYuXgQk=	2	3	111	77	{4,6,6,4,6,6,3,6,4,6,6}	23166005000061388	jxHVdwvGZELXQ5vfhWVBwKuhVgyEPbaiqUSjZViGgj1zayMfpY5	80	103	103	1	\N	1729645088000	canonical
111	3NLhidsF2NYucEiy19MJYYhFUfVVu3qGFx9ZDTKoFdDoVQvSDFAq	109	3NL1dprTPmRjSNCEANWrZBhs1wYWXpzqh1GyqFDExdWoYf8zAupw	67	66	SsKLQwbFTp0CDmcJpffLjkbXK1u31XSP1opX_gDnmA0=	2	3	113	77	{4,6,6,4,1,6,3,6,4,6,6}	23166005000061388	jwKiCZcii31jhmV8SfGFar4Tgp6vk3327pusrNAxQXjqvNMJ6oP	81	105	105	1	\N	1729645448000	orphaned
113	3NKhw7f4MPTU7GdkCAy3QvZRvC15d2Gds9rjcDmGbBujqNWBhCYf	112	3NK6MNgobMVJAUwkUvsTvkchimSfyxD2C55KnNDYiwkBH7vsLxgd	67	66	z8fVj7P04fnJZSYFGHTx1_-n7gupdkbK5nq-ofGfeA0=	2	3	115	77	{4,6,6,4,3,6,3,6,4,6,6}	23166005000061388	jxe5HcVwS8MckjpW4HkqhSuHH68RqTAWAsXaD9DYdreb5pYgN8T	83	107	107	1	\N	1729645808000	canonical
115	3NLnA7ciMPdQiBHZqwFZeC5MYk7pxnPSbikvGVFuAU4heZrBgFn9	113	3NKhw7f4MPTU7GdkCAy3QvZRvC15d2Gds9rjcDmGbBujqNWBhCYf	96	95	eI0FnWi0Xx0SIDjapzMzCO6--3AtHbr7Rd8TnYuXrgM=	2	3	117	77	{4,6,6,4,4,6,3,6,4,6,6}	23166005000061388	jxkiuhxk6kfD3RpZ83HtBDsHkaaZQ4Coc4sAWAZXgqno3UqxZ2c	84	108	108	1	\N	1729645988000	orphaned
117	3NKSxSHK4MvmgkuuR5YeLuHTk65Fa2f4T1qFD3mjVXyt2SJHdmdk	116	3NLMSs4GyXxoXgEbmnTFekzPUmcsH3wxzru8Ei9BWW31u4W7ZSth	96	95	5DqeWyymbDoQJ-TLVDczj_inoz01ysZRyPVoKTyf9A4=	2	3	119	77	{4,6,6,4,6,6,3,6,4,6,6}	23166005000061388	jxd8sSXUCTVFWuNpT4Tr6yH4phE43WGEhmc1rtf6U5MfcfM3DUL	86	110	110	1	\N	1729646348000	canonical
119	3NKsLhnaY56wHLa1LKVQDXkVWHf4wKGNNsT3dytQ7nfPctihNZtx	117	3NKSxSHK4MvmgkuuR5YeLuHTk65Fa2f4T1qFD3mjVXyt2SJHdmdk	67	66	iNv-hPFvID8l6LDn6fVNb1besZ1DxH9PiYkt3kqOeQI=	2	3	121	77	{4,6,6,4,7,6,3,6,4,6,6}	23166005000061388	jxRDyPQbH57wopjpJa3Z51tBtrjfi1o3ibtyYS6ANJaZvspUvrg	87	111	111	1	\N	1729646528000	canonical
121	3NL3NPgsmr5J8MUU6snZ1TsDwEjw4Jthpt8Jh77kuYJyt89Hm7Xq	119	3NKsLhnaY56wHLa1LKVQDXkVWHf4wKGNNsT3dytQ7nfPctihNZtx	96	95	vMJws6-wKzlA6WcnaY6ur38ztu1YzpSfw-YIsV0KQgE=	2	3	123	77	{4,6,6,4,7,1,3,6,4,6,6}	23166005000061388	jwzHk3jyJsRAkipU6vai3Ju255zfB13xYx8wtDQC8VLnp7Pc252	88	112	112	1	\N	1729646708000	canonical
123	3NL7CF8ZE5th1Vrq5ChkzV4YdfFsWmheWYf3MjxDomy1N8LH48dU	121	3NL3NPgsmr5J8MUU6snZ1TsDwEjw4Jthpt8Jh77kuYJyt89Hm7Xq	96	95	-YiKXRJA7orPtHy3UheQoY7tnipqJ6Z8ZYtcSfdyzg8=	2	3	125	77	{4,6,6,4,7,2,3,6,4,6,6}	23166005000061388	jw9p74a9bJcaos3vNQmXdgCb4g7YPELkd5r8Hk6HCPe7xZWk3Si	89	113	113	1	\N	1729646888000	orphaned
128	3NKf6xteTgDJih1L8Av3ai2tpJFiAdQDWGSnt5bFbzKq8o2Co6Jp	127	3NLxEQ7QCFdiMpEof7o9X2yJHXYPAF5uhhoQbRidoTWV58GNzkin	67	66	vCjjyspL3_UI0MVl4eUNb21KOflN4Oj_MC4rpiGCeQ4=	2	3	130	77	{4,6,6,4,7,5,3,6,4,6,6}	23166005000061388	jwPaQo4orK1rg8LujuzRRAY6NsNn231BpJ1RzEL8ZreaRGikiAx	92	117	117	1	\N	1729647608000	canonical
136	3NLFAGbxot8WDoMWDYjkyALPgP89SVa4HRdRmphuzR4ZjW4gS5Zh	134	3NK82gbGxMnVd4DXgSa3nLurwKq6JxrbPFanUCDsyFaZRvozPQN9	96	95	YLE8IaHQMO4Yog119TqdzWbNtaQc22U67kJ4mxeFDAI=	2	3	138	77	{4,6,6,4,7,6,3,6,4,6,6}	23166005000061388	jwjxn8JD2kAr4UXxmRbPUV6WMuHRR8o43oh4cKhCbtUrKM6pGuc	96	121	121	1	\N	1729648328000	canonical
137	3NLTFdwfTEwCq4kQZit7bF5eCDWpXSsbDUBRXg7e7gpPMUwvPsaN	136	3NLFAGbxot8WDoMWDYjkyALPgP89SVa4HRdRmphuzR4ZjW4gS5Zh	67	66	Pl5aq6wqhuTIZRFudQ4K07QbQb1s_5ijdWc3RDeriAc=	2	3	139	77	{4,6,6,4,7,6,4,6,4,6,6}	23166005000061388	jxQnSfRtpXqAqyDa3iEyGcFx9N6sYzjVhy1ukoKHF2fWuWaUHqE	97	122	122	1	\N	1729648508000	canonical
86	3NKKfoC5XgGtZ9F3y2sFVFDXkw31wvcBdDr7oF6c71yZhGTpsRWW	85	3NLWgqvGBwkrwvjJq2GqxyuMT2xRfiGgz4nLm9AjzuAXmbsKwfwK	96	95	F8V1iQcNgVmTaUeTwPIgIBhhZQiHm5i0rHQire9Aug4=	2	3	88	77	{4,1,6,6,6,6,3,6,4,6,6}	23166005000061388	jwk8d7YxJPaewWydyq3rLHg2F4k12r5ALyymf3RfktMuH4ksi3V	65	84	84	1	\N	1729641668000	orphaned
90	3NL5pTSeiFLabjrbemXxWFcixNoKdrSm1ZjeznuSwmBGrRtjgcFq	89	3NLYbos5rhZmn2eAF1XLnzWxBGrGQkkZQ7xkGLxYr4Yvu7wiBD83	96	95	363CiEabLFCsKXR43jHTTNsdDUPinQSG0LabOar_RwI=	2	3	92	77	{4,4,6,6,6,6,3,6,4,6,6}	23166005000061388	jwjfWEq8DGCYXDbSdduLSWkNvpFnpT3tP4otU6cNZxFQbfTownX	68	87	87	1	\N	1729642208000	canonical
91	3NKLdqLe1D5TbfM72odamfrcWR8iMWKivakmwD8tr2rxryoeZpFm	89	3NLYbos5rhZmn2eAF1XLnzWxBGrGQkkZQ7xkGLxYr4Yvu7wiBD83	67	66	e8eh36AExrWU9lkQFoPm_bwT2duStczb7o7RS13_Nwg=	2	3	93	77	{4,4,6,6,6,6,3,6,4,6,6}	23166005000061388	jw75UYULew7MphGBJvHHq5drDjDDax4aAH1yRQN5uVEhntaQroa	68	87	87	1	\N	1729642208000	orphaned
92	3NKHjvp9W8tfvKtVUDhjapkirhVin6EHk4sS6pK8AJEiLMwqj77G	90	3NL5pTSeiFLabjrbemXxWFcixNoKdrSm1ZjeznuSwmBGrRtjgcFq	96	95	OdSBWY7Pl0fZPrn6u-knNV9RJI6uLmGLA2otW9kT1go=	2	3	94	77	{4,5,6,6,6,6,3,6,4,6,6}	23166005000061388	jxALaUmwDFxLpkLCdmd4YattjbbyGEgRyzoLdtJM6aSrovjmXFg	69	88	88	1	\N	1729642388000	orphaned
139	3NK8i1uSvkv7kRg1CB5AwRTcCd491rVZbTo6Aogr2WguYcPhTr4y	137	3NLTFdwfTEwCq4kQZit7bF5eCDWpXSsbDUBRXg7e7gpPMUwvPsaN	67	66	IJNZwk92SvICjHWQAagPaXQGKNGrQnO9wljPhRdfbgQ=	2	3	141	77	{4,6,6,4,7,6,5,6,4,6,6}	23166005000061388	jxiaCRLJCYxR3h2HVU4jbyqz9tFkQNLDUg5ALqm9a7mQRqmMmEv	98	123	123	1	\N	1729648688000	canonical
138	3NLrarQmgrBXpdQuHorAEWLDbx2Vg54kQorVNVxr5JewqCmsDAv4	137	3NLTFdwfTEwCq4kQZit7bF5eCDWpXSsbDUBRXg7e7gpPMUwvPsaN	96	95	kZhlYfKnqxtv0bVrQNGJnVN0l-0dWUTrjSPDWEQRBw8=	2	3	140	77	{4,6,6,4,7,6,5,6,4,6,6}	23166005000061388	jwPBaRD8JVAaQ9g9KUmLvZvEWraFDMbnUu2Nqop7fhC2fuH7TG2	98	123	123	1	\N	1729648688000	orphaned
95	3NKsXJERS4LiDDLJVjaPrPAfEVfnz9wH5o1S1JQbDomU3UUoLVNH	94	3NK361Mxk18yrvfvyQgvZHhKeeDSiHrFhebj95xF65f36dHnvZS9	96	95	jKnr89TYTYAMQCOud0zM1eb4gmqsQlWBRzHVSsdRSA0=	2	3	97	77	{4,6,1,6,6,6,3,6,4,6,6}	23166005000061388	jx11N6LSwyBXXkSUtDdkK2VC2o2RuYUE8EM5qwRdWfUu1bB3uEr	71	91	91	1	\N	1729642928000	canonical
266	3NKyCM3Dg2EX3gqK6ci3KuoCyH2KF3MCYdfpzb1f28RUWWYYxpC9	265	3NL3VRRCdEe2dCVbKWvnKSAtUBavAzxy2vncwz78Haci8Avra7yp	67	66	GbRjTlalDEtKOIUqPilIL0opmIhcnoxL4P87wDi6ggM=	2	3	268	77	{7,3,4,5,6,6,4,6,5,5,3}	23166005000061388	jwLnNZzRxyFTSXKMesTmUwrivkw9v9ML8KK68dChkb2oviCWNWV	193	258	258	1	\N	1729672988000	canonical
140	3NL7dXiH2z9UKNNq6qYxp8u8KGeV1NrYNipv8drhUbKzUmKqkpJA	139	3NK8i1uSvkv7kRg1CB5AwRTcCd491rVZbTo6Aogr2WguYcPhTr4y	96	95	L7SFamU7n7DB0AlTQ5Wci6CEA35BSUOvRrF4wqxlIgs=	2	3	142	77	{4,6,6,4,7,6,6,6,4,6,6}	23166005000061388	jxiuiJVenfGJykFHWMVEvnaqqckwKxQ5tUK9tqDEDepErbVCneA	99	124	124	1	\N	1729648868000	canonical
130	3NKbDtsHswo1W9WiQK5KJQ9KEnjyPTYG61zQ6jMudmjFSLXja2SJ	128	3NKf6xteTgDJih1L8Av3ai2tpJFiAdQDWGSnt5bFbzKq8o2Co6Jp	67	66	F15skA5ul3jJalficxT5zNWOS6Z4tMTJeonmjv2NhAU=	2	3	132	77	{4,6,6,4,7,6,3,6,4,6,6}	23166005000061388	jxWVULT3Eb242hGWc31vEpJmj1M4ncsSffs8Sk75uAiLvx1Ji28	93	118	118	1	\N	1729647788000	orphaned
134	3NK82gbGxMnVd4DXgSa3nLurwKq6JxrbPFanUCDsyFaZRvozPQN9	131	3NKRvd9PW9GB6eVtHKyB5x1BVHqTw7QNazof9TvPxVX3kQuWebq8	67	66	U6PXhw0LrTCaepUjmqbKo9lfloEVVk5O4mY25lP7wAk=	2	3	136	77	{4,6,6,4,7,6,2,6,4,6,6}	23166005000061388	jxngffEaS6oe5AumtLx2dpN75fDiSbWDaCp65JUHuxy8bbjwX2n	95	120	120	1	\N	1729648148000	canonical
141	3NLC5sZyYWyyZG66FvP2zXLKDNHd9WDmx3Fq56AgEoiZvc1VDqNu	140	3NL7dXiH2z9UKNNq6qYxp8u8KGeV1NrYNipv8drhUbKzUmKqkpJA	67	66	fpq8T838HxxRgBUlS7KGy0yGOvUvUhSe1j9SwADUyw8=	2	3	143	77	{4,6,6,4,7,6,7,6,4,6,6}	23166005000061388	jxeo2aVLeV7VkM6kcVnVdAGevwQZVRMoaSyUqr8RBCmJxU6WoRL	100	125	125	1	\N	1729649048000	canonical
143	3NLMFkgXrvPPCVgXrT2wyEjFM4HCRVrB9tRyTFEpWPdP7AKUastb	142	3NKmP2TRECXWdX67YMX41hY4mw5iPXxz2rjxYN9BEdxZFABtsBpk	96	95	pSbx0ZvVheo2rLbgPY4ae5UF9CbGrFGKennuJUOzegw=	2	3	145	77	{4,6,6,4,7,6,7,2,4,6,6}	23166005000061388	jwNh6csaQV4WtriakdCfRyLoLioKmfbVLH5UCsJQ9KZ8b8pwfsW	102	128	128	1	\N	1729649588000	canonical
181	3NL6Uq3DS1oTMh2RwwPwnpND4dGAH4vUGXKwefEhhYuJvPJdKubA	180	3NLj7iHjnbFE8TbgjmBBjSoeYXESc7qUXMz3fnXThfrxsUSCxgCk	67	66	puweo4tEXmrQkx4beOUJEOLTbVRZXaVApU68-CfHRgI=	2	3	183	77	{2,7,5,4,7,6,7,5,3,5,5}	23166005000061388	jwhNCXFKRvBrYYB1qXzW4WRrUU3VxPiLgLpg5YTHuvTyuHBFp1w	132	172	172	1	\N	1729657508000	canonical
102	3NKbBdrUjkGBcrrtk9kvmyPRbLnLJd9jDqwhwREzHKK2qzi9X8sM	99	3NKSMBEkRJKQ29n586gss7GudMtqBH9HhqhVUPUxi4E8ioF1xk85	96	95	dverI6uDiuNfdo7-Fj9XK4Qpy9WeFmQt0zEtogmHmA8=	2	3	104	77	{4,6,6,6,6,6,3,6,4,6,6}	23166005000061388	jwg4X5k9ipf8dbSMCS3Y18R7jSwQ663LQoBDxe6BJWwAcAZBn6V	76	97	97	1	\N	1729644008000	canonical
103	3NLmAW4bEwUxn6FMiftRXxXQbY2eB9ZRGu5Fo8H5YBKsykgVNyb3	102	3NKbBdrUjkGBcrrtk9kvmyPRbLnLJd9jDqwhwREzHKK2qzi9X8sM	96	95	hcFxs0Q0Z9yZHh5kg1XNxjHSi2EmJkFN-wla6FxJMAE=	2	3	105	77	{4,6,6,1,6,6,3,6,4,6,6}	23166005000061388	jxxyuJAKKytvMNyoMtZaqH6zvorgaagsKgsmqReD3Skcru3wp8U	77	98	98	1	\N	1729644188000	canonical
142	3NKmP2TRECXWdX67YMX41hY4mw5iPXxz2rjxYN9BEdxZFABtsBpk	141	3NLC5sZyYWyyZG66FvP2zXLKDNHd9WDmx3Fq56AgEoiZvc1VDqNu	67	66	gzqM_jIDsnz2Mwx5QKAVB8g3HK26wztTwmqlcytC7QM=	2	3	144	77	{4,6,6,4,7,6,7,1,4,6,6}	23166005000061388	jxAJkseTS81ShhWnBZfghXbCAVRSwWyeVKDJ5gTPykc8pboqwQa	101	126	126	1	\N	1729649228000	canonical
144	3NKsFyVwfox4BAT4Cz4ZFH4K5gYShDQezQKGp4gMn4FfZenpZFFv	143	3NLMFkgXrvPPCVgXrT2wyEjFM4HCRVrB9tRyTFEpWPdP7AKUastb	96	95	DEbeuZEsFnZ8QD9L1jrWWTb0doVecZdohuVfZxK3Xw4=	2	3	146	77	{4,6,6,4,7,6,7,3,4,6,6}	23166005000061388	jwhPKUj2qfCenb1X3LR9fin6GdgP9mPpH8TYd9kcF5M2AXNQQ3h	103	129	129	1	\N	1729649768000	canonical
150	3NLtu4aM2hod8MbeEd3iR3We3DmG83vRp9y9k6K3vZk1vyigKpA1	148	3NKNaux7B4YQnP12hL849GPHLiVkRUEHb6ibAQimthC6tjdVbRFz	67	66	jihP80sHHZXK5m2X6lDqWYuFF5HygqZy2lD_k0Z9Ngw=	2	3	152	77	{4,6,6,4,7,6,7,5,3,6,6}	23166005000061388	jx3NHuDHBRrTGDtRqiH1zUHSg7pSmGrWEV6AkMY4hKtzrXQJFam	108	137	137	1	\N	1729651208000	canonical
155	3NKUGuao8UzeZdhocLwRFPy4goLCLWMnYf1pwg6PRX1HQoeZ3u4P	153	3NLmLgbCscBatWFTcYypyKhUamiTcGg1D8tQhY41BDyRzcywoWDJ	96	95	12MXPCL0YnwEfYS-vus_hGUTs5eJq5R457GmoXBOgwM=	2	3	157	77	{4,6,6,4,7,6,7,5,3,3,6}	23166005000061388	jx8b9Yyfc3i6vPn4yV1Dpojfux5WXyASSG8LHniPHMNWYtanupu	111	142	142	1	\N	1729652108000	orphaned
267	3NL41E8UXHgFiLU3ZArMhNTkjnSQNXTu6VyVrqcDDVdF4dD6NPP3	266	3NKyCM3Dg2EX3gqK6ci3KuoCyH2KF3MCYdfpzb1f28RUWWYYxpC9	67	66	_D-phw23oRTCKneeyV9qnimnV5ZuqaSs97Sp28fUggk=	2	3	269	77	{7,3,4,5,1,6,4,6,5,5,3}	23166005000061388	jxUxZhKZg5eT328bRddrWaYzuCfk4q4PzQQCYg98JpeEnuzCeZn	194	259	259	1	\N	1729673168000	canonical
170	3NLe6qU8ECjKUc22UK8JE3wu8iBtLJ76sEZVp6VKTKf9HU1rYwQL	169	3NLgU8AheA4t5LTioXNDCnRzNFxpeHVSG9nbMVjYWPLdjXSiSZqB	96	95	VP2Uv_NW2-LDY_2lYpK1jSaLeL2vMRDNqBhjSd_Ugg8=	2	3	172	77	{2,2,6,4,7,6,7,5,3,5,5}	23166005000061388	jwW9chuuGyvgXS2p9YbTrJQwGjkixdh7WYdaQ3gaXtWb1yCjzqM	122	162	162	1	\N	1729655708000	canonical
188	3NKJ7p2aQWMpS6jUmRLy8ZYi8Pix43D3gNCRMzq2qbSEpbG5BFvR	187	3NLGG5TNA9paaVZc2JZ8Bf2exH3cQnP6hYY9hf5yPiu42yzLPxUj	67	66	EdNYvBR_q20_mrxBIFNMCjhZ9tLyUueWkury25dEmAc=	2	3	190	77	{2,7,6,5,7,6,7,5,3,5,5}	23166005000061388	jwZV1o4qW4osGRbZBJGcb1rEns5FP3DPNkYiq5PSvgZgZ8J2Saj	138	180	180	1	\N	1729658948000	canonical
192	3NL6HuDtswEf3csTyHRm5rDc2bUMZNHjaEw3Lc44EAf5VgnS1xGn	190	3NKPxbxm2bbCcWsDivF6A5g9RBUfiVtSuc7MrpF3Wdp3AkseRQ5E	96	95	VEEIOFimfOQwSUO-3Ma9TxbFLj015TUlwMayVtvZiQc=	2	3	194	77	{2,7,6,6,1,6,7,5,3,5,5}	23166005000061388	jxkTv1riDpmkdyKJD6vT7NEMVo92ce65vjCNbvHFyBCXzrACYr9	140	182	182	1	\N	1729659308000	canonical
194	3NL7fzi8gSnfSDtjCqD8RQBDJsWqNkDz3sfRoBSz2ZYTiwiJ4pWJ	193	3NKs7vPY8gyHtNCxEa6MJNMxN6da96BeBYuBqU1kRLcbtTLytuga	67	66	nRU_gW8pjmYtvY-_48PUxeHXMGlsNMnv55h3USV8FQ8=	2	3	196	77	{2,7,6,6,3,6,7,5,3,5,5}	23166005000061388	jwnddYKBjLaKCurwhvnTo5PwweKA6nDsdsdWHsBYFviVg1vpZBn	142	185	185	1	\N	1729659848000	orphaned
196	3NLHevLcqkkQoZ6TLwUHmBrnoR4ZXh94jE6HJMBAmfJxzNBxUCSo	195	3NKdPpNn92jGwLCu15gxzL2SYB48G47VdoBrLSSau56fMQw4biKv	96	95	acAwc7xdjbBcTrSzxqv4f-nBViMUo6dW4yvdTbws-wE=	2	3	198	77	{2,7,6,6,4,6,7,5,3,5,5}	23166005000061388	jxmAYkgPX5AUCegGqbfwnx2pKGWJ5c2vFt471Y1QvBfSkKrqPaT	143	186	186	1	\N	1729660028000	canonical
198	3NLPXbx1ft8UG3c66BLSqgs1P9JhPSVkqvxfgQQp3QXxiYjriomV	196	3NLHevLcqkkQoZ6TLwUHmBrnoR4ZXh94jE6HJMBAmfJxzNBxUCSo	96	95	nxrix-k3u7UBBEbqOEvp3Rsj9g6VeVU7vnVi1D45rg8=	2	3	200	77	{2,7,6,6,5,6,7,5,3,5,5}	23166005000061388	jwGnykGtrbSCmZZAPNaBR2mFim2ffbr6BdfhhxLw4z4uZDD6S97	144	187	187	1	\N	1729660208000	canonical
200	3NLdsSYLhm4Z92BgFhfCMa5qKNZztxuFazawbwb6Ya8H6hAvZ5tb	199	3NLfjB4Lys2P9XD97d1ao3gpWazdCd1wPRPYAhtKhAazRp5HfYpU	96	95	Q4w71ZTriAUE4tawQ8M5oXm9p30Izud7_1rMoXH3QAs=	2	3	202	77	{2,7,6,6,6,1,7,5,3,5,5}	23166005000061388	jxjHjUET45XGgUdnQwebbC2QRyJCddkJv7GCzRJFoKbWBBskxMb	146	189	189	1	\N	1729660568000	canonical
202	3NL2edsmZBtTvzduswPsXRusQJGpQMQvcak77vpCNoryANGDSncR	200	3NLdsSYLhm4Z92BgFhfCMa5qKNZztxuFazawbwb6Ya8H6hAvZ5tb	67	66	Aymt9AzEqhXzeaw6ZaacnZ2yVZR-hL-FAU24FN5oog8=	2	3	204	77	{2,7,6,6,6,2,7,5,3,5,5}	23166005000061388	jwNxkk7qemZeGTRTs1sJnTev9rHcN7GVp4LhjGkA2o4eXDXpdMd	147	190	190	1	\N	1729660748000	orphaned
204	3NKF3582wModCUtjmLwVi9Q6bfw4HbCeEnhSu6q8EiztWkiZx4XM	201	3NL5Kg9iAbRXhLfSfuFsxCbczn79U7kVVLkR75re718zCqskzyQ5	67	66	xdjmHPdcMvmSCDTrvqDXl1OtHgqeY2p6VWLcjs-5yQE=	2	3	206	77	{2,7,6,6,6,3,7,5,3,5,5}	23166005000061388	jwTjQ6dmKzZgZsJB9BB5xxTKJ9sGz7yevRK7c8xVmXSfcsqFAmx	148	191	191	1	\N	1729660928000	orphaned
108	3NLuFJE7C1Zdm8q6niprn26vxRjeEKvdZFyor4jdzKoVAQTHc4CF	107	3NLWch8xAVpdjkPL9UzRPA4HyiYjeNvREDftuqxRCQWvEweSkUas	67	66	cdG0HRKU-lhSnSo-uVgzbGCGieXhPrChfeukF1jqQgs=	2	3	110	77	{4,6,6,4,6,6,3,6,4,6,6}	23166005000061388	jxhXngJZeqoYPQNkuCDXG7mmvyXiXmp4UvJmwpKgrE18T4RMjVF	80	103	103	1	\N	1729645088000	orphaned
402	3NLW3NYQZxPgvvZuXQcGAcPhPa5rKcrKqnL3BCZVhJtFUjbpupur	400	3NKPoYs93yYkiXhzjANC9eAwRm6Zgr9LkpLX7goC9A6St3WKZLYo	67	66	3IgZgx2sNePc3AO5UR2MfHBKEn83JduD0jkAOiNZlgk=	2	3	404	77	{5,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jx2o5NEcyJyqM7dD2hC2yeFJ3sfmYRsxkRD8dvhvD3uDCsnpAGb	292	389	389	1	\N	1729696568000	orphaned
268	3NKm2E2pzbaP3f7dFTfo4r3VDNE5LjqJAAKv3u14uPor384BuwTc	267	3NL41E8UXHgFiLU3ZArMhNTkjnSQNXTu6VyVrqcDDVdF4dD6NPP3	67	66	10r46wJkt-21A22uwlq0y-UxJKZ9C6WPItAw90AlJAg=	2	3	270	77	{7,3,4,5,2,6,4,6,5,5,3}	23166005000061388	jwR9kavkV13myA8se4NDv8nUzbKQ1GshpWQHuHuPKzTEFtfVwjQ	195	260	260	1	\N	1729673348000	orphaned
272	3NLYFrV3i5L5A5kzzf84j3P1LtAagMBiKBdKxgriNPvwEV1a61DD	271	3NLpbGm3wNWTJR4XwF2dq48BkUtAZz93vF4UKXwn3fEuMnsBxody	96	95	e5qho2wQjFb-IMSGqH8eIg5olC9_CQQoLNTRHCePgQs=	2	3	274	77	{7,3,4,5,5,6,4,6,5,5,3}	23166005000061388	jxuV1gxYBsZroaZ8wXXAW4PT2g9ZHiqYNwpScKemH8GCVRfSSCG	198	263	263	1	\N	1729673888000	orphaned
146	3NKXkhpwr6pucBS7EdUMsybJbQHQEjWzzWdNtdeJ7fpdauT8m8qp	145	3NKC7K5c9eJMu8HHMr9oWbKtcEdoVUPwgGHrMBXZkYdjaCGf6YrN	96	95	EWGW0uQNvEAbJIks3vSbVJRiQcR3QjWPlLkIutw9fwk=	2	3	148	77	{4,6,6,4,7,6,7,5,4,6,6}	23166005000061388	jxSSfSeHtrjqn9cSRW2AkvmVLGSXJTYq7dLstznoppi8NcUCjhn	105	132	132	1	\N	1729650308000	canonical
148	3NKNaux7B4YQnP12hL849GPHLiVkRUEHb6ibAQimthC6tjdVbRFz	147	3NLYBQwXjwr2ixYHd3xiQ77UtVbTcX4FxoArSqxoMeUqc94oJsCd	96	95	dcTN7Zjli29j_G2i129rd0fxSFrciVg2ZGJooAke8AU=	2	3	150	77	{4,6,6,4,7,6,7,5,2,6,6}	23166005000061388	jwPe7JaTpyKMWFcVhMLJR5bpAdBbboWYdP2LMY9nDsU36euuRtJ	107	136	136	1	\N	1729651028000	canonical
149	3NKavpDd1x5e7aszfdnfqGGbYnCaLBP28iUGjirEEJLE7qQCMh9x	147	3NLYBQwXjwr2ixYHd3xiQ77UtVbTcX4FxoArSqxoMeUqc94oJsCd	67	66	rnBNJqSiMymvTwIO6UhN730-6FfN8oHYKUx4MnW3OAw=	2	3	151	77	{4,6,6,4,7,6,7,5,2,6,6}	23166005000061388	jwbae1CjWDnm2vQeQEZnirvQ7FVsZCYHt6MrXXzVXaa7poHEbCF	107	136	136	1	\N	1729651028000	orphaned
151	3NKf7Md4X33Qer5KFrxib1NZQV2jokRaqC5a9wzVjAu8SXKHtPxv	150	3NLtu4aM2hod8MbeEd3iR3We3DmG83vRp9y9k6K3vZk1vyigKpA1	67	66	jfutGpeRF9Khmk_S4zYjg38w3CZR6HuWeMiaYBIePg8=	2	3	153	77	{4,6,6,4,7,6,7,5,3,1,6}	23166005000061388	jxqXSUpXavZNs2h6kzVEJVbwWQH8oETkq21cineceznSKdzuUcd	109	140	140	1	\N	1729651748000	canonical
153	3NLmLgbCscBatWFTcYypyKhUamiTcGg1D8tQhY41BDyRzcywoWDJ	151	3NKf7Md4X33Qer5KFrxib1NZQV2jokRaqC5a9wzVjAu8SXKHtPxv	96	95	xJBXk0tPhxbeqp5-gF0Ap2KZmqpqx_WwZ1on8riz1gM=	2	3	155	77	{4,6,6,4,7,6,7,5,3,2,6}	23166005000061388	jxyCiYZ7GsCQx4jPTMk1tgxw8BMCXCgnLwaXqs3g1dSGgvwAcBW	110	141	141	1	\N	1729651928000	canonical
152	3NL6hn3JM1ToAWnpvzLuLdhV2mEoVc3ZJ6RrpoJBMhticrHkR2nJ	151	3NKf7Md4X33Qer5KFrxib1NZQV2jokRaqC5a9wzVjAu8SXKHtPxv	67	66	t2OHhsa1n_SLEaO-kunmVNS4ks0vvT-2MC9rS5Iu-g0=	2	3	154	77	{4,6,6,4,7,6,7,5,3,2,6}	23166005000061388	jwvmBZZMVsvFtdtuvtwavxrjrRMssKWYj39xZY3eC3rrkh8GkAU	110	141	141	1	\N	1729651928000	orphaned
154	3NKGauj81h5RqpcyzSrMrckZDJmisQXBdYVTV7EBzmL66ZuUscZh	153	3NLmLgbCscBatWFTcYypyKhUamiTcGg1D8tQhY41BDyRzcywoWDJ	67	66	pkkCgK_MHPSuLTdqtC-tBFKIVYbKLETuUMqRYrgLbAQ=	2	3	156	77	{4,6,6,4,7,6,7,5,3,3,6}	23166005000061388	jx9deq8aR4RHxdySjUmnrhCehJVRjbu17eyXMARY4D9AdHixVpT	111	142	142	1	\N	1729652108000	canonical
157	3NKgZNBAL7oZaQp3HWubXKz1ujhmFQnv94zHEUGbXhyeQqCjJ3HR	154	3NKGauj81h5RqpcyzSrMrckZDJmisQXBdYVTV7EBzmL66ZuUscZh	96	95	dUQUtkpycqEKeyUCf3YK7F6gOA8ELP15k8ZMnfeQSQM=	2	3	159	77	{4,6,6,4,7,6,7,5,3,4,6}	23166005000061388	jwnp8XcbbD7FugjGM1XUK6dKiRFNhJ7rafzriA6FZztQ8zvhkLd	112	143	143	1	\N	1729652288000	canonical
156	3NLauRFBPwdB4BW3X7WXPVPztV73hG69gqDFfAe7pPLhVf6Av3U9	154	3NKGauj81h5RqpcyzSrMrckZDJmisQXBdYVTV7EBzmL66ZuUscZh	67	66	QRNhJoh_jI6aPGxpLlER18ByVMwtNG51w_nxTljt3wg=	2	3	158	77	{4,6,6,4,7,6,7,5,3,4,6}	23166005000061388	jxXVPCCCdXtnZZx8d6kyzt3izH34soNxypZymHsLv86WjsVjBvc	112	143	143	1	\N	1729652288000	orphaned
159	3NLWV3TLVz935Zb43bbzmv2nMgk8QShuB2rUD2thED33Vqkz9YM5	157	3NKgZNBAL7oZaQp3HWubXKz1ujhmFQnv94zHEUGbXhyeQqCjJ3HR	67	66	kG4sitrzrgdeM46Z6mkYz1UxGL051vZiLRJ9APsY-AA=	2	3	161	77	{4,6,6,4,7,6,7,5,3,5,6}	23166005000061388	jwKepumC7pzDrZtRYLBgk975gtig2bZ33EtUwPZtrn1Yh6b2ug9	113	145	145	1	\N	1729652648000	canonical
158	3NKkTF3Ls5GN3Y5Eqvq256Khu4pZm7NYfJhDyivcHtuNV6brfpec	157	3NKgZNBAL7oZaQp3HWubXKz1ujhmFQnv94zHEUGbXhyeQqCjJ3HR	96	95	WtotUlyRha4AJADVqA3P5FYEXUNldmgBrHo66fMc2As=	2	3	160	77	{4,6,6,4,7,6,7,5,3,5,6}	23166005000061388	jx88YV6Y8ry4SijaYS5cmfnpTFfwuLqsgCh1cELYJCVRbRaP2Nv	113	145	145	1	\N	1729652648000	orphaned
161	3NKFrRtBCnitaeNN4Nz6947ucEMb9w8R4yniFZdhXNXcd1GA6sAh	160	3NLFF6qyVLp8vxziA6gURw3NLczojmMAFaAvczRBAi7roxEUQzjv	67	66	K1NTdGGAaVrvQKWLFcoyyNPeJKQuPxCLd-W9WkI7BQA=	2	3	163	77	{4,6,6,4,7,6,7,5,3,5,2}	23166005000061388	jwdxgeJNA235qmFMCcbmkDoGFjLDTixYhfrLon7NNP9gd5b87t1	115	149	149	1	\N	1729653368000	canonical
122	3NLgAToowRQfjGFPGZzyXU4x3dkj9WVryRTbNixmBWzVMz1rkpNg	121	3NL3NPgsmr5J8MUU6snZ1TsDwEjw4Jthpt8Jh77kuYJyt89Hm7Xq	67	66	6sqsw5dkAJ1Rv87IFOWrWEd6w9CDXJZlYPgBxvd4Zgo=	2	3	124	77	{4,6,6,4,7,2,3,6,4,6,6}	23166005000061388	jxZBZ7r9XM3G5xY9ae8GGs4VgfdNvFSoDsn5PsiuWM2P2Mcnjf4	89	113	113	1	\N	1729646888000	canonical
132	3NK81EGCDQcPsWLP6REQqUid1bN4n785kcP2GqxuUmEUrcSqkA2K	129	3NLmgCxFd1Fh7SxoEMnWKDXL2cWbBZCoB2HE99FQuax3kPUuhoSH	67	66	2mcCZ7A0Eo8NqkyJ8oI_u4U-8IzJMNGFH1bgY-WIrwE=	2	3	134	77	{4,6,6,4,7,6,1,6,4,6,6}	23166005000061388	jwT3jnHBy8Z6nSHcutcBhdvtDLD7ALQMDu4DFYrs4Y9wZpztyAM	94	119	119	1	\N	1729647968000	orphaned
271	3NLpbGm3wNWTJR4XwF2dq48BkUtAZz93vF4UKXwn3fEuMnsBxody	270	3NLhbC5u6wifxGcpfaxGt23wBaZM2XYrybs5AGvxC8GbFz8wyVA6	67	66	QafQXkN3-gu4_bTHNTR1IhgXJTdvF_y0mA2IMURIMwE=	2	3	273	77	{7,3,4,5,4,6,4,6,5,5,3}	23166005000061388	jxZwypGTDJa2nP7kmkATx1fmjUnbBjLCUjJgdVZGvjh1pn2Zcg5	197	262	262	1	\N	1729673708000	canonical
160	3NLFF6qyVLp8vxziA6gURw3NLczojmMAFaAvczRBAi7roxEUQzjv	159	3NLWV3TLVz935Zb43bbzmv2nMgk8QShuB2rUD2thED33Vqkz9YM5	67	66	QxoQQ5W_wEmneEgaO0MVyfg2KwHwT9GeNDwW1D4zkQ4=	2	3	162	77	{4,6,6,4,7,6,7,5,3,5,1}	23166005000061388	jwh3W3jgZjcAq3RVnZNzxxUE8HsL6F1QLaydhc6zYhdccaNDytS	114	147	147	1	\N	1729653008000	canonical
162	3NLVQUrKPw5JKo5FYu6nxJR1vFouqDH9x1QVWpBJKvEsvWjgDSNW	161	3NKFrRtBCnitaeNN4Nz6947ucEMb9w8R4yniFZdhXNXcd1GA6sAh	67	66	oApolFcHZRxTlD64MFcGGOFYmwq1VXQU9sD9uxhLhw8=	2	3	164	77	{4,6,6,4,7,6,7,5,3,5,3}	23166005000061388	jx1R9HZk41on4QVeyPjZUj7aL5VFUWXCV17YP1Ps2yhmbTrgadu	116	150	150	1	\N	1729653548000	canonical
164	3NLnZsrYaP7sRHA3A88M1pHzc94BTvuLMgwGNbSeULwQUYGGjugT	163	3NL9yJ97EJePzqH2v7HqwKcmEkAz1KN8C7Y6ogNs3EgAMfNJzT2c	67	66	Xslgad9ie25MW5CrAHWSuhAg7wXf02kE_TRS0jNABwE=	2	3	166	77	{4,6,6,4,7,6,7,5,3,5,5}	23166005000061388	jwbgpeBdSuTDv1DS9F2jTtZ1byjmKEzp7XZvLQVPqwaXU6dWMFG	118	152	152	1	\N	1729653908000	canonical
374	3NLakSutYkhiCj2PAMUDeQHavSeVCpggC7mDFRgy64rnEmJXuee4	372	3NLsujzatRYQzXMfkPpiAr1p94BEFYKfHTfbUw8HDQ91VcjJoEED	96	95	_VJavDsyCrvUZUwKRXPDAWlSy5HWLnsUR4j0ibk_Rgg=	2	3	376	77	{5,6,4,5,4,5,4,7,3,5,7}	23166005000061388	jx5J4ue54zZWGZ9L8cpaQcFBcGJfKZ1zNoRd6vmYGk9tNiEVqyV	274	366	366	1	\N	1729692428000	canonical
171	3NLrHi1LpwLoxUF2sTSP28xLMrsSsnVDgMkAWVSkJWEPtL2oSgKj	170	3NLe6qU8ECjKUc22UK8JE3wu8iBtLJ76sEZVp6VKTKf9HU1rYwQL	67	66	6po188rI_5uGllBEd5kLPAgM6NCjVjDt8Yzm7WeGmwo=	2	3	173	77	{2,3,6,4,7,6,7,5,3,5,5}	23166005000061388	jxNvB1yxYvQYnTDZ7w66kGkcocgsDabihFmgzigW6EjD2xMFbZC	123	163	163	1	\N	1729655888000	canonical
173	3NLRVLsLUr2w782BHhm1zjfvs4fFMDAbw4qZxmnpffn7vmqsuBVQ	172	3NL97XTEAXxSVCVGazV8aDJNkAbLsGvqqBJRRbj2AdcWehLsi4mY	96	95	ioddWXZBx9oK_mQj8_LpVnhd37IeQ2q_khIUtv4Sbw4=	2	3	175	77	{2,5,6,4,7,6,7,5,3,5,5}	23166005000061388	jy2K9s2Qb3pJgjnmGpKHG5hHf8oHGWtG58ea3uiF1hApcwN1Hkg	125	165	165	1	\N	1729656248000	canonical
174	3NKBxUAEc9C6bPAdLGeUzq4VeV62S15mJoSiFFX1V9es2MMUz3XR	173	3NLRVLsLUr2w782BHhm1zjfvs4fFMDAbw4qZxmnpffn7vmqsuBVQ	67	66	wzVPg39BuKLUrIYzsxFSbJVp0zsapKSmflNyMey0Iwg=	2	3	176	77	{2,6,6,4,7,6,7,5,3,5,5}	23166005000061388	jxvT6QWo137sabMpTHCHHUBPraLwjBhaRLdimhMaFyUAYK37anS	126	166	166	1	\N	1729656428000	canonical
186	3NKbzRNHBNtnZWRXE4qfkSo5ffTc6nPerpzNrVmNhYQVuH3c3uWs	185	3NKW7jpFrVVsbvWcnHJT5SdkJsckYZ2ZsNGL2RQNwu2gij5msL4e	67	66	rT5ukALHUe-wUGPdDFcYa5VYlkiNMI-1_n2BgHHDDww=	2	3	188	77	{2,7,6,3,7,6,7,5,3,5,5}	23166005000061388	jwyZzp5mLkAn9TVYw7FSJAaLphciJxswh5FbuyvnSuhtbBeVhnC	136	178	178	1	\N	1729658588000	canonical
203	3NKkCKono21EmTBpfjyfEEacwrYpuCy9NoUXPzC5ZZTZAE7W96CK	201	3NL5Kg9iAbRXhLfSfuFsxCbczn79U7kVVLkR75re718zCqskzyQ5	96	95	6rgQPU5omQE3FqOMxLnS1t5OPNqh5h0vRrGiwdW8NwE=	2	3	205	77	{2,7,6,6,6,3,7,5,3,5,5}	23166005000061388	jxts8PTDs4kZL5J6GiBRU3RKLKNAvZUXtCsxMAp1wSrKCicUACM	148	191	191	1	\N	1729660928000	canonical
206	3NLn2EgksomoxfC9kmTx98MohABfF7DjvW5HwBEHYHFvVxC7dKB3	205	3NLnoeoLuD5nUCkDXkpAMBHELesPFJ8FtCVDmtuHmvSRrRepy1Nw	67	66	R_74vcIglIC4JWgWZboI47YXapXQkW2bXXU1csvAwQo=	2	3	208	77	{2,7,6,6,6,5,7,5,3,5,5}	23166005000061388	jxWt4xrkZvswjForKKXbNBsBipKhqtp5RJj8Btkp1xcNRUpagjY	150	194	194	1	\N	1729661468000	canonical
207	3NLuqXrJ2LGukurCdZoTDDQMGXKp3e8rRsgSCNmH88YnHHBQgdub	205	3NLnoeoLuD5nUCkDXkpAMBHELesPFJ8FtCVDmtuHmvSRrRepy1Nw	96	95	2F_vX_BSDNC1vvfmv8pYcvXLQYUC-mqpONb_37DNHwU=	2	3	209	77	{2,7,6,6,6,5,7,5,3,5,5}	23166005000061388	jwi3GVvNia8afPMY6GKzdjyAA4mw4p7XHKFgbLTrMAo77tGaiN3	150	194	194	1	\N	1729661468000	orphaned
209	3NLWY8DvtGB7TAPSewA3KdaRY3BrGWgPLzeTLjw3snrpG4yN9oe6	208	3NKVQk543FXqDFPRodmCj16BhBuQFfwHgFgvsNMhV6E2qeZ51bcq	67	66	AHNoj4Spqh4EO8YLFc2CMj8Phr-kKsEesHoRZU8vFAQ=	2	3	211	77	{2,7,6,6,6,6,1,5,3,5,5}	23166005000061388	jxvEesCUSuEAw3e72p5r5HxN5M3j1ibT5ZC5PZ4Dbf9FXA8mVcj	152	197	197	1	\N	1729662008000	canonical
211	3NKwGVUfPjqBrRwvznsChJXsbDpgpvfjHz7HinfKNo8ex55QMJw1	209	3NLWY8DvtGB7TAPSewA3KdaRY3BrGWgPLzeTLjw3snrpG4yN9oe6	96	95	WeWBDkbc10vt5YHJnyB93JLc-x1U4vGHQhxnLQd63AE=	2	3	213	77	{2,7,6,6,6,6,2,5,3,5,5}	23166005000061388	jxNq2zZL4jDqsr275h1fd3MrFj8S5FjXtNtBxXJsrbPeevBZ7Hu	153	198	198	1	\N	1729662188000	canonical
127	3NLxEQ7QCFdiMpEof7o9X2yJHXYPAF5uhhoQbRidoTWV58GNzkin	124	3NKMoHYXLuqfe2d95HYV1C4jiq2s6abCUHY4MbmBXPokwBR3t74h	96	95	5KLuK-0XWZsu79_rSgGJjoqCJDlXWjklXvdibXi6gwk=	2	3	129	77	{4,6,6,4,7,4,3,6,4,6,6}	23166005000061388	jwSP8yRVvSAuczEuGfs6QuUBDhABK3ZUHgUMo8xFXT7txykCB6m	91	116	116	1	\N	1729647428000	canonical
126	3NKbHPsmbQdk2xo1GbhQLoJRmiQWrdBBbkF9srpzKMnxdsDkLA7A	124	3NKMoHYXLuqfe2d95HYV1C4jiq2s6abCUHY4MbmBXPokwBR3t74h	67	66	_WxPsZ5bkoI8iRh2hfFLPWYU9Jm0l-z4xUjN0_MauAg=	2	3	128	77	{4,6,6,4,7,4,3,6,4,6,6}	23166005000061388	jxLF1o3fXjHbrGXgbGFEzb1oGCNe21JrcFGbeXZZraai1EdhBhC	91	116	116	1	\N	1729647428000	orphaned
274	3NL2HUfzJVoujoAc1RHi4cq1JHqkQHkjPFoUWdAkwgNeHQR2pW1n	273	3NK3BtEFJPRx1qyr3FkGWNNshUDJ1Mvds9wZWDjBScmQK9rPEvei	96	95	hT5rfDm_aO-SpUtosgw-B9CezdUt0bLY93fyHd7i9gU=	2	3	276	77	{7,3,4,5,6,6,4,6,5,5,3}	23166005000061388	jxoa8ULPZ6SNr1Nac1B8VtEHgAcUXZcSPWDBHiGre4cNcjoKVxr	199	264	264	1	\N	1729674068000	canonical
135	3NKVSwcP4kHyfntULQbdqp5NoZs7xy5XoRQSSm4VtNceDTPodtmH	134	3NK82gbGxMnVd4DXgSa3nLurwKq6JxrbPFanUCDsyFaZRvozPQN9	67	66	uRK7yvnQos13OWm96umV629yZVu8kLCmF0v_qLDM8A4=	2	3	137	77	{4,6,6,4,7,6,3,6,4,6,6}	23166005000061388	jx2B8UexTvC2nW3uNLwvXM6hwihFGgABwQEp1vhhciWDDNPmwFH	96	121	121	1	\N	1729648328000	orphaned
163	3NL9yJ97EJePzqH2v7HqwKcmEkAz1KN8C7Y6ogNs3EgAMfNJzT2c	162	3NLVQUrKPw5JKo5FYu6nxJR1vFouqDH9x1QVWpBJKvEsvWjgDSNW	67	66	wNYAZBC_28BKk0zIkNb-2uYBKZopFbiCGzkws8G1zwk=	2	3	165	77	{4,6,6,4,7,6,7,5,3,5,4}	23166005000061388	jxN1V3H4oBXZTuizRNPsv2JU3QqK2AsK4DqntEnxB11ARrmvZuF	117	151	151	1	\N	1729653728000	canonical
165	3NLeAJsg1rS9tMK7kJzBGfnFporKVcLAtRrqHzF7WVYQ6azPp9ez	163	3NL9yJ97EJePzqH2v7HqwKcmEkAz1KN8C7Y6ogNs3EgAMfNJzT2c	96	95	gSeIrLgeOK1MKIP5iap02LbzfEgB6wQJgM62YWDdEgE=	2	3	167	77	{4,6,6,4,7,6,7,5,3,5,5}	23166005000061388	jxyrbiEkCB1RdTqfkzgCZLmW77vCRL1cb44ruZoPnTNEDEXabXc	118	152	152	1	\N	1729653908000	orphaned
167	3NKQBbZrcYKnhofcfJbMoMiQXoXWDetgWN1ecatnreYaNamGXqTQ	164	3NLnZsrYaP7sRHA3A88M1pHzc94BTvuLMgwGNbSeULwQUYGGjugT	96	95	cUU4PN6gY9OHqPkCJXuPTeoNqSPQ0pwMsPCtP8uADAE=	2	3	169	77	{1,6,6,4,7,6,7,5,3,5,5}	23166005000061388	jxPSQUSKHMYx7AMQRpUxV5gVsC2nDvTaKR2bXmxzz7Yi1zsiAja	119	159	159	1	\N	1729655168000	canonical
166	3NLvdqPkaxVUXdABAvYFkhnWLTKhzLHFmY62yQFjcJrwx7GWrsZF	164	3NLnZsrYaP7sRHA3A88M1pHzc94BTvuLMgwGNbSeULwQUYGGjugT	67	66	VcxV2fezIi04oOEkZKZAxweGOCViTXONTWQW37fh_AI=	2	3	168	77	{1,6,6,4,7,6,7,5,3,5,5}	23166005000061388	jx5x7eKngX6gJaro6QUkqXkmJZxKdRwgob2mLVwkVHNjVcBwLKF	119	159	159	1	\N	1729655168000	orphaned
168	3NLA9hANaeXi6QqGfV5UCHecbKj3ZgDnSumSgqsLfYtpHqpCUux4	167	3NKQBbZrcYKnhofcfJbMoMiQXoXWDetgWN1ecatnreYaNamGXqTQ	96	95	BmkiQVq93aC-br-jalS7dqm60289zQ6bQWUpSZtH6wk=	2	3	170	77	{2,6,6,4,7,6,7,5,3,5,5}	23166005000061388	jwechH6r2fLnrN8ZbeFUE6c2tdwXJcqoom5XDC1ZhtWZi5JGbXP	120	160	160	1	\N	1729655348000	canonical
169	3NLgU8AheA4t5LTioXNDCnRzNFxpeHVSG9nbMVjYWPLdjXSiSZqB	168	3NLA9hANaeXi6QqGfV5UCHecbKj3ZgDnSumSgqsLfYtpHqpCUux4	67	66	1_r0MLHgi8shfMR3rh0cq3dtdIIx6vcYZGp49z9goAs=	2	3	171	77	{2,1,6,4,7,6,7,5,3,5,5}	23166005000061388	jwEDSpxrmEScGX5vr1JNpU8UsQ98nsaa4M849wDbecnaqEYkijZ	121	161	161	1	\N	1729655528000	canonical
189	3NLuLqjPA2SjaR9nbHezAvGkvBXYt2ZyhdRwYPrk3s2x2J3iz9zz	187	3NLGG5TNA9paaVZc2JZ8Bf2exH3cQnP6hYY9hf5yPiu42yzLPxUj	96	95	09zwxkVD8BcnXK57-fLpfcw40TnSUOkFrWhoqljtWQs=	2	3	191	77	{2,7,6,5,7,6,7,5,3,5,5}	23166005000061388	jxUtaCiBp57AT7bznTjNvXW6a2zVHNmChCFyswYJaKaSfL56cfG	138	180	180	1	\N	1729658948000	orphaned
193	3NKs7vPY8gyHtNCxEa6MJNMxN6da96BeBYuBqU1kRLcbtTLytuga	192	3NL6HuDtswEf3csTyHRm5rDc2bUMZNHjaEw3Lc44EAf5VgnS1xGn	67	66	wTqtK3YNAFXJqKcKQeJh6yUr_fY-g5yMyZesXTu8Sgo=	2	3	195	77	{2,7,6,6,2,6,7,5,3,5,5}	23166005000061388	jxNrEEX3TC5WaNdVBtJRz61nkV8aJ8jC5FmrNpJeChNnyYLqFPv	141	184	184	1	\N	1729659668000	canonical
195	3NKdPpNn92jGwLCu15gxzL2SYB48G47VdoBrLSSau56fMQw4biKv	193	3NKs7vPY8gyHtNCxEa6MJNMxN6da96BeBYuBqU1kRLcbtTLytuga	96	95	AEsN2gHSKeGhekIuPwU4bj7z4e3Axz5uaVQLKevPHQ8=	2	3	197	77	{2,7,6,6,3,6,7,5,3,5,5}	23166005000061388	jxC1vwLkD8F4CfrFXUQHYNoVzQoxQSfCNa1FvNEezgYpwHWG8qE	142	185	185	1	\N	1729659848000	canonical
197	3NKr1UynoyFMv3ZGVrFgmXrf8ApW9TYWR6tayMcJPny9y1Bjanko	195	3NKdPpNn92jGwLCu15gxzL2SYB48G47VdoBrLSSau56fMQw4biKv	67	66	qmg5pvxtXODGN9LqafC-anpl0T_pD_I1zLI-2-wQiQY=	2	3	199	77	{2,7,6,6,4,6,7,5,3,5,5}	23166005000061388	jwVxT6csGHTh3RoaRTqaufhXM3U7taFnaEJ2e2Hh8MJpy4BxCZp	143	186	186	1	\N	1729660028000	orphaned
199	3NLfjB4Lys2P9XD97d1ao3gpWazdCd1wPRPYAhtKhAazRp5HfYpU	198	3NLPXbx1ft8UG3c66BLSqgs1P9JhPSVkqvxfgQQp3QXxiYjriomV	96	95	o69f2aRAQG-sRgzQ3nmFAzv7YHH20JPmGa7_lHVlKwQ=	2	3	201	77	{2,7,6,6,6,6,7,5,3,5,5}	23166005000061388	jx9ejZwukFtKx33Ko8WeWGD9NQXseXmM3msRymFR1PbTZqwxR4t	145	188	188	1	\N	1729660388000	canonical
201	3NL5Kg9iAbRXhLfSfuFsxCbczn79U7kVVLkR75re718zCqskzyQ5	200	3NLdsSYLhm4Z92BgFhfCMa5qKNZztxuFazawbwb6Ya8H6hAvZ5tb	96	95	BPCdT465MxY9K6nopo_qZxmk3b_1AA19ycf13kOmJgc=	2	3	203	77	{2,7,6,6,6,2,7,5,3,5,5}	23166005000061388	jwnypG9YH1nYokgtUtMGQP2hiV18HUyBcPe1fecPUBR1Xi5jr5z	147	190	190	1	\N	1729660748000	canonical
241	3NKUSEwi3ZFvBeJ8rzQVn3usujTUcx38eJMdWQR4jFCnzxN9eiQ4	238	3NKMEF99qAwxvDBYfpQ21FpmZU46viJ1igU1db6CNJcttJfnhjRd	67	66	fQmcmFlX0qszpCrXz1l9benZmEHTB2YqSAaIqBR2ngM=	2	3	243	77	{2,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jxfkJUGTruzAYL4NzqWwan95hrXv8es791j3a68m2rVdfpL3s1U	174	230	230	1	\N	1729667948000	canonical
177	3NL2iKM2aUoU8DzKYNrW5S21AReFnZ2upUQK6qbdDg4kEbGSNfmo	176	3NK2vJj4NuroGWfcS4jcUasC7KGUz3tQkXyF2Y1Ej9w9gDv3FDxd	96	95	ZsAtxktfb3aEwAUGR2hkDzjau3wMIx6UHO5mq632sg8=	2	3	179	77	{2,7,1,4,7,6,7,5,3,5,5}	23166005000061388	jwUSfi6xDyWL7hj47f4oaPK4bq7EVzXbpyxPTqkGrxyjU1zeAeQ	128	168	168	1	\N	1729656788000	canonical
240	3NKWwAD3tGvgG1NMRqiSGh4Ve64aK5GcYC9hmgUn65P1YAofaSn2	238	3NKMEF99qAwxvDBYfpQ21FpmZU46viJ1igU1db6CNJcttJfnhjRd	96	95	QrEULTf2aAnJJScFLlk2dFhcbvQLavMAPrYkh_m08g4=	2	3	242	77	{2,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jwNvsmhbytXZCVQ1hxKZNfmTZGrCuRP5Tbvk1WsxX3aN6Wet1h5	174	230	230	1	\N	1729667948000	orphaned
178	3NL4eyQwc9XkvkmDSUtvb9g5QKW3nxTar9yKSRtoadt777e82bJ2	177	3NL2iKM2aUoU8DzKYNrW5S21AReFnZ2upUQK6qbdDg4kEbGSNfmo	96	95	rAr89cYofAx1gK_8f4TxNZZXaqJMHMpwxCLI2knaFwQ=	2	3	180	77	{2,7,2,4,7,6,7,5,3,5,5}	23166005000061388	jwKkxY5aRfCZCHxgKBBmeP5nke2vPFuzwuEFPuffn5GPUgvPefp	129	169	169	1	\N	1729656968000	canonical
182	3NKyAxhmsETDi3FJQXr7jZR6Gtw3nwWCZ7HAatjwPjw8w3HcnoVj	180	3NLj7iHjnbFE8TbgjmBBjSoeYXESc7qUXMz3fnXThfrxsUSCxgCk	96	95	y8DtgDy67C5D32wOOOXVD27MTwqYXpSlHoh0214_yAM=	2	3	184	77	{2,7,5,4,7,6,7,5,3,5,5}	23166005000061388	jwgxNGSjLcTXPcFRxjmDBHzhJrV58hojcyuQeuHJ8AGWsGSB8rN	132	172	172	1	\N	1729657508000	orphaned
183	3NLgt6Y2tYN1nerEsqFHs5yRVp2UVCFojkZT1oTV3zHt5rzkpph1	181	3NL6Uq3DS1oTMh2RwwPwnpND4dGAH4vUGXKwefEhhYuJvPJdKubA	67	66	WS-wluC1naRjm41e4E5zMP82YeJtG6s4QaiZwy71YQ8=	2	3	185	77	{2,7,6,4,7,6,7,5,3,5,5}	23166005000061388	jxwxFcNAaJauyCd2AJodWCDdHrcq53tPncaaihar7i65pPv9ipX	133	174	174	1	\N	1729657868000	canonical
184	3NLG8TY4HEWBFbR8nUFdi3oeM8iDWy4jfEPRN6XhB9tu4ufsJbCV	183	3NLgt6Y2tYN1nerEsqFHs5yRVp2UVCFojkZT1oTV3zHt5rzkpph1	96	95	E3DXcAP03vBeUd2hU5cJgKuextbzHpoVVVSQcudKTg0=	2	3	186	77	{2,7,6,1,7,6,7,5,3,5,5}	23166005000061388	jxCVgjpfP67jmv1K2trkVoZEUCL1uZXyE7nZZ6Ppzagi8hettgK	134	176	176	1	\N	1729658228000	canonical
185	3NKW7jpFrVVsbvWcnHJT5SdkJsckYZ2ZsNGL2RQNwu2gij5msL4e	184	3NLG8TY4HEWBFbR8nUFdi3oeM8iDWy4jfEPRN6XhB9tu4ufsJbCV	67	66	Qn0fKFRisd-ASB86Xwh_-QNk-ja637ym77vbSayxNAc=	2	3	187	77	{2,7,6,2,7,6,7,5,3,5,5}	23166005000061388	jwMUoTU1988UosUcNS3iciCxZnvtZvpJHMsjFwEHdisebjw8Hkh	135	177	177	1	\N	1729658408000	canonical
212	3NKPu6mGnaBhgQw9bnrCX9pFaqmtpb1oHM12G2miasuqhc99N8Mb	211	3NKwGVUfPjqBrRwvznsChJXsbDpgpvfjHz7HinfKNo8ex55QMJw1	67	66	BTzPl3ZHmsYaapvONJTKLGd7SYA5ecD90T0h_J0fdQM=	2	3	214	77	{2,7,6,6,6,6,3,5,3,5,5}	23166005000061388	jxvQNfKs3vwVz2fqRCULoiz6cNUyozY9EyqsX3Q79dPMGkMtmnG	154	199	199	1	\N	1729662368000	canonical
214	3NKQvB3ZqamdvycbrwuqZ3Y5iSCtTpnCrS6pmF7fvpTdzdHMCRTq	213	3NKY5qV8eusg9QN7VNEgPy4W5bebLSMLh4WLWgz8UULNEYdXKEKY	96	95	SoqYFYSqUWOLTHieqOqQiUqLfwwTkaLsfXQe8W_HzwQ=	2	3	216	77	{2,7,6,6,6,6,4,1,3,5,5}	23166005000061388	jwhBWbsyremKMf3aLPfPBWsVd918hUUvUQeRkAHeT3j99somJAV	156	203	203	1	\N	1729663088000	canonical
216	3NLvbppbKVdmsiHa1K7mrJt9Y5zKU3MgEsqzMXi9gGAJaW1cwjWy	214	3NKQvB3ZqamdvycbrwuqZ3Y5iSCtTpnCrS6pmF7fvpTdzdHMCRTq	67	66	GGghLjcZsFFaYl_F9Akhpf5b5_PsbeIYCL1_w8_Mkwo=	2	3	218	77	{2,7,6,6,6,6,4,2,3,5,5}	23166005000061388	jxoVgQt2gZ7MFdQBAaesSeaDeQkgjEqB9nopdWQEVShhA6XxRR9	157	204	204	1	\N	1729663268000	canonical
217	3NLZNVZ6gtSvsGqP1gYdh5ftW6N6uAAJLCABUr5d9if3RvBUymj2	216	3NLvbppbKVdmsiHa1K7mrJt9Y5zKU3MgEsqzMXi9gGAJaW1cwjWy	96	95	U07z1H4xYARbl72JJs4kMDpq_TENSoCL712QoukLlgM=	2	3	219	77	{2,7,6,6,6,6,4,3,3,5,5}	23166005000061388	jwfkmkYcMUjp9cge8Lyqd4uE44KN2dbJKQjuxgoSN2ZyXCBWiok	158	205	205	1	\N	1729663448000	canonical
218	3NK6PGoupDQTYa7RZ37XbPM18SdbjFmTyAzsCy1oKNXgrt2NeN7D	217	3NLZNVZ6gtSvsGqP1gYdh5ftW6N6uAAJLCABUr5d9if3RvBUymj2	96	95	CAuZvAMYwLM1gzYDVlcQ3Gd_dtzVr7YSsNwcLADvdAo=	2	3	220	77	{2,7,6,6,6,6,4,4,3,5,5}	23166005000061388	jxRMGXjW8SFjbb2zB2VjcWPWXBxawMmWExMBsp4KkSuSJXv1yH4	159	206	206	1	\N	1729663628000	canonical
219	3NLwZVzBgNkzRUQjnufmdCiJ81nEi2W7zcXUrs2SRjQNZ4teBaoZ	218	3NK6PGoupDQTYa7RZ37XbPM18SdbjFmTyAzsCy1oKNXgrt2NeN7D	67	66	09oatJwQTzrR4j6j1bD6bBZo5wFO9ODXck8E7bZSDg8=	2	3	221	77	{2,7,6,6,6,6,4,5,3,5,5}	23166005000061388	jwRPvDiy9k91JGSW7japUn8tBsL8mUJn1pTHHiLU6K5pMgKtMJz	160	207	207	1	\N	1729663808000	canonical
220	3NKkdhbAnsa3dBEUhXc38qBTHThmueBBHtNSfq12Xg9QMgwKAxfo	218	3NK6PGoupDQTYa7RZ37XbPM18SdbjFmTyAzsCy1oKNXgrt2NeN7D	96	95	2lgIWjQ6XJcYb3zJR355G-ktvb3qSlCNlbFS1pQPcwo=	2	3	222	77	{2,7,6,6,6,6,4,5,3,5,5}	23166005000061388	jwtJNjA69LaW7ay6pt4Ry5TgowL6grmCxcMkSzuQCWH39Ljx1HJ	160	207	207	1	\N	1729663808000	orphaned
221	3NLwzvUNwZYvPsStErPWUgPhUynPRwsvvSeFrzXJ3RLYvNpTquW3	219	3NLwZVzBgNkzRUQjnufmdCiJ81nEi2W7zcXUrs2SRjQNZ4teBaoZ	96	95	jwohxdVl3fyAkU9f_4NtGWHZM6MZ_vVtesKKe8AqjQI=	2	3	223	77	{2,7,6,6,6,6,4,6,3,5,5}	23166005000061388	jwrp9ozRwwbRwGtCvuzeCzTAuZv2oA5z8jt6fNnJAX36VtP9Hi5	161	208	208	1	\N	1729663988000	canonical
187	3NLGG5TNA9paaVZc2JZ8Bf2exH3cQnP6hYY9hf5yPiu42yzLPxUj	186	3NKbzRNHBNtnZWRXE4qfkSo5ffTc6nPerpzNrVmNhYQVuH3c3uWs	96	95	zQRayLjV1OoUQSFzUvWRKAcYcCaRg4Lf64Yxldw9WQ0=	2	3	189	77	{2,7,6,4,7,6,7,5,3,5,5}	23166005000061388	jxf6FW6J63v2eZFZ3v2WiPMCeDb4LjZwe6GTVtWF1emR1U8pch8	137	179	179	1	\N	1729658768000	canonical
190	3NKPxbxm2bbCcWsDivF6A5g9RBUfiVtSuc7MrpF3Wdp3AkseRQ5E	188	3NKJ7p2aQWMpS6jUmRLy8ZYi8Pix43D3gNCRMzq2qbSEpbG5BFvR	67	66	9PWB1pAuvlGazj7NDGFvMC8Im4haVMHZgn6jnITNzA4=	2	3	192	77	{2,7,6,6,7,6,7,5,3,5,5}	23166005000061388	jy1YmgimxNNpNoibPBrYU2AdExr2XJcyeFBxYsVyu5XBkwinJhS	139	181	181	1	\N	1729659128000	canonical
191	3NKgnfuwvYPXPWW3F14MTGHpK3L9ryircXHDCvcdsoZvL2qyrQyY	188	3NKJ7p2aQWMpS6jUmRLy8ZYi8Pix43D3gNCRMzq2qbSEpbG5BFvR	96	95	B0RbhIEzw6oBKyKUZGRgW7IuYN2WpLgdDo6U9kUJVw4=	2	3	193	77	{2,7,6,6,7,6,7,5,3,5,5}	23166005000061388	jwjHPrabk3xvhZRBqKsw7Z3v9DUfVquBhCBcr2DpLmhEax7xjRp	139	181	181	1	\N	1729659128000	orphaned
378	3NLE9tv4AVH2gRRJ8zk57hHQew4Xwxj4WEGahUNfnUTdZsNgGQkH	376	3NKdWqJz3XHGDcXdVnM86qMxLmaJW3cQYtBbv5zWQqffDXBEzrze	67	66	Tr0arIdomyBizwaNrmALl6RbK9zNo4xYkLbnwWEqlA8=	2	3	380	77	{5,6,4,5,4,5,4,7,6,5,7}	23166005000061388	jxgY9ejbVcEPVSLSUodJ8y81mqTjkaQ15drfriYpt6boFhy5oLk	277	369	369	1	\N	1729692968000	canonical
223	3NL82mP66t6PNPSz5iKrzM3SUop7xS3tCEExYLUeHfgTVFM6Btjv	222	3NLrMva9XUG3AZY965VBNHuumNgnU7wU5d4WChYZXus52qs45uRY	67	66	SmIC6_4MtEWv9w8czZU_2qcK63eAt3RDgH5d_JQOSQw=	2	3	225	77	{2,7,6,6,6,6,4,6,2,5,5}	23166005000061388	jxTXL5Emwm8GgoTT1dHVvhY3uzUytcM5ekgFgdVnYD68nRga2ST	163	211	211	1	\N	1729664528000	canonical
225	3NKZN4v9ijnHaCwmu7higA9YPcv7e9bfE4cUFu2FgYbn2Qm4tUHC	223	3NL82mP66t6PNPSz5iKrzM3SUop7xS3tCEExYLUeHfgTVFM6Btjv	96	95	QBifrLWCHQHa0LRCFFDNDzGEB2lot_czEEQGNrwLgwo=	2	3	227	77	{2,7,6,6,6,6,4,6,3,5,5}	23166005000061388	jxPr6gua99DSGtgxEKC5i6vrNu5a5jYNvd3M437SdQ9Esqi18Mr	164	212	212	1	\N	1729664708000	canonical
227	3NLRb7D53tN26uzFWaqVnwN2jttEMdUhurBybKq3sTAV1v9gKPyS	225	3NKZN4v9ijnHaCwmu7higA9YPcv7e9bfE4cUFu2FgYbn2Qm4tUHC	67	66	NeHWW0yv2yxTtjTMH9IVnHkrZWhVkDw-V61ixZYhLww=	2	3	229	77	{2,7,6,6,6,6,4,6,4,5,5}	23166005000061388	jxLmeUqTB3AGZvV1qQ4bHNdphNinbuHbbcp281azGZ8G459TbZu	165	214	214	1	\N	1729665068000	orphaned
229	3NLQqKrhDATnriqeuzu32TaVCkEKwxP17r5CSmtNp2M6JLFbMqpW	228	3NLt9ZW3Cx52W45G2wGxgJ559DmjnP5aZQTmEQATcXEzJ3Ljhkmo	67	66	aikHR4RFP43J2-A3XqpTa75nZ2RSbc39w0PFxZPbpA4=	2	3	231	77	{2,7,6,6,6,6,4,6,5,5,5}	23166005000061388	jwXD9HijJ4BvWzW4wH7mFdpvQDn39z8g5MWAe2MPVdfr5uDRfbe	166	215	215	1	\N	1729665248000	canonical
231	3NKAjZRdauVqnjh1PKYWbRnpjQetNG1DV6z7A7BpYvsudWtDkULb	230	3NK78hd74MMnY3aG1sfpp69gRiVWmLVAn96wQjAR1NSFy16bvb53	96	95	lBJjVmm21DikpqNkEOTvUhuRXUqY0kz8lbh1hd1pSAg=	2	3	233	77	{2,7,6,6,6,6,4,6,5,2,5}	23166005000061388	jxh5o19LhtPWnPDYR9i8CW8BZtfYpfAGNhHC1YW8bkM44mrE65g	168	218	218	1	\N	1729665788000	canonical
233	3NKGo8RUUm59YdYEa5n4g19DzEFd3NauhWhEnLPbiMdiAGoWad2K	231	3NKAjZRdauVqnjh1PKYWbRnpjQetNG1DV6z7A7BpYvsudWtDkULb	96	95	uP4Z3lmIcNWDR77BfCaMr9ol6rH0mCoJ_obM_QvudAE=	2	3	235	77	{2,7,6,6,6,6,4,6,5,3,5}	23166005000061388	jwFA5VZZYUp3kVMuDF4Dp2sEJ4xWMuGTyH2KbjvCthFVBnmiZpd	169	219	219	1	\N	1729665968000	canonical
235	3NKNBp7vUnUTGP8oqm66Q4RLVzuMM5TZibG6VPharquTyWGR2PF9	233	3NKGo8RUUm59YdYEa5n4g19DzEFd3NauhWhEnLPbiMdiAGoWad2K	96	95	oJwiA0wWFBgMdtSfU9V3Ef96onqv5JZxxO-Oe9127Ao=	2	3	237	77	{2,7,6,6,6,6,4,6,5,4,5}	23166005000061388	jwTbVCpEPKmeDAsaNf8nBh8UY7MvaA2skGK7eTRG2yFqS7R4gD8	170	220	220	1	\N	1729666148000	orphaned
237	3NKTJ9d1jDGH2mCKxSQshT4aN1D1G6npMyfSWf7w5wUSDLc2a16M	236	3NKxpy4JU2g6ssN8ukxauBdjs7KFGRkwE9m7xvvPByubhgM4QzS7	96	95	6LUOgotAD4iR8muGeqAgr9MUD_4YKMd5taCX21cqNgg=	2	3	239	77	{2,7,6,6,6,6,4,6,5,5,1}	23166005000061388	jx7EfwFhVBq9ZahSduGJmSp5fGqPKHdM7ZVGM1YnKNtgTbTrhoN	172	225	225	1	\N	1729667048000	canonical
277	3NLq4fpoP2f7v24Ya6cqAugtmCfsDnXULZ8NEdxeoJPYPLuYkLvJ	276	3NKiqiL5bw7u5YiTP6i1HZodfJH36WyqqMtHudjXU7ct56zkTeGP	67	66	sSnS08S_GQq1MowXh-2rPUZvW8JDpH57h60PYw0pHgA=	2	3	279	77	{7,3,4,5,6,2,4,6,5,5,3}	23166005000061388	jxaxPv44PhhyZjAf1xETuSnoSfDjkLoQosbAPuDkTvdK4yzNALB	201	267	267	1	\N	1729674608000	canonical
281	3NKracPHp6JcMZGbnhXpvfSxsCdgsbC5s6YYUyfVqhz9ZusMdn7m	280	3NKFuuSsJJsXy9dQySQHX88hm9jS3XZ2Ay4W3bHzjFDmhymc1m6f	96	95	rRcDfBAWyQt3iHsnCE_uG50GxCC92i8ufsTwmBREhwA=	2	3	283	77	{7,3,4,5,6,4,4,6,5,5,3}	23166005000061388	jy1biKt8DYV3jqhTd2VgkCPnB5w7Qjpg5oBzFhZRNib3CGQXRes	203	270	270	1	\N	1729675148000	orphaned
283	3NLbHNKXr9vaj9ooqHWfCKmcT35QDbH3i8W7NctHTMttfYDV6ee8	282	3NL9Khg8VRK2evLweHCkWVn9frtWjvoNMVN7xzyJNVUHA91G2nS8	67	66	qILXufDP4wO6AIM0GmSyb3pCzALtjARsc5vpKK7bHAk=	2	3	285	77	{7,3,4,5,6,5,4,6,5,5,3}	23166005000061388	jwmcPDiaRu6gtG6wnqGZSGkEKCT2jtqPTwCzdDAyLNYhkQ5JkU3	204	271	271	1	\N	1729675328000	canonical
285	3NLjzWGbNmtbJF7pRgBB9idGUpq8fe2nVtuTsUPmLRYAipbq1aV8	283	3NLbHNKXr9vaj9ooqHWfCKmcT35QDbH3i8W7NctHTMttfYDV6ee8	67	66	ZI26zSBIBAfhTOAn5iM-PFLoiy6WEqX_SMwD962jyQ0=	2	3	287	77	{7,3,4,5,6,6,4,6,5,5,3}	23166005000061388	jwYVKH5zro42bGGNrZTQ1L7AumNwDC62Ehy4koU7cnCxN5jKUzo	205	272	272	1	\N	1729675508000	orphaned
379	3NK7phXzERGppxN3mqhSfbY1xmvdFkuRTKzxXnJ3H6NewVqAXLdw	378	3NLE9tv4AVH2gRRJ8zk57hHQew4Xwxj4WEGahUNfnUTdZsNgGQkH	96	95	zvDn0ZEetaYHfj3_0dx-_ifOaPb7qFGXFDgeBjUwxg8=	2	3	381	77	{5,6,4,5,4,5,4,7,7,5,7}	23166005000061388	jxeYdH7r4btiNwbSH6xa54TbUFA9kq7AidcwsxbnsqWD9Pi4jRw	278	370	370	1	\N	1729693148000	canonical
205	3NLnoeoLuD5nUCkDXkpAMBHELesPFJ8FtCVDmtuHmvSRrRepy1Nw	203	3NKkCKono21EmTBpfjyfEEacwrYpuCy9NoUXPzC5ZZTZAE7W96CK	67	66	QVuVt01VJiwTLpk-IQ286WId0xp9FB0IEbmnfmIzwgw=	2	3	207	77	{2,7,6,6,6,4,7,5,3,5,5}	23166005000061388	jxe56UaCx7UZ9JDMHjtySQfRZhMv9Dra55pSwy2N9juZgEAQ5bU	149	193	193	1	\N	1729661288000	canonical
208	3NKVQk543FXqDFPRodmCj16BhBuQFfwHgFgvsNMhV6E2qeZ51bcq	206	3NLn2EgksomoxfC9kmTx98MohABfF7DjvW5HwBEHYHFvVxC7dKB3	67	66	JKJewFakHPFZuDgJU-1jDidrLV4HLiPpmpX66aP1TAM=	2	3	210	77	{2,7,6,6,6,6,7,5,3,5,5}	23166005000061388	jwdEAniA9dWRpFot8ZrQA8c23FB652PZMHePw3E5DwqQMEYrtRg	151	195	195	1	\N	1729661648000	canonical
224	3NLxc75bMpg6F4R8j8wUaJQSb3aVTxk9VePxtHZLyMeTtPRQDmkz	222	3NLrMva9XUG3AZY965VBNHuumNgnU7wU5d4WChYZXus52qs45uRY	96	95	nMNomJNGGsSqsDdE_DTAJKQkUGtkSC4vhQxpyFRcxAA=	2	3	226	77	{2,7,6,6,6,6,4,6,2,5,5}	23166005000061388	jxGp6EYSWy1wTkjRY22CE8MUqFqzTSSh4adQyCov974MoGZSyrw	163	211	211	1	\N	1729664528000	orphaned
228	3NLt9ZW3Cx52W45G2wGxgJ559DmjnP5aZQTmEQATcXEzJ3Ljhkmo	225	3NKZN4v9ijnHaCwmu7higA9YPcv7e9bfE4cUFu2FgYbn2Qm4tUHC	96	95	0rHDN2boYFNsE0-jzZCa27_n7vAP6y47lOMbx09K5Qk=	2	3	230	77	{2,7,6,6,6,6,4,6,4,5,5}	23166005000061388	jxmdd6eaihEj1gTPF9BavJ3VVhbmcqtLe463rNT8M8sxX1fRTL3	165	214	214	1	\N	1729665068000	canonical
230	3NK78hd74MMnY3aG1sfpp69gRiVWmLVAn96wQjAR1NSFy16bvb53	229	3NLQqKrhDATnriqeuzu32TaVCkEKwxP17r5CSmtNp2M6JLFbMqpW	96	95	NNnlVfh0kOyTQ1mmLnrWcdbYAV8BBbf6Ebo1EdYdBgs=	2	3	232	77	{2,7,6,6,6,6,4,6,5,1,5}	23166005000061388	jwLHfRH6L63QHmoMQsqox7KoTFBn9XRkKFD5YCfgxpvf6StEpQx	167	217	217	1	\N	1729665608000	canonical
232	3NLPk3ffB3v484gPEab4rPT7FGxdFc7fAmso1s2xfDoUS1NrPVMt	231	3NKAjZRdauVqnjh1PKYWbRnpjQetNG1DV6z7A7BpYvsudWtDkULb	67	66	gMf8k9CRIm57t4VzmtPicky0L6zz2jGFg_RFyFCzGgY=	2	3	234	77	{2,7,6,6,6,6,4,6,5,3,5}	23166005000061388	jwU8vCfxs8d5Qqn1JsrcqbXu4N3yaHGrdLv2A9Kd26uhMagaC8h	169	219	219	1	\N	1729665968000	orphaned
234	3NLwadr7Ab4otwDx6EE1nJnovuEm6yUcmcZhiwewoqqr7gnSeyLW	233	3NKGo8RUUm59YdYEa5n4g19DzEFd3NauhWhEnLPbiMdiAGoWad2K	67	66	UKNHrkbQK1rFNH5VVJMjMjg5tumy5KV482XQ9yETtAA=	2	3	236	77	{2,7,6,6,6,6,4,6,5,4,5}	23166005000061388	jwZAGyXydZUVCqPzTbbFdRc3utbfzxcZYrUHbupaWTefU9v1kcm	170	220	220	1	\N	1729666148000	canonical
236	3NKxpy4JU2g6ssN8ukxauBdjs7KFGRkwE9m7xvvPByubhgM4QzS7	234	3NLwadr7Ab4otwDx6EE1nJnovuEm6yUcmcZhiwewoqqr7gnSeyLW	67	66	RollMFecsPO1Ar4lqJ-OOKXusDeqd-zC2hXJFBIFmQk=	2	3	238	77	{2,7,6,6,6,6,4,6,5,5,5}	23166005000061388	jwYPtgam7JmqkcqChtf25NptYqLcFjXhtF6MG4QGxS6g5xetqbX	171	221	221	1	\N	1729666328000	canonical
238	3NKMEF99qAwxvDBYfpQ21FpmZU46viJ1igU1db6CNJcttJfnhjRd	237	3NKTJ9d1jDGH2mCKxSQshT4aN1D1G6npMyfSWf7w5wUSDLc2a16M	96	95	anE_m6d-RcOu9x-ZUYb4LzoG0yKF9yvpO_c3UA78gwA=	2	3	240	77	{2,7,6,6,6,6,4,6,5,5,2}	23166005000061388	jxS4jFjnP2FxfFFtvMZRnrr6R2GnYZu7yhx9FpbB9YE1kFwUhUV	173	226	226	1	\N	1729667228000	canonical
239	3NLUWNGTpH9RS8F75vPLzqPd7BjMEhGFAMMnYM2Ef2kyU8pxjNdN	237	3NKTJ9d1jDGH2mCKxSQshT4aN1D1G6npMyfSWf7w5wUSDLc2a16M	67	66	2XpeQnxFBrfwbvEjv2xozn9DhhaICxW_5xoyNPD_NQk=	2	3	241	77	{2,7,6,6,6,6,4,6,5,5,2}	23166005000061388	jwogt3KFwtgixugibWyMQP4f5gDFzYJhijwtTPCMtMjNrnv8dWy	173	226	226	1	\N	1729667228000	orphaned
242	3NK7RH3HEVMsTzqadNU3qSyfoCgNiFMFskwY98n6STYwHP2ozGv1	241	3NKUSEwi3ZFvBeJ8rzQVn3usujTUcx38eJMdWQR4jFCnzxN9eiQ4	96	95	UmdTIY3J8sjQsnvmlP5sm7d10pF2xbSuQSOmRYqxNgA=	2	3	244	77	{1,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jxmwSBpJFYNPbX3ws8uRzo8Twau46pJRk3o7hu81w3vSi3G4KrQ	175	231	231	1	\N	1729668128000	canonical
243	3NLMxwxs3CGCLKbWEdeuniMQCb5WmjtpnuKVzwU9cdW55k5reqwC	242	3NK7RH3HEVMsTzqadNU3qSyfoCgNiFMFskwY98n6STYwHP2ozGv1	96	95	YqzzE2Cfh1XJ557sUmDoXGE4NSXkyfJreD9ITOK-LwU=	2	3	245	77	{2,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jxTkEBJ9YEcrjEdP3wLyVx9a1vrHL3quHTbeDEyRJoHb2ADkmsW	176	232	232	1	\N	1729668308000	canonical
244	3NL6euSEL3kna2Kh9N9TQkUDeS3cACCK3ERuvWPmBSrRTHPB8pwY	243	3NLMxwxs3CGCLKbWEdeuniMQCb5WmjtpnuKVzwU9cdW55k5reqwC	96	95	qY12TwlhH6cQSwN8cBPocvpnVeDKwNQlpbRkB0OjkwM=	2	3	246	77	{3,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jxBsfHyiJvcLdvkAed726skHi1TtRxgRXBfg9baSH4QNmZxq9yR	177	233	233	1	\N	1729668488000	orphaned
280	3NKFuuSsJJsXy9dQySQHX88hm9jS3XZ2Ay4W3bHzjFDmhymc1m6f	277	3NLq4fpoP2f7v24Ya6cqAugtmCfsDnXULZ8NEdxeoJPYPLuYkLvJ	96	95	5xVCZLLj2oybBn9uPNG4Gz1FII7-t0VeZqV9ojGS0gs=	2	3	282	77	{7,3,4,5,6,3,4,6,5,5,3}	23166005000061388	jxdog7MYkE98TPNP9LrvFbWrQoqvnp9KdcR7rRJxzbpS2XQ9HvN	202	268	268	1	\N	1729674788000	canonical
284	3NLvP6ybZRbJcV8af7p9YPmtHyXXbbmEUndVUJA7ieG6EdL3wGGX	283	3NLbHNKXr9vaj9ooqHWfCKmcT35QDbH3i8W7NctHTMttfYDV6ee8	96	95	Kf2WxBdK-66hcqeApmciKZm8dI7I7Cgbg9UVybFMbAs=	2	3	286	77	{7,3,4,5,6,6,4,6,5,5,3}	23166005000061388	jxKoGdReerYSSmdpHCrwvPLPn8ypWKJ5jGDk9y3RqAvmwBh84tF	205	272	272	1	\N	1729675508000	canonical
210	3NKjjRYotBhwPgYQmSyqiLQUjG8xMDCFwp7xv8LexHSmjv8WbrHG	209	3NLWY8DvtGB7TAPSewA3KdaRY3BrGWgPLzeTLjw3snrpG4yN9oe6	67	66	--NPKzTZJq2SmsPmBXEwpC7paboxOiC5uQ3gUoc1owo=	2	3	212	77	{2,7,6,6,6,6,2,5,3,5,5}	23166005000061388	jxq3uojagVHs4eKatVN588dtAHP3goUvJ7CFsgX3tGSzGih7y8b	153	198	198	1	\N	1729662188000	orphaned
215	3NKphXyEQpaaVLEcyMcW4P97J3QXtisEEXyhWS27BEHcLTNt9ka8	214	3NKQvB3ZqamdvycbrwuqZ3Y5iSCtTpnCrS6pmF7fvpTdzdHMCRTq	96	95	pPE8uh5UFQnlhg4H853upSbjv3lPxLEv9b4sN7hsYQ4=	2	3	217	77	{2,7,6,6,6,6,4,2,3,5,5}	23166005000061388	jxZyXPKyT6FPZwCktETL7AXGJN8B3Kc7r3ZusTCPgdDz4pbEM7D	157	204	204	1	\N	1729663268000	orphaned
382	3NL1KzDcdg2rEoA9arc2aV9BwJzvVKccAFWKNy7HAChBcnSHUjNd	381	3NLMSRCr18qNpS72cbWz3PnSpvabUmKhkR2V3XiscX39zTX96wwr	96	95	5pKq-p9Ag2GQ6K9Z1ZeJYsql1wu0EhDiN2qEDYh-LAE=	2	3	384	77	{5,6,4,5,4,5,4,7,7,3,7}	23166005000061388	jwpLwabqwAcLUurVtAKYP3rMYU2M5mc7TKGxg9GqFvGM62amKq3	281	375	375	1	\N	1729694048000	canonical
222	3NLrMva9XUG3AZY965VBNHuumNgnU7wU5d4WChYZXus52qs45uRY	221	3NLwzvUNwZYvPsStErPWUgPhUynPRwsvvSeFrzXJ3RLYvNpTquW3	96	95	X2lH5c4omnmPLpzZ5AU-ouSH_me3eWvS2Dx5DPB5cAA=	2	3	224	77	{2,7,6,6,6,6,4,6,1,5,5}	23166005000061388	jxzLfU2skmhypGEGJA5Loeop8LaiBc8gFMk9fEaEZESogv2rSYN	162	210	210	1	\N	1729664348000	canonical
246	3NLKPK9EAYrvAHD4B4gJco6Lkoygyn6gsvJQoS4zcKJKGPsdUDhB	245	3NKrePSajK1hxrJL2utm7xVY7Mz2RoBEX5eNDw9aSuB34wDDCTmk	96	95	F_KLr-50JnTq9JLzeLdRHesI9ScOvuQyV4tmbDDLjAk=	2	3	248	77	{4,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jxShTEc5ZxEBUcMajzL22FEBsWiLuevdfukoAgYh9uS1Zo77C12	178	234	234	1	\N	1729668668000	canonical
248	3NKozNKtmY53HgoyxEK9hbKmkCQ2a57vUiXZXpxU3Y7rkaAps923	247	3NLD6WqMCzMHS7xZSEtS1uXi6y6yJyaim2X62eo9nAk8AXG1e3gt	96	95	1bC4HD7mam8aCixesBO3Rr2GhXI8mLPt9m6oKez-YQo=	2	3	250	77	{6,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jxC3SUCRoUXygCE56vfFFP3J6D6VcFhzZuJWoLVrsa57ZYGepGq	180	236	236	1	\N	1729669028000	orphaned
250	3NLtHt3bCeoUMZuSNush515Yv28QXzaDQpSq8dmBSySkiZwE17eV	249	3NLrfG495tUiiCokXqH2qiwx7JKXgc5dqD9TEgNiuPLay6yrhpAo	67	66	Zu3tJZoLquUjHARZg2MBTBksCbSAFDpHChSf19NPlAU=	2	3	252	77	{7,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jwTG4HQnDq9DkDEqhBV3ao6JJtnjXiZVftUvEhsU6jnFGSqBJtT	181	237	237	1	\N	1729669208000	canonical
252	3NLDvnqEBjyKs1pqwFVvPSxzpbeQ9LNbUChVspTqU3SkyFHtaKfw	251	3NLP2FHn2GT628LcA8uzdKXKiRAG67W37bew3h3d2jHGnjdwoQbW	67	66	S8SyZ068JGPTILDeQOgQ1Dz_vXLjeuEkk76AROoffg8=	2	3	254	77	{7,2,6,6,6,6,4,6,5,5,3}	23166005000061388	jx3scRMyRBBsr6e3nKvuYUd8L5d9FH2yDHgwmZL9gZC6M3b3fWA	183	240	240	1	\N	1729669748000	canonical
254	3NLtafAWzWCfVBYJ4X1N57wGgSsH91QitZwE3RomdXmvFLNoyQpV	252	3NLDvnqEBjyKs1pqwFVvPSxzpbeQ9LNbUChVspTqU3SkyFHtaKfw	67	66	Qp6qzTc3nyjQG_jwTeHal9Il8wrFMMRmlB3dD0QnqAk=	2	3	256	77	{7,3,6,6,6,6,4,6,5,5,3}	23166005000061388	jxZyFGfDhhSYLyo9bDuF1YC5tCSDeiMjdNSr3cDEuWAa1KM9zmx	184	243	243	1	\N	1729670288000	canonical
256	3NLctitMQyHZKcaDnMDFFX71HtUCmNkWtDLsb434oKnBgquNfBQd	255	3NLHx66CNg3SmUsbLBfb5b4TRWJt29tDimYESNecY5papeyMnUCW	67	66	cA7CuTdbNwdohLfzDDd88R_6Kzg_4kvfXArhM55sCQE=	2	3	258	77	{7,3,2,6,6,6,4,6,5,5,3}	23166005000061388	jwLF8dfTxr4nHFT8JC6RQQUQn3kdcbCVQikMZ5vEo4X1aCrjUZn	186	247	247	1	\N	1729671008000	orphaned
259	3NKx2qAEETJFYbbAcTNoHBbKbsr6JqA2hHf2TLHPTbesFBLyzRH1	258	3NL6nsLQcg6xtJprsgHv6pSWJXRdVE8hYv2Xwjqggiw4T5iu4DYk	96	95	d2ach8nUSUAE5XSGexs6jPeHbamEL15-ua5sRL2OzAs=	2	3	261	77	{7,3,4,6,6,6,4,6,5,5,3}	23166005000061388	jx1Cv9rb3SQncPyVzZLWq42w1NHKhAVoZ7qs4kJrRQGgemULq9v	188	250	250	1	\N	1729671548000	canonical
286	3NLYTL7pEKu6HueCgNSRzyBNMX6iVtA9BceSgn12VqX1nsAs7XE8	284	3NLvP6ybZRbJcV8af7p9YPmtHyXXbbmEUndVUJA7ieG6EdL3wGGX	67	66	d28KdW7itupJlPg0QmINWG0RPNh2-FmN7CD_YkZpeQ8=	2	3	288	77	{7,3,4,5,6,6,1,6,5,5,3}	23166005000061388	jwLSiUe3Wobv319NXaJYaZUj7VeVFwta47dfawMfi3RWzgwqYwG	206	274	274	1	\N	1729675868000	canonical
290	3NLjdShnS1Po6PdpLkQDwzHjJsuAv6TrMfbKjfyC9kfLt77hLtZb	289	3NK54TskdjRETx1BB8tNuXpPLETrvn3SftL2drwEdMEPgjgZaGL6	67	66	zFXIXOKXwMBJlnMpPKLg9Jw50dZol1l5Ef9iAZIOwQI=	2	3	292	77	{7,3,4,5,6,6,4,6,5,5,3}	23166005000061388	jxE3V7ZoZoZ2xt8R5AHGrHNDCvDShno8j8ynVMvKwQfk7Z5nncS	209	277	277	1	\N	1729676408000	canonical
292	3NKNifzRNp2T6RaGErUsHN8qYqd1xGLLMqd6ew3nJfemwjoe4ve8	290	3NLjdShnS1Po6PdpLkQDwzHjJsuAv6TrMfbKjfyC9kfLt77hLtZb	96	95	XPu2eiZrzUFTjKRHsHWgpnPV2pwqps6x_t6JBuT7Eg8=	2	3	294	77	{7,3,4,5,6,6,5,6,5,5,3}	23166005000061388	jwymuiRcgN4WVH7xWax4yqgjL1YguNXUsTuahAbYFXdu5M7L9PB	210	278	278	1	\N	1729676588000	canonical
294	3NK8J2fKUpBGGk8pVrifLWQByvmn8VuGXhyzwfaJEUHp9nGw1QWA	293	3NLKuKv1hSs1BEpMMrtHxvWhuJywqL1U3FCzkSWPvY7X2KpmFf4o	67	66	O9IwtiwN1hceMKWXtiiozzXIT6d84l7_q9tkJ70XqwA=	2	3	296	77	{7,3,4,5,6,6,6,1,5,5,3}	23166005000061388	jwjkaCqeMW8NiudYxJB5hM3xpcX1KHVkar5KWRZyvN6nuEgNHo7	212	280	280	1	\N	1729676948000	canonical
296	3NK3iVkRJZZdoYXEfHzpSnWgFg4t7zqjunDTpxePc7ztUhJjt4H6	295	3NKEWrm6HXmxVjwoYtPTczm8cMjRmxdYdJVRDnQPSMTbj7A6QMpi	67	66	FSiatS4lHGK1HZwHnNTCYMs8AqjSTEAPpMbZKBZV3As=	2	3	298	77	{7,3,4,5,6,6,6,3,5,5,3}	23166005000061388	jw8eseN4D9rXG8b8FQjcaDHeEBWiPyrCy5AhyvTzcHBkEEy3Upz	214	282	282	1	\N	1729677308000	orphaned
213	3NKY5qV8eusg9QN7VNEgPy4W5bebLSMLh4WLWgz8UULNEYdXKEKY	212	3NKPu6mGnaBhgQw9bnrCX9pFaqmtpb1oHM12G2miasuqhc99N8Mb	96	95	lf37iR12VbEcJv-XhERqi8rN9VmxKjS-NuUdqRandw8=	2	3	215	77	{2,7,6,6,6,6,4,5,3,5,5}	23166005000061388	jy1yqDhTfA2yP7Y4yFhJSgRwkCg3Ar88ixL1N3QZ1YhLaV8RDaW	155	202	202	1	\N	1729662908000	canonical
383	3NKWEFT9nYfvV5tqGUtS6ULedAU8dgHVrR7njz4uGF4zQUUTtgSj	382	3NL1KzDcdg2rEoA9arc2aV9BwJzvVKccAFWKNy7HAChBcnSHUjNd	96	95	sE92WLA5R2G9VnZEd7TiO3GmgaHo1Ac1Tov3gc_zTQ8=	2	3	385	77	{5,6,4,5,4,5,4,7,7,4,7}	23166005000061388	jwrzc3hcQFtA1y16rheyZrY4PrHJYbwMckBpk9vD1AGewvpDT1N	282	377	377	1	\N	1729694408000	orphaned
245	3NKrePSajK1hxrJL2utm7xVY7Mz2RoBEX5eNDw9aSuB34wDDCTmk	243	3NLMxwxs3CGCLKbWEdeuniMQCb5WmjtpnuKVzwU9cdW55k5reqwC	67	66	skHVEtrArYo-2ow803rnAIM-JQI9fxEbgI9vPGZSgQ8=	2	3	247	77	{3,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jxH3L4nY9MpJ1q9LUwkpM4wvZJKFJQ6CwSgUXbpbSFWQ4wMKX1V	177	233	233	1	\N	1729668488000	canonical
247	3NLD6WqMCzMHS7xZSEtS1uXi6y6yJyaim2X62eo9nAk8AXG1e3gt	246	3NLKPK9EAYrvAHD4B4gJco6Lkoygyn6gsvJQoS4zcKJKGPsdUDhB	67	66	HebfYJWqyXC6hNr58LgUGhaKRb-hDsNqC8e2alPJPwA=	2	3	249	77	{5,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jxY16uVWxd8e6VXcvMHewQbn2kRAp1v9gYwcSrE1naXaqQLdE4C	179	235	235	1	\N	1729668848000	canonical
249	3NLrfG495tUiiCokXqH2qiwx7JKXgc5dqD9TEgNiuPLay6yrhpAo	247	3NLD6WqMCzMHS7xZSEtS1uXi6y6yJyaim2X62eo9nAk8AXG1e3gt	67	66	AnTnYTfBytbA6fYJL5qHOdTm3mVs4kNH4m9x_gAFfQo=	2	3	251	77	{6,7,6,6,6,6,4,6,5,5,3}	23166005000061388	jx9ubSbUPPEkmpYurfB7PonhMwr9fLnHgAx4JNwH1FBdTDqcAwb	180	236	236	1	\N	1729669028000	canonical
251	3NLP2FHn2GT628LcA8uzdKXKiRAG67W37bew3h3d2jHGnjdwoQbW	250	3NLtHt3bCeoUMZuSNush515Yv28QXzaDQpSq8dmBSySkiZwE17eV	67	66	DCgleu0xAOYhWVt-6_tjozGasgm5ULB1132Q1TIIPws=	2	3	253	77	{7,1,6,6,6,6,4,6,5,5,3}	23166005000061388	jxHgwiMhnBom46RzEUPV11dbotT4bgorKjU8yxVQA92FWTo8a8V	182	238	238	1	\N	1729669388000	canonical
253	3NKFrwbjvz1QG6PQThoSttifwEG7orNi3nfY9DDrRRzNR51fF5Lv	251	3NLP2FHn2GT628LcA8uzdKXKiRAG67W37bew3h3d2jHGnjdwoQbW	96	95	e1X43OneAWkq9pqLfde6d2FrGdHYCIPNAJ-fjlCvcww=	2	3	255	77	{7,2,6,6,6,6,4,6,5,5,3}	23166005000061388	jxApsJS5FdJB5hAaytoR43rrYbzhJsDBje5ZmDYXRVr2KpRtgAP	183	240	240	1	\N	1729669748000	orphaned
255	3NLHx66CNg3SmUsbLBfb5b4TRWJt29tDimYESNecY5papeyMnUCW	254	3NLtafAWzWCfVBYJ4X1N57wGgSsH91QitZwE3RomdXmvFLNoyQpV	67	66	JdXRYhVmLtMz4ldcGV525-wjCmRe1_qLHAUuZ1_WGQU=	2	3	257	77	{7,3,1,6,6,6,4,6,5,5,3}	23166005000061388	jxsWhn6MJB16NzJzat2drHx3AZ9WjXTJRJH8uDXboag9Km5CyYJ	185	245	245	1	\N	1729670648000	canonical
257	3NK3hqHmkMJMSFpk5DcLrXcjg2U8EpN97ckXWzRghiAgKbi6jo9N	255	3NLHx66CNg3SmUsbLBfb5b4TRWJt29tDimYESNecY5papeyMnUCW	96	95	WunVGRPGgqKDAqVReHVT2-OIyzLxz2tMnUKT3eymtQY=	2	3	259	77	{7,3,2,6,6,6,4,6,5,5,3}	23166005000061388	jxs9WkUvPVYQoN87izMN4o6DM74dfQA9GxYZDapeJ6QaySzVkyx	186	247	247	1	\N	1729671008000	canonical
258	3NL6nsLQcg6xtJprsgHv6pSWJXRdVE8hYv2Xwjqggiw4T5iu4DYk	257	3NK3hqHmkMJMSFpk5DcLrXcjg2U8EpN97ckXWzRghiAgKbi6jo9N	67	66	-v6fowOKv9wBibWaz0fXG8K33tydOsHX8TjvqV9ObQU=	2	3	260	77	{7,3,3,6,6,6,4,6,5,5,3}	23166005000061388	jxZVkCmaAxr7TTz4MCB8tRjBw57pH1uEfgL9NqnF3ZYCMxLa5DW	187	249	249	1	\N	1729671368000	canonical
260	3NLoA91H1gqjNn93DfeEW8ruoCNuuBChNdExWM6Aca6jw3P7wifH	258	3NL6nsLQcg6xtJprsgHv6pSWJXRdVE8hYv2Xwjqggiw4T5iu4DYk	67	66	2v352SVDu6g4VGXe4xLKvecfSnB-W4y_K1ANDe_IjgE=	2	3	262	77	{7,3,4,6,6,6,4,6,5,5,3}	23166005000061388	jwhTXLibNJJewffERgr1jTqx4xVTwQ1fas3BmVMj1TbGEcEMb9q	188	250	250	1	\N	1729671548000	orphaned
261	3NKP1VrQtZczXuKU5C2siVwKWe4cNQRYQ3AWHaabvN4H2TEpJ2QE	259	3NKx2qAEETJFYbbAcTNoHBbKbsr6JqA2hHf2TLHPTbesFBLyzRH1	96	95	C2NdtUbfW2VBcjSUbORk8TShD7kvLQTejD688caDYgo=	2	3	263	77	{7,3,4,1,6,6,4,6,5,5,3}	23166005000061388	jwZwWd5EsQkwxC3CdTnCH52etryYkF6FWc7i8PFNXNCVXVtazpH	189	253	253	1	\N	1729672088000	canonical
289	3NK54TskdjRETx1BB8tNuXpPLETrvn3SftL2drwEdMEPgjgZaGL6	288	3NLuBgS2kWugKb3ZY1DZDL5KMkJvSDNAPg5B4kujW8UAG7CSU8mV	67	66	fO4uqi9TBTUh8Bag3LQ4LkKd1TqXSlsPWlLhrkBHFgU=	2	3	291	77	{7,3,4,5,6,6,3,6,5,5,3}	23166005000061388	jx9jPQunsq71swx6CYM4FnqJkXC3zy5cYj7d6sqFGrUSSWTcaZP	208	276	276	1	\N	1729676228000	canonical
293	3NLKuKv1hSs1BEpMMrtHxvWhuJywqL1U3FCzkSWPvY7X2KpmFf4o	292	3NKNifzRNp2T6RaGErUsHN8qYqd1xGLLMqd6ew3nJfemwjoe4ve8	67	66	yXFYU4Rrxj-r6lOpypWe7hfXPJ_-cydSvxvNGM9dqwM=	2	3	295	77	{7,3,4,5,6,6,6,6,5,5,3}	23166005000061388	jwKiekTnifiuQ1WC1Z5TK9qTKFUgPMRMxsPntdXnFL1jdijK98s	211	279	279	1	\N	1729676768000	canonical
295	3NKEWrm6HXmxVjwoYtPTczm8cMjRmxdYdJVRDnQPSMTbj7A6QMpi	294	3NK8J2fKUpBGGk8pVrifLWQByvmn8VuGXhyzwfaJEUHp9nGw1QWA	96	95	oWHKKclK11_7TWksWip3-nakVAKVrC3EoZ58RALe9A8=	2	3	297	77	{7,3,4,5,6,6,6,2,5,5,3}	23166005000061388	jwiNHkQDsZGaTjgSti4iF7SudxtYTABcGLqGKguoBx9ro43Fhfz	213	281	281	1	\N	1729677128000	canonical
299	3NKfLkuhT8xMdgf5G1mVdtydbsyLJG86P2aD7GnxkVcjQpTx4CjF	298	3NK9L2nvrwfEjZEJyXXtcnUJwsWWzMGLa77znVgWegiw3FYmNcDF	96	95	JKU2-J8SvkphCFrUUGs6FosmOufTEJjpQ4qgqc_XGgA=	2	3	301	77	{7,3,4,5,6,6,6,5,5,5,3}	23166005000061388	jxmbjbgisqJEBRRrRfGEgv5MWUmVzk7eneMqjQZzWNqYMhMVTJ2	216	286	286	1	\N	1729678028000	canonical
262	3NKkh96Xu78k6oLFFWwTdeFSQNehU3D62YsRXBt4pjA4dAfaKH9e	261	3NKP1VrQtZczXuKU5C2siVwKWe4cNQRYQ3AWHaabvN4H2TEpJ2QE	67	66	jybDuwMYwfH2rI4PlYOHgMuGMZqaq6oRF8Zlfbz3wgk=	2	3	264	77	{7,3,4,2,6,6,4,6,5,5,3}	23166005000061388	jwVeNLkNAH4MkR753yypsXagBNWugGKr7k5EaQMy3TD75pRTTNd	190	254	254	1	\N	1729672268000	canonical
263	3NLhe1WHsomoEx2Vp1ERm89TJpjordyoDgtfgYZ6M1KvoVkzSqXk	261	3NKP1VrQtZczXuKU5C2siVwKWe4cNQRYQ3AWHaabvN4H2TEpJ2QE	96	95	p1gjUAp4Hqtuq-o1R8nkS32Co_1Y2oaloMtX4n1NhgE=	2	3	265	77	{7,3,4,2,6,6,4,6,5,5,3}	23166005000061388	jxYDcJkNzheP9YTFKv9QuYWwp6vyZiLWz53ZWbX4S5thCHzTdeM	190	254	254	1	\N	1729672268000	orphaned
264	3NLihiLMqZBxoaE6uUp15tFczNUK422S51T6JWPwEWUx3CGVa5vZ	262	3NKkh96Xu78k6oLFFWwTdeFSQNehU3D62YsRXBt4pjA4dAfaKH9e	67	66	djYaW3VlZ6PYNTET4QPFyvhEf26LsZDji3c52o_x1wc=	2	3	266	77	{7,3,4,3,6,6,4,6,5,5,3}	23166005000061388	jx2fjyxojhgtSSoUuPzV3LMEpTfA9tqHhdx6BnCDLQNoFVv6U4a	191	255	255	1	\N	1729672448000	canonical
386	3NKcuZaNxuV1XgJQHvVdrqAW4XtSc725sU6yNzQDZf4pqcaB3oxV	384	3NKRiCr86grVFn7T8Uwm5b5bM5zSMoz9tBk4Gx2kzLqxoLFZnjhW	67	66	5HwLBMLkRqJXaWFGU8a6Zx8AlhUVtpOYS1D95YuwAwQ=	2	3	388	77	{5,6,4,5,4,5,4,7,7,4,1}	23166005000061388	jwCPA8R3fDk2GZ6HMwPrRMhq3AzYu8xux7xJKHgFsso6uPkRsXi	283	378	378	1	\N	1729694588000	orphaned
269	3NKV4sorNEhbPi4HmekJ7n6ZNA9cjT2pcYDZesEWk1t9zb4Fd5pd	267	3NL41E8UXHgFiLU3ZArMhNTkjnSQNXTu6VyVrqcDDVdF4dD6NPP3	96	95	hO6_tzRS_ypX5VMGAaOLtlAIJmjgrn-ygUMBxfZKmgM=	2	3	271	77	{7,3,4,5,2,6,4,6,5,5,3}	23166005000061388	jxwz1nwVHAeLLMpayGbitUALYXVT2aG7Lv93G3fD6gyykP6toc1	195	260	260	1	\N	1729673348000	canonical
270	3NLhbC5u6wifxGcpfaxGt23wBaZM2XYrybs5AGvxC8GbFz8wyVA6	269	3NKV4sorNEhbPi4HmekJ7n6ZNA9cjT2pcYDZesEWk1t9zb4Fd5pd	67	66	tgp-jwzDlxui6g7qnqVu5efySy_gwFHrT0Dl7NYebwM=	2	3	272	77	{7,3,4,5,3,6,4,6,5,5,3}	23166005000061388	jwK4A7eYq1EFb72NZ6ZSZf15qte5nf9pK5w6mAPH1awHde2MLBP	196	261	261	1	\N	1729673528000	canonical
273	3NK3BtEFJPRx1qyr3FkGWNNshUDJ1Mvds9wZWDjBScmQK9rPEvei	271	3NLpbGm3wNWTJR4XwF2dq48BkUtAZz93vF4UKXwn3fEuMnsBxody	67	66	I79v3zdBgy49dziGRT8MT1pTpW4JlDp0_jmW4VD41Ak=	2	3	275	77	{7,3,4,5,5,6,4,6,5,5,3}	23166005000061388	jxUBCGhSxX7phnFic54xJC5P9FeNVY1iCaWtqw8xKnn6nfJhywZ	198	263	263	1	\N	1729673888000	canonical
276	3NKiqiL5bw7u5YiTP6i1HZodfJH36WyqqMtHudjXU7ct56zkTeGP	274	3NL2HUfzJVoujoAc1RHi4cq1JHqkQHkjPFoUWdAkwgNeHQR2pW1n	96	95	ExWS-jdNS3Cq-AsYk6ouz40Z5fmkMX-jUKT0r9yGEQc=	2	3	278	77	{7,3,4,5,6,1,4,6,5,5,3}	23166005000061388	jwoK59WS6H8ghyk5CjusS5Fg7uJgfr8GZWuePLc5VSxWF4GbSDy	200	266	266	1	\N	1729674428000	canonical
300	3NLLaMYPmntSfXjDXQ9ufo87KHfGjVMxAg1NUMERQbGr22GebUh6	299	3NKfLkuhT8xMdgf5G1mVdtydbsyLJG86P2aD7GnxkVcjQpTx4CjF	67	66	-41S__rgRJwyClHOrO3ia8b_NnxW0rh1zwumks7H1AE=	2	3	302	77	{7,3,4,5,6,6,6,5,1,5,3}	23166005000061388	jwkJFdoBnuGEFPp2geMXbhz2w95ykjpwWSDUZ9mJxYyn43sA4X9	217	287	287	1	\N	1729678208000	canonical
304	3NKB5frN2XN6aPkVkX3j3Bb3r34EkiVF8P2BoNEqS2BNMiQ69nrp	302	3NL2SVAK61Dxf7645yrtnyCwk7xq13ubXfDkdoWjQMBMpbdBsHgQ	96	95	rtG9J1yLUj0-gcj20_hiDq13_vI0Ez8VS_8ktLcTpwo=	2	3	306	77	{7,3,4,5,6,6,6,5,3,5,3}	23166005000061388	jxzMPQxewvW4H6uJJWzxBzsqSwH58KajRcYkoBridjSessS2KFN	219	293	293	1	\N	1729679288000	orphaned
306	3NLrV79zpk8KzaR3X668QQGAgMBgMLCBFzLwBmDytcvCUjURjKck	305	3NLSKrYLorV7zdrnNBdbKKKUvrV7HkBkyh6ah1fEvzwNkZ8SFsLw	96	95	n22T9pu__mh9cytMLr68i8VOMXSZQUoYe7jCxYYujgc=	2	3	308	77	{7,3,4,5,6,6,6,5,3,1,3}	23166005000061388	jxpt2uyZcADDkXTRp8MkU2J85TurGaLYCXLpwfchdK9iZ11ZTJf	220	295	295	1	\N	1729679648000	orphaned
308	3NKmfMJNyCbhMNw88gNeaGd9hbmFJX6wyGBsjDEmM53XSX89yPvC	307	3NLdA8vPA1pj6n7V7UZmNaaNhoHzXssL5GNc1yKUKWKukTVyjn5C	96	95	_6cS8yxQ89_iBBjCRfqiRXKvHHvhB074OvFXBkO-iAs=	2	3	310	77	{7,3,4,5,6,6,6,5,3,2,3}	23166005000061388	jxhZoqoZFLWeRmH3Fc1vwiP9uwrZviaE1YLB7r6ghCyhK8FD7aZ	221	297	297	1	\N	1729680008000	orphaned
310	3NK3pBJaoFeRGNpK2fssKSaySKRMBf8H5VqTgC4xTmJx5tAWVUiz	309	3NKeN5TSugs4g12Mz4a4hbh4GZgnXmDAMqkS8YxNYrQh7rvEsWJy	67	66	80OdtcFSh-KeRfe-J_Tr-SsqWuCOrg2cSGAaX_CS1wg=	2	3	312	77	{7,3,4,5,6,6,6,5,3,3,3}	23166005000061388	jxrPNaEGLEx4dvwAjrTtL8qSeZBV1HFHgMj1mfME1yRXC57nRoP	222	298	298	1	\N	1729680188000	canonical
312	3NKR6aoWmGhk17iXoD3uTRJgx2Bq9NmA6835vYcGdyW7cPGMMbYQ	311	3NLkNYxcdvfL9yww29C6Nrttgv7yqVgSrMAPM1xYsVkm2hGbvRfe	96	95	NvNt-8Ld3HQ45JBoCjFUp3lpAORnE8KlAr206jR_Ago=	2	3	314	77	{7,3,4,5,6,6,6,5,3,5,3}	23166005000061388	jy1fHL3DcsMtTkTRwNFZPTB79N6QX9DV44LFC9iaLKDhhiVfcJ1	224	300	300	1	\N	1729680548000	canonical
314	3NLtDbVtZJGjyvTWUSKbp2cwh42yu6K457YA73bogXbD3UaQyf4N	313	3NLijdazkcmYmnWC3JibiLi96KxBhNwhJfaJsFKcWSVJsu1PaBVQ	96	95	G9hYHmu519DrczFUOTTkVUfRAH1OwgPHpRORzyANWAg=	2	3	316	77	{7,3,4,5,6,6,6,5,3,5,2}	23166005000061388	jxJjL5taawLHGMRjpytsUFx1SHqZA4uXzPRLbRkXSJ6VgrUHJ9g	226	302	302	1	\N	1729680908000	canonical
316	3NLDfNT7wvRZsKnCCLiB4MpkoG6as6UeiBuevZvBiJW8tpRSv8si	315	3NLjdzQtQSGPfBKCSGaJq3MAWwBfJmQs4motRLq4NYCaHA32ff3i	96	95	67Y79PsXu_UkvyzbcuMxtw6gCXico2b3eyiB57upmw4=	2	3	318	77	{7,3,4,5,6,6,6,5,3,5,4}	23166005000061388	jxbn4nGA7hC9tW8oFqnjok6TFsJSnxV1NJ4VkHwVpamy3DcoJF2	228	304	304	1	\N	1729681268000	canonical
265	3NL3VRRCdEe2dCVbKWvnKSAtUBavAzxy2vncwz78Haci8Avra7yp	264	3NLihiLMqZBxoaE6uUp15tFczNUK422S51T6JWPwEWUx3CGVa5vZ	96	95	oEjHd4m0HguMKHlQUkNSmN5GHSu1JE4y49xAJ829AAc=	2	3	267	77	{7,3,4,4,6,6,4,6,5,5,3}	23166005000061388	jx5Cp3YqHw9LSeq7m8GBLEaisTfpovEcP2GecKVNeVAktT3xToM	192	257	257	1	\N	1729672808000	canonical
389	3NLinAkkuvhCtNKJAzgCkf2DMCgph5QuorE1LQobTu9w3ntKgLkk	385	3NLyaCYAwa4wBRyZZPZFcCDoHjYxPdXTqZ54f9Ht3iJPcQ53QASA	96	95	9f5siGHYsg2CVJsMBSAeZgMJ6cK-yqz0I2qKu2BBBAQ=	2	3	391	77	{5,6,4,5,4,5,4,7,7,4,2}	23166005000061388	jxLNaVwNuZFtcbfKgYMzarfFZDfEYnC5ojQcJmZmSL6RtaZ5nWH	284	379	379	1	\N	1729694768000	orphaned
275	3NKi9vGS2u1QBfDWFrdFAJZYGqRp44GD9fKFYpsabx4wwkhKR6uX	273	3NK3BtEFJPRx1qyr3FkGWNNshUDJ1Mvds9wZWDjBScmQK9rPEvei	67	66	vNz5d90uoGKafw5BVt_03pMD1JdXnzyYf9FMdxQ_XQQ=	2	3	277	77	{7,3,4,5,6,6,4,6,5,5,3}	23166005000061388	jwJd5eBrV26UGnEz4VDWEpUR4rhP2LSSikJHPkb61DVhmHoPeMN	199	264	264	1	\N	1729674068000	orphaned
278	3NLWtXknoG337bpoeJpq4X1gBJMiEuG1ZvHDd8Dm657qdvZMRPof	276	3NKiqiL5bw7u5YiTP6i1HZodfJH36WyqqMtHudjXU7ct56zkTeGP	96	95	S8oi3dkc_Fvz2898UBrCPmmql4B4VVVLEMaEGrm6oQs=	2	3	280	77	{7,3,4,5,6,2,4,6,5,5,3}	23166005000061388	jwPjrSwD7RnfxQ2wVyYfjkXZuwWFooQLmpETXkcGrc51yrP24Jh	201	267	267	1	\N	1729674608000	orphaned
279	3NKURJxN5bJVQWctutR3Q3wDBpHFyMtseQBNJ7jbimubEZBKZoDY	277	3NLq4fpoP2f7v24Ya6cqAugtmCfsDnXULZ8NEdxeoJPYPLuYkLvJ	67	66	YqbyCpg8nV2IAAsakEILQXIml1fb2xdThwmFgEoq9gM=	2	3	281	77	{7,3,4,5,6,3,4,6,5,5,3}	23166005000061388	jwpmAYD85jJKFzK7xyMNNao4j3xhCSKzRkDaT686JvoptSGryov	202	268	268	1	\N	1729674788000	orphaned
282	3NL9Khg8VRK2evLweHCkWVn9frtWjvoNMVN7xzyJNVUHA91G2nS8	280	3NKFuuSsJJsXy9dQySQHX88hm9jS3XZ2Ay4W3bHzjFDmhymc1m6f	67	66	bNZozEqBFLLkZrQIx1L_V4bSib-jE0aGtxZXZcoGhgQ=	2	3	284	77	{7,3,4,5,6,4,4,6,5,5,3}	23166005000061388	jwYKGvXMBH5bxUXFEkV4BvB7PyjwyztcQTex8Sni3E98YDwWZp8	203	270	270	1	\N	1729675148000	canonical
303	3NKxdP4s2SmzsJL3z9ebKC4yBw278cHYABwZwr4eY1xpwpm8oknj	300	3NLLaMYPmntSfXjDXQ9ufo87KHfGjVMxAg1NUMERQbGr22GebUh6	96	95	dOql20BcQK_UhtI1T-SBLJqmy-LLU46ybB6AR1iQ8AU=	2	3	305	77	{7,3,4,5,6,6,6,5,2,5,3}	23166005000061388	jxsSerPoa1CYqkcQKKNkDAV7DaEfdcu5VaSwZvMRJdGi4D85a1a	218	292	292	1	\N	1729679108000	orphaned
307	3NLdA8vPA1pj6n7V7UZmNaaNhoHzXssL5GNc1yKUKWKukTVyjn5C	305	3NLSKrYLorV7zdrnNBdbKKKUvrV7HkBkyh6ah1fEvzwNkZ8SFsLw	67	66	qr53vQBh421JXOeb_Bbz2RQ7kJ-5KzQjmOmh9tsZlgA=	2	3	309	77	{7,3,4,5,6,6,6,5,3,1,3}	23166005000061388	jxq9PAPaUh4wNAHRahUTSTAWcXrQR8vFWTvebS923ESEFRRFVWy	220	295	295	1	\N	1729679648000	canonical
309	3NKeN5TSugs4g12Mz4a4hbh4GZgnXmDAMqkS8YxNYrQh7rvEsWJy	307	3NLdA8vPA1pj6n7V7UZmNaaNhoHzXssL5GNc1yKUKWKukTVyjn5C	67	66	NnJHe0hEzXNKwo9-KMd1lozV4_9LANu1g3ox2qqRUAg=	2	3	311	77	{7,3,4,5,6,6,6,5,3,2,3}	23166005000061388	jxmsuvu5fp8JoxQSYsgFkdrbgnDQed4gVE3UPsVm2TzPtnRb4Ld	221	297	297	1	\N	1729680008000	canonical
311	3NLkNYxcdvfL9yww29C6Nrttgv7yqVgSrMAPM1xYsVkm2hGbvRfe	310	3NK3pBJaoFeRGNpK2fssKSaySKRMBf8H5VqTgC4xTmJx5tAWVUiz	96	95	hVWD0zdxWFXf8ThuwH_nHpB4Uhc7Hh6YZ5iBYO5kuA4=	2	3	313	77	{7,3,4,5,6,6,6,5,3,4,3}	23166005000061388	jxQ6vy8f4Vx94Zj1Bf44hqbCQbcij1K3GCN5xvPRwpaW5FXp3PJ	223	299	299	1	\N	1729680368000	canonical
313	3NLijdazkcmYmnWC3JibiLi96KxBhNwhJfaJsFKcWSVJsu1PaBVQ	312	3NKR6aoWmGhk17iXoD3uTRJgx2Bq9NmA6835vYcGdyW7cPGMMbYQ	67	66	GH5e_IaeB1UI9iur0ikx9rVDbJdj0Ayw-Et-X-XKWwg=	2	3	315	77	{7,3,4,5,6,6,6,5,3,5,1}	23166005000061388	jxTvZD1pjxg4sh2ugoSq2LU64K2Ta9aMjiTDWXs3Rpmkbi9ZnPc	225	301	301	1	\N	1729680728000	canonical
315	3NLjdzQtQSGPfBKCSGaJq3MAWwBfJmQs4motRLq4NYCaHA32ff3i	314	3NLtDbVtZJGjyvTWUSKbp2cwh42yu6K457YA73bogXbD3UaQyf4N	96	95	lTruMaT9xE2ikmnVCpLZcbYPZkX49LjzHe5GlCbULQ4=	2	3	317	77	{7,3,4,5,6,6,6,5,3,5,3}	23166005000061388	jxGJVuFS4EPRKervwdX3c7hQRtfXtpWYhRKQvyo8woXSjbhTo7K	227	303	303	1	\N	1729681088000	canonical
318	3NKk3bXFJc45uTxepphLt85jiLib8UbmJAwcV6oTYjhQA56jN3C5	316	3NLDfNT7wvRZsKnCCLiB4MpkoG6as6UeiBuevZvBiJW8tpRSv8si	67	66	0e1PKCbUwZ7zhAA5ZejkwMor9paKnG-EdBJw2M9s4wU=	2	3	320	77	{7,3,4,5,6,6,6,5,3,5,5}	23166005000061388	jxGmcx7QjkgMQAbtmCasPQc4QjDutAjP3Ab3ceNVUZQ9ewH3GCG	229	305	305	1	\N	1729681448000	canonical
317	3NL3Ev8QhymaRLefY1UjWKJwRDBCCNbxRWiAkvsvjdaPbv19D4TR	316	3NLDfNT7wvRZsKnCCLiB4MpkoG6as6UeiBuevZvBiJW8tpRSv8si	96	95	gYWSTFzmz4CigMtcuwWh-rdgsN9DxBeHT9uR9cALJgE=	2	3	319	77	{7,3,4,5,6,6,6,5,3,5,5}	23166005000061388	jx6uyoJ5F5kG7MTPgV5gEbA1Xh2HNKF1Hc8HSQMi94E4bSbuPZT	229	305	305	1	\N	1729681448000	orphaned
320	3NK57eHxLvUznCzxRoht8TRtvHWHpBumbgk6W1y39teb7hhDJa1A	319	3NLSQfSwnXccqbJkM9zYtqBdoeC8whTVa2kCFHG8PTdaWKnERbnC	67	66	JZ0NvmskZQo2gefhNsb2jBXQLvlyCMK4f8wHT3aJ2wQ=	2	3	322	77	{7,3,4,5,6,6,6,5,3,5,7}	23166005000061388	jwK7maoHEMvApNzyohso7ukwafSrrJA7M9cZmbHBtvAkicQurDd	231	307	307	1	\N	1729681808000	orphaned
288	3NLuBgS2kWugKb3ZY1DZDL5KMkJvSDNAPg5B4kujW8UAG7CSU8mV	286	3NLYTL7pEKu6HueCgNSRzyBNMX6iVtA9BceSgn12VqX1nsAs7XE8	96	95	CG3HnLSZwp9XrPSH1KtOpEbeL_RQjUWzqG0i9dkTkQU=	2	3	290	77	{7,3,4,5,6,6,2,6,5,5,3}	23166005000061388	jxwNuVLmZEan6tbj2KGZ57qxSSuNdjJzUqKdmE25Ht7J3L4whxn	207	275	275	1	\N	1729676048000	canonical
287	3NKsWGm8N2ZxAjfqB6z3gEqY2xehPVE8vNQZB8q1CbeA5fDeSG4H	286	3NLYTL7pEKu6HueCgNSRzyBNMX6iVtA9BceSgn12VqX1nsAs7XE8	67	66	E_yA37c6hc1hfv1NdAXYf0afCCIKjCHgVQ6e6hh9Sgw=	2	3	289	77	{7,3,4,5,6,6,2,6,5,5,3}	23166005000061388	jxZgrX1wX7tKgU9SVmZUaeMzWGiQyUp47NfpEkbw5UAsKSy3aW5	207	275	275	1	\N	1729676048000	orphaned
332	3NLUwMJLBFkY82CfT1iPBqntYgQYnpRtxYa3u9tWQZmMpq24sL5J	331	3NKaZfwp2nsXPCVotTyVF1vchD3hcCZdsFd9cb3aSpw7rzAWmpDi	96	95	l7s9_uEGP7hBBh1f5viDHrttqFAWDx8Owe4u__Q-6QY=	2	3	334	77	{5,5,4,5,6,6,6,5,3,5,7}	23166005000061388	jx2v4YkvKa5sGFqiCTyUMNNbZbGP23YsSCidozNuAZADXZWjKzR	241	319	319	1	\N	1729683968000	canonical
334	3NKZNXKucG1C3ZPRuGChsePjdSUjxXTH1CfX8tJP5ewuA5rniZRR	333	3NKBrCnYPd9Lm7AjCSBYnL3yUfU3EwsXrWD9nEeV43bHakkUw5LC	67	66	NKcHv893J1Xn1hswHH9vzUzE_cQNWEv8C-1IqVvcEAM=	2	3	336	77	{5,6,1,5,6,6,6,5,3,5,7}	23166005000061388	jwuZVeUWvsaTLhQgQm4kfZLVCoXotN7i4kSqwxgoPbwGrFqQSxJ	243	325	325	1	\N	1729685048000	canonical
298	3NK9L2nvrwfEjZEJyXXtcnUJwsWWzMGLa77znVgWegiw3FYmNcDF	297	3NKvHtpYCnJCG1fZvUYHPcm6tF2zfezhgCGbN1ogc6ywzubGvW81	96	95	j_4XzshnEfmaTQRyRMDoyMsD_TbRBHZzIJ5rYnZkpQs=	2	3	300	77	{7,3,4,5,6,6,6,4,5,5,3}	23166005000061388	jwba1YHbfanemG26X7eAnPMtoPFZn3hjuXsYut7koyX5e3noCV1	215	283	283	1	\N	1729677488000	canonical
301	3NKy4sNj9uoNqDNtJa5HLtRhKWFG8ZSfKTuGhAMHebVvC7CPZDwP	299	3NKfLkuhT8xMdgf5G1mVdtydbsyLJG86P2aD7GnxkVcjQpTx4CjF	96	95	qxQbnOqwUDJqHbARrnBbtuVX5pIEfwWVv-EzamrgSwo=	2	3	303	77	{7,3,4,5,6,6,6,5,1,5,3}	23166005000061388	jwHzvPsseYBCqdibBE8DGG5aweahGbTjzsX2PAxEURPJAutJ6JF	217	287	287	1	\N	1729678208000	orphaned
305	3NLSKrYLorV7zdrnNBdbKKKUvrV7HkBkyh6ah1fEvzwNkZ8SFsLw	302	3NL2SVAK61Dxf7645yrtnyCwk7xq13ubXfDkdoWjQMBMpbdBsHgQ	67	66	Dhir-ZSd28gXuqiK8ORiLcBkNEtiEv9eqx4swf_RAAE=	2	3	307	77	{7,3,4,5,6,6,6,5,3,5,3}	23166005000061388	jxD9qkwUmCfyYri64p3APxddVuLNFAn96raawgk66KNG9P8wNPb	219	293	293	1	\N	1729679288000	canonical
322	3NKQk8KKuEevjEHLeJhkBgp67MKKzmBSRRPxty6n9L7CfA3UGEYG	321	3NK8C7pzDXvCeC1ssddneEe3Pf8cLR2x3oFuMPTrGUyGD7rqAuhX	96	95	SG6ed1w9iLRXiAK6BJrDMTsYqDAosdtjQisVUX9YzA8=	2	3	324	77	{1,3,4,5,6,6,6,5,3,5,7}	23166005000061388	jwEvPQHV4mVELenhwBEMdbvQDXrwbigf2SxPxAgXDioYjc77epB	232	308	308	1	\N	1729681988000	canonical
324	3NLad8f8AmEkHUiYYSbtztsUi36NKTmZFBqpANrupkJMMFqHMXVf	322	3NKQk8KKuEevjEHLeJhkBgp67MKKzmBSRRPxty6n9L7CfA3UGEYG	67	66	Kzp_HUhfjAdw5r_U7Jc3Uh1e8_zZKECzXt2rSHjz2gc=	2	3	326	77	{2,3,4,5,6,6,6,5,3,5,7}	23166005000061388	jxyf6PBgJSvXUoV6MAqG72cYUDexKjTxBSGP4ou3NCvsK3hkLzZ	233	309	309	1	\N	1729682168000	orphaned
326	3NLGCJoMGsm14Lqx4kazx5Ei3ouJPv4tY362jSjo57fSbxjjZc2q	325	3NK3U5wHaGFoqishLvhPNPW7Dph971dDUybtBm9s6UQdmKUn5gPx	96	95	kWuudALg7WERgoYWVqLjTTOcOShnWUIo28i-RClxKQw=	2	3	328	77	{4,3,4,5,6,6,6,5,3,5,7}	23166005000061388	jxNZ6nf3MCYDaT5TXVDMzyyWDtfThrvueZx7uvxYYdN1VmLGKCB	235	311	311	1	\N	1729682528000	canonical
328	3NKY1Zhd9h18dvv141pTwz6YozbYtbfabHhAi8DjBBX9d53AXrZk	327	3NKn2vztzDjRG9Kyo3ZGzskieGsxoWR9QxrqR8WseLQXC3LaCfWh	67	66	tW6Acde3QpM9UE1YpMedc0MdCx04-RVKepRnopJPygE=	2	3	330	77	{5,1,4,5,6,6,6,5,3,5,7}	23166005000061388	jxAikDu5T4RNKea19ERxh5bGEzHBCgK3W4DQvNstFw1cnoco8vV	237	315	315	1	\N	1729683248000	canonical
330	3NLTjvcHAi4nMtweT9TC5Avw6ZtWLMuZR2F8uzZ1FWHhrn5B9uJV	329	3NKggqZMAjLi1TybErmWsxY43YE8Mn6JtR4ksXXyxvwGt8pAsogK	67	66	RuDjOfGOk2tYQehzoFTs4p00Ie-U5yQ6FAYIn0Y0tQ4=	2	3	332	77	{5,3,4,5,6,6,6,5,3,5,7}	23166005000061388	jxQWLMrhomf6YBunD1wgwRpqSdikpTnB5sq7hmHjiEJkxXbbbYa	239	317	317	1	\N	1729683608000	canonical
336	3NKfyBw28Mpn3x4HeJGVCV3RakXtqAGnXi94fMthD7NRKJroyuWd	335	3NLXVtY2bPhkL5YJyX6VHerDELY9TDmePGmsVxmt9VFRM6z3Jx86	96	95	BKgf_okzDlmnoIHOvXv9kdAE8nNlu3kM5MPZSsZWBQY=	2	3	338	77	{5,6,3,5,6,6,6,5,3,5,7}	23166005000061388	jwWHNptQtPyhXwamerTy2RxTW486yurqnY3egDcK5M9CVWN3gGH	245	327	327	1	\N	1729685408000	canonical
338	3NKeLZKcVVYr691eHSejiALyhCZarbjpYmZpwDJLUVcsbcLmo2xL	336	3NKfyBw28Mpn3x4HeJGVCV3RakXtqAGnXi94fMthD7NRKJroyuWd	67	66	QgudJTguVu1DjHNHYD6JpHcvmOyxRFWloTedC3_3NQ8=	2	3	340	77	{5,6,4,5,6,6,6,5,3,5,7}	23166005000061388	jwD1VDdb1kRXcqg2RQ24uzMLW7mpryv8NSf3k7M9fHaBMFYDNAw	246	328	328	1	\N	1729685588000	canonical
340	3NKErDyLBGvkKrfnUqA4CwU3TTizPwhmca2WUJnpj4ojQAb58ehU	339	3NLnXnZjsgqnnovQKCuy5BydFbYWJ5TbHaBcDG7qTvMPz2mtPdPn	96	95	7YKsGWojyKbONusCUXWHKkFwyNn0hIl6st7NYceFIAg=	2	3	342	77	{5,6,4,2,6,6,6,5,3,5,7}	23166005000061388	jx815xww1etkwtNVnZiCxKy7qK7yE8y8EKSJrk9D9CqSuVHDGRr	248	330	330	1	\N	1729685948000	orphaned
390	3NLNJHZSZW5bWo2rEtCLJbrdAFkVXLePUTYxxRHBLb8UKcCUs4BB	388	3NLiZz85fBTg8SCV6MNJ8rdmnfmDxk6UssCjwfojyZT1js64wjAR	96	95	34YEQxQfI3LYv1X-XRRG7s_FC3Kj0D2BfZ6oX0mdIAA=	2	3	392	77	{5,6,4,5,4,5,4,7,7,4,3}	23166005000061388	jxQzHxX5GfWy5WjsUEJ47QxKkG93VmUbVuACQzvFjuMoeZSmyHW	285	380	380	1	\N	1729694948000	orphaned
331	3NKaZfwp2nsXPCVotTyVF1vchD3hcCZdsFd9cb3aSpw7rzAWmpDi	330	3NLTjvcHAi4nMtweT9TC5Avw6ZtWLMuZR2F8uzZ1FWHhrn5B9uJV	96	95	mECwnhdDC4aRsIrBakleBGeiPqoUJp0JPo8Q7568_wk=	2	3	333	77	{5,4,4,5,6,6,6,5,3,5,7}	23166005000061388	jx7ATDfNzccM6AwKcCQneZWAAMzDM4D4zG4uoBNWcgY4WNM3sfL	240	318	318	1	\N	1729683788000	canonical
333	3NKBrCnYPd9Lm7AjCSBYnL3yUfU3EwsXrWD9nEeV43bHakkUw5LC	332	3NLUwMJLBFkY82CfT1iPBqntYgQYnpRtxYa3u9tWQZmMpq24sL5J	96	95	xkXlkw8rxUKhb9Ar9NegbmrbJ7TWqTw31pOxvVkcuQg=	2	3	335	77	{5,6,4,5,6,6,6,5,3,5,7}	23166005000061388	jwhDdS7x7HWHEzj5rQVw6rAWG8ykvmJUnLbCgztjP1eiPrPPnWc	242	320	320	1	\N	1729684148000	canonical
335	3NLXVtY2bPhkL5YJyX6VHerDELY9TDmePGmsVxmt9VFRM6z3Jx86	334	3NKZNXKucG1C3ZPRuGChsePjdSUjxXTH1CfX8tJP5ewuA5rniZRR	96	95	xnCMzsXMlv1Pr9U6gV6vkzoLnU1KM9KNe5N1E3G_tgY=	2	3	337	77	{5,6,2,5,6,6,6,5,3,5,7}	23166005000061388	jwvxnhJ2SbrRbTMBntJoPWKUXqvQgeHyD7sGLWFEwJJBFBcpoLr	244	326	326	1	\N	1729685228000	canonical
297	3NKvHtpYCnJCG1fZvUYHPcm6tF2zfezhgCGbN1ogc6ywzubGvW81	295	3NKEWrm6HXmxVjwoYtPTczm8cMjRmxdYdJVRDnQPSMTbj7A6QMpi	96	95	TUppDtJ6lOiRqpjHRm5OyGVCnunt6-ZlhmD_cY9AuAE=	2	3	299	77	{7,3,4,5,6,6,6,3,5,5,3}	23166005000061388	jwJEeVK1x6zyDvhBU7bBFAUbVJg1LeMd258QV6dcvbasojWMZL5	214	282	282	1	\N	1729677308000	canonical
302	3NL2SVAK61Dxf7645yrtnyCwk7xq13ubXfDkdoWjQMBMpbdBsHgQ	300	3NLLaMYPmntSfXjDXQ9ufo87KHfGjVMxAg1NUMERQbGr22GebUh6	67	66	-QOPO9dk4ABNhW6miBsB8kfn86TtppHL2a2ozNlEKws=	2	3	304	77	{7,3,4,5,6,6,6,5,2,5,3}	23166005000061388	jwrUMwG2URw3KtDfjw8P9x4cg4SwnZNbmJZc8Ki78R3tuBMawQr	218	292	292	1	\N	1729679108000	canonical
323	3NLLhGQga5XroRWXX1EczJS7cedK4JsfzuAAUFpFTfNqXVNZpwd6	322	3NKQk8KKuEevjEHLeJhkBgp67MKKzmBSRRPxty6n9L7CfA3UGEYG	96	95	LDGcFEujcY8XLi0PYVX3LD0ui3gRLKxdooks1Kxfmwc=	2	3	325	77	{2,3,4,5,6,6,6,5,3,5,7}	23166005000061388	jwp69Eu4gKw18A5KL83o4kZ6nShqfaPruyXsw1bhEA4ERjWXhQo	233	309	309	1	\N	1729682168000	canonical
327	3NKn2vztzDjRG9Kyo3ZGzskieGsxoWR9QxrqR8WseLQXC3LaCfWh	326	3NLGCJoMGsm14Lqx4kazx5Ei3ouJPv4tY362jSjo57fSbxjjZc2q	67	66	iK647vQyzxMUCQ-jKm9_GVm5k9PI-2B0OxbEbmBs4AE=	2	3	329	77	{5,3,4,5,6,6,6,5,3,5,7}	23166005000061388	jwwQsk1CXBbeymzjp5jknmS8dhZuB9PSdvj28QxGjzkzK9Lmwr8	236	314	314	1	\N	1729683068000	canonical
329	3NKggqZMAjLi1TybErmWsxY43YE8Mn6JtR4ksXXyxvwGt8pAsogK	328	3NKY1Zhd9h18dvv141pTwz6YozbYtbfabHhAi8DjBBX9d53AXrZk	96	95	bR7rAYAQpN74VbLF_NYgwelVYENK_7sf7AxFqdHVzwE=	2	3	331	77	{5,2,4,5,6,6,6,5,3,5,7}	23166005000061388	jxoeU6DNd7zhcLZqQhh37iX2mSRUKKn6FtFHVDgKHtM4z2U4yjB	238	316	316	1	\N	1729683428000	canonical
337	3NK3ACyxVCsDrpXcHLWLaqNxTvtv9ytEf7RBjE7SioomgzqKSvMe	336	3NKfyBw28Mpn3x4HeJGVCV3RakXtqAGnXi94fMthD7NRKJroyuWd	96	95	IijDF2-Vrt5sPBjpVMTTtD1UyC4AnFEs4rdbHXVTbwU=	2	3	339	77	{5,6,4,5,6,6,6,5,3,5,7}	23166005000061388	jxVEpSiLfQaLJL8iynWHteqDJhPxZnmXEXdRS4DvsrUL7pF7bgH	246	328	328	1	\N	1729685588000	orphaned
339	3NLnXnZjsgqnnovQKCuy5BydFbYWJ5TbHaBcDG7qTvMPz2mtPdPn	338	3NKeLZKcVVYr691eHSejiALyhCZarbjpYmZpwDJLUVcsbcLmo2xL	96	95	uGRNSEs_X0y2vc3ae294hjFP6tnUSpPAITG86xmEBQk=	2	3	341	77	{5,6,4,1,6,6,6,5,3,5,7}	23166005000061388	jwyrVkDBXz96HMbjzwNiHLAPRwNhUaindGSVLZUHbXS6kLdh3ep	247	329	329	1	\N	1729685768000	canonical
341	3NKGKpTsLmVvJ9qsjhrTQKnkm9UDKwmuqec6sSUt4nDzfSGQH5XQ	339	3NLnXnZjsgqnnovQKCuy5BydFbYWJ5TbHaBcDG7qTvMPz2mtPdPn	67	66	UHMfDxNJb-Yjo1EscaN4atfvKjTc_L8h2YSuu8pmDAc=	2	3	343	77	{5,6,4,2,6,6,6,5,3,5,7}	23166005000061388	jxjfDAcKQ3XgWW5nBHRfhzZVCZwtmB6Yqz9KCdk5PwrXjSfoUHe	248	330	330	1	\N	1729685948000	canonical
342	3NLEs4j3QvBDpmLe4QxuEmexChcedDsKLcj1cxdV6tiH5g1Ghh23	341	3NKGKpTsLmVvJ9qsjhrTQKnkm9UDKwmuqec6sSUt4nDzfSGQH5XQ	96	95	EJgDuKQ5aiIBm_Wft5C2qS7YL67-NPWw3F1TRLa9RwY=	2	3	344	77	{5,6,4,3,6,6,6,5,3,5,7}	23166005000061388	jwu4vyfWrVPjsAEYXVZKLfM2V5xq9rN1FFuez9f8wtdbQs7saLZ	249	331	331	1	\N	1729686128000	canonical
343	3NKGv9x9s1WP26qvTLHTfwurVEiXoe9ME3GUQhrosnRzgxiWRrKj	342	3NLEs4j3QvBDpmLe4QxuEmexChcedDsKLcj1cxdV6tiH5g1Ghh23	67	66	cK5-Hj7trnwH6VLV0El8vBsrTdqJ2wyWiaGV1RthVws=	2	3	345	77	{5,6,4,4,6,6,6,5,3,5,7}	23166005000061388	jy1PD3R2TbPnp95MQbvTA3FsP4wGM3yqWMKoTSU17xLaQYCR9sD	250	333	333	1	\N	1729686488000	canonical
344	3NKtQTpio7UwvoAHXUS56zHQqcMtBcvAaUbFkmSMgHnLQR6rsa16	343	3NKGv9x9s1WP26qvTLHTfwurVEiXoe9ME3GUQhrosnRzgxiWRrKj	96	95	chouEZR0uDMbCU4zooZATHlkg5qNJgzp-uWwH7wnng4=	2	3	346	77	{5,6,4,5,6,6,6,5,3,5,7}	23166005000061388	jxbbmAdwVrhyLYdmfZAhQYcwjnZythAqD8hQ6YN88Ht9eD1kL2M	251	334	334	1	\N	1729686668000	canonical
345	3NKtmW677naNkBdfgLHRdAQJopWqpDZxCmhHL6Y2mhT6SA21be1u	344	3NKtQTpio7UwvoAHXUS56zHQqcMtBcvAaUbFkmSMgHnLQR6rsa16	67	66	VIYAskI7IYIFvFfrbDycLhDgxiJNqgb3swXr1oLsWws=	2	3	347	77	{5,6,4,5,1,6,6,5,3,5,7}	23166005000061388	jxMDwtTfR8u8iD5ZKMuWhpJbdtZGWBHr8oUWpHYdvG4oxGGNf2s	252	336	336	1	\N	1729687028000	canonical
393	3NL5PeLuQRvfoeWqJQiBJ6LBbbEmTZiyg2yGL441fA32paux2dk7	391	3NLsv2ZqewJKRp8DHqwXm4ZiHyiBK31pQLQCwnL8cRrRdg92RncB	96	95	fKm54tDL-TBdbvpBcJPfbt9nK-wZ0HFr45JzVs3voAk=	2	3	395	77	{5,6,4,5,4,5,4,7,7,4,4}	23166005000061388	jwvEuDHgK7pLagFk1nrNoMEpjszp9ws8mS46MwBcUK1yGVgR87q	286	382	382	1	\N	1729695308000	canonical
319	3NLSQfSwnXccqbJkM9zYtqBdoeC8whTVa2kCFHG8PTdaWKnERbnC	318	3NKk3bXFJc45uTxepphLt85jiLib8UbmJAwcV6oTYjhQA56jN3C5	67	66	O2VXXd605JhM-zEmVs6Logh7SNL5u-Cfy9yBqug6yg4=	2	3	321	77	{7,3,4,5,6,6,6,5,3,5,6}	23166005000061388	jwNp64F5KofqYYJPqkCtJtRopHKaKNCTUjdiGUHwcNktH3VX1ip	230	306	306	1	\N	1729681628000	canonical
321	3NK8C7pzDXvCeC1ssddneEe3Pf8cLR2x3oFuMPTrGUyGD7rqAuhX	319	3NLSQfSwnXccqbJkM9zYtqBdoeC8whTVa2kCFHG8PTdaWKnERbnC	96	95	FIT3eTM1KoWFQnG8uPGRkoVeIhVJlISS68YIElOl0Q8=	2	3	323	77	{7,3,4,5,6,6,6,5,3,5,7}	23166005000061388	jwKLDgxgUyxVwerfnneqDtC6sqCbXxdqw62C3UxJjmC1Tark1fE	231	307	307	1	\N	1729681808000	canonical
346	3NLdbTSX7FGz1eP2FAXSs4jtDXaCkjH3CnucTQAxk8qv15tBBemZ	345	3NKtmW677naNkBdfgLHRdAQJopWqpDZxCmhHL6Y2mhT6SA21be1u	96	95	ILeJe5spfsTNF3c1EIoXXv4X9_vAuWlhr-BWwuS1TwY=	2	3	348	77	{5,6,4,5,2,6,6,5,3,5,7}	23166005000061388	jwMyGvx4fpGmHVjVDeugi8cDesBpmbKm98rxYgicCF7K8AXsBJS	253	339	339	1	\N	1729687568000	canonical
348	3NLfBNKRWgSWUygJHJsyBjHu3TXREefTSvFScjBbnsDiqMwS41vw	346	3NLdbTSX7FGz1eP2FAXSs4jtDXaCkjH3CnucTQAxk8qv15tBBemZ	67	66	qyu3CmfAYFGiL_UUd64Ynt4Vjcjv9TjiO3zH6IyA5w4=	2	3	350	77	{5,6,4,5,3,6,6,5,3,5,7}	23166005000061388	jwC88nNg38Ceyfqnq7Zh4iPB9dkXk2JcYr5ifarprbxTb3ep8Ng	254	340	340	1	\N	1729687748000	canonical
350	3NKzwMWps4rsKkWbhVFuSH1dmxzGXMgpP9pKWXsudcP3fWAyD8PX	348	3NLfBNKRWgSWUygJHJsyBjHu3TXREefTSvFScjBbnsDiqMwS41vw	67	66	G4rIyzSlZ0sjJslNPwVLVkQ2WQOrEo_c_2j9uQNyBQY=	2	3	352	77	{5,6,4,5,4,6,6,5,3,5,7}	23166005000061388	jxJWNJKnJofY8W7JYFayT5r4DrnZAK8zWLQWdyuiVWkXncCPihj	255	341	341	1	\N	1729687928000	canonical
352	3NLtAXotLup2vSqqGJQNKVqHaEN8bbzRkD3z558Q9zUXj2oxe9UT	350	3NKzwMWps4rsKkWbhVFuSH1dmxzGXMgpP9pKWXsudcP3fWAyD8PX	67	66	WdLTBVm-MLh3Wxqi8LqcR_1OMFPAOmtc8bPaywxb6As=	2	3	354	77	{5,6,4,5,4,1,6,5,3,5,7}	23166005000061388	jwDdxFbWGgSqRYR8eXEuHCSUoDsYpL8so7deTm9EFWZXD1zMMs7	256	343	343	1	\N	1729688288000	orphaned
354	3NKZGrGxx5aLTKwRLmvKY4Y2BLwSGEtZ9tMnBwFVddxFqa1AvFyN	353	3NL8GXjXan3ZjBAYaAaKienRaaG3jQ5cE3fjLRL8L4E5UFUGHLg2	67	66	veHUagtEPoA2qgDsrPFccAKvPHx1-nZy8VS1MgeUOQU=	2	3	356	77	{5,6,4,5,4,2,6,5,3,5,7}	23166005000061388	jwLfg6G3HfYHAqXCG8ZuaxxXnA2NzpjU6M4E3VpLdgnzUFQtxXA	257	344	344	1	\N	1729688468000	canonical
356	3NLn25eZXyhCND6UvH9pX2CeQWvBf26fQBqnk5zfMPssPXjNsCKs	355	3NLaqfzct8wxSS3x1KwDcF4UXJqQRWaJxjJ2V2QqbNM1E8su9zXt	96	95	r4iOI3456NADBvrURvmpCoRu4rfUybfu-9SaF9_aUAw=	2	3	358	77	{5,6,4,5,4,4,6,5,3,5,7}	23166005000061388	jwermomAZAtiY2DXkKygPMZujFkzmE91GjXkbpjk4vx4iM5G7ks	259	347	347	1	\N	1729689008000	canonical
358	3NKccEG31asRQqWyJWM6hnoijYsq5yTozfgK8v2aytV55gVJrrhE	357	3NLgQcVBEJPWxuiFubXCQSJSvNnVdvbVwHAub4ix62KVEVYLYWso	67	66	DOCVIfI1GudQFTT7V4ScuI7T_8XiX47XYGN2d7wH2AM=	2	3	360	77	{5,6,4,5,4,5,1,5,3,5,7}	23166005000061388	jx3JaWJkFWo5Vp29Qgk12F3iDvCKCiFNHwn1jpfcUfMZ4tojDsw	261	350	350	1	\N	1729689548000	canonical
360	3NL5rHSAARKxj8EhwjgzaXWy1DokW4pRqKdPKqa8ar94G35atcxv	359	3NKBsUmXF2Qr75dJuR4fWAGTAPsuShrHdHY7pvT2btqLCrzQYR45	67	66	TfwglgfiQfH9_duKbFGQ9Z3Z2F4ECEz78q_FZgCOQwo=	2	3	362	77	{5,6,4,5,4,5,3,5,3,5,7}	23166005000061388	jwjG1bdG2LZbAnPLz6RVy1BirCKwV1ZKqbXvCLEHxGUWenKtuUU	263	352	352	1	\N	1729689908000	canonical
392	3NK4JgHBWi6oS2PhZRmANxNuv3i5neV2CLJ4CDyyZmNXty3gxygb	391	3NLsv2ZqewJKRp8DHqwXm4ZiHyiBK31pQLQCwnL8cRrRdg92RncB	67	66	Nxj9p45ZhYKOGfiMTZafnPXBkYA_9A617-eqDYoPdAg=	2	3	394	77	{5,6,4,5,4,5,4,7,7,4,4}	23166005000061388	jxiUdc4mawBPAZsfzPmCDsQZrncVWMhjPoX1Ws98qujvErBSDWb	286	382	382	1	\N	1729695308000	orphaned
394	3NLPVbYq7kWC1DrjZRo3REXpg98QGKR1Dbeomo3RokbNLu7MPGsJ	393	3NL5PeLuQRvfoeWqJQiBJ6LBbbEmTZiyg2yGL441fA32paux2dk7	67	66	EDTFYZI5c8flVjn9TPsxkQVfhmDvJl9p1H2Nb9_vTAQ=	2	3	396	77	{5,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jwCPMmw4ia2EPdfCefUm88CTkybj2efTcXZJSweLRS5gwVpUaM2	287	383	383	1	\N	1729695488000	canonical
396	3NKKWcC8N7mdmZkB92dveH5NQ5NQvActZC1QcsGqjF9Ap3cRRgvY	394	3NLPVbYq7kWC1DrjZRo3REXpg98QGKR1Dbeomo3RokbNLu7MPGsJ	67	66	ziu0jA3bWmPLIT2D9mNUCtGJoFLgkyBP0DSiImOOCgY=	2	3	398	77	{1,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jwMhZ6FB2GC6yNSbNgAZzXptZAHwTo96bHF4VXKRA6bJGfaTNU2	288	385	385	1	\N	1729695848000	canonical
398	3NKBVRzJTz54Ay5FPBU6B9ChuMxJxEf6ua9yrTC3JfSLebzMQznm	396	3NKKWcC8N7mdmZkB92dveH5NQ5NQvActZC1QcsGqjF9Ap3cRRgvY	96	95	z1cZ_LhXVgrLeuS2ZmBTmuhjjzLwoW27e9Pl_bt6HAI=	2	3	400	77	{2,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jwgMyuBXtjo9n8XBnwXoYTk1PbJuDMHFo9Tbu4iTJZEaFPPq4Go	289	386	386	1	\N	1729696028000	orphaned
400	3NKPoYs93yYkiXhzjANC9eAwRm6Zgr9LkpLX7goC9A6St3WKZLYo	399	3NKHAzxXaUwe1GCNkEiBrRJE6WoqhNwevP8VFsNYtJy94rWbArsn	67	66	tOtpbm16c0VOsHxf1eVgRBcOqTz2M2dYFxec1AixXA4=	2	3	402	77	{4,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jxZ9Bu6pVAev46ZALWuJ5SY6WqqQE5TyJzp4hJBCTKPsKwYFbf2	291	388	388	1	\N	1729696388000	canonical
325	3NK3U5wHaGFoqishLvhPNPW7Dph971dDUybtBm9s6UQdmKUn5gPx	323	3NLLhGQga5XroRWXX1EczJS7cedK4JsfzuAAUFpFTfNqXVNZpwd6	96	95	4Z_a9vTijMb2NecRVMO2c74oUV1mzhs_40m_6HSCfA4=	2	3	327	77	{3,3,4,5,6,6,6,5,3,5,7}	23166005000061388	jxwCx1U76L8RNWVG3ZRYFw1jzrREKKKqgSdQchTDH2M1pChTtsh	234	310	310	1	\N	1729682348000	canonical
347	3NLoNmCKZwSFYqbq5ThiBzX4qg6uDyVrSU2aH5ZgfPPtUmgTrsgx	345	3NKtmW677naNkBdfgLHRdAQJopWqpDZxCmhHL6Y2mhT6SA21be1u	67	66	2MfifI0IeIFIcr5iUVlPFrNDgB7vODaW0cfSh6lHQwc=	2	3	349	77	{5,6,4,5,2,6,6,5,3,5,7}	23166005000061388	jwbGDddEvWmgCyrdfPa3MBq3bUdi9jzv4uZPap7Dd5HVW6gDhAJ	253	339	339	1	\N	1729687568000	orphaned
349	3NLK6AiefKGqbyBijFpH92ZQEo8s9tbouqQMkG5b6jJ2msaJspWm	346	3NLdbTSX7FGz1eP2FAXSs4jtDXaCkjH3CnucTQAxk8qv15tBBemZ	96	95	t6qEES4AfBFx4e4XtoRJ-7dIZeeSyrimRRq3xT30cw0=	2	3	351	77	{5,6,4,5,3,6,6,5,3,5,7}	23166005000061388	jxcBW4agAc5DAFdHYkCEmC7X6e1xCpPp8L2gbBVcaLSFnXyBBxp	254	340	340	1	\N	1729687748000	orphaned
351	3NKpJQf2MskSiHqcweyyBeQo949Aq3qZe5g9VQWVPojwBe2wFECQ	348	3NLfBNKRWgSWUygJHJsyBjHu3TXREefTSvFScjBbnsDiqMwS41vw	96	95	X7suwohaXLW0t15uY5wtk7Z8INr6gDJLRu-mz_Ce4AM=	2	3	353	77	{5,6,4,5,4,6,6,5,3,5,7}	23166005000061388	jxghHyP9yCqKQC6CRCgQaSFQ5NV1CjvERvxRLWNCCbJSUF4pphd	255	341	341	1	\N	1729687928000	orphaned
353	3NL8GXjXan3ZjBAYaAaKienRaaG3jQ5cE3fjLRL8L4E5UFUGHLg2	350	3NKzwMWps4rsKkWbhVFuSH1dmxzGXMgpP9pKWXsudcP3fWAyD8PX	96	95	ZdBD00fQpLXLS6_4bptMXr9h-PC0yelQrAvNq3uIvQw=	2	3	355	77	{5,6,4,5,4,1,6,5,3,5,7}	23166005000061388	jwqCCC7Hfx2hi1DEZzR79WcubfjzZJ6RR5MP2CLK9zxtrc3u5gj	256	343	343	1	\N	1729688288000	canonical
355	3NLaqfzct8wxSS3x1KwDcF4UXJqQRWaJxjJ2V2QqbNM1E8su9zXt	354	3NKZGrGxx5aLTKwRLmvKY4Y2BLwSGEtZ9tMnBwFVddxFqa1AvFyN	96	95	7rD0UghZOhOrOBk9JRv6h1R4JeDbmd612UiIGQFaDgc=	2	3	357	77	{5,6,4,5,4,3,6,5,3,5,7}	23166005000061388	jxXLvWAGC1oiFmVPUw3WzifqjLqwjjT6BpMGUqiTg21Pb5N52iF	258	346	346	1	\N	1729688828000	canonical
357	3NLgQcVBEJPWxuiFubXCQSJSvNnVdvbVwHAub4ix62KVEVYLYWso	356	3NLn25eZXyhCND6UvH9pX2CeQWvBf26fQBqnk5zfMPssPXjNsCKs	96	95	GODchAOscG4G5uwOJxvcWnShDBYmvVHLlk4a4iLhrwg=	2	3	359	77	{5,6,4,5,4,5,6,5,3,5,7}	23166005000061388	jxeaCMhMhZTbNUAqriQBAAzMryFiTJM7tQJbMzh5TZp16SzhyfN	260	349	349	1	\N	1729689368000	canonical
359	3NKBsUmXF2Qr75dJuR4fWAGTAPsuShrHdHY7pvT2btqLCrzQYR45	358	3NKccEG31asRQqWyJWM6hnoijYsq5yTozfgK8v2aytV55gVJrrhE	96	95	UYMW3YbcGxNjsPEyxLN8bRbqafnhWtngwPzn2WJjywU=	2	3	361	77	{5,6,4,5,4,5,2,5,3,5,7}	23166005000061388	jx8AqH8ixBY5N7kQZdhrtu6KjRcNJ88XhVJgumyeTw8ho5GwE2W	262	351	351	1	\N	1729689728000	canonical
361	3NK3yCtqWrpixFzMpJjmerXrvmVhWizNZHz1F9S3fp1ZB522ieiF	360	3NL5rHSAARKxj8EhwjgzaXWy1DokW4pRqKdPKqa8ar94G35atcxv	67	66	EUFXhfEMJ_AQjTRssQ6RJmkPeKyEDW-FEI-a7AJIkAo=	2	3	363	77	{5,6,4,5,4,5,4,5,3,5,7}	23166005000061388	jxrZJ4uroiYbGq3cuCbyYyP7qGd9Cf9GupxSTZJQFPHEr5YPp7W	264	356	356	1	\N	1729690628000	canonical
362	3NL7jcubEBg6A9EzfgXhjYk6ig8ZMLX98ZH6pkBDGK6RJXMKvgUt	361	3NK3yCtqWrpixFzMpJjmerXrvmVhWizNZHz1F9S3fp1ZB522ieiF	96	95	yivNB5JhPYcjMV-aRHzNUH_YD4dUGf8NnzOwyLpeFwQ=	2	3	364	77	{5,6,4,5,4,5,4,1,3,5,7}	23166005000061388	jwSLgDug6tLesVehr8441mHmPYyGFgqgS6BMRFWrf8qLvQGeHpB	265	357	357	1	\N	1729690808000	canonical
364	3NKNZbb9728wVn4HAzzYyZvcZbnZLTo3eZ8ioiJ3EWRiwnZRUKS2	362	3NL7jcubEBg6A9EzfgXhjYk6ig8ZMLX98ZH6pkBDGK6RJXMKvgUt	67	66	5PTJsBVB-5MibxVy0k17h7Thvb2oaRHdiTYFliRnOQI=	2	3	366	77	{5,6,4,5,4,5,4,2,3,5,7}	23166005000061388	jxpj6JPuwhLK73yJ11to1RTvUwpgsSjSTCUCzPxVh3tFTcuB7Lj	266	358	358	1	\N	1729690988000	canonical
363	3NLuhNJwuJWA5N6ayK1toL7rCU2X3UC9rN1oBexmsRCQXqSFKwgT	362	3NL7jcubEBg6A9EzfgXhjYk6ig8ZMLX98ZH6pkBDGK6RJXMKvgUt	96	95	-ekgO6NN_7hH1WwLBiXFoDXZVo6USvfKDLlRm9DlswI=	2	3	365	77	{5,6,4,5,4,5,4,2,3,5,7}	23166005000061388	jw7Z6sBGZJ9St4cJHZmkpJ9MkTiu3vpq2TCHm4fDybxN1oM1Gok	266	358	358	1	\N	1729690988000	orphaned
365	3NKhxKUsgPhAevHuxLEaDvhgYfuUNig4GANyqi9XxSh4oEtptvsT	364	3NKNZbb9728wVn4HAzzYyZvcZbnZLTo3eZ8ioiJ3EWRiwnZRUKS2	67	66	-kFB-5vbl5C9VMDx9gN8Lp15_uCuB3tYI4Q1Q2ijZgs=	2	3	367	77	{5,6,4,5,4,5,4,3,3,5,7}	23166005000061388	jxhDEcfHZexcm4LZh5HvHfFWF1oqybTifgYRSxa2eDAkwfJTRHM	267	359	359	1	\N	1729691168000	canonical
397	3NK8VQ3LSbvuFYkJyxmf39ZEioS72oYs8TPX42K4M1eBfCDEhagn	396	3NKKWcC8N7mdmZkB92dveH5NQ5NQvActZC1QcsGqjF9Ap3cRRgvY	67	66	-Ali9U8mj8MxhieyyXCj4MCUuA2j8nZsqDlwH6-YLQE=	2	3	399	77	{2,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jxohkvfZRy4UbYSkdekP8MTNMu21JGt6gCx2AZGptNbME63Gdfw	289	386	386	1	\N	1729696028000	canonical
401	3NKcwpFktkczb6YFkyQrsqSqn5nPcgvH3LgTiuHpfewaYr9UJqTn	399	3NKHAzxXaUwe1GCNkEiBrRJE6WoqhNwevP8VFsNYtJy94rWbArsn	96	95	gXOb5FdtIw8amSPa_D9RPj6TToGghKUfgC8uhLfBFA4=	2	3	403	77	{4,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jwcxNLRiXp8nGRcVPFKVKUzqehWiB9RsBbZ3neUE5sYHCuAB94d	291	388	388	1	\N	1729696388000	orphaned
366	3NKmK4wEUFPyjKnibpZCUhSsZHCTwDGukuy8XtP2Mh4DdCm4WYcf	364	3NKNZbb9728wVn4HAzzYyZvcZbnZLTo3eZ8ioiJ3EWRiwnZRUKS2	96	95	yMnqTk-fHMY8nhOjKOZOO44WG4iFJN0wzJBocBR3ogg=	2	3	368	77	{5,6,4,5,4,5,4,3,3,5,7}	23166005000061388	jxu1YsE749PKaxa5XtfJkb4sosR5xyG3sctd3wsBCUDvKvcr9md	267	359	359	1	\N	1729691168000	orphaned
367	3NL2bTFTEbmGeeGQi3utmWrRfpfXE2vy1BgDDqRzuBHCkyDnqQup	365	3NKhxKUsgPhAevHuxLEaDvhgYfuUNig4GANyqi9XxSh4oEtptvsT	96	95	2x1ML5gcG34gnXVCPdBz_FtsYd4aXaobnUfXJ4dYWgM=	2	3	369	77	{5,6,4,5,4,5,4,4,3,5,7}	23166005000061388	jxevCiXi3h1NUDihyD9TCYEuPdigypCwP6PQAeU1Q9YxmGSLrA7	268	360	360	1	\N	1729691348000	canonical
368	3NKYxZkGGvL1rka5EQoCvXXoyguUsH3Jzzcy73pS94nGyJ1WPoS9	367	3NL2bTFTEbmGeeGQi3utmWrRfpfXE2vy1BgDDqRzuBHCkyDnqQup	96	95	stvaKA_C19emedAx24X4g3fx6S1j5klmy-qeE12IzgY=	2	3	370	77	{5,6,4,5,4,5,4,5,3,5,7}	23166005000061388	jxduRtHebMGZLgMQABDnkezL81rM9HeVvDAWnBKu6Y781zEj2Hf	269	361	361	1	\N	1729691528000	canonical
404	3NLnMcPE78aDAYU8L1ReTC2K6C9rcqeq5kywH929BP5jp38SSUT2	403	3NLChsTTJ3XveQBGWF1YGBT66e1UUH3RaMAn4v7h9Y1GeACkFTVM	67	66	-86m3jK0Gp_J7hhTWtBiRb7oEaFhb86SWVfIhhWUTQI=	2	3	406	77	{5,1,4,5,4,5,4,7,7,4,5}	23166005000061388	jxfWnx7mnvkwcEcHw4BVCVYqoAKH4PAECWhaT5QpvvRixWQ68Yf	293	394	394	1	\N	1729697468000	canonical
369	3NLSjduaXLramRMRptyvLYeR9SPfcyNdintkiUtiVHBSUHVJp9ii	368	3NKYxZkGGvL1rka5EQoCvXXoyguUsH3Jzzcy73pS94nGyJ1WPoS9	67	66	YvhLymhiF4EZuaNXAfEaSGcMV1vkErSkJgrBKYyyhgU=	2	3	371	77	{5,6,4,5,4,5,4,6,3,5,7}	23166005000061388	jwfbNUQBiSDWgfbZMnNrMxRtoZC6ppgYAwQiXLdcs8SzWzz9Emu	270	362	362	1	\N	1729691708000	canonical
370	3NLWwDa3VprdUafMVtCMhKNgNNoG9Afcj8iZVgYAAZHb3JgJkiLQ	369	3NLSjduaXLramRMRptyvLYeR9SPfcyNdintkiUtiVHBSUHVJp9ii	67	66	7e4s3vZcAml5vvUYPo_pFNgEUkxqNTICibHtoezgkAc=	2	3	372	77	{5,6,4,5,4,5,4,7,3,5,7}	23166005000061388	jxc4Te1b4dLLuqrEocqw9aEPedgG1MThRvRNQAFAacEhw8RPzJf	271	363	363	1	\N	1729691888000	canonical
371	3NLaAcXYKReP5SpGMz5fuahJMmRnDqR3byt5427raipoirKDS1tB	370	3NLWwDa3VprdUafMVtCMhKNgNNoG9Afcj8iZVgYAAZHb3JgJkiLQ	96	95	pXMRdnCL1qux4meRmTDv1WsWYRaNUQriuronpLH58g0=	2	3	373	77	{5,6,4,5,4,5,4,7,1,5,7}	23166005000061388	jwpUzWSxKHz76hWcbtETsLG81xoMPr3WPLC6FRm1vma5ZjJh3m7	272	364	364	1	\N	1729692068000	canonical
372	3NLsujzatRYQzXMfkPpiAr1p94BEFYKfHTfbUw8HDQ91VcjJoEED	371	3NLaAcXYKReP5SpGMz5fuahJMmRnDqR3byt5427raipoirKDS1tB	67	66	NR_rffORvYpnzqfgc14tTJ9hB8FHmiR6bTyCMuG5EA8=	2	3	374	77	{5,6,4,5,4,5,4,7,2,5,7}	23166005000061388	jwxHDq5uckYyA6snPMMEZ3oygCGtpXneULijBafC7xTKtzMAomi	273	365	365	1	\N	1729692248000	canonical
373	3NKDGP2WWktjKwiP4xgLnFjvww6zbx2AK8rYTnnZpTCFBXJ6RjLy	372	3NLsujzatRYQzXMfkPpiAr1p94BEFYKfHTfbUw8HDQ91VcjJoEED	67	66	Tj4Nc30ORx86-O_rxA_ns2fRAAl7UKZw5fHdfzEYVgc=	2	3	375	77	{5,6,4,5,4,5,4,7,3,5,7}	23166005000061388	jwbfbb83En5Bcsxp27hiPrMUvLvrFeXwT6nDEhGAB5PEyShoNeX	274	366	366	1	\N	1729692428000	orphaned
406	3NLXsdM1Zt5FYgaAx8oKqRvUQgLdUL3yotR8MsgZaJ7ZhfUnHRPf	404	3NLnMcPE78aDAYU8L1ReTC2K6C9rcqeq5kywH929BP5jp38SSUT2	96	95	1lo0goDEzYlsUSxQxzFKIwYgPWGAsTT6qp3QGx0ddQM=	2	3	408	77	{5,2,4,5,4,5,4,7,7,4,5}	23166005000061388	jwYYmAcHzQZeaTJ9qj9uZRT7LRdryBjUL74Ng6ZLTni383Pa5UA	294	395	395	1	\N	1729697648000	canonical
408	3NLTtgGykC8qJGwGwuXRDoV5nHiKAgJ1ShmLhGWTTtaYMd6UghSu	406	3NLXsdM1Zt5FYgaAx8oKqRvUQgLdUL3yotR8MsgZaJ7ZhfUnHRPf	67	66	JjkKxmo6JUHX4I52BU2aZUU3nVLzX6wpVLNfieer3wE=	2	3	410	77	{5,3,4,5,4,5,4,7,7,4,5}	23166005000061388	jxfAyzEvYzin8ossg4Ruda8XCFreGTeD12nwoSnkqsjuA8iPF9z	295	396	396	1	\N	1729697828000	canonical
409	3NL9YPLyjdfXEryksMKvQWm9XjNnun3UE7nmuFwvj6YWuzFid448	408	3NLTtgGykC8qJGwGwuXRDoV5nHiKAgJ1ShmLhGWTTtaYMd6UghSu	67	66	JqUyj98vApunfKi3Jcv3honKbYlV6HEKbs3sUpZ5zQE=	2	3	411	77	{5,4,4,5,4,5,4,7,7,4,5}	23166005000061388	jwaiYA1NGMb1ubWa4i2vHmNekhnrjEzmmpA473UfH28y5V6x5kF	296	397	397	1	\N	1729698008000	canonical
410	3NK99gg8WkMZbaLWAb8iEyXjW6f7WCSDScbxe85ZkiVHcPtJwQc8	408	3NLTtgGykC8qJGwGwuXRDoV5nHiKAgJ1ShmLhGWTTtaYMd6UghSu	96	95	GHv2P4Eu20DR4bI87IKZ2XnkS8zIfeR6Y27UXqhfoAk=	2	3	412	77	{5,4,4,5,4,5,4,7,7,4,5}	23166005000061388	jwtiQkaNTizdj1ZutSWimpZssYgidGWvZsNZc2w32N9SCicK9cz	296	397	397	1	\N	1729698008000	orphaned
411	3NLQvXgAryySavY29bi4r3KGvJsSVF4sfypD3cdXbovFQet4ncqB	409	3NL9YPLyjdfXEryksMKvQWm9XjNnun3UE7nmuFwvj6YWuzFid448	96	95	1uKUImIIePnhbhxjEewBzRIf7TGVLFQIo4EdHFa-7w8=	2	3	413	77	{5,5,4,5,4,5,4,7,7,4,5}	23166005000061388	jwASD8bryAGRwZsuxrstncY27KbeggVD58C49i2J7W2rRAZRhWS	297	398	398	1	\N	1729698188000	canonical
412	3NLpnWhBbM7uJjHtYeG7KagsCYQTdA6FRgm7Ku6xccCazWTMxGhf	411	3NLQvXgAryySavY29bi4r3KGvJsSVF4sfypD3cdXbovFQet4ncqB	96	95	W1hVCjAqvdS5NxWfmTB1lRIPZXu7IlxGo4DEBkxuCgI=	2	3	414	77	{5,5,1,5,4,5,4,7,7,4,5}	23166005000061388	jwnXT1SVTw8gvWdHyhhnPEgvs6k8DruheGB37tUmdJZaXzz6GKT	298	399	399	1	\N	1729698368000	canonical
413	3NKQX882VYAqUBdd1aBHJrh1MnD7A3Qoyx2uTMbWD6nbSdY7qUaJ	412	3NLpnWhBbM7uJjHtYeG7KagsCYQTdA6FRgm7Ku6xccCazWTMxGhf	96	95	zjxr-7-5EGStZcjFTwy8i8Y1xlwXM5GnHkJn6FuzIAg=	2	3	415	77	{5,5,2,5,4,5,4,7,7,4,5}	23166005000061388	jxHsAADuCs1GbFhCFg83GeEHkDTZRNs3k75ziJEwedVSKHTCYnH	299	400	400	1	\N	1729698548000	canonical
414	3NLoRLyW8QJshSUbmWAV2VAgWRjhrH3DDHHX4ijm12iimB7WhMk3	413	3NKQX882VYAqUBdd1aBHJrh1MnD7A3Qoyx2uTMbWD6nbSdY7qUaJ	67	66	KlHB6ghc80IT8DiQuD1ERrexLt0990Ct5Qi3dmWAggY=	2	3	416	77	{5,5,3,5,4,5,4,7,7,4,5}	23166005000061388	jwhM1g1oAjYdoWTCoaH2vWkKMVqVtn3AtBXxRk7YvktnojM2CSj	300	401	401	1	\N	1729698728000	canonical
415	3NLu99z9L4eHA6gfxH52uZzJRwqfuAq1NuhUQWkpizpnKgnySQks	414	3NLoRLyW8QJshSUbmWAV2VAgWRjhrH3DDHHX4ijm12iimB7WhMk3	67	66	0AonRa-IcOWjmtGQ4rWJ9VHSK04cnlvkI-yxhJDalQ4=	2	3	417	77	{5,5,4,5,4,5,4,7,7,4,5}	23166005000061388	jwhEnEMC5ohhRjrpoVYsxpYQL4uDKA3xgSGAmvtushio59oMpPo	301	404	404	1	\N	1729699268000	canonical
375	3NLbjjW58ce9sTTCAdReu7FXpEwHT15cdUJf2CggfmcqkzyDf2Ga	374	3NLakSutYkhiCj2PAMUDeQHavSeVCpggC7mDFRgy64rnEmJXuee4	67	66	6J9O6mzYEkJ1pefmYkcN-JJ4NNsO0XiYJHEfEUvtXgg=	2	3	377	77	{5,6,4,5,4,5,4,7,4,5,7}	23166005000061388	jx8r2QHSQx2vzuAJbDByNvNSky5Re9G7mTZaUjrisUKLvnu1t8o	275	367	367	1	\N	1729692608000	canonical
376	3NKdWqJz3XHGDcXdVnM86qMxLmaJW3cQYtBbv5zWQqffDXBEzrze	375	3NLbjjW58ce9sTTCAdReu7FXpEwHT15cdUJf2CggfmcqkzyDf2Ga	67	66	jOaAReR0bKXJbJ6m3YhbXTI0GCtBAgSjDAvH_z4Ibg8=	2	3	378	77	{5,6,4,5,4,5,4,7,5,5,7}	23166005000061388	jwsPPxLZKzoSPjE3Woty3ti76F2vYsyWYKRz6PSvWz7rg1iyGks	276	368	368	1	\N	1729692788000	canonical
418	3NLjWLkcKRhBWq2n4drT2ENATbN1a9Px2hxHEaRDne6a3FQrwPmi	417	3NLPSLmC5xmKNXugX5i3hRWrb4U9ZZHJLbxsYD5r7y8tFBgfAiyP	67	66	4PykmmYByas81Hsa2jQtJ9_sqmCiwB8rMKZZ4JfZ1gY=	2	3	420	77	{5,5,5,1,4,5,4,7,7,4,5}	23166005000061388	jxtVWXZMDem6KPqf9LnRa2HFLFEqYGw17QjRJMtqereU3AKxMaH	303	406	406	1	\N	1729699628000	pending
380	3NL8rWgoaorWuxM8oEfqZuVKpPzchKwTwJxFZDbfLpeYhGShdhzn	379	3NK7phXzERGppxN3mqhSfbY1xmvdFkuRTKzxXnJ3H6NewVqAXLdw	96	95	EFoYNbnIMpAxxFDWYHxGV9QOTmXrIUaKf3Sx7xHEwgg=	2	3	382	77	{5,6,4,5,4,5,4,7,7,1,7}	23166005000061388	jwboGwqK1jmZUgspFAzX4uqDxheeYQEGCPmCerGA4GzdzV8Na8y	279	371	371	1	\N	1729693328000	canonical
420	3NKBKUVSzRSAVEiN4mDsFEeqBL2S6VUkeS7gBKBw2XXATiKx8oFA	419	3NLgQ5enAXQeY8RZNwpGTnKCT7caX4sJHdVEuHt5W4w9vxZLiAj6	96	95	f4z1v1R6_NoInAkfMEN-A50QbvzVF-DOBIhXV-zEWgg=	2	3	422	77	{5,5,5,3,4,5,4,7,7,4,5}	23166005000061388	jwBaNJ665KJSiSznvsZSKYXWfDjZ3ZbzsbHTu77BTb62QSkfY7o	305	410	410	1	\N	1729700348000	pending
422	3NKZGKS6CWZt1v5u2fKtAcMN2qE9EpeVhg7AQhA72Ree7DMVX8hj	421	3NKDGRekLJK9PHadeZnxLBUvY3Q4yvhQiEm6Q8FtZABesXUfZTxE	67	66	mE4o7BM3z7062gD-iEdb_ppxSMbKpVAx1JBLJClwEwA=	2	3	424	77	{5,5,5,5,4,5,4,7,7,4,5}	23166005000061388	jxEKcetUoLFci5oe8sTY9GGQxXb5pdxdqFVdTrFEqBsnwHnDA4D	307	412	412	1	\N	1729700708000	pending
424	3NKiq1WGFsEvEFzz4ERy8jCwz4PcAd7epaqWujJkhEwZUAJE9JvP	422	3NKZGKS6CWZt1v5u2fKtAcMN2qE9EpeVhg7AQhA72Ree7DMVX8hj	67	66	FmFOOEneSwDn65AGx4j6kZKzezn1IzspR0gY40gzJQ0=	2	3	426	77	{5,5,5,5,1,5,4,7,7,4,5}	23166005000061388	jxqqWwSjpPWKo22Qi9xZjHvshm8Sx7JFLHvAsycGE6mZYqasHvw	308	413	413	1	\N	1729700888000	pending
385	3NLyaCYAwa4wBRyZZPZFcCDoHjYxPdXTqZ54f9Ht3iJPcQ53QASA	384	3NKRiCr86grVFn7T8Uwm5b5bM5zSMoz9tBk4Gx2kzLqxoLFZnjhW	96	95	VU52Wz-JGc-sRQBJzp7rlzQDB7adeJHMowyMOIejTQ4=	2	3	387	77	{5,6,4,5,4,5,4,7,7,4,1}	23166005000061388	jwE9EG2oJ1SNauUqHr8NgUwkL9HpQyB4Q7xPF8E8VGrhZ3T8jfR	283	378	378	1	\N	1729694588000	canonical
387	3NLEQrBoe5KVDgqCq1WCVejBwtz6opbXdkL15JepxqKU35Lsedxo	384	3NKRiCr86grVFn7T8Uwm5b5bM5zSMoz9tBk4Gx2kzLqxoLFZnjhW	115	114	k1vUTGyXP8wGMIUnivzUBWP4x62blyz-Ckx-CgTsGwA=	2	3	389	77	{5,6,4,5,4,5,4,7,7,4,1}	23166005000061388	jx5kdX8hjbFke6gNf9A89N7yNc3HRA9i9cC1uwrYuMTq3KJcGEf	283	378	378	1	\N	1729694588000	orphaned
388	3NLiZz85fBTg8SCV6MNJ8rdmnfmDxk6UssCjwfojyZT1js64wjAR	385	3NLyaCYAwa4wBRyZZPZFcCDoHjYxPdXTqZ54f9Ht3iJPcQ53QASA	67	66	YSjvOU8ox1ULYg6svtc8_DLJdsSMyHbBGZSq4sc6EgY=	2	3	390	77	{5,6,4,5,4,5,4,7,7,4,2}	23166005000061388	jwGXVCq6FSeMqPAcr4w4jq4BUACdV8D59F7gPjuFzQLae7PsYGL	284	379	379	1	\N	1729694768000	canonical
426	3NLfUBWvH4ELw5iQQarbcvpYn9RbyMN6fhakiHg4qHdqyuCeCPrZ	425	3NLr7Wet39PhbLbuvV2yjdbqkie65bVdmtJSD663FXizGFjzq9W9	96	95	vOG6_QBUT-ZGbZzCzLT8pNz89rDtOjYKwdm52ZGQ7Q8=	2	3	428	77	{5,5,5,5,3,5,4,7,7,4,5}	23166005000061388	jw9JeUV3H7sAPgTTLRtvCAayR8TU3S1uCwibKW9ddWxPTonoQoU	310	415	415	1	\N	1729701248000	pending
428	3NLPnfMre3JtEyvMx31FMF938bWJdTvHPLQSBJq8SepGrSTXAW4g	426	3NLfUBWvH4ELw5iQQarbcvpYn9RbyMN6fhakiHg4qHdqyuCeCPrZ	96	95	b4AU0nN48eQ1FVwUyn9SQTr_3sk_CKOK2lH9yLhVAQk=	2	3	430	77	{5,5,5,5,4,5,4,7,7,4,5}	23166005000061388	jx7BCGfG32MHeHBaK3A1q7vvEnzDwcyPPLM3v7hvmAyUrhaUQmE	311	416	416	1	\N	1729701428000	pending
430	3NK8k1umhCVaJswH4bw8CbSFGNQhrMEUcHCptXeqPCB2K1kbkyqG	429	3NKgrDqoZkhuEC94ZtcmA4iHvKbTwXihDfYVSzUZCpGqmr31yXtz	96	95	q4lJWO3amvpuGRTwLkX5SULhBH1aYPsVy5M-qz67GwQ=	2	3	432	77	{5,5,5,5,5,1,4,7,7,4,5}	23166005000061388	jwC2ErudY76LUgaYwRmssYXjdh6GKMoKZsQDVbhk37SQ5Gk4MPi	313	420	420	1	\N	1729702148000	pending
432	3NL94D4vxyZrY7VDsG9C3QE6eKeRnHXpaCtRAnQFbGCP6tPUgW58	431	3NKbnoTbbCEtYhUnuGNZNbszB4qV5KCjMhS7eSoQ7nxh5Pbs1sQK	67	66	8i57xDz80PG6tavahNQ0F7IuRr0Kdz9InaeamwVtzAo=	2	3	434	77	{5,5,5,5,5,3,4,7,7,4,5}	23166005000061388	jxhzz5Smgcbzo1acRT53qVLTosphssNQfA7Azwbc3LYnshwP9rS	315	422	422	1	\N	1729702508000	pending
416	3NLjtsaTifnRKLU8Q4kBZKKScutc3btotEMfLhf7dzBYGA7HrQ5Y	414	3NLoRLyW8QJshSUbmWAV2VAgWRjhrH3DDHHX4ijm12iimB7WhMk3	96	95	znd8HBBSYQPfBjPfFDI5vVXiyQJHk0__doZi_9nYQg8=	2	3	418	77	{5,5,4,5,4,5,4,7,7,4,5}	23166005000061388	jxUJjY63VPb4CUpF2xk2tWQiznJ8VSXkJpMbJCAahUYz4Uc6kBc	301	404	404	1	\N	1729699268000	orphaned
377	3NKNzBsFB2oNekQnZGP7zExTcDrgQ1tcCshsEwKpuwqFSgznAw8y	376	3NKdWqJz3XHGDcXdVnM86qMxLmaJW3cQYtBbv5zWQqffDXBEzrze	96	95	Y3PKvIethRUPDmV6IjVI1LRifgUbzSevJwt-c_Jn0w0=	2	3	379	77	{5,6,4,5,4,5,4,7,6,5,7}	23166005000061388	jxFSyx3NHfAqDFceGx5pS67MYaUA4hTJMqiCurckeb51MgtAwj4	277	369	369	1	\N	1729692968000	orphaned
419	3NLgQ5enAXQeY8RZNwpGTnKCT7caX4sJHdVEuHt5W4w9vxZLiAj6	418	3NLjWLkcKRhBWq2n4drT2ENATbN1a9Px2hxHEaRDne6a3FQrwPmi	67	66	T-xrcrYQkUEdUoRv31s2X_-Cm6Hz9lQgW3dGG5NKQQk=	2	3	421	77	{5,5,5,2,4,5,4,7,7,4,5}	23166005000061388	jxUC8uRXmR91ud3RFkY8YumypdHyqyMJdNKi9xni23r9nMqD63w	304	409	409	1	\N	1729700168000	pending
381	3NLMSRCr18qNpS72cbWz3PnSpvabUmKhkR2V3XiscX39zTX96wwr	380	3NL8rWgoaorWuxM8oEfqZuVKpPzchKwTwJxFZDbfLpeYhGShdhzn	96	95	6ENwr7nlIE4nuK7pnJ49gGA6z8b0UyUl8_DT7XQw7Ao=	2	3	383	77	{5,6,4,5,4,5,4,7,7,2,7}	23166005000061388	jwYUteNBFHVn47cfVQtxxCaroQeZzEFKN7Xtz6ooBWxfo8MG5Lr	280	372	372	1	\N	1729693508000	canonical
421	3NKDGRekLJK9PHadeZnxLBUvY3Q4yvhQiEm6Q8FtZABesXUfZTxE	420	3NKBKUVSzRSAVEiN4mDsFEeqBL2S6VUkeS7gBKBw2XXATiKx8oFA	96	95	ouZhtcKT7p3BvOel_aN0xo6p7rF4DaBlIkjNQA3SJAY=	2	3	423	77	{5,5,5,4,4,5,4,7,7,4,5}	23166005000061388	jxX6RRKDX78tcvZpzVx2tV24yLbTerANDACKj41pCKGQnM7x3rH	306	411	411	1	\N	1729700528000	pending
384	3NKRiCr86grVFn7T8Uwm5b5bM5zSMoz9tBk4Gx2kzLqxoLFZnjhW	382	3NL1KzDcdg2rEoA9arc2aV9BwJzvVKccAFWKNy7HAChBcnSHUjNd	67	66	EmoUno_oKtYZyBb0u39A6Y54D9R9VPGqDbQtv-NskgY=	2	3	386	77	{5,6,4,5,4,5,4,7,7,4,7}	23166005000061388	jwJykBevrfXj3FSSaWEEQsYjgGdVAshRunEfJX4tpcABJ8Kv9VN	282	377	377	1	\N	1729694408000	canonical
423	3NLPADDitP6b1uz7MrsU1pgiieahHt5myrkLuDQJV2BEK2EDJ3Jw	421	3NKDGRekLJK9PHadeZnxLBUvY3Q4yvhQiEm6Q8FtZABesXUfZTxE	96	95	O13dWFnjSc3iDbTOlIx1gJa32VsLviB1ZWxkcgSV_Qs=	2	3	425	77	{5,5,5,5,4,5,4,7,7,4,5}	23166005000061388	jwVeLMpYaZV33H2Dryhy1LTeZWyJbFW2BGYgUrbjcCkyagmKUcg	307	412	412	1	\N	1729700708000	pending
425	3NLr7Wet39PhbLbuvV2yjdbqkie65bVdmtJSD663FXizGFjzq9W9	424	3NKiq1WGFsEvEFzz4ERy8jCwz4PcAd7epaqWujJkhEwZUAJE9JvP	96	95	JEXn3XKKc_TWDGwk7ECt46FZNIgZjtC_XZhs9Eijvwk=	2	3	427	77	{5,5,5,5,2,5,4,7,7,4,5}	23166005000061388	jwZshVg2cvcCPxE7kV7QbBEybVCBV3s2BaAL22GKqYdjyjL3hhK	309	414	414	1	\N	1729701068000	pending
391	3NLsv2ZqewJKRp8DHqwXm4ZiHyiBK31pQLQCwnL8cRrRdg92RncB	388	3NLiZz85fBTg8SCV6MNJ8rdmnfmDxk6UssCjwfojyZT1js64wjAR	67	66	bo_y07MQooLNZvhPuhfVCBaPs9AnIvf4TEIJdK1-lgM=	2	3	393	77	{5,6,4,5,4,5,4,7,7,4,3}	23166005000061388	jxitFquSXA3ZALph5sdWyqEuYdtEsGF223s9RfhKtMDbjW1zbLM	285	380	380	1	\N	1729694948000	canonical
427	3NLccwsEiP2YSySq5NNb8aGfS72ETtG5kqWVr3FAWxbm5tQZaTfD	426	3NLfUBWvH4ELw5iQQarbcvpYn9RbyMN6fhakiHg4qHdqyuCeCPrZ	67	66	OPT2LGOaDU7irpgt8Fy2H86kY-xSqCpsaB3rMOU9CQY=	2	3	429	77	{5,5,5,5,4,5,4,7,7,4,5}	23166005000061388	jx8J9ZtYSmY6BS6ugTgyeKMD99qpRWkursqvzgss536s6qmA75H	311	416	416	1	\N	1729701428000	pending
429	3NKgrDqoZkhuEC94ZtcmA4iHvKbTwXihDfYVSzUZCpGqmr31yXtz	427	3NLccwsEiP2YSySq5NNb8aGfS72ETtG5kqWVr3FAWxbm5tQZaTfD	96	95	QJfhDsnpnoV_DyuHp0fenhLX7t2rD3sKFLNrfczVuQk=	2	3	431	77	{5,5,5,5,5,5,4,7,7,4,5}	23166005000061388	jxaQKcnmEpwpzrWJnzjpoC4d7u8tVBaMzbyYR6Lf3GjmzU4iXVs	312	417	417	1	\N	1729701608000	pending
395	3NLKZwocxgbx1U8TP8Cy7qhwVVsZEeyszmWhdFJcomDyKu3dAS3o	394	3NLPVbYq7kWC1DrjZRo3REXpg98QGKR1Dbeomo3RokbNLu7MPGsJ	96	95	NxKoM9VFd_cCHVuYSQ8GpnU6nGV1gMI-209FiK1loQ0=	2	3	397	77	{1,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jxu3Y8fX8NNbUCKxYBmC5hH4YRiYMMP9ga6Ay6WQoVvVLP6Nyxu	288	385	385	1	\N	1729695848000	orphaned
431	3NKbnoTbbCEtYhUnuGNZNbszB4qV5KCjMhS7eSoQ7nxh5Pbs1sQK	430	3NK8k1umhCVaJswH4bw8CbSFGNQhrMEUcHCptXeqPCB2K1kbkyqG	96	95	wHbKXOMtSoNWhNmcFQMBhUAwI-x9RmeWBvSupj_R9AY=	2	3	433	77	{5,5,5,5,5,2,4,7,7,4,5}	23166005000061388	jxMVZrUJnyuAQD37koz5vL67hJ2j26YTutkbu7Vs73qZNwFGPFg	314	421	421	1	\N	1729702328000	pending
399	3NKHAzxXaUwe1GCNkEiBrRJE6WoqhNwevP8VFsNYtJy94rWbArsn	397	3NK8VQ3LSbvuFYkJyxmf39ZEioS72oYs8TPX42K4M1eBfCDEhagn	96	95	679DCwZOtJJ642TMOu5YqZrL4Se_TaEqOaiR9hEjhA8=	2	3	401	77	{3,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jxwnNXcEUrc85EXk6DHSyLANVEsXyHGymSsyDyBM7MjEpPyK5cu	290	387	387	1	\N	1729696208000	canonical
433	3NKRT7Gz3z916mCVjeubWjTddyLhHRgeGdvtDHHbRSzBKZ8433dV	432	3NL94D4vxyZrY7VDsG9C3QE6eKeRnHXpaCtRAnQFbGCP6tPUgW58	96	95	aro9OPbnsDruUp06iQgAj7faoGE-l-2RyU6r8ERTfQQ=	2	3	435	77	{5,5,5,5,5,4,4,7,7,4,5}	23166005000061388	jxQ6kDCjAoFGsS5EoQmrzzyVibp8b2hjdTzaQicWTLb7CEChTww	316	423	423	1	\N	1729702688000	pending
434	3NKkd6i8HZ5mcyXe6UeDHJqWxKgfpde5wd1pLEdtRYVxgBWEcvba	433	3NKRT7Gz3z916mCVjeubWjTddyLhHRgeGdvtDHHbRSzBKZ8433dV	96	95	Dc5CmsLbaKHUWJm2fHFqVIh8ep-Zk1yARKqvGIxFCw4=	2	3	436	77	{5,5,5,5,5,5,4,7,7,4,5}	23166005000061388	jw8BYmFqRSmtukhbz35BqjyAzoUUrN6vfsK6KhdjF3c3qvUG2ur	317	424	424	1	\N	1729702868000	pending
435	3NL7QiekAoaXtzcEZ58s5YYGD1Gsq2XrgbK6scMcgGDH34raPLfa	434	3NKkd6i8HZ5mcyXe6UeDHJqWxKgfpde5wd1pLEdtRYVxgBWEcvba	67	66	nP6DRj0R5TWP_zMacevy9Tjh-CahsRB0MYoneaskmQQ=	2	3	437	77	{5,5,5,5,5,5,1,7,7,4,5}	23166005000061388	jwnUsikAtHQgkuV687APmLHacLc9GjReW4xHWuThnMpqQ88tfQv	318	427	427	1	\N	1729703408000	pending
403	3NLChsTTJ3XveQBGWF1YGBT66e1UUH3RaMAn4v7h9Y1GeACkFTVM	400	3NKPoYs93yYkiXhzjANC9eAwRm6Zgr9LkpLX7goC9A6St3WKZLYo	96	95	YmOiS5HE75K0gXgNzHhkdhl5r0E-zRFGjgJZJmK63wA=	2	3	405	77	{5,6,4,5,4,5,4,7,7,4,5}	23166005000061388	jxt9j1nxka2xpC9eMJeaugrMzbzhkiMi3HHMZpxNEs13WnPgKrb	292	389	389	1	\N	1729696568000	canonical
436	3NLAWmb5wWm1SzTBE7gMHrTan3cnKnkvUgote3kMqrXESKmzeTXj	435	3NL7QiekAoaXtzcEZ58s5YYGD1Gsq2XrgbK6scMcgGDH34raPLfa	96	95	ZVSBSiF2TA2cY7QG34T9FR8PhCRrxHyrPaR8_qAmsww=	2	3	438	77	{5,5,5,5,5,5,2,7,7,4,5}	23166005000061388	jxfipYLhxcww8SB4dUF8hmELKCfUkjsyx3xcLm2WywCgynfrXbb	319	428	428	1	\N	1729703588000	pending
438	3NLAQ2VGUTpJTD8jueQLa9wPer2eqL4JqfHPbu6Swx56xZZ5TRPf	437	3NKJb1doKYHwpw8YcTuruuTSfHrpf47HpuQUBJ8BFjxvzFQw28vL	67	66	U09o4El6eS1uvVkvDftFw9OW9cGLe7v09cVJY43jMQg=	2	3	440	77	{5,5,5,5,5,5,3,7,7,4,5}	23166005000061388	jxMtwMNpwWEBfVjQUGp3WPMkTA7YkLxBU8P3YpcdGjNDmGzUS1P	320	430	430	1	\N	1729703948000	pending
407	3NKkFJNSBSUQL2zUMaKa96hk5csEnB4nPPJ238R6wPZWSYBqC18M	406	3NLXsdM1Zt5FYgaAx8oKqRvUQgLdUL3yotR8MsgZaJ7ZhfUnHRPf	96	95	NN4qvEXIm5Ui7wxZXYGBin5P0Ofz7qK_5nFzY-2Lego=	2	3	409	77	{5,3,4,5,4,5,4,7,7,4,5}	23166005000061388	jwNwJxLXrwnw8ej53ayiYv2AbReLgCgtb9WdEis22J7utD6guov	295	396	396	1	\N	1729697828000	orphaned
440	3NKqoNTjB6DB9XDdtktP3fs2hh7tzVGjQo3SQGpWBbZUhbjcnJt6	439	3NLXf7FcuPFVsdVvmFktRTuSQXT3SkCWpcr3U34HgDokuEK1xEmE	67	66	-Or72eu0i0-iP3H8Pp3XXHUavGQWmfhIFvR66vzGMgY=	2	3	442	77	{5,5,5,5,5,5,5,7,7,4,5}	23166005000061388	jwf81cPH1LvZ8Ai9sRcdPij65jCb6eVtPUZw3gJ3ouT8MpM5Xzt	322	433	433	1	\N	1729704488000	pending
442	3NLMJRjWHdW8eeAXC6CX5f45CyZLVpeQhekEQGCaRWaz7UMDKMet	441	3NKDKU7npYshYURKMeLbLQHa7iJBrP8opwioxnBh1ATACwQQ9WMs	67	66	2ntH_pyebkNVhjhmnVigDkQzXBE8sstMYFeQSNjsugE=	2	3	444	77	{5,5,5,5,5,5,5,1,7,4,5}	23166005000061388	jxYruTNwuQk2F3dThAU9ELbyNKg3sFQNGDwEX95LYyi3YDWohBD	323	434	434	1	\N	1729704668000	pending
444	3NKWycfGUHbKw5z7hqbezaayvr8yNoRfovHLH2XGqJwUQEbb64NS	442	3NLMJRjWHdW8eeAXC6CX5f45CyZLVpeQhekEQGCaRWaz7UMDKMet	96	95	kf5AUo16HAi9EbbVq5rkGlBDRtxfakd9x3n69awk9gA=	2	3	446	77	{5,5,5,5,5,5,5,2,7,4,5}	23166005000061388	jx6uWk3Eg4PQqbKYZWczdtHVrmugZjqUWRnxpA2srYfTcPajCjo	324	435	435	1	\N	1729704848000	pending
446	3NLyXamPK5Kxz4pt68k4AkeuNggzbfURiVAogUyhbUUi3JLQ8UVc	445	3NL9ybSM6AEVzXXssvGfnF3Uh5RNAx3ANe4reL82iKgJUm3oC9vS	96	95	Ok0cHVbAshglcqPEkzKI3Z2-0Li2D6hhKHiFKTzGOgY=	2	3	448	77	{5,5,5,5,5,5,5,3,7,4,5}	23166005000061388	jwDKagNf9Vv5Dw7Y7NCUqkyU4c4nYxYx4ZwbvDRscZd8VqGervX	325	436	436	1	\N	1729705028000	pending
405	3NLsTMhSQGS9JabPQvTxD4q4nwXjefqZZHzyWWnyx3kAARnHHVyE	404	3NLnMcPE78aDAYU8L1ReTC2K6C9rcqeq5kywH929BP5jp38SSUT2	67	66	RmUn8RBUGLNl2Mm3Eu2tx9vFpIKFuK3k4v48l-BNeAw=	2	3	407	77	{5,2,4,5,4,5,4,7,7,4,5}	23166005000061388	jxCA3h1iieiG77JmH4L67z1h9bWmCkYyuLH1UP5jbgok31UmNxF	294	395	395	1	\N	1729697648000	orphaned
437	3NKJb1doKYHwpw8YcTuruuTSfHrpf47HpuQUBJ8BFjxvzFQw28vL	435	3NL7QiekAoaXtzcEZ58s5YYGD1Gsq2XrgbK6scMcgGDH34raPLfa	67	66	vRoJn-s1gBw7j1HddDVUQyiDeTRN1kUiJBJK_saj_As=	2	3	439	77	{5,5,5,5,5,5,2,7,7,4,5}	23166005000061388	jx68usPtnXxEkmfHT3Drh4bpyABHStnFUxLTAEBHnneakFUNarm	319	428	428	1	\N	1729703588000	pending
439	3NLXf7FcuPFVsdVvmFktRTuSQXT3SkCWpcr3U34HgDokuEK1xEmE	438	3NLAQ2VGUTpJTD8jueQLa9wPer2eqL4JqfHPbu6Swx56xZZ5TRPf	96	95	8zR8XdA-PsVzAjKyaDkUBfhtzVJYKgxlMY-DTSjG_QA=	2	3	441	77	{5,5,5,5,5,5,4,7,7,4,5}	23166005000061388	jwo58UQ4x7LkqvfcUk8CyZwG3maVquAc8b6MzFB1wWHB9rmVkU1	321	432	432	1	\N	1729704308000	pending
441	3NKDKU7npYshYURKMeLbLQHa7iJBrP8opwioxnBh1ATACwQQ9WMs	439	3NLXf7FcuPFVsdVvmFktRTuSQXT3SkCWpcr3U34HgDokuEK1xEmE	96	95	KR6I8RXwQu7F13EupSFQzAOqd2qpEz8fSe-ZwgJ_IQU=	2	3	443	77	{5,5,5,5,5,5,5,7,7,4,5}	23166005000061388	jwce7A9cUhWwpqDgkG7dy3o8E8fPMqc5FKHimWbu8vSNRjYRjkQ	322	433	433	1	\N	1729704488000	pending
443	3NLG2R45PPBmTxnwhuUQ9nN2x192vMCtGuSnTCwUEcDCwVeC37n4	441	3NKDKU7npYshYURKMeLbLQHa7iJBrP8opwioxnBh1ATACwQQ9WMs	96	95	Zx_eRpoTKjDJy6mGkrf0AqPQA9n-z9ygBpDiMGoOLQo=	2	3	445	77	{5,5,5,5,5,5,5,1,7,4,5}	23166005000061388	jxmVk8GqWAdaQMsPuc5n8dKdQiC9umRqDcoZt7wQjEkMmj97x6k	323	434	434	1	\N	1729704668000	pending
445	3NL9ybSM6AEVzXXssvGfnF3Uh5RNAx3ANe4reL82iKgJUm3oC9vS	442	3NLMJRjWHdW8eeAXC6CX5f45CyZLVpeQhekEQGCaRWaz7UMDKMet	67	66	7unEAWZeBMNFOWMUMuirvhLYnmLCFG3BVDbAuf57yAE=	2	3	447	77	{5,5,5,5,5,5,5,2,7,4,5}	23166005000061388	jxXQ9o9RRTp6TTHPgj1PbQM192Fiqf6KCVKY2mk9vmhe9Ztoz3o	324	435	435	1	\N	1729704848000	pending
447	3NLaMamCKzFQoWicxgKTm4UT4Fp5Bn9JVuk8d9i9Rccis7YJHuBS	446	3NLyXamPK5Kxz4pt68k4AkeuNggzbfURiVAogUyhbUUi3JLQ8UVc	67	66	_poWWf1UMtqv67FZPk15U1gc6l1IKuNddHuK2iMMvgk=	2	3	449	77	{5,5,5,5,5,5,5,4,7,4,5}	23166005000061388	jx2Eg8LX6PTgaFEJhkVc8DRckfSj5E6SS9esjHmpn1B5dgB93Cc	326	437	437	1	\N	1729705208000	pending
417	3NLPSLmC5xmKNXugX5i3hRWrb4U9ZZHJLbxsYD5r7y8tFBgfAiyP	415	3NLu99z9L4eHA6gfxH52uZzJRwqfuAq1NuhUQWkpizpnKgnySQks	67	66	bOvXNhbhLj5gKEv-U4nlcredHO8ivOLOoCT9YpHwng4=	2	3	419	77	{5,5,5,5,4,5,4,7,7,4,5}	23166005000061388	jwC22nkzp5tx4cQFKv7Gi6tZQjbt8C8FSicB3Ag2hys9smfVd8f	302	405	405	1	\N	1729699448000	canonical
\.


--
-- Data for Name: blocks_internal_commands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.blocks_internal_commands (block_id, internal_command_id, sequence_no, secondary_sequence_no, status, failure_reason) FROM stdin;
3	1	2	0	applied	\N
3	2	3	0	applied	\N
4	1	11	0	applied	\N
4	3	12	0	applied	\N
5	4	12	0	applied	\N
5	5	13	0	applied	\N
6	1	12	0	applied	\N
6	6	13	0	applied	\N
7	4	12	0	applied	\N
7	5	13	0	applied	\N
8	4	12	0	applied	\N
8	5	13	0	applied	\N
9	1	12	0	applied	\N
9	6	13	0	applied	\N
10	4	12	0	applied	\N
10	5	13	0	applied	\N
11	4	38	0	applied	\N
11	7	39	0	applied	\N
12	1	11	0	applied	\N
12	3	12	0	applied	\N
13	4	11	0	applied	\N
13	8	12	0	applied	\N
14	9	1	0	applied	\N
14	1	13	0	applied	\N
14	3	14	0	applied	\N
15	4	13	0	applied	\N
15	10	14	0	applied	\N
16	1	13	0	applied	\N
16	11	14	0	applied	\N
17	4	12	0	applied	\N
17	5	13	0	applied	\N
18	4	12	0	applied	\N
18	5	13	0	applied	\N
19	4	12	0	applied	\N
19	5	13	0	applied	\N
20	1	12	0	applied	\N
20	6	13	0	applied	\N
21	4	13	0	applied	\N
21	10	14	0	applied	\N
22	1	13	0	applied	\N
22	11	14	0	applied	\N
23	4	24	0	applied	\N
23	12	25	0	applied	\N
24	1	24	0	applied	\N
24	13	25	0	applied	\N
25	2	2	0	applied	\N
25	1	13	0	applied	\N
25	14	14	0	applied	\N
26	1	25	0	applied	\N
26	15	26	0	applied	\N
27	4	25	0	applied	\N
27	16	26	0	applied	\N
28	1	12	0	applied	\N
28	6	13	0	applied	\N
29	1	12	0	applied	\N
29	6	13	0	applied	\N
30	4	12	0	applied	\N
30	5	13	0	applied	\N
31	1	12	0	applied	\N
31	6	13	0	applied	\N
32	4	12	0	applied	\N
32	5	13	0	applied	\N
33	1	12	0	applied	\N
33	6	13	0	applied	\N
34	4	12	0	applied	\N
34	5	13	0	applied	\N
35	17	18	0	applied	\N
35	18	26	0	applied	\N
35	19	26	0	applied	\N
35	20	27	0	applied	\N
35	21	27	1	applied	\N
36	22	18	0	applied	\N
36	18	26	0	applied	\N
36	23	26	0	applied	\N
36	24	27	0	applied	\N
36	21	27	1	applied	\N
37	4	12	0	applied	\N
37	5	13	0	applied	\N
38	1	12	0	applied	\N
38	6	13	0	applied	\N
39	1	11	0	applied	\N
39	3	12	0	applied	\N
40	4	7	0	applied	\N
40	25	8	0	applied	\N
41	1	7	0	applied	\N
41	26	8	0	applied	\N
42	1	7	0	applied	\N
42	26	8	0	applied	\N
43	1	7	0	applied	\N
43	26	8	0	applied	\N
44	1	23	0	applied	\N
44	27	24	0	applied	\N
45	4	11	0	applied	\N
45	8	12	0	applied	\N
46	5	12	0	applied	\N
46	18	14	0	applied	\N
46	23	14	0	applied	\N
46	28	15	0	applied	\N
46	21	15	1	applied	\N
47	6	12	0	applied	\N
47	18	14	0	applied	\N
47	19	14	0	applied	\N
47	29	15	0	applied	\N
47	21	15	1	applied	\N
48	4	11	0	applied	\N
48	8	12	0	applied	\N
49	4	12	0	applied	\N
49	5	13	0	applied	\N
50	1	12	0	applied	\N
50	6	13	0	applied	\N
51	4	36	0	applied	\N
51	30	37	0	applied	\N
52	1	36	0	applied	\N
52	31	37	0	applied	\N
53	1	24	0	applied	\N
53	13	25	0	applied	\N
54	32	33	0	applied	\N
54	18	38	0	applied	\N
54	19	38	0	applied	\N
54	33	39	0	applied	\N
54	21	39	1	applied	\N
55	4	12	0	applied	\N
55	5	13	0	applied	\N
56	1	12	0	applied	\N
56	6	13	0	applied	\N
57	1	12	0	applied	\N
57	6	13	0	applied	\N
58	1	11	0	applied	\N
58	3	12	0	applied	\N
59	1	12	0	applied	\N
59	6	13	0	applied	\N
60	4	12	0	applied	\N
60	5	13	0	applied	\N
61	1	37	0	applied	\N
61	34	38	0	applied	\N
62	18	24	0	applied	\N
62	23	24	0	applied	\N
62	35	25	0	applied	\N
62	36	25	1	applied	\N
63	1	12	0	applied	\N
63	6	13	0	applied	\N
64	4	12	0	applied	\N
64	5	13	0	applied	\N
65	4	11	0	applied	\N
65	8	12	0	applied	\N
66	1	11	0	applied	\N
66	3	12	0	applied	\N
67	1	24	0	applied	\N
67	13	25	0	applied	\N
68	1	12	0	applied	\N
68	6	13	0	applied	\N
69	4	11	0	applied	\N
69	8	12	0	applied	\N
70	25	7	0	applied	\N
70	18	13	0	applied	\N
70	23	13	0	applied	\N
70	37	14	0	applied	\N
70	36	14	1	applied	\N
72	1	12	0	applied	\N
72	6	13	0	applied	\N
74	4	12	0	applied	\N
74	5	13	0	applied	\N
76	1	11	0	applied	\N
76	3	12	0	applied	\N
71	26	7	0	applied	\N
71	18	13	0	applied	\N
71	19	13	0	applied	\N
71	38	14	0	applied	\N
71	36	14	1	applied	\N
73	4	12	0	applied	\N
73	5	13	0	applied	\N
75	1	12	0	applied	\N
75	6	13	0	applied	\N
77	1	12	0	applied	\N
77	6	13	0	applied	\N
78	4	12	0	applied	\N
78	5	13	0	applied	\N
79	1	12	0	applied	\N
79	6	13	0	applied	\N
80	1	36	0	applied	\N
80	31	37	0	applied	\N
81	18	12	0	applied	\N
81	23	12	0	applied	\N
81	39	13	0	applied	\N
81	36	13	1	applied	\N
82	18	12	0	applied	\N
82	19	12	0	applied	\N
82	40	13	0	applied	\N
82	36	13	1	applied	\N
83	4	12	0	applied	\N
83	5	13	0	applied	\N
84	1	11	0	applied	\N
84	3	12	0	applied	\N
85	4	11	0	applied	\N
85	8	12	0	applied	\N
86	1	36	0	applied	\N
86	31	37	0	applied	\N
87	4	36	0	applied	\N
87	30	37	0	applied	\N
88	4	11	0	applied	\N
88	8	12	0	applied	\N
89	4	12	0	applied	\N
89	5	13	0	applied	\N
90	1	12	0	applied	\N
90	6	13	0	applied	\N
91	4	12	0	applied	\N
91	5	13	0	applied	\N
92	26	7	0	applied	\N
92	18	13	0	applied	\N
92	19	13	0	applied	\N
92	41	14	0	applied	\N
92	42	14	1	applied	\N
93	25	7	0	applied	\N
93	18	13	0	applied	\N
93	23	13	0	applied	\N
93	43	14	0	applied	\N
93	42	14	1	applied	\N
94	1	23	0	applied	\N
94	27	24	0	applied	\N
95	1	12	0	applied	\N
95	6	13	0	applied	\N
96	4	23	0	applied	\N
96	44	24	0	applied	\N
97	4	12	0	applied	\N
97	5	13	0	applied	\N
98	1	12	0	applied	\N
98	6	13	0	applied	\N
99	4	11	0	applied	\N
99	8	12	0	applied	\N
100	1	11	0	applied	\N
100	3	12	0	applied	\N
101	4	12	0	applied	\N
101	5	13	0	applied	\N
102	1	12	0	applied	\N
102	6	13	0	applied	\N
103	9	1	0	applied	\N
103	18	13	0	applied	\N
103	19	13	0	applied	\N
103	45	14	0	applied	\N
103	42	14	1	applied	\N
104	46	1	0	applied	\N
104	18	13	0	applied	\N
104	23	13	0	applied	\N
104	47	14	0	applied	\N
104	42	14	1	applied	\N
105	4	12	0	applied	\N
105	5	13	0	applied	\N
106	1	35	0	applied	\N
106	48	36	0	applied	\N
107	4	35	0	applied	\N
107	49	36	0	applied	\N
108	4	12	0	applied	\N
108	5	13	0	applied	\N
109	1	12	0	applied	\N
109	6	13	0	applied	\N
110	1	24	0	applied	\N
110	13	25	0	applied	\N
111	4	24	0	applied	\N
111	12	25	0	applied	\N
112	4	11	0	applied	\N
112	8	12	0	applied	\N
113	50	10	0	applied	\N
113	18	13	0	applied	\N
113	23	13	0	applied	\N
113	51	14	0	applied	\N
113	42	14	1	applied	\N
114	4	12	0	applied	\N
114	5	13	0	applied	\N
115	1	12	0	applied	\N
115	6	13	0	applied	\N
116	1	11	0	applied	\N
116	3	12	0	applied	\N
117	1	12	0	applied	\N
117	6	13	0	applied	\N
118	4	12	0	applied	\N
118	5	13	0	applied	\N
119	4	12	0	applied	\N
119	5	13	0	applied	\N
120	4	11	0	applied	\N
120	8	12	0	applied	\N
121	1	11	0	applied	\N
121	3	12	0	applied	\N
122	4	12	0	applied	\N
122	5	13	0	applied	\N
123	1	12	0	applied	\N
123	6	13	0	applied	\N
124	1	12	0	applied	\N
124	6	13	0	applied	\N
125	4	12	0	applied	\N
125	5	13	0	applied	\N
126	4	23	0	applied	\N
126	44	24	0	applied	\N
127	1	23	0	applied	\N
127	27	24	0	applied	\N
128	52	2	0	applied	\N
128	18	13	0	applied	\N
128	23	13	0	applied	\N
128	53	14	0	applied	\N
128	54	14	1	applied	\N
129	1	12	0	applied	\N
129	6	13	0	applied	\N
130	4	12	0	applied	\N
130	5	13	0	applied	\N
131	1	11	0	applied	\N
131	3	12	0	applied	\N
132	4	11	0	applied	\N
132	8	12	0	applied	\N
133	1	12	0	applied	\N
133	6	13	0	applied	\N
134	4	12	0	applied	\N
134	5	13	0	applied	\N
135	4	12	0	applied	\N
135	5	13	0	applied	\N
136	1	12	0	applied	\N
136	6	13	0	applied	\N
137	4	11	0	applied	\N
137	8	12	0	applied	\N
138	1	12	0	applied	\N
138	6	13	0	applied	\N
139	4	12	0	applied	\N
139	5	13	0	applied	\N
140	1	11	0	applied	\N
140	3	12	0	applied	\N
141	4	12	0	applied	\N
141	5	13	0	applied	\N
142	55	6	0	applied	\N
142	18	13	0	applied	\N
142	23	13	0	applied	\N
142	56	14	0	applied	\N
142	54	14	1	applied	\N
143	1	24	0	applied	\N
143	13	25	0	applied	\N
144	1	12	0	applied	\N
144	6	13	0	applied	\N
145	1	23	0	applied	\N
145	27	24	0	applied	\N
146	1	12	0	applied	\N
146	6	13	0	applied	\N
147	1	12	0	applied	\N
147	6	13	0	applied	\N
148	57	26	0	applied	\N
148	18	36	0	applied	\N
148	19	36	0	applied	\N
148	58	37	0	applied	\N
148	59	37	1	applied	\N
149	60	26	0	applied	\N
149	18	36	0	applied	\N
149	23	36	0	applied	\N
149	61	37	0	applied	\N
149	59	37	1	applied	\N
150	18	12	0	applied	\N
150	23	12	0	applied	\N
150	62	13	0	applied	\N
150	63	13	1	applied	\N
151	4	35	0	applied	\N
151	49	36	0	applied	\N
152	4	12	0	applied	\N
152	5	13	0	applied	\N
153	1	12	0	applied	\N
153	6	13	0	applied	\N
154	4	11	0	applied	\N
154	8	12	0	applied	\N
155	1	11	0	applied	\N
155	3	12	0	applied	\N
156	4	12	0	applied	\N
156	5	13	0	applied	\N
157	1	12	0	applied	\N
157	6	13	0	applied	\N
158	1	23	0	applied	\N
158	27	24	0	applied	\N
159	4	23	0	applied	\N
159	44	24	0	applied	\N
160	18	24	0	applied	\N
160	23	24	0	applied	\N
160	64	25	0	applied	\N
160	65	25	1	applied	\N
161	4	24	0	applied	\N
161	12	25	0	applied	\N
162	4	12	0	applied	\N
162	5	13	0	applied	\N
163	4	11	0	applied	\N
163	8	12	0	applied	\N
164	4	12	0	applied	\N
164	5	13	0	applied	\N
165	1	12	0	applied	\N
165	6	13	0	applied	\N
166	66	34	0	applied	\N
166	18	47	0	applied	\N
166	23	47	0	applied	\N
166	67	48	0	applied	\N
166	68	48	1	applied	\N
167	69	34	0	applied	\N
167	18	47	0	applied	\N
167	19	47	0	applied	\N
167	70	48	0	applied	\N
167	68	48	1	applied	\N
168	18	11	0	applied	\N
168	19	11	0	applied	\N
168	71	12	0	applied	\N
168	72	12	1	applied	\N
169	4	11	0	applied	\N
169	8	12	0	applied	\N
170	1	12	0	applied	\N
170	6	13	0	applied	\N
171	4	12	0	applied	\N
171	5	13	0	applied	\N
172	4	12	0	applied	\N
172	5	13	0	applied	\N
173	1	11	0	applied	\N
173	3	12	0	applied	\N
174	4	12	0	applied	\N
174	5	13	0	applied	\N
175	1	12	0	applied	\N
175	6	13	0	applied	\N
176	4	12	0	applied	\N
176	5	13	0	applied	\N
177	73	4	0	applied	\N
177	18	13	0	applied	\N
177	19	13	0	applied	\N
177	74	14	0	applied	\N
177	75	14	1	applied	\N
178	18	11	0	applied	\N
178	19	11	0	applied	\N
178	3	12	0	applied	\N
179	1	12	0	applied	\N
179	6	13	0	applied	\N
180	1	11	0	applied	\N
180	3	12	0	applied	\N
181	4	9	0	applied	\N
181	76	10	0	applied	\N
182	1	9	0	applied	\N
182	77	10	0	applied	\N
183	4	7	0	applied	\N
183	25	8	0	applied	\N
184	1	6	0	applied	\N
184	78	7	0	applied	\N
185	4	5	0	applied	\N
185	79	6	0	applied	\N
186	4	4	0	applied	\N
186	80	5	0	applied	\N
187	1	3	0	applied	\N
187	81	4	0	applied	\N
188	4	2	0	applied	\N
188	52	3	0	applied	\N
189	1	2	0	applied	\N
189	2	3	0	applied	\N
190	4	2	0	applied	\N
190	52	3	0	applied	\N
191	1	2	0	applied	\N
191	2	3	0	applied	\N
192	1	2	0	applied	\N
192	2	3	0	applied	\N
193	4	1	0	applied	\N
193	46	2	0	applied	\N
194	4	1	0	applied	\N
194	46	2	0	applied	\N
195	1	1	0	applied	\N
195	9	2	0	applied	\N
196	1	1	0	applied	\N
196	9	2	0	applied	\N
197	4	1	0	applied	\N
197	46	2	0	applied	\N
198	1	1	0	applied	\N
198	9	2	0	applied	\N
199	1	0	0	applied	\N
200	1	0	0	applied	\N
201	1	0	0	applied	\N
202	4	0	0	applied	\N
203	1	0	0	applied	\N
204	4	0	0	applied	\N
205	4	0	0	applied	\N
206	4	0	0	applied	\N
207	1	0	0	applied	\N
208	4	0	0	applied	\N
209	4	0	0	applied	\N
210	18	0	0	applied	\N
210	23	0	0	applied	\N
211	18	0	0	applied	\N
211	19	0	0	applied	\N
213	18	0	0	applied	\N
213	19	0	0	applied	\N
215	18	0	0	applied	\N
215	19	0	0	applied	\N
217	18	0	0	applied	\N
217	19	0	0	applied	\N
219	18	0	0	applied	\N
219	23	0	0	applied	\N
212	18	0	0	applied	\N
212	23	0	0	applied	\N
214	18	0	0	applied	\N
214	19	0	0	applied	\N
216	18	0	0	applied	\N
216	23	0	0	applied	\N
218	18	0	0	applied	\N
218	19	0	0	applied	\N
220	18	0	0	applied	\N
220	19	0	0	applied	\N
221	18	0	0	applied	\N
221	19	0	0	applied	\N
222	18	0	0	applied	\N
222	19	0	0	applied	\N
223	18	0	0	applied	\N
223	23	0	0	applied	\N
224	18	0	0	applied	\N
224	19	0	0	applied	\N
225	18	0	0	applied	\N
225	19	0	0	applied	\N
226	18	0	0	applied	\N
226	23	0	0	applied	\N
227	18	0	0	applied	\N
227	23	0	0	applied	\N
228	18	0	0	applied	\N
228	19	0	0	applied	\N
229	18	0	0	applied	\N
229	23	0	0	applied	\N
230	18	0	0	applied	\N
230	19	0	0	applied	\N
231	18	0	0	applied	\N
231	19	0	0	applied	\N
232	18	0	0	applied	\N
232	23	0	0	applied	\N
233	18	0	0	applied	\N
233	19	0	0	applied	\N
234	18	0	0	applied	\N
234	23	0	0	applied	\N
235	18	0	0	applied	\N
235	19	0	0	applied	\N
236	18	0	0	applied	\N
236	23	0	0	applied	\N
237	18	0	0	applied	\N
237	19	0	0	applied	\N
238	18	0	0	applied	\N
238	19	0	0	applied	\N
239	18	0	0	applied	\N
239	23	0	0	applied	\N
240	18	0	0	applied	\N
240	19	0	0	applied	\N
241	18	0	0	applied	\N
241	23	0	0	applied	\N
242	18	0	0	applied	\N
242	19	0	0	applied	\N
243	18	0	0	applied	\N
243	19	0	0	applied	\N
244	18	0	0	applied	\N
244	19	0	0	applied	\N
245	18	0	0	applied	\N
245	23	0	0	applied	\N
246	18	0	0	applied	\N
246	19	0	0	applied	\N
247	18	0	0	applied	\N
247	23	0	0	applied	\N
248	18	0	0	applied	\N
248	19	0	0	applied	\N
249	18	0	0	applied	\N
249	23	0	0	applied	\N
250	18	0	0	applied	\N
250	23	0	0	applied	\N
251	18	0	0	applied	\N
251	23	0	0	applied	\N
252	18	0	0	applied	\N
252	23	0	0	applied	\N
253	18	0	0	applied	\N
253	19	0	0	applied	\N
254	18	0	0	applied	\N
254	23	0	0	applied	\N
255	18	0	0	applied	\N
255	23	0	0	applied	\N
256	18	0	0	applied	\N
256	23	0	0	applied	\N
257	18	0	0	applied	\N
257	19	0	0	applied	\N
258	18	0	0	applied	\N
258	23	0	0	applied	\N
259	18	0	0	applied	\N
259	19	0	0	applied	\N
260	18	0	0	applied	\N
260	23	0	0	applied	\N
261	18	0	0	applied	\N
261	19	0	0	applied	\N
262	18	0	0	applied	\N
262	23	0	0	applied	\N
263	18	0	0	applied	\N
263	19	0	0	applied	\N
264	18	0	0	applied	\N
264	23	0	0	applied	\N
265	18	0	0	applied	\N
265	19	0	0	applied	\N
266	18	0	0	applied	\N
266	23	0	0	applied	\N
267	18	0	0	applied	\N
267	23	0	0	applied	\N
268	18	0	0	applied	\N
268	23	0	0	applied	\N
269	18	0	0	applied	\N
269	19	0	0	applied	\N
270	18	0	0	applied	\N
270	23	0	0	applied	\N
271	18	0	0	applied	\N
271	23	0	0	applied	\N
272	18	0	0	applied	\N
272	19	0	0	applied	\N
273	18	0	0	applied	\N
273	23	0	0	applied	\N
274	18	0	0	applied	\N
274	19	0	0	applied	\N
275	18	0	0	applied	\N
275	23	0	0	applied	\N
276	18	0	0	applied	\N
276	19	0	0	applied	\N
277	18	0	0	applied	\N
277	23	0	0	applied	\N
278	18	0	0	applied	\N
278	19	0	0	applied	\N
279	18	0	0	applied	\N
279	23	0	0	applied	\N
280	18	0	0	applied	\N
280	19	0	0	applied	\N
281	18	0	0	applied	\N
281	19	0	0	applied	\N
282	18	0	0	applied	\N
282	23	0	0	applied	\N
283	18	0	0	applied	\N
283	23	0	0	applied	\N
284	18	0	0	applied	\N
284	19	0	0	applied	\N
285	18	0	0	applied	\N
285	23	0	0	applied	\N
286	18	0	0	applied	\N
286	23	0	0	applied	\N
287	18	0	0	applied	\N
287	23	0	0	applied	\N
288	18	0	0	applied	\N
288	19	0	0	applied	\N
289	18	0	0	applied	\N
289	23	0	0	applied	\N
290	18	0	0	applied	\N
290	23	0	0	applied	\N
291	18	0	0	applied	\N
291	23	0	0	applied	\N
292	18	0	0	applied	\N
292	19	0	0	applied	\N
293	18	0	0	applied	\N
293	23	0	0	applied	\N
294	18	0	0	applied	\N
294	23	0	0	applied	\N
296	18	0	0	applied	\N
296	23	0	0	applied	\N
298	18	0	0	applied	\N
298	19	0	0	applied	\N
300	18	0	0	applied	\N
300	23	0	0	applied	\N
302	18	0	0	applied	\N
302	23	0	0	applied	\N
304	18	0	0	applied	\N
304	19	0	0	applied	\N
306	18	0	0	applied	\N
306	19	0	0	applied	\N
308	18	0	0	applied	\N
308	19	0	0	applied	\N
310	18	0	0	applied	\N
310	23	0	0	applied	\N
312	18	0	0	applied	\N
312	19	0	0	applied	\N
314	18	0	0	applied	\N
314	19	0	0	applied	\N
316	18	0	0	applied	\N
316	19	0	0	applied	\N
318	18	0	0	applied	\N
318	23	0	0	applied	\N
320	18	0	0	applied	\N
320	23	0	0	applied	\N
322	18	0	0	applied	\N
322	19	0	0	applied	\N
324	18	0	0	applied	\N
324	23	0	0	applied	\N
295	18	0	0	applied	\N
295	19	0	0	applied	\N
297	18	0	0	applied	\N
297	19	0	0	applied	\N
299	18	0	0	applied	\N
299	19	0	0	applied	\N
301	18	0	0	applied	\N
301	19	0	0	applied	\N
303	18	0	0	applied	\N
303	19	0	0	applied	\N
305	18	0	0	applied	\N
305	23	0	0	applied	\N
307	18	0	0	applied	\N
307	23	0	0	applied	\N
309	18	0	0	applied	\N
309	23	0	0	applied	\N
311	18	0	0	applied	\N
311	19	0	0	applied	\N
313	18	0	0	applied	\N
313	23	0	0	applied	\N
315	18	0	0	applied	\N
315	19	0	0	applied	\N
317	18	0	0	applied	\N
317	19	0	0	applied	\N
319	18	0	0	applied	\N
319	23	0	0	applied	\N
321	18	0	0	applied	\N
321	19	0	0	applied	\N
323	18	0	0	applied	\N
323	19	0	0	applied	\N
325	18	0	0	applied	\N
325	19	0	0	applied	\N
326	18	0	0	applied	\N
326	19	0	0	applied	\N
327	18	0	0	applied	\N
327	23	0	0	applied	\N
328	18	0	0	applied	\N
328	23	0	0	applied	\N
329	18	0	0	applied	\N
329	19	0	0	applied	\N
330	18	0	0	applied	\N
330	23	0	0	applied	\N
331	18	0	0	applied	\N
331	19	0	0	applied	\N
332	18	0	0	applied	\N
332	19	0	0	applied	\N
333	18	0	0	applied	\N
333	19	0	0	applied	\N
334	18	0	0	applied	\N
334	23	0	0	applied	\N
335	18	0	0	applied	\N
335	19	0	0	applied	\N
336	18	0	0	applied	\N
336	19	0	0	applied	\N
337	18	0	0	applied	\N
337	19	0	0	applied	\N
338	18	0	0	applied	\N
338	23	0	0	applied	\N
339	18	0	0	applied	\N
339	19	0	0	applied	\N
340	18	0	0	applied	\N
340	19	0	0	applied	\N
341	18	0	0	applied	\N
341	23	0	0	applied	\N
342	18	0	0	applied	\N
342	19	0	0	applied	\N
343	18	0	0	applied	\N
343	23	0	0	applied	\N
344	18	0	0	applied	\N
344	19	0	0	applied	\N
345	18	0	0	applied	\N
345	23	0	0	applied	\N
346	18	0	0	applied	\N
346	19	0	0	applied	\N
347	18	0	0	applied	\N
347	23	0	0	applied	\N
348	18	0	0	applied	\N
348	23	0	0	applied	\N
349	18	0	0	applied	\N
349	19	0	0	applied	\N
350	18	0	0	applied	\N
350	23	0	0	applied	\N
351	18	0	0	applied	\N
351	19	0	0	applied	\N
352	18	0	0	applied	\N
352	23	0	0	applied	\N
353	18	0	0	applied	\N
353	19	0	0	applied	\N
354	18	0	0	applied	\N
354	23	0	0	applied	\N
355	18	0	0	applied	\N
355	19	0	0	applied	\N
356	18	0	0	applied	\N
356	19	0	0	applied	\N
357	18	0	0	applied	\N
357	19	0	0	applied	\N
358	18	0	0	applied	\N
358	23	0	0	applied	\N
359	18	0	0	applied	\N
359	19	0	0	applied	\N
360	18	0	0	applied	\N
360	23	0	0	applied	\N
361	18	0	0	applied	\N
361	23	0	0	applied	\N
362	18	0	0	applied	\N
362	19	0	0	applied	\N
363	18	0	0	applied	\N
363	19	0	0	applied	\N
364	18	0	0	applied	\N
364	23	0	0	applied	\N
365	18	0	0	applied	\N
365	23	0	0	applied	\N
366	18	0	0	applied	\N
366	19	0	0	applied	\N
367	18	0	0	applied	\N
367	19	0	0	applied	\N
368	18	0	0	applied	\N
368	19	0	0	applied	\N
369	18	0	0	applied	\N
369	23	0	0	applied	\N
370	18	0	0	applied	\N
370	23	0	0	applied	\N
371	18	0	0	applied	\N
371	19	0	0	applied	\N
372	18	0	0	applied	\N
372	23	0	0	applied	\N
373	18	0	0	applied	\N
373	23	0	0	applied	\N
374	18	0	0	applied	\N
374	19	0	0	applied	\N
375	18	0	0	applied	\N
375	23	0	0	applied	\N
376	18	0	0	applied	\N
376	23	0	0	applied	\N
377	18	0	0	applied	\N
377	19	0	0	applied	\N
378	18	0	0	applied	\N
378	23	0	0	applied	\N
379	18	0	0	applied	\N
379	19	0	0	applied	\N
380	1	0	0	applied	\N
381	1	0	0	applied	\N
382	18	0	0	applied	\N
382	19	0	0	applied	\N
383	18	0	0	applied	\N
383	19	0	0	applied	\N
384	18	0	0	applied	\N
384	23	0	0	applied	\N
385	18	0	0	applied	\N
385	19	0	0	applied	\N
386	18	0	0	applied	\N
386	23	0	0	applied	\N
387	18	0	0	applied	\N
387	82	0	0	applied	\N
388	18	0	0	applied	\N
388	23	0	0	applied	\N
389	18	0	0	applied	\N
389	19	0	0	applied	\N
391	18	0	0	applied	\N
391	23	0	0	applied	\N
393	18	0	0	applied	\N
393	19	0	0	applied	\N
395	18	0	0	applied	\N
395	19	0	0	applied	\N
397	18	0	0	applied	\N
397	23	0	0	applied	\N
399	18	0	0	applied	\N
399	19	0	0	applied	\N
401	18	0	0	applied	\N
401	19	0	0	applied	\N
403	18	0	0	applied	\N
403	19	0	0	applied	\N
405	18	0	0	applied	\N
405	23	0	0	applied	\N
407	18	0	0	applied	\N
407	19	0	0	applied	\N
409	18	0	0	applied	\N
409	23	0	0	applied	\N
411	18	0	0	applied	\N
411	19	0	0	applied	\N
413	18	0	0	applied	\N
413	19	0	0	applied	\N
415	18	0	0	applied	\N
415	23	0	0	applied	\N
417	18	0	0	applied	\N
417	23	0	0	applied	\N
419	18	0	0	applied	\N
419	23	0	0	applied	\N
421	18	0	0	applied	\N
421	19	0	0	applied	\N
423	18	0	0	applied	\N
423	19	0	0	applied	\N
425	18	0	0	applied	\N
425	19	0	0	applied	\N
427	18	0	0	applied	\N
427	23	0	0	applied	\N
429	18	0	0	applied	\N
429	19	0	0	applied	\N
431	18	0	0	applied	\N
431	19	0	0	applied	\N
433	18	0	0	applied	\N
433	19	0	0	applied	\N
435	18	0	0	applied	\N
435	23	0	0	applied	\N
437	18	0	0	applied	\N
437	23	0	0	applied	\N
439	18	0	0	applied	\N
439	19	0	0	applied	\N
441	18	0	0	applied	\N
441	19	0	0	applied	\N
443	18	0	0	applied	\N
443	19	0	0	applied	\N
445	18	0	0	applied	\N
445	23	0	0	applied	\N
447	18	0	0	applied	\N
447	23	0	0	applied	\N
390	18	0	0	applied	\N
390	19	0	0	applied	\N
392	18	0	0	applied	\N
392	23	0	0	applied	\N
394	18	0	0	applied	\N
394	23	0	0	applied	\N
396	18	0	0	applied	\N
396	23	0	0	applied	\N
398	18	0	0	applied	\N
398	19	0	0	applied	\N
400	18	0	0	applied	\N
400	23	0	0	applied	\N
402	18	0	0	applied	\N
402	23	0	0	applied	\N
404	18	0	0	applied	\N
404	23	0	0	applied	\N
406	18	0	0	applied	\N
406	19	0	0	applied	\N
408	18	0	0	applied	\N
408	23	0	0	applied	\N
410	18	0	0	applied	\N
410	19	0	0	applied	\N
412	18	0	0	applied	\N
412	19	0	0	applied	\N
414	18	0	0	applied	\N
414	23	0	0	applied	\N
416	18	0	0	applied	\N
416	19	0	0	applied	\N
418	18	0	0	applied	\N
418	23	0	0	applied	\N
420	18	0	0	applied	\N
420	19	0	0	applied	\N
422	18	0	0	applied	\N
422	23	0	0	applied	\N
424	18	0	0	applied	\N
424	23	0	0	applied	\N
426	18	0	0	applied	\N
426	19	0	0	applied	\N
428	18	0	0	applied	\N
428	19	0	0	applied	\N
430	18	0	0	applied	\N
430	19	0	0	applied	\N
432	18	0	0	applied	\N
432	23	0	0	applied	\N
434	18	0	0	applied	\N
434	19	0	0	applied	\N
436	18	0	0	applied	\N
436	19	0	0	applied	\N
438	18	0	0	applied	\N
438	23	0	0	applied	\N
440	18	0	0	applied	\N
440	23	0	0	applied	\N
442	18	0	0	applied	\N
442	23	0	0	applied	\N
444	18	0	0	applied	\N
444	19	0	0	applied	\N
446	18	0	0	applied	\N
446	19	0	0	applied	\N
\.


--
-- Data for Name: blocks_user_commands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.blocks_user_commands (block_id, user_command_id, sequence_no, status, failure_reason) FROM stdin;
3	1	0	applied	\N
3	2	1	applied	\N
4	3	0	applied	\N
4	4	1	applied	\N
4	5	2	applied	\N
4	6	3	applied	\N
4	7	4	applied	\N
4	8	5	applied	\N
4	9	6	applied	\N
4	10	7	applied	\N
4	11	8	applied	\N
4	12	9	applied	\N
4	13	10	applied	\N
5	14	0	applied	\N
5	15	1	applied	\N
5	16	2	applied	\N
5	17	3	applied	\N
5	18	4	applied	\N
5	19	5	applied	\N
5	20	6	applied	\N
5	21	7	applied	\N
5	22	8	applied	\N
5	23	9	applied	\N
5	24	10	applied	\N
5	25	11	applied	\N
6	26	0	applied	\N
6	27	1	applied	\N
6	28	2	applied	\N
6	29	3	applied	\N
6	30	4	applied	\N
6	31	5	applied	\N
6	32	6	applied	\N
6	33	7	applied	\N
6	34	8	applied	\N
6	35	9	applied	\N
6	36	10	applied	\N
6	37	11	applied	\N
7	26	0	applied	\N
7	27	1	applied	\N
7	28	2	applied	\N
7	29	3	applied	\N
7	30	4	applied	\N
7	31	5	applied	\N
7	32	6	applied	\N
7	33	7	applied	\N
7	34	8	applied	\N
7	35	9	applied	\N
7	36	10	applied	\N
7	37	11	applied	\N
8	38	0	applied	\N
8	39	1	applied	\N
8	40	2	applied	\N
8	41	3	applied	\N
8	42	4	applied	\N
8	43	5	applied	\N
8	44	6	applied	\N
8	45	7	applied	\N
8	46	8	applied	\N
8	47	9	applied	\N
8	48	10	applied	\N
8	49	11	applied	\N
9	50	0	applied	\N
9	51	1	applied	\N
9	52	2	applied	\N
9	53	3	applied	\N
9	54	4	applied	\N
9	55	5	applied	\N
9	56	6	applied	\N
9	57	7	applied	\N
9	58	8	applied	\N
9	59	9	applied	\N
9	60	10	applied	\N
9	61	11	applied	\N
10	50	0	applied	\N
10	51	1	applied	\N
10	52	2	applied	\N
10	53	3	applied	\N
10	54	4	applied	\N
10	55	5	applied	\N
10	56	6	applied	\N
10	57	7	applied	\N
10	58	8	applied	\N
10	59	9	applied	\N
10	60	10	applied	\N
10	61	11	applied	\N
11	62	0	applied	\N
11	63	1	applied	\N
11	64	2	applied	\N
11	65	3	applied	\N
11	66	4	applied	\N
11	67	5	applied	\N
11	68	6	applied	\N
11	69	7	applied	\N
11	70	8	applied	\N
11	71	9	applied	\N
11	72	10	applied	\N
11	73	11	applied	\N
11	74	12	applied	\N
11	75	13	applied	\N
11	76	14	applied	\N
11	77	15	applied	\N
11	78	16	applied	\N
11	79	17	applied	\N
11	80	18	applied	\N
11	81	19	applied	\N
11	82	20	applied	\N
11	83	21	applied	\N
11	84	22	applied	\N
11	85	23	applied	\N
11	86	24	applied	\N
11	87	25	applied	\N
11	88	26	applied	\N
11	89	27	applied	\N
11	90	28	applied	\N
11	91	29	applied	\N
11	92	30	applied	\N
11	93	31	applied	\N
11	94	32	applied	\N
11	95	33	applied	\N
11	96	34	applied	\N
11	97	35	applied	\N
11	98	36	applied	\N
11	99	37	applied	\N
12	100	0	applied	\N
12	101	1	applied	\N
12	102	2	applied	\N
12	103	3	applied	\N
12	104	4	applied	\N
12	105	5	applied	\N
12	106	6	applied	\N
12	107	7	applied	\N
12	108	8	applied	\N
12	109	9	applied	\N
12	110	10	applied	\N
13	100	0	applied	\N
13	101	1	applied	\N
13	102	2	applied	\N
13	103	3	applied	\N
13	104	4	applied	\N
13	105	5	applied	\N
13	106	6	applied	\N
13	107	7	applied	\N
13	108	8	applied	\N
13	109	9	applied	\N
13	110	10	applied	\N
14	111	0	applied	\N
14	112	2	applied	\N
14	113	3	applied	\N
14	114	4	applied	\N
14	115	5	applied	\N
14	116	6	applied	\N
14	117	7	applied	\N
14	118	8	applied	\N
14	119	9	applied	\N
14	120	10	applied	\N
14	121	11	applied	\N
14	122	12	applied	\N
15	123	0	applied	\N
15	124	1	applied	\N
15	125	2	applied	\N
15	126	3	applied	\N
15	127	4	applied	\N
15	128	5	applied	\N
15	129	6	applied	\N
15	130	7	applied	\N
15	131	8	applied	\N
15	132	9	applied	\N
15	133	10	applied	\N
15	134	11	applied	\N
15	135	12	applied	\N
16	123	0	applied	\N
16	124	1	applied	\N
16	125	2	applied	\N
16	126	3	applied	\N
16	127	4	applied	\N
16	128	5	applied	\N
16	129	6	applied	\N
16	130	7	applied	\N
16	131	8	applied	\N
16	132	9	applied	\N
16	133	10	applied	\N
16	134	11	applied	\N
16	135	12	applied	\N
17	136	0	applied	\N
17	137	1	applied	\N
17	138	2	applied	\N
17	139	3	applied	\N
17	140	4	applied	\N
17	141	5	applied	\N
17	142	6	applied	\N
17	143	7	applied	\N
17	144	8	applied	\N
17	145	9	applied	\N
17	146	10	applied	\N
17	147	11	applied	\N
18	148	0	applied	\N
18	149	1	applied	\N
18	150	2	applied	\N
18	151	3	applied	\N
18	152	4	applied	\N
18	153	5	applied	\N
18	154	6	applied	\N
18	155	7	applied	\N
18	156	8	applied	\N
18	157	9	applied	\N
18	158	10	applied	\N
18	159	11	applied	\N
19	160	0	applied	\N
19	161	1	applied	\N
19	162	2	applied	\N
19	163	3	applied	\N
19	164	4	applied	\N
19	165	5	applied	\N
19	166	6	applied	\N
19	167	7	applied	\N
19	168	8	applied	\N
19	169	9	applied	\N
19	170	10	applied	\N
19	171	11	applied	\N
20	172	0	applied	\N
20	173	1	applied	\N
20	174	2	applied	\N
20	175	3	applied	\N
20	176	4	applied	\N
20	177	5	applied	\N
20	178	6	applied	\N
20	179	7	applied	\N
20	180	8	applied	\N
20	181	9	applied	\N
20	182	10	applied	\N
20	183	11	applied	\N
21	184	0	applied	\N
21	185	1	applied	\N
21	186	2	applied	\N
21	187	3	applied	\N
21	188	4	applied	\N
21	189	5	applied	\N
21	190	6	applied	\N
21	191	7	applied	\N
21	192	8	applied	\N
21	193	9	applied	\N
21	194	10	applied	\N
21	195	11	applied	\N
21	196	12	applied	\N
22	184	0	applied	\N
22	185	1	applied	\N
22	186	2	applied	\N
22	187	3	applied	\N
22	188	4	applied	\N
22	189	5	applied	\N
22	190	6	applied	\N
22	191	7	applied	\N
22	192	8	applied	\N
22	193	9	applied	\N
22	194	10	applied	\N
22	195	11	applied	\N
22	196	12	applied	\N
23	197	0	applied	\N
23	198	1	applied	\N
23	199	2	applied	\N
23	200	3	applied	\N
23	201	4	applied	\N
23	202	5	applied	\N
23	203	6	applied	\N
23	204	7	applied	\N
23	205	8	applied	\N
23	206	9	applied	\N
23	207	10	applied	\N
23	208	11	applied	\N
23	209	12	applied	\N
23	210	13	applied	\N
23	211	14	applied	\N
23	212	15	applied	\N
23	213	16	applied	\N
23	214	17	applied	\N
23	215	18	applied	\N
23	216	19	applied	\N
23	217	20	applied	\N
23	218	21	applied	\N
23	219	22	applied	\N
23	220	23	applied	\N
24	197	0	applied	\N
24	198	1	applied	\N
24	199	2	applied	\N
24	200	3	applied	\N
24	201	4	applied	\N
24	202	5	applied	\N
24	203	6	applied	\N
24	204	7	applied	\N
24	205	8	applied	\N
24	206	9	applied	\N
24	207	10	applied	\N
24	208	11	applied	\N
24	209	12	applied	\N
24	210	13	applied	\N
24	211	14	applied	\N
24	212	15	applied	\N
24	213	16	applied	\N
24	214	17	applied	\N
24	215	18	applied	\N
24	216	19	applied	\N
24	217	20	applied	\N
24	218	21	applied	\N
24	219	22	applied	\N
24	220	23	applied	\N
25	221	0	applied	\N
25	222	1	applied	\N
25	223	3	applied	\N
25	224	4	applied	\N
25	225	5	applied	\N
25	226	6	applied	\N
25	227	7	applied	\N
25	228	8	applied	\N
25	229	9	applied	\N
25	230	10	applied	\N
25	231	11	applied	\N
25	232	12	applied	\N
26	233	0	applied	\N
26	234	1	applied	\N
26	235	2	applied	\N
26	236	3	applied	\N
26	237	4	applied	\N
26	238	5	applied	\N
26	239	6	applied	\N
26	240	7	applied	\N
26	241	8	applied	\N
26	242	9	applied	\N
26	243	10	applied	\N
26	244	11	applied	\N
26	245	12	applied	\N
26	246	13	applied	\N
26	247	14	applied	\N
26	248	15	applied	\N
26	249	16	applied	\N
26	250	17	applied	\N
26	251	18	applied	\N
26	252	19	applied	\N
26	253	20	applied	\N
26	254	21	applied	\N
26	255	22	applied	\N
26	256	23	applied	\N
26	257	24	applied	\N
27	233	0	applied	\N
27	234	1	applied	\N
27	235	2	applied	\N
27	236	3	applied	\N
27	237	4	applied	\N
27	238	5	applied	\N
27	239	6	applied	\N
27	240	7	applied	\N
27	241	8	applied	\N
27	242	9	applied	\N
27	243	10	applied	\N
27	244	11	applied	\N
27	245	12	applied	\N
27	246	13	applied	\N
27	247	14	applied	\N
27	248	15	applied	\N
27	249	16	applied	\N
27	250	17	applied	\N
27	251	18	applied	\N
27	252	19	applied	\N
27	253	20	applied	\N
27	254	21	applied	\N
27	255	22	applied	\N
27	256	23	applied	\N
27	257	24	applied	\N
28	258	0	applied	\N
28	259	1	applied	\N
28	260	2	applied	\N
28	261	3	applied	\N
28	262	4	applied	\N
28	263	5	applied	\N
28	264	6	applied	\N
28	265	7	applied	\N
28	266	8	applied	\N
28	267	9	applied	\N
28	268	10	applied	\N
28	269	11	applied	\N
88	970	0	applied	\N
88	971	1	applied	\N
88	972	2	applied	\N
88	973	3	applied	\N
88	974	4	applied	\N
88	975	5	applied	\N
88	976	6	applied	\N
88	977	7	applied	\N
88	978	8	applied	\N
88	979	9	applied	\N
88	980	10	applied	\N
90	993	0	applied	\N
90	994	1	applied	\N
90	995	2	applied	\N
90	996	3	applied	\N
90	997	4	applied	\N
90	998	5	applied	\N
90	999	6	applied	\N
90	1000	7	applied	\N
90	1001	8	applied	\N
90	1002	9	applied	\N
90	1003	10	applied	\N
90	1004	11	applied	\N
92	1005	0	applied	\N
92	1006	1	applied	\N
92	1007	2	applied	\N
92	1008	3	applied	\N
92	1009	4	applied	\N
92	1010	5	applied	\N
92	1011	6	applied	\N
92	1012	8	applied	\N
92	1013	9	applied	\N
92	1014	10	applied	\N
92	1015	11	applied	\N
92	1016	12	applied	\N
94	1017	0	applied	\N
94	1018	1	applied	\N
94	1019	2	applied	\N
94	1020	3	applied	\N
94	1021	4	applied	\N
94	1022	5	applied	\N
94	1023	6	applied	\N
94	1024	7	applied	\N
94	1025	8	applied	\N
94	1026	9	applied	\N
94	1027	10	applied	\N
94	1028	11	applied	\N
94	1029	12	applied	\N
94	1030	13	applied	\N
94	1031	14	applied	\N
94	1032	15	applied	\N
94	1033	16	applied	\N
94	1034	17	applied	\N
94	1035	18	applied	\N
94	1036	19	applied	\N
94	1037	20	applied	\N
94	1038	21	applied	\N
94	1039	22	applied	\N
106	1161	15	applied	\N
106	1162	16	applied	\N
106	1163	17	applied	\N
106	1164	18	applied	\N
106	1165	19	applied	\N
106	1166	20	applied	\N
106	1167	21	applied	\N
106	1168	22	applied	\N
106	1169	23	applied	\N
106	1170	24	applied	\N
106	1171	25	applied	\N
106	1172	26	applied	\N
106	1173	27	applied	\N
106	1174	28	applied	\N
106	1175	29	applied	\N
106	1176	30	applied	\N
106	1177	31	applied	\N
106	1178	32	applied	\N
106	1179	33	applied	\N
106	1180	34	applied	\N
111	1213	20	applied	\N
111	1214	21	applied	\N
111	1215	22	applied	\N
111	1216	23	applied	\N
113	1228	0	applied	\N
113	1229	1	applied	\N
113	1230	2	applied	\N
113	1231	3	applied	\N
113	1232	4	applied	\N
113	1233	5	applied	\N
113	1234	6	applied	\N
113	1235	7	applied	\N
113	1236	8	applied	\N
113	1237	9	applied	\N
113	1238	11	applied	\N
113	1239	12	applied	\N
115	1240	0	applied	\N
115	1241	1	applied	\N
115	1242	2	applied	\N
115	1243	3	applied	\N
115	1244	4	applied	\N
115	1245	5	applied	\N
115	1246	6	applied	\N
115	1247	7	applied	\N
115	1248	8	applied	\N
115	1249	9	applied	\N
115	1250	10	applied	\N
115	1251	11	applied	\N
117	1263	0	applied	\N
117	1264	1	applied	\N
117	1265	2	applied	\N
117	1266	3	applied	\N
117	1267	4	applied	\N
117	1268	5	applied	\N
117	1269	6	applied	\N
117	1270	7	applied	\N
117	1271	8	applied	\N
117	1272	9	applied	\N
117	1273	10	applied	\N
117	1274	11	applied	\N
119	1275	0	applied	\N
119	1276	1	applied	\N
119	1277	2	applied	\N
119	1278	3	applied	\N
119	1279	4	applied	\N
119	1280	5	applied	\N
119	1281	6	applied	\N
119	1282	7	applied	\N
119	1283	8	applied	\N
119	1284	9	applied	\N
119	1285	10	applied	\N
119	1286	11	applied	\N
121	1287	0	applied	\N
121	1288	1	applied	\N
121	1289	2	applied	\N
121	1290	3	applied	\N
121	1291	4	applied	\N
121	1292	5	applied	\N
121	1293	6	applied	\N
121	1294	7	applied	\N
121	1295	8	applied	\N
121	1296	9	applied	\N
121	1297	10	applied	\N
123	1298	0	applied	\N
123	1299	1	applied	\N
123	1300	2	applied	\N
123	1301	3	applied	\N
123	1302	4	applied	\N
123	1303	5	applied	\N
123	1304	6	applied	\N
123	1305	7	applied	\N
123	1306	8	applied	\N
123	1307	9	applied	\N
123	1308	10	applied	\N
123	1309	11	applied	\N
124	1318	8	applied	\N
124	1319	9	applied	\N
124	1320	10	applied	\N
124	1321	11	applied	\N
125	1310	0	applied	\N
125	1311	1	applied	\N
125	1312	2	applied	\N
125	1313	3	applied	\N
125	1314	4	applied	\N
125	1315	5	applied	\N
125	1316	6	applied	\N
125	1317	7	applied	\N
125	1318	8	applied	\N
125	1319	9	applied	\N
125	1320	10	applied	\N
125	1321	11	applied	\N
126	1322	0	applied	\N
126	1323	1	applied	\N
126	1324	2	applied	\N
126	1325	3	applied	\N
126	1326	4	applied	\N
126	1327	5	applied	\N
126	1328	6	applied	\N
29	270	0	applied	\N
29	271	1	applied	\N
29	272	2	applied	\N
29	273	3	applied	\N
29	274	4	applied	\N
29	275	5	applied	\N
29	276	6	applied	\N
29	277	7	applied	\N
29	278	8	applied	\N
29	279	9	applied	\N
29	280	10	applied	\N
29	281	11	applied	\N
30	282	0	applied	\N
30	283	1	applied	\N
30	284	2	applied	\N
30	285	3	applied	\N
30	286	4	applied	\N
30	287	5	applied	\N
30	288	6	applied	\N
30	289	7	applied	\N
30	290	8	applied	\N
30	291	9	applied	\N
30	292	10	applied	\N
30	293	11	applied	\N
31	282	0	applied	\N
31	283	1	applied	\N
31	284	2	applied	\N
31	285	3	applied	\N
31	286	4	applied	\N
31	287	5	applied	\N
31	288	6	applied	\N
31	289	7	applied	\N
31	290	8	applied	\N
31	291	9	applied	\N
31	292	10	applied	\N
31	293	11	applied	\N
32	294	0	applied	\N
32	295	1	applied	\N
32	296	2	applied	\N
32	297	3	applied	\N
32	298	4	applied	\N
32	299	5	applied	\N
32	300	6	applied	\N
32	301	7	applied	\N
32	302	8	applied	\N
32	303	9	applied	\N
32	304	10	applied	\N
32	305	11	applied	\N
33	306	0	applied	\N
33	307	1	applied	\N
33	308	2	applied	\N
33	309	3	applied	\N
33	310	4	applied	\N
33	311	5	applied	\N
33	312	6	applied	\N
33	313	7	applied	\N
33	314	8	applied	\N
33	315	9	applied	\N
33	316	10	applied	\N
33	317	11	applied	\N
34	306	0	applied	\N
34	307	1	applied	\N
34	308	2	applied	\N
34	309	3	applied	\N
34	310	4	applied	\N
34	311	5	applied	\N
34	312	6	applied	\N
34	313	7	applied	\N
34	314	8	applied	\N
34	315	9	applied	\N
34	316	10	applied	\N
34	317	11	applied	\N
35	318	0	applied	\N
35	319	1	applied	\N
35	320	2	applied	\N
35	321	3	applied	\N
35	322	4	applied	\N
35	323	5	applied	\N
35	324	6	applied	\N
35	325	7	applied	\N
35	326	8	applied	\N
35	327	9	applied	\N
35	328	10	applied	\N
35	329	11	applied	\N
35	330	12	applied	\N
35	331	13	applied	\N
35	332	14	applied	\N
35	333	15	applied	\N
35	334	16	applied	\N
35	335	17	applied	\N
35	336	19	applied	\N
35	337	20	applied	\N
35	338	21	applied	\N
35	339	22	applied	\N
35	340	23	applied	\N
35	341	24	applied	\N
35	342	25	applied	\N
36	318	0	applied	\N
36	319	1	applied	\N
36	320	2	applied	\N
36	321	3	applied	\N
36	322	4	applied	\N
36	323	5	applied	\N
36	324	6	applied	\N
36	325	7	applied	\N
36	326	8	applied	\N
36	327	9	applied	\N
36	328	10	applied	\N
36	329	11	applied	\N
36	330	12	applied	\N
36	331	13	applied	\N
36	332	14	applied	\N
36	333	15	applied	\N
36	334	16	applied	\N
36	335	17	applied	\N
36	336	19	applied	\N
36	337	20	applied	\N
36	338	21	applied	\N
36	339	22	applied	\N
36	340	23	applied	\N
36	341	24	applied	\N
36	342	25	applied	\N
37	343	0	applied	\N
37	344	1	applied	\N
37	345	2	applied	\N
37	346	3	applied	\N
37	347	4	applied	\N
37	348	5	applied	\N
37	349	6	applied	\N
37	350	7	applied	\N
37	351	8	applied	\N
37	352	9	applied	\N
37	353	10	applied	\N
37	354	11	applied	\N
38	355	0	applied	\N
38	356	1	applied	\N
38	357	2	applied	\N
38	358	3	applied	\N
38	359	4	applied	\N
38	360	5	applied	\N
38	361	6	applied	\N
38	362	7	applied	\N
38	363	8	applied	\N
38	364	9	applied	\N
38	365	10	applied	\N
38	366	11	applied	\N
39	367	0	applied	\N
39	368	1	applied	\N
39	369	2	applied	\N
39	370	3	applied	\N
39	371	4	applied	\N
39	372	5	applied	\N
39	373	6	applied	\N
39	374	7	applied	\N
39	375	8	applied	\N
39	376	9	applied	\N
39	377	10	applied	\N
40	378	0	applied	\N
40	379	1	applied	\N
40	380	2	applied	\N
40	381	3	applied	\N
40	382	4	applied	\N
40	383	5	applied	\N
40	384	6	applied	\N
41	378	0	applied	\N
41	379	1	applied	\N
41	380	2	applied	\N
41	381	3	applied	\N
41	382	4	applied	\N
41	383	5	applied	\N
41	384	6	applied	\N
42	385	0	applied	\N
42	386	1	applied	\N
42	387	2	applied	\N
42	388	3	applied	\N
42	389	4	applied	\N
42	390	5	applied	\N
42	391	6	applied	\N
43	392	0	applied	\N
43	393	1	applied	\N
43	394	2	applied	\N
43	395	3	applied	\N
43	396	4	applied	\N
43	397	5	applied	\N
43	398	6	applied	\N
44	399	0	applied	\N
44	400	1	applied	\N
44	401	2	applied	\N
44	402	3	applied	\N
44	403	4	applied	\N
44	404	5	applied	\N
44	405	6	applied	\N
44	406	7	applied	\N
44	407	8	applied	\N
44	408	9	applied	\N
44	409	10	applied	\N
44	410	11	applied	\N
44	411	12	applied	\N
44	412	13	applied	\N
44	413	14	applied	\N
44	414	15	applied	\N
44	415	16	applied	\N
44	416	17	applied	\N
44	417	18	applied	\N
44	418	19	applied	\N
44	419	20	applied	\N
44	420	21	applied	\N
44	421	22	applied	\N
46	433	0	applied	\N
46	434	1	applied	\N
46	435	2	applied	\N
46	436	3	applied	\N
46	437	4	applied	\N
46	438	5	applied	\N
46	439	6	applied	\N
46	440	7	applied	\N
46	441	8	applied	\N
46	442	9	applied	\N
46	443	10	applied	\N
46	444	11	applied	\N
46	445	13	applied	\N
89	981	0	applied	\N
89	982	1	applied	\N
89	983	2	applied	\N
89	984	3	applied	\N
89	985	4	applied	\N
89	986	5	applied	\N
89	987	6	applied	\N
89	988	7	applied	\N
89	989	8	applied	\N
89	990	9	applied	\N
89	991	10	applied	\N
89	992	11	applied	\N
91	993	0	applied	\N
91	994	1	applied	\N
91	995	2	applied	\N
91	996	3	applied	\N
91	997	4	applied	\N
91	998	5	applied	\N
91	999	6	applied	\N
91	1000	7	applied	\N
91	1001	8	applied	\N
91	1002	9	applied	\N
91	1003	10	applied	\N
91	1004	11	applied	\N
93	1005	0	applied	\N
93	1006	1	applied	\N
93	1007	2	applied	\N
93	1008	3	applied	\N
93	1009	4	applied	\N
93	1010	5	applied	\N
93	1011	6	applied	\N
93	1012	8	applied	\N
93	1013	9	applied	\N
93	1014	10	applied	\N
93	1015	11	applied	\N
93	1016	12	applied	\N
108	1181	0	applied	\N
108	1182	1	applied	\N
108	1183	2	applied	\N
108	1184	3	applied	\N
108	1185	4	applied	\N
108	1186	5	applied	\N
108	1187	6	applied	\N
108	1188	7	applied	\N
108	1189	8	applied	\N
108	1190	9	applied	\N
108	1191	10	applied	\N
108	1192	11	applied	\N
110	1193	0	applied	\N
110	1194	1	applied	\N
110	1195	2	applied	\N
110	1196	3	applied	\N
110	1197	4	applied	\N
110	1198	5	applied	\N
110	1199	6	applied	\N
110	1200	7	applied	\N
110	1201	8	applied	\N
110	1202	9	applied	\N
110	1203	10	applied	\N
110	1204	11	applied	\N
110	1205	12	applied	\N
110	1206	13	applied	\N
110	1207	14	applied	\N
110	1208	15	applied	\N
110	1209	16	applied	\N
110	1210	17	applied	\N
110	1211	18	applied	\N
110	1212	19	applied	\N
110	1213	20	applied	\N
110	1214	21	applied	\N
110	1215	22	applied	\N
110	1216	23	applied	\N
112	1217	0	applied	\N
112	1218	1	applied	\N
112	1219	2	applied	\N
112	1220	3	applied	\N
112	1221	4	applied	\N
112	1222	5	applied	\N
112	1223	6	applied	\N
112	1224	7	applied	\N
112	1225	8	applied	\N
112	1226	9	applied	\N
112	1227	10	applied	\N
114	1240	0	applied	\N
114	1241	1	applied	\N
114	1242	2	applied	\N
114	1243	3	applied	\N
114	1244	4	applied	\N
114	1245	5	applied	\N
114	1246	6	applied	\N
114	1247	7	applied	\N
114	1248	8	applied	\N
114	1249	9	applied	\N
114	1250	10	applied	\N
114	1251	11	applied	\N
116	1252	0	applied	\N
116	1253	1	applied	\N
116	1254	2	applied	\N
116	1255	3	applied	\N
116	1256	4	applied	\N
116	1257	5	applied	\N
116	1258	6	applied	\N
116	1259	7	applied	\N
116	1260	8	applied	\N
116	1261	9	applied	\N
116	1262	10	applied	\N
118	1263	0	applied	\N
118	1264	1	applied	\N
118	1265	2	applied	\N
118	1266	3	applied	\N
118	1267	4	applied	\N
118	1268	5	applied	\N
118	1269	6	applied	\N
118	1270	7	applied	\N
118	1271	8	applied	\N
118	1272	9	applied	\N
118	1273	10	applied	\N
118	1274	11	applied	\N
120	1287	0	applied	\N
120	1288	1	applied	\N
120	1289	2	applied	\N
120	1290	3	applied	\N
120	1291	4	applied	\N
120	1292	5	applied	\N
120	1293	6	applied	\N
120	1294	7	applied	\N
120	1295	8	applied	\N
120	1296	9	applied	\N
120	1297	10	applied	\N
122	1298	0	applied	\N
122	1299	1	applied	\N
122	1300	2	applied	\N
122	1301	3	applied	\N
122	1302	4	applied	\N
122	1303	5	applied	\N
122	1304	6	applied	\N
122	1305	7	applied	\N
122	1306	8	applied	\N
122	1307	9	applied	\N
122	1308	10	applied	\N
122	1309	11	applied	\N
124	1310	0	applied	\N
124	1311	1	applied	\N
124	1312	2	applied	\N
124	1313	3	applied	\N
124	1314	4	applied	\N
124	1315	5	applied	\N
124	1316	6	applied	\N
124	1317	7	applied	\N
45	422	0	applied	\N
45	423	1	applied	\N
45	424	2	applied	\N
45	425	3	applied	\N
45	426	4	applied	\N
45	427	5	applied	\N
45	428	6	applied	\N
45	429	7	applied	\N
45	430	8	applied	\N
45	431	9	applied	\N
45	432	10	applied	\N
47	433	0	applied	\N
47	434	1	applied	\N
47	435	2	applied	\N
47	436	3	applied	\N
47	437	4	applied	\N
47	438	5	applied	\N
47	439	6	applied	\N
47	440	7	applied	\N
47	441	8	applied	\N
47	442	9	applied	\N
47	443	10	applied	\N
47	444	11	applied	\N
47	445	13	applied	\N
48	446	0	applied	\N
48	447	1	applied	\N
48	448	2	applied	\N
48	449	3	applied	\N
48	450	4	applied	\N
48	451	5	applied	\N
48	452	6	applied	\N
48	453	7	applied	\N
48	454	8	applied	\N
48	455	9	applied	\N
48	456	10	applied	\N
49	457	0	applied	\N
49	458	1	applied	\N
49	459	2	applied	\N
49	460	3	applied	\N
49	461	4	applied	\N
49	462	5	applied	\N
49	463	6	applied	\N
49	464	7	applied	\N
49	465	8	applied	\N
49	466	9	applied	\N
49	467	10	applied	\N
49	468	11	applied	\N
50	457	0	applied	\N
50	458	1	applied	\N
50	459	2	applied	\N
50	460	3	applied	\N
50	461	4	applied	\N
50	462	5	applied	\N
50	463	6	applied	\N
50	464	7	applied	\N
50	465	8	applied	\N
50	466	9	applied	\N
50	467	10	applied	\N
50	468	11	applied	\N
51	469	0	applied	\N
51	470	1	applied	\N
51	471	2	applied	\N
51	472	3	applied	\N
51	473	4	applied	\N
51	474	5	applied	\N
51	475	6	applied	\N
51	476	7	applied	\N
51	477	8	applied	\N
51	478	9	applied	\N
51	479	10	applied	\N
51	480	11	applied	\N
51	481	12	applied	\N
51	482	13	applied	\N
51	483	14	applied	\N
51	484	15	applied	\N
51	485	16	applied	\N
51	486	17	applied	\N
51	487	18	applied	\N
51	488	19	applied	\N
51	489	20	applied	\N
51	490	21	applied	\N
51	491	22	applied	\N
51	492	23	applied	\N
51	493	24	applied	\N
51	494	25	applied	\N
51	495	26	applied	\N
51	496	27	applied	\N
51	497	28	applied	\N
51	498	29	applied	\N
51	499	30	applied	\N
51	500	31	applied	\N
51	501	32	applied	\N
51	502	33	applied	\N
51	503	34	applied	\N
51	504	35	applied	\N
52	469	0	applied	\N
52	470	1	applied	\N
52	471	2	applied	\N
52	472	3	applied	\N
52	473	4	applied	\N
52	474	5	applied	\N
52	475	6	applied	\N
52	476	7	applied	\N
52	477	8	applied	\N
52	478	9	applied	\N
52	479	10	applied	\N
52	480	11	applied	\N
52	481	12	applied	\N
52	482	13	applied	\N
52	483	14	applied	\N
52	484	15	applied	\N
52	485	16	applied	\N
52	486	17	applied	\N
52	487	18	applied	\N
52	488	19	applied	\N
52	489	20	applied	\N
52	490	21	applied	\N
52	491	22	applied	\N
52	492	23	applied	\N
52	493	24	applied	\N
52	494	25	applied	\N
52	495	26	applied	\N
52	496	27	applied	\N
52	497	28	applied	\N
52	498	29	applied	\N
52	499	30	applied	\N
52	500	31	applied	\N
52	501	32	applied	\N
52	502	33	applied	\N
52	503	34	applied	\N
52	504	35	applied	\N
53	505	0	applied	\N
53	506	1	applied	\N
53	507	2	applied	\N
53	508	3	applied	\N
53	509	4	applied	\N
53	510	5	applied	\N
53	511	6	applied	\N
53	512	7	applied	\N
53	513	8	applied	\N
53	514	9	applied	\N
53	515	10	applied	\N
53	516	11	applied	\N
53	517	12	applied	\N
53	518	13	applied	\N
53	519	14	applied	\N
53	520	15	applied	\N
53	521	16	applied	\N
53	522	17	applied	\N
53	523	18	applied	\N
53	524	19	applied	\N
53	525	20	applied	\N
53	526	21	applied	\N
53	527	22	applied	\N
53	528	23	applied	\N
54	529	0	applied	\N
54	530	1	applied	\N
54	531	2	applied	\N
54	532	3	applied	\N
54	533	4	applied	\N
54	534	5	applied	\N
54	535	6	applied	\N
54	536	7	applied	\N
54	537	8	applied	\N
54	538	9	applied	\N
54	539	10	applied	\N
54	540	11	applied	\N
54	541	12	applied	\N
54	542	13	applied	\N
54	543	14	applied	\N
54	544	15	applied	\N
54	545	16	applied	\N
54	546	17	applied	\N
54	547	18	applied	\N
54	548	19	applied	\N
54	549	20	applied	\N
54	550	21	applied	\N
54	551	22	applied	\N
54	552	23	applied	\N
54	553	24	applied	\N
54	554	25	applied	\N
54	555	26	applied	\N
54	556	27	applied	\N
54	557	28	applied	\N
54	558	29	applied	\N
54	559	30	applied	\N
54	560	31	applied	\N
54	561	32	applied	\N
54	562	34	applied	\N
54	563	35	applied	\N
54	564	36	applied	\N
54	565	37	applied	\N
55	566	0	applied	\N
55	567	1	applied	\N
55	568	2	applied	\N
55	569	3	applied	\N
55	570	4	applied	\N
55	571	5	applied	\N
55	572	6	applied	\N
55	573	7	applied	\N
55	574	8	applied	\N
55	575	9	applied	\N
55	576	10	applied	\N
55	577	11	applied	\N
56	578	0	applied	\N
56	579	1	applied	\N
56	580	2	applied	\N
56	581	3	applied	\N
56	582	4	applied	\N
56	583	5	applied	\N
56	584	6	applied	\N
56	585	7	applied	\N
56	586	8	applied	\N
56	587	9	applied	\N
56	588	10	applied	\N
56	589	11	applied	\N
57	590	0	applied	\N
57	591	1	applied	\N
57	592	2	applied	\N
57	593	3	applied	\N
57	594	4	applied	\N
57	595	5	applied	\N
57	596	6	applied	\N
57	597	7	applied	\N
57	598	8	applied	\N
57	599	9	applied	\N
57	600	10	applied	\N
57	601	11	applied	\N
58	602	0	applied	\N
58	603	1	applied	\N
58	604	2	applied	\N
58	605	3	applied	\N
58	606	4	applied	\N
58	607	5	applied	\N
58	608	6	applied	\N
58	609	7	applied	\N
58	610	8	applied	\N
58	611	9	applied	\N
58	612	10	applied	\N
59	613	0	applied	\N
59	614	1	applied	\N
59	615	2	applied	\N
59	616	3	applied	\N
59	617	4	applied	\N
59	618	5	applied	\N
59	619	6	applied	\N
59	620	7	applied	\N
59	621	8	applied	\N
59	622	9	applied	\N
59	623	10	applied	\N
59	624	11	applied	\N
60	625	0	applied	\N
60	626	1	applied	\N
60	627	2	applied	\N
60	628	3	applied	\N
60	629	4	applied	\N
60	630	5	applied	\N
60	631	6	applied	\N
60	632	7	applied	\N
60	633	8	applied	\N
60	634	9	applied	\N
60	635	10	applied	\N
60	636	11	applied	\N
61	637	0	applied	\N
61	638	1	applied	\N
61	639	2	applied	\N
61	640	3	applied	\N
61	641	4	applied	\N
61	642	5	applied	\N
61	643	6	applied	\N
61	644	7	applied	\N
61	645	8	applied	\N
61	646	9	applied	\N
61	647	10	applied	\N
61	648	11	applied	\N
61	649	12	applied	\N
61	650	13	applied	\N
61	651	14	applied	\N
61	652	15	applied	\N
61	653	16	applied	\N
61	654	17	applied	\N
61	655	18	applied	\N
61	656	19	applied	\N
61	657	20	applied	\N
61	658	21	applied	\N
61	659	22	applied	\N
61	660	23	applied	\N
61	661	24	applied	\N
61	662	25	applied	\N
61	663	26	applied	\N
61	664	27	applied	\N
61	665	28	applied	\N
61	666	29	applied	\N
61	667	30	applied	\N
61	668	31	applied	\N
61	669	32	applied	\N
61	670	33	applied	\N
61	671	34	applied	\N
61	672	35	applied	\N
61	673	36	applied	\N
62	674	0	applied	\N
62	675	1	applied	\N
62	676	2	applied	\N
62	677	3	applied	\N
62	678	4	applied	\N
62	679	5	applied	\N
62	680	6	applied	\N
62	681	7	applied	\N
62	682	8	applied	\N
62	683	9	applied	\N
62	684	10	applied	\N
62	685	11	applied	\N
62	686	12	applied	\N
62	687	13	applied	\N
62	688	14	applied	\N
62	689	15	applied	\N
62	690	16	applied	\N
62	691	17	applied	\N
62	692	18	applied	\N
62	693	19	applied	\N
62	694	20	applied	\N
62	695	21	applied	\N
62	696	22	applied	\N
62	697	23	applied	\N
63	698	0	applied	\N
63	699	1	applied	\N
63	700	2	applied	\N
63	701	3	applied	\N
63	702	4	applied	\N
63	703	5	applied	\N
63	704	6	applied	\N
63	705	7	applied	\N
63	706	8	applied	\N
63	707	9	applied	\N
63	708	10	applied	\N
63	709	11	applied	\N
64	710	0	applied	\N
64	711	1	applied	\N
64	712	2	applied	\N
64	713	3	applied	\N
64	714	4	applied	\N
64	715	5	applied	\N
64	716	6	applied	\N
64	717	7	applied	\N
64	718	8	applied	\N
64	719	9	applied	\N
64	720	10	applied	\N
64	721	11	applied	\N
65	722	0	applied	\N
65	723	1	applied	\N
65	724	2	applied	\N
65	725	3	applied	\N
65	726	4	applied	\N
65	727	5	applied	\N
65	728	6	applied	\N
65	729	7	applied	\N
65	730	8	applied	\N
65	731	9	applied	\N
65	732	10	applied	\N
66	722	0	applied	\N
66	723	1	applied	\N
66	724	2	applied	\N
66	725	3	applied	\N
66	726	4	applied	\N
66	727	5	applied	\N
66	728	6	applied	\N
66	729	7	applied	\N
66	730	8	applied	\N
66	731	9	applied	\N
66	732	10	applied	\N
67	733	0	applied	\N
67	734	1	applied	\N
67	735	2	applied	\N
67	736	3	applied	\N
67	737	4	applied	\N
67	738	5	applied	\N
67	739	6	applied	\N
67	740	7	applied	\N
67	741	8	applied	\N
67	742	9	applied	\N
67	743	10	applied	\N
67	744	11	applied	\N
67	745	12	applied	\N
67	746	13	applied	\N
67	747	14	applied	\N
67	748	15	applied	\N
67	749	16	applied	\N
67	750	17	applied	\N
67	751	18	applied	\N
67	752	19	applied	\N
67	753	20	applied	\N
67	754	21	applied	\N
67	755	22	applied	\N
67	756	23	applied	\N
69	769	0	applied	\N
69	770	1	applied	\N
69	771	2	applied	\N
69	772	3	applied	\N
69	773	4	applied	\N
69	774	5	applied	\N
69	775	6	applied	\N
69	776	7	applied	\N
69	777	8	applied	\N
69	778	9	applied	\N
69	779	10	applied	\N
71	780	0	applied	\N
71	781	1	applied	\N
71	782	2	applied	\N
71	783	3	applied	\N
71	784	4	applied	\N
71	785	5	applied	\N
71	786	6	applied	\N
71	787	8	applied	\N
71	788	9	applied	\N
71	789	10	applied	\N
71	790	11	applied	\N
71	791	12	applied	\N
95	1040	0	applied	\N
95	1041	1	applied	\N
95	1042	2	applied	\N
95	1043	3	applied	\N
95	1044	4	applied	\N
95	1045	5	applied	\N
95	1046	6	applied	\N
95	1047	7	applied	\N
95	1048	8	applied	\N
95	1049	9	applied	\N
95	1050	10	applied	\N
95	1051	11	applied	\N
97	1075	0	applied	\N
97	1076	1	applied	\N
97	1077	2	applied	\N
97	1078	3	applied	\N
97	1079	4	applied	\N
97	1080	5	applied	\N
97	1081	6	applied	\N
97	1082	7	applied	\N
97	1083	8	applied	\N
97	1084	9	applied	\N
97	1085	10	applied	\N
97	1086	11	applied	\N
99	1099	0	applied	\N
99	1100	1	applied	\N
99	1101	2	applied	\N
99	1102	3	applied	\N
99	1103	4	applied	\N
99	1104	5	applied	\N
99	1105	6	applied	\N
99	1106	7	applied	\N
99	1107	8	applied	\N
99	1108	9	applied	\N
99	1109	10	applied	\N
101	1110	0	applied	\N
101	1111	1	applied	\N
101	1112	2	applied	\N
101	1113	3	applied	\N
101	1114	4	applied	\N
101	1115	5	applied	\N
101	1116	6	applied	\N
101	1117	7	applied	\N
101	1118	8	applied	\N
101	1119	9	applied	\N
101	1120	10	applied	\N
101	1121	11	applied	\N
103	1122	0	applied	\N
103	1123	2	applied	\N
103	1124	3	applied	\N
103	1125	4	applied	\N
103	1126	5	applied	\N
103	1127	6	applied	\N
103	1128	7	applied	\N
103	1129	8	applied	\N
103	1130	9	applied	\N
103	1131	10	applied	\N
103	1132	11	applied	\N
103	1133	12	applied	\N
105	1134	0	applied	\N
105	1135	1	applied	\N
105	1136	2	applied	\N
105	1137	3	applied	\N
105	1138	4	applied	\N
105	1139	5	applied	\N
105	1140	6	applied	\N
105	1141	7	applied	\N
105	1142	8	applied	\N
105	1143	9	applied	\N
105	1144	10	applied	\N
105	1145	11	applied	\N
107	1146	0	applied	\N
107	1147	1	applied	\N
107	1148	2	applied	\N
107	1149	3	applied	\N
107	1150	4	applied	\N
107	1151	5	applied	\N
107	1152	6	applied	\N
107	1153	7	applied	\N
107	1154	8	applied	\N
107	1155	9	applied	\N
107	1156	10	applied	\N
107	1157	11	applied	\N
107	1158	12	applied	\N
107	1159	13	applied	\N
107	1160	14	applied	\N
107	1161	15	applied	\N
107	1162	16	applied	\N
107	1163	17	applied	\N
107	1164	18	applied	\N
107	1165	19	applied	\N
107	1166	20	applied	\N
107	1167	21	applied	\N
107	1168	22	applied	\N
107	1169	23	applied	\N
107	1170	24	applied	\N
107	1171	25	applied	\N
107	1172	26	applied	\N
107	1173	27	applied	\N
107	1174	28	applied	\N
107	1175	29	applied	\N
107	1176	30	applied	\N
107	1177	31	applied	\N
107	1178	32	applied	\N
107	1179	33	applied	\N
107	1180	34	applied	\N
109	1181	0	applied	\N
109	1182	1	applied	\N
109	1183	2	applied	\N
109	1184	3	applied	\N
109	1185	4	applied	\N
109	1186	5	applied	\N
109	1187	6	applied	\N
109	1188	7	applied	\N
109	1189	8	applied	\N
109	1190	9	applied	\N
109	1191	10	applied	\N
109	1192	11	applied	\N
111	1193	0	applied	\N
111	1194	1	applied	\N
111	1195	2	applied	\N
111	1196	3	applied	\N
111	1197	4	applied	\N
111	1198	5	applied	\N
111	1199	6	applied	\N
111	1200	7	applied	\N
111	1201	8	applied	\N
111	1202	9	applied	\N
111	1203	10	applied	\N
111	1204	11	applied	\N
111	1205	12	applied	\N
111	1206	13	applied	\N
111	1207	14	applied	\N
111	1208	15	applied	\N
111	1209	16	applied	\N
111	1210	17	applied	\N
111	1211	18	applied	\N
111	1212	19	applied	\N
68	757	0	applied	\N
68	758	1	applied	\N
68	759	2	applied	\N
68	760	3	applied	\N
68	761	4	applied	\N
68	762	5	applied	\N
68	763	6	applied	\N
68	764	7	applied	\N
68	765	8	applied	\N
68	766	9	applied	\N
68	767	10	applied	\N
68	768	11	applied	\N
70	780	0	applied	\N
70	781	1	applied	\N
70	782	2	applied	\N
70	783	3	applied	\N
70	784	4	applied	\N
70	785	5	applied	\N
70	786	6	applied	\N
70	787	8	applied	\N
70	788	9	applied	\N
70	789	10	applied	\N
70	790	11	applied	\N
70	791	12	applied	\N
72	792	0	applied	\N
72	793	1	applied	\N
72	794	2	applied	\N
72	795	3	applied	\N
72	796	4	applied	\N
72	797	5	applied	\N
72	798	6	applied	\N
72	799	7	applied	\N
72	800	8	applied	\N
72	801	9	applied	\N
72	802	10	applied	\N
72	803	11	applied	\N
73	792	0	applied	\N
73	793	1	applied	\N
73	794	2	applied	\N
73	795	3	applied	\N
73	796	4	applied	\N
73	797	5	applied	\N
73	798	6	applied	\N
73	799	7	applied	\N
73	800	8	applied	\N
73	801	9	applied	\N
73	802	10	applied	\N
73	803	11	applied	\N
74	804	0	applied	\N
74	805	1	applied	\N
74	806	2	applied	\N
74	807	3	applied	\N
74	808	4	applied	\N
74	809	5	applied	\N
74	810	6	applied	\N
74	811	7	applied	\N
74	812	8	applied	\N
74	813	9	applied	\N
74	814	10	applied	\N
74	815	11	applied	\N
75	804	0	applied	\N
75	805	1	applied	\N
75	806	2	applied	\N
75	807	3	applied	\N
75	808	4	applied	\N
75	809	5	applied	\N
75	810	6	applied	\N
75	811	7	applied	\N
75	812	8	applied	\N
75	813	9	applied	\N
75	814	10	applied	\N
75	815	11	applied	\N
76	816	0	applied	\N
76	817	1	applied	\N
76	818	2	applied	\N
76	819	3	applied	\N
76	820	4	applied	\N
76	821	5	applied	\N
76	822	6	applied	\N
76	823	7	applied	\N
76	824	8	applied	\N
76	825	9	applied	\N
76	826	10	applied	\N
77	827	0	applied	\N
77	828	1	applied	\N
77	829	2	applied	\N
77	830	3	applied	\N
77	831	4	applied	\N
77	832	5	applied	\N
77	833	6	applied	\N
77	834	7	applied	\N
77	835	8	applied	\N
77	836	9	applied	\N
77	837	10	applied	\N
77	838	11	applied	\N
78	839	0	applied	\N
78	840	1	applied	\N
78	841	2	applied	\N
78	842	3	applied	\N
78	843	4	applied	\N
78	844	5	applied	\N
78	845	6	applied	\N
78	846	7	applied	\N
78	847	8	applied	\N
78	848	9	applied	\N
78	849	10	applied	\N
78	850	11	applied	\N
79	851	0	applied	\N
79	852	1	applied	\N
79	853	2	applied	\N
79	854	3	applied	\N
79	855	4	applied	\N
79	856	5	applied	\N
79	857	6	applied	\N
79	858	7	applied	\N
79	859	8	applied	\N
79	860	9	applied	\N
79	861	10	applied	\N
79	862	11	applied	\N
80	863	0	applied	\N
80	864	1	applied	\N
80	865	2	applied	\N
80	866	3	applied	\N
80	867	4	applied	\N
80	868	5	applied	\N
80	869	6	applied	\N
80	870	7	applied	\N
80	871	8	applied	\N
80	872	9	applied	\N
80	873	10	applied	\N
80	874	11	applied	\N
80	875	12	applied	\N
80	876	13	applied	\N
80	877	14	applied	\N
80	878	15	applied	\N
80	879	16	applied	\N
80	880	17	applied	\N
80	881	18	applied	\N
80	882	19	applied	\N
80	883	20	applied	\N
80	884	21	applied	\N
80	885	22	applied	\N
80	886	23	applied	\N
80	887	24	applied	\N
80	888	25	applied	\N
80	889	26	applied	\N
80	890	27	applied	\N
80	891	28	applied	\N
80	892	29	applied	\N
80	893	30	applied	\N
80	894	31	applied	\N
80	895	32	applied	\N
80	896	33	applied	\N
80	897	34	applied	\N
80	898	35	applied	\N
81	899	0	applied	\N
81	900	1	applied	\N
81	901	2	applied	\N
81	902	3	applied	\N
81	903	4	applied	\N
81	904	5	applied	\N
81	905	6	applied	\N
81	906	7	applied	\N
81	907	8	applied	\N
81	908	9	applied	\N
81	909	10	applied	\N
81	910	11	applied	\N
82	899	0	applied	\N
82	900	1	applied	\N
82	901	2	applied	\N
82	902	3	applied	\N
82	903	4	applied	\N
82	904	5	applied	\N
82	905	6	applied	\N
82	906	7	applied	\N
82	907	8	applied	\N
82	908	9	applied	\N
82	909	10	applied	\N
82	910	11	applied	\N
83	911	0	applied	\N
83	912	1	applied	\N
83	913	2	applied	\N
83	914	3	applied	\N
83	915	4	applied	\N
83	916	5	applied	\N
83	917	6	applied	\N
83	918	7	applied	\N
83	919	8	applied	\N
83	920	9	applied	\N
83	921	10	applied	\N
83	922	11	applied	\N
84	923	0	applied	\N
84	924	1	applied	\N
84	925	2	applied	\N
84	926	3	applied	\N
84	927	4	applied	\N
84	928	5	applied	\N
84	929	6	applied	\N
84	930	7	applied	\N
84	931	8	applied	\N
84	932	9	applied	\N
84	933	10	applied	\N
85	923	0	applied	\N
85	924	1	applied	\N
85	925	2	applied	\N
85	926	3	applied	\N
85	927	4	applied	\N
85	928	5	applied	\N
85	929	6	applied	\N
85	930	7	applied	\N
85	931	8	applied	\N
85	932	9	applied	\N
85	933	10	applied	\N
86	934	0	applied	\N
86	935	1	applied	\N
86	936	2	applied	\N
86	937	3	applied	\N
86	938	4	applied	\N
86	939	5	applied	\N
86	940	6	applied	\N
86	941	7	applied	\N
86	942	8	applied	\N
86	943	9	applied	\N
86	944	10	applied	\N
86	945	11	applied	\N
86	946	12	applied	\N
86	947	13	applied	\N
86	948	14	applied	\N
86	949	15	applied	\N
86	950	16	applied	\N
86	951	17	applied	\N
86	952	18	applied	\N
86	953	19	applied	\N
86	954	20	applied	\N
86	955	21	applied	\N
86	956	22	applied	\N
86	957	23	applied	\N
86	958	24	applied	\N
86	959	25	applied	\N
86	960	26	applied	\N
86	961	27	applied	\N
86	962	28	applied	\N
86	963	29	applied	\N
86	964	30	applied	\N
86	965	31	applied	\N
86	966	32	applied	\N
86	967	33	applied	\N
86	968	34	applied	\N
86	969	35	applied	\N
87	934	0	applied	\N
87	935	1	applied	\N
87	936	2	applied	\N
87	937	3	applied	\N
87	938	4	applied	\N
87	939	5	applied	\N
87	940	6	applied	\N
87	941	7	applied	\N
87	942	8	applied	\N
87	943	9	applied	\N
87	944	10	applied	\N
87	945	11	applied	\N
87	946	12	applied	\N
87	947	13	applied	\N
87	948	14	applied	\N
87	949	15	applied	\N
87	950	16	applied	\N
87	951	17	applied	\N
87	952	18	applied	\N
87	953	19	applied	\N
87	954	20	applied	\N
87	955	21	applied	\N
87	956	22	applied	\N
87	957	23	applied	\N
87	958	24	applied	\N
87	959	25	applied	\N
87	960	26	applied	\N
87	961	27	applied	\N
87	962	28	applied	\N
87	963	29	applied	\N
87	964	30	applied	\N
87	965	31	applied	\N
87	966	32	applied	\N
87	967	33	applied	\N
87	968	34	applied	\N
87	969	35	applied	\N
96	1052	0	applied	\N
96	1053	1	applied	\N
96	1054	2	applied	\N
96	1055	3	applied	\N
96	1056	4	applied	\N
96	1057	5	applied	\N
96	1058	6	applied	\N
96	1059	7	applied	\N
96	1060	8	applied	\N
96	1061	9	applied	\N
96	1062	10	applied	\N
96	1063	11	applied	\N
96	1064	12	applied	\N
96	1065	13	applied	\N
96	1066	14	applied	\N
96	1067	15	applied	\N
96	1068	16	applied	\N
96	1069	17	applied	\N
96	1070	18	applied	\N
96	1071	19	applied	\N
96	1072	20	applied	\N
96	1073	21	applied	\N
96	1074	22	applied	\N
98	1087	0	applied	\N
98	1088	1	applied	\N
98	1089	2	applied	\N
98	1090	3	applied	\N
98	1091	4	applied	\N
98	1092	5	applied	\N
98	1093	6	applied	\N
98	1094	7	applied	\N
98	1095	8	applied	\N
98	1096	9	applied	\N
98	1097	10	applied	\N
98	1098	11	applied	\N
100	1099	0	applied	\N
100	1100	1	applied	\N
100	1101	2	applied	\N
100	1102	3	applied	\N
100	1103	4	applied	\N
100	1104	5	applied	\N
100	1105	6	applied	\N
100	1106	7	applied	\N
100	1107	8	applied	\N
100	1108	9	applied	\N
100	1109	10	applied	\N
102	1110	0	applied	\N
102	1111	1	applied	\N
102	1112	2	applied	\N
102	1113	3	applied	\N
102	1114	4	applied	\N
102	1115	5	applied	\N
102	1116	6	applied	\N
102	1117	7	applied	\N
102	1118	8	applied	\N
102	1119	9	applied	\N
102	1120	10	applied	\N
102	1121	11	applied	\N
104	1122	0	applied	\N
104	1123	2	applied	\N
104	1124	3	applied	\N
104	1125	4	applied	\N
104	1126	5	applied	\N
104	1127	6	applied	\N
104	1128	7	applied	\N
104	1129	8	applied	\N
104	1130	9	applied	\N
104	1131	10	applied	\N
104	1132	11	applied	\N
104	1133	12	applied	\N
106	1146	0	applied	\N
106	1147	1	applied	\N
106	1148	2	applied	\N
106	1149	3	applied	\N
106	1150	4	applied	\N
106	1151	5	applied	\N
106	1152	6	applied	\N
106	1153	7	applied	\N
106	1154	8	applied	\N
106	1155	9	applied	\N
106	1156	10	applied	\N
106	1157	11	applied	\N
106	1158	12	applied	\N
106	1159	13	applied	\N
106	1160	14	applied	\N
126	1329	7	applied	\N
126	1330	8	applied	\N
126	1331	9	applied	\N
126	1332	10	applied	\N
126	1333	11	applied	\N
126	1334	12	applied	\N
126	1335	13	applied	\N
126	1336	14	applied	\N
126	1337	15	applied	\N
126	1338	16	applied	\N
126	1339	17	applied	\N
126	1340	18	applied	\N
126	1341	19	applied	\N
126	1342	20	applied	\N
126	1343	21	applied	\N
126	1344	22	applied	\N
128	1345	0	applied	\N
128	1346	1	applied	\N
128	1347	3	applied	\N
128	1348	4	applied	\N
128	1349	5	applied	\N
128	1350	6	applied	\N
128	1351	7	applied	\N
128	1352	8	applied	\N
128	1353	9	applied	\N
128	1354	10	applied	\N
128	1355	11	applied	\N
128	1356	12	applied	\N
130	1357	0	applied	\N
130	1358	1	applied	\N
130	1359	2	applied	\N
130	1360	3	applied	\N
130	1361	4	applied	\N
130	1362	5	applied	\N
130	1363	6	applied	\N
130	1364	7	applied	\N
130	1365	8	applied	\N
130	1366	9	applied	\N
130	1367	10	applied	\N
130	1368	11	applied	\N
132	1369	0	applied	\N
132	1370	1	applied	\N
132	1371	2	applied	\N
132	1372	3	applied	\N
132	1373	4	applied	\N
132	1374	5	applied	\N
132	1375	6	applied	\N
132	1376	7	applied	\N
132	1377	8	applied	\N
132	1378	9	applied	\N
132	1379	10	applied	\N
134	1380	0	applied	\N
134	1381	1	applied	\N
134	1382	2	applied	\N
134	1383	3	applied	\N
134	1384	4	applied	\N
134	1385	5	applied	\N
134	1386	6	applied	\N
134	1387	7	applied	\N
134	1388	8	applied	\N
134	1389	9	applied	\N
134	1390	10	applied	\N
134	1391	11	applied	\N
136	1392	0	applied	\N
136	1393	1	applied	\N
136	1394	2	applied	\N
136	1395	3	applied	\N
136	1396	4	applied	\N
136	1397	5	applied	\N
136	1398	6	applied	\N
136	1399	7	applied	\N
136	1400	8	applied	\N
136	1401	9	applied	\N
136	1402	10	applied	\N
136	1403	11	applied	\N
138	1415	0	applied	\N
138	1416	1	applied	\N
138	1417	2	applied	\N
138	1418	3	applied	\N
138	1419	4	applied	\N
138	1420	5	applied	\N
138	1421	6	applied	\N
138	1422	7	applied	\N
138	1423	8	applied	\N
138	1424	9	applied	\N
138	1425	10	applied	\N
138	1426	11	applied	\N
140	1427	0	applied	\N
140	1428	1	applied	\N
140	1429	2	applied	\N
140	1430	3	applied	\N
140	1431	4	applied	\N
140	1432	5	applied	\N
140	1433	6	applied	\N
140	1434	7	applied	\N
140	1435	8	applied	\N
140	1436	9	applied	\N
140	1437	10	applied	\N
127	1322	0	applied	\N
127	1323	1	applied	\N
127	1324	2	applied	\N
127	1325	3	applied	\N
127	1326	4	applied	\N
127	1327	5	applied	\N
127	1328	6	applied	\N
127	1329	7	applied	\N
127	1330	8	applied	\N
127	1331	9	applied	\N
127	1332	10	applied	\N
127	1333	11	applied	\N
127	1334	12	applied	\N
127	1335	13	applied	\N
127	1336	14	applied	\N
127	1337	15	applied	\N
127	1338	16	applied	\N
127	1339	17	applied	\N
127	1340	18	applied	\N
127	1341	19	applied	\N
127	1342	20	applied	\N
127	1343	21	applied	\N
127	1344	22	applied	\N
129	1357	0	applied	\N
129	1358	1	applied	\N
129	1359	2	applied	\N
129	1360	3	applied	\N
129	1361	4	applied	\N
129	1362	5	applied	\N
129	1363	6	applied	\N
129	1364	7	applied	\N
129	1365	8	applied	\N
129	1366	9	applied	\N
129	1367	10	applied	\N
129	1368	11	applied	\N
131	1369	0	applied	\N
131	1370	1	applied	\N
131	1371	2	applied	\N
131	1372	3	applied	\N
131	1373	4	applied	\N
131	1374	5	applied	\N
131	1375	6	applied	\N
131	1376	7	applied	\N
131	1377	8	applied	\N
131	1378	9	applied	\N
131	1379	10	applied	\N
133	1380	0	applied	\N
133	1381	1	applied	\N
133	1382	2	applied	\N
133	1383	3	applied	\N
133	1384	4	applied	\N
133	1385	5	applied	\N
133	1386	6	applied	\N
133	1387	7	applied	\N
133	1388	8	applied	\N
133	1389	9	applied	\N
133	1390	10	applied	\N
133	1391	11	applied	\N
135	1392	0	applied	\N
135	1393	1	applied	\N
135	1394	2	applied	\N
135	1395	3	applied	\N
135	1396	4	applied	\N
135	1397	5	applied	\N
135	1398	6	applied	\N
135	1399	7	applied	\N
135	1400	8	applied	\N
135	1401	9	applied	\N
135	1402	10	applied	\N
135	1403	11	applied	\N
137	1404	0	applied	\N
137	1405	1	applied	\N
137	1406	2	applied	\N
137	1407	3	applied	\N
137	1408	4	applied	\N
137	1409	5	applied	\N
137	1410	6	applied	\N
137	1411	7	applied	\N
137	1412	8	applied	\N
137	1413	9	applied	\N
137	1414	10	applied	\N
139	1415	0	applied	\N
139	1416	1	applied	\N
139	1417	2	applied	\N
139	1418	3	applied	\N
139	1419	4	applied	\N
139	1420	5	applied	\N
139	1421	6	applied	\N
139	1422	7	applied	\N
139	1423	8	applied	\N
139	1424	9	applied	\N
139	1425	10	applied	\N
139	1426	11	applied	\N
141	1438	0	applied	\N
141	1439	1	applied	\N
141	1440	2	applied	\N
141	1441	3	applied	\N
141	1442	4	applied	\N
141	1443	5	applied	\N
141	1444	6	applied	\N
141	1445	7	applied	\N
141	1446	8	applied	\N
141	1447	9	applied	\N
141	1448	10	applied	\N
141	1449	11	applied	\N
142	1450	0	applied	\N
142	1451	1	applied	\N
142	1452	2	applied	\N
142	1453	3	applied	\N
142	1454	4	applied	\N
142	1455	5	applied	\N
142	1456	7	applied	\N
142	1457	8	applied	\N
142	1458	9	applied	\N
142	1459	10	applied	\N
142	1460	11	applied	\N
142	1461	12	applied	\N
143	1462	0	applied	\N
143	1463	1	applied	\N
143	1464	2	applied	\N
143	1465	3	applied	\N
143	1466	4	applied	\N
143	1467	5	applied	\N
143	1468	6	applied	\N
143	1469	7	applied	\N
143	1470	8	applied	\N
143	1471	9	applied	\N
143	1472	10	applied	\N
143	1473	11	applied	\N
143	1474	12	applied	\N
143	1475	13	applied	\N
143	1476	14	applied	\N
143	1477	15	applied	\N
143	1478	16	applied	\N
143	1479	17	applied	\N
143	1480	18	applied	\N
143	1481	19	applied	\N
143	1482	20	applied	\N
143	1483	21	applied	\N
143	1484	22	applied	\N
143	1485	23	applied	\N
144	1486	0	applied	\N
144	1487	1	applied	\N
144	1488	2	applied	\N
144	1489	3	applied	\N
144	1490	4	applied	\N
144	1491	5	applied	\N
144	1492	6	applied	\N
144	1493	7	applied	\N
144	1494	8	applied	\N
144	1495	9	applied	\N
144	1496	10	applied	\N
144	1497	11	applied	\N
145	1498	0	applied	\N
145	1499	1	applied	\N
145	1500	2	applied	\N
145	1501	3	applied	\N
145	1502	4	applied	\N
145	1503	5	applied	\N
145	1504	6	applied	\N
145	1505	7	applied	\N
145	1506	8	applied	\N
145	1507	9	applied	\N
145	1508	10	applied	\N
145	1509	11	applied	\N
145	1510	12	applied	\N
145	1511	13	applied	\N
145	1512	14	applied	\N
145	1513	15	applied	\N
145	1514	16	applied	\N
145	1515	17	applied	\N
145	1516	18	applied	\N
145	1517	19	applied	\N
145	1518	20	applied	\N
145	1519	21	applied	\N
145	1520	22	applied	\N
146	1521	0	applied	\N
146	1522	1	applied	\N
146	1523	2	applied	\N
146	1524	3	applied	\N
146	1525	4	applied	\N
146	1526	5	applied	\N
146	1527	6	applied	\N
146	1528	7	applied	\N
146	1529	8	applied	\N
146	1530	9	applied	\N
146	1531	10	applied	\N
146	1532	11	applied	\N
148	1545	0	applied	\N
148	1546	1	applied	\N
148	1547	2	applied	\N
148	1548	3	applied	\N
148	1549	4	applied	\N
148	1550	5	applied	\N
148	1551	6	applied	\N
148	1552	7	applied	\N
148	1553	8	applied	\N
148	1554	9	applied	\N
148	1555	10	applied	\N
148	1556	11	applied	\N
148	1557	12	applied	\N
148	1558	13	applied	\N
148	1559	14	applied	\N
148	1560	15	applied	\N
148	1561	16	applied	\N
148	1562	17	applied	\N
148	1563	18	applied	\N
148	1564	19	applied	\N
148	1565	20	applied	\N
148	1566	21	applied	\N
148	1567	22	applied	\N
148	1568	23	applied	\N
148	1569	24	applied	\N
148	1570	25	applied	\N
148	1571	27	applied	\N
148	1572	28	applied	\N
148	1573	29	applied	\N
148	1574	30	applied	\N
148	1575	31	applied	\N
148	1576	32	applied	\N
148	1577	33	applied	\N
148	1578	34	applied	\N
148	1579	35	applied	\N
150	1580	0	applied	\N
150	1581	1	applied	\N
150	1582	2	applied	\N
150	1583	3	applied	\N
150	1584	4	applied	\N
150	1585	5	applied	\N
150	1586	6	applied	\N
150	1587	7	applied	\N
150	1588	8	applied	\N
150	1589	9	applied	\N
150	1590	10	applied	\N
150	1591	11	applied	\N
152	1627	0	applied	\N
152	1628	1	applied	\N
152	1629	2	applied	\N
152	1630	3	applied	\N
152	1631	4	applied	\N
152	1632	5	applied	\N
152	1633	6	applied	\N
152	1634	7	applied	\N
152	1635	8	applied	\N
152	1636	9	applied	\N
152	1637	10	applied	\N
152	1638	11	applied	\N
154	1639	0	applied	\N
154	1640	1	applied	\N
154	1641	2	applied	\N
154	1642	3	applied	\N
154	1643	4	applied	\N
154	1644	5	applied	\N
154	1645	6	applied	\N
154	1646	7	applied	\N
154	1647	8	applied	\N
154	1648	9	applied	\N
154	1649	10	applied	\N
147	1533	0	applied	\N
147	1534	1	applied	\N
147	1535	2	applied	\N
147	1536	3	applied	\N
147	1537	4	applied	\N
147	1538	5	applied	\N
147	1539	6	applied	\N
147	1540	7	applied	\N
147	1541	8	applied	\N
147	1542	9	applied	\N
147	1543	10	applied	\N
147	1544	11	applied	\N
149	1545	0	applied	\N
149	1546	1	applied	\N
149	1547	2	applied	\N
149	1548	3	applied	\N
149	1549	4	applied	\N
149	1550	5	applied	\N
149	1551	6	applied	\N
149	1552	7	applied	\N
149	1553	8	applied	\N
149	1554	9	applied	\N
149	1555	10	applied	\N
149	1556	11	applied	\N
149	1557	12	applied	\N
149	1558	13	applied	\N
149	1559	14	applied	\N
149	1560	15	applied	\N
149	1561	16	applied	\N
149	1562	17	applied	\N
149	1563	18	applied	\N
149	1564	19	applied	\N
149	1565	20	applied	\N
149	1566	21	applied	\N
149	1567	22	applied	\N
149	1568	23	applied	\N
149	1569	24	applied	\N
149	1570	25	applied	\N
149	1571	27	applied	\N
149	1572	28	applied	\N
149	1573	29	applied	\N
149	1574	30	applied	\N
149	1575	31	applied	\N
149	1576	32	applied	\N
149	1577	33	applied	\N
149	1578	34	applied	\N
149	1579	35	applied	\N
151	1592	0	applied	\N
151	1593	1	applied	\N
151	1594	2	applied	\N
151	1595	3	applied	\N
151	1596	4	applied	\N
151	1597	5	applied	\N
151	1598	6	applied	\N
151	1599	7	applied	\N
151	1600	8	applied	\N
151	1601	9	applied	\N
151	1602	10	applied	\N
151	1603	11	applied	\N
151	1604	12	applied	\N
151	1605	13	applied	\N
151	1606	14	applied	\N
151	1607	15	applied	\N
151	1608	16	applied	\N
151	1609	17	applied	\N
151	1610	18	applied	\N
151	1611	19	applied	\N
151	1612	20	applied	\N
151	1613	21	applied	\N
151	1614	22	applied	\N
151	1615	23	applied	\N
151	1616	24	applied	\N
151	1617	25	applied	\N
151	1618	26	applied	\N
151	1619	27	applied	\N
151	1620	28	applied	\N
151	1621	29	applied	\N
151	1622	30	applied	\N
151	1623	31	applied	\N
151	1624	32	applied	\N
151	1625	33	applied	\N
151	1626	34	applied	\N
153	1627	0	applied	\N
153	1628	1	applied	\N
153	1629	2	applied	\N
153	1630	3	applied	\N
153	1631	4	applied	\N
153	1632	5	applied	\N
153	1633	6	applied	\N
153	1634	7	applied	\N
153	1635	8	applied	\N
153	1636	9	applied	\N
153	1637	10	applied	\N
153	1638	11	applied	\N
155	1639	0	applied	\N
155	1640	1	applied	\N
155	1641	2	applied	\N
155	1642	3	applied	\N
155	1643	4	applied	\N
155	1644	5	applied	\N
155	1645	6	applied	\N
155	1646	7	applied	\N
155	1647	8	applied	\N
155	1648	9	applied	\N
155	1649	10	applied	\N
156	1650	0	applied	\N
156	1651	1	applied	\N
156	1652	2	applied	\N
156	1653	3	applied	\N
156	1654	4	applied	\N
156	1655	5	applied	\N
156	1656	6	applied	\N
156	1657	7	applied	\N
156	1658	8	applied	\N
156	1659	9	applied	\N
156	1660	10	applied	\N
156	1661	11	applied	\N
157	1650	0	applied	\N
157	1651	1	applied	\N
157	1652	2	applied	\N
157	1653	3	applied	\N
157	1654	4	applied	\N
157	1655	5	applied	\N
157	1656	6	applied	\N
157	1657	7	applied	\N
157	1658	8	applied	\N
157	1659	9	applied	\N
157	1660	10	applied	\N
157	1661	11	applied	\N
158	1662	0	applied	\N
158	1663	1	applied	\N
158	1664	2	applied	\N
158	1665	3	applied	\N
158	1666	4	applied	\N
158	1667	5	applied	\N
158	1668	6	applied	\N
158	1669	7	applied	\N
158	1670	8	applied	\N
158	1671	9	applied	\N
158	1672	10	applied	\N
158	1673	11	applied	\N
158	1674	12	applied	\N
158	1675	13	applied	\N
158	1676	14	applied	\N
158	1677	15	applied	\N
158	1678	16	applied	\N
158	1679	17	applied	\N
158	1680	18	applied	\N
158	1681	19	applied	\N
158	1682	20	applied	\N
158	1683	21	applied	\N
158	1684	22	applied	\N
159	1662	0	applied	\N
159	1663	1	applied	\N
159	1664	2	applied	\N
159	1665	3	applied	\N
159	1666	4	applied	\N
159	1667	5	applied	\N
159	1668	6	applied	\N
159	1669	7	applied	\N
159	1670	8	applied	\N
159	1671	9	applied	\N
159	1672	10	applied	\N
159	1673	11	applied	\N
159	1674	12	applied	\N
159	1675	13	applied	\N
159	1676	14	applied	\N
159	1677	15	applied	\N
159	1678	16	applied	\N
159	1679	17	applied	\N
159	1680	18	applied	\N
159	1681	19	applied	\N
159	1682	20	applied	\N
159	1683	21	applied	\N
159	1684	22	applied	\N
160	1685	0	applied	\N
160	1686	1	applied	\N
160	1687	2	applied	\N
160	1688	3	applied	\N
160	1689	4	applied	\N
160	1690	5	applied	\N
160	1691	6	applied	\N
160	1692	7	applied	\N
160	1693	8	applied	\N
160	1694	9	applied	\N
160	1695	10	applied	\N
160	1696	11	applied	\N
160	1697	12	applied	\N
160	1698	13	applied	\N
160	1699	14	applied	\N
160	1700	15	applied	\N
160	1701	16	applied	\N
160	1702	17	applied	\N
160	1703	18	applied	\N
160	1704	19	applied	\N
160	1705	20	applied	\N
160	1706	21	applied	\N
160	1707	22	applied	\N
160	1708	23	applied	\N
162	1733	0	applied	\N
162	1734	1	applied	\N
162	1735	2	applied	\N
162	1736	3	applied	\N
162	1737	4	applied	\N
162	1738	5	applied	\N
162	1739	6	applied	\N
162	1740	7	applied	\N
162	1741	8	applied	\N
162	1742	9	applied	\N
162	1743	10	applied	\N
162	1744	11	applied	\N
164	1756	0	applied	\N
164	1757	1	applied	\N
164	1758	2	applied	\N
164	1759	3	applied	\N
164	1760	4	applied	\N
164	1761	5	applied	\N
164	1762	6	applied	\N
164	1763	7	applied	\N
164	1764	8	applied	\N
164	1765	9	applied	\N
164	1766	10	applied	\N
164	1767	11	applied	\N
166	1768	0	applied	\N
166	1769	1	applied	\N
166	1770	2	applied	\N
166	1771	3	applied	\N
166	1772	4	applied	\N
166	1773	5	applied	\N
166	1774	6	applied	\N
166	1775	7	applied	\N
166	1776	8	applied	\N
166	1777	9	applied	\N
166	1778	10	applied	\N
166	1779	11	applied	\N
166	1780	12	applied	\N
166	1781	13	applied	\N
166	1782	14	applied	\N
166	1783	15	applied	\N
166	1784	16	applied	\N
166	1785	17	applied	\N
166	1786	18	applied	\N
166	1787	19	applied	\N
166	1788	20	applied	\N
166	1789	21	applied	\N
166	1790	22	applied	\N
166	1791	23	applied	\N
166	1792	24	applied	\N
166	1793	25	applied	\N
166	1794	26	applied	\N
166	1795	27	applied	\N
166	1796	28	applied	\N
166	1797	29	applied	\N
166	1798	30	applied	\N
166	1799	31	applied	\N
166	1800	32	applied	\N
166	1801	33	applied	\N
166	1802	35	applied	\N
166	1803	36	applied	\N
166	1804	37	applied	\N
166	1805	38	applied	\N
166	1806	39	applied	\N
166	1807	40	applied	\N
166	1808	41	applied	\N
166	1809	42	applied	\N
166	1810	43	applied	\N
166	1811	44	applied	\N
166	1812	45	applied	\N
166	1813	46	applied	\N
168	1814	0	applied	\N
168	1815	1	applied	\N
168	1816	2	applied	\N
168	1817	3	applied	\N
168	1818	4	applied	\N
168	1819	5	applied	\N
168	1820	6	applied	\N
168	1821	7	applied	\N
168	1822	8	applied	\N
168	1823	9	applied	\N
168	1824	10	applied	\N
170	1836	0	applied	\N
170	1837	1	applied	\N
170	1838	2	applied	\N
170	1839	3	applied	\N
170	1840	4	applied	\N
170	1841	5	applied	\N
170	1842	6	applied	\N
170	1843	7	applied	\N
170	1844	8	applied	\N
170	1845	9	applied	\N
170	1846	10	applied	\N
170	1847	11	applied	\N
161	1709	0	applied	\N
161	1710	1	applied	\N
161	1711	2	applied	\N
161	1712	3	applied	\N
161	1713	4	applied	\N
161	1714	5	applied	\N
161	1715	6	applied	\N
161	1716	7	applied	\N
161	1717	8	applied	\N
161	1718	9	applied	\N
161	1719	10	applied	\N
161	1720	11	applied	\N
161	1721	12	applied	\N
161	1722	13	applied	\N
161	1723	14	applied	\N
161	1724	15	applied	\N
161	1725	16	applied	\N
161	1726	17	applied	\N
161	1727	18	applied	\N
161	1728	19	applied	\N
161	1729	20	applied	\N
161	1730	21	applied	\N
161	1731	22	applied	\N
161	1732	23	applied	\N
163	1745	0	applied	\N
163	1746	1	applied	\N
163	1747	2	applied	\N
163	1748	3	applied	\N
163	1749	4	applied	\N
163	1750	5	applied	\N
163	1751	6	applied	\N
163	1752	7	applied	\N
163	1753	8	applied	\N
163	1754	9	applied	\N
163	1755	10	applied	\N
165	1756	0	applied	\N
165	1757	1	applied	\N
165	1758	2	applied	\N
165	1759	3	applied	\N
165	1760	4	applied	\N
165	1761	5	applied	\N
165	1762	6	applied	\N
165	1763	7	applied	\N
165	1764	8	applied	\N
165	1765	9	applied	\N
165	1766	10	applied	\N
165	1767	11	applied	\N
167	1768	0	applied	\N
167	1769	1	applied	\N
167	1770	2	applied	\N
167	1771	3	applied	\N
167	1772	4	applied	\N
167	1773	5	applied	\N
167	1774	6	applied	\N
167	1775	7	applied	\N
167	1776	8	applied	\N
167	1777	9	applied	\N
167	1778	10	applied	\N
167	1779	11	applied	\N
167	1780	12	applied	\N
167	1781	13	applied	\N
167	1782	14	applied	\N
167	1783	15	applied	\N
167	1784	16	applied	\N
167	1785	17	applied	\N
167	1786	18	applied	\N
167	1787	19	applied	\N
167	1788	20	applied	\N
167	1789	21	applied	\N
167	1790	22	applied	\N
167	1791	23	applied	\N
167	1792	24	applied	\N
167	1793	25	applied	\N
167	1794	26	applied	\N
167	1795	27	applied	\N
167	1796	28	applied	\N
167	1797	29	applied	\N
167	1798	30	applied	\N
167	1799	31	applied	\N
167	1800	32	applied	\N
167	1801	33	applied	\N
167	1802	35	applied	\N
167	1803	36	applied	\N
167	1804	37	applied	\N
167	1805	38	applied	\N
167	1806	39	applied	\N
167	1807	40	applied	\N
167	1808	41	applied	\N
167	1809	42	applied	\N
167	1810	43	applied	\N
167	1811	44	applied	\N
167	1812	45	applied	\N
167	1813	46	applied	\N
169	1825	0	applied	\N
169	1826	1	applied	\N
169	1827	2	applied	\N
169	1828	3	applied	\N
169	1829	4	applied	\N
169	1830	5	applied	\N
169	1831	6	applied	\N
169	1832	7	applied	\N
169	1833	8	applied	\N
169	1834	9	applied	\N
169	1835	10	applied	\N
171	1848	0	applied	\N
171	1849	1	applied	\N
171	1850	2	applied	\N
171	1851	3	applied	\N
171	1852	4	applied	\N
171	1853	5	applied	\N
171	1854	6	applied	\N
171	1855	7	applied	\N
171	1856	8	applied	\N
171	1857	9	applied	\N
171	1858	10	applied	\N
171	1859	11	applied	\N
172	1860	0	applied	\N
172	1861	1	applied	\N
172	1862	2	applied	\N
172	1863	3	applied	\N
172	1864	4	applied	\N
172	1865	5	applied	\N
172	1866	6	applied	\N
172	1867	7	applied	\N
172	1868	8	applied	\N
172	1869	9	applied	\N
172	1870	10	applied	\N
172	1871	11	applied	\N
173	1872	0	applied	\N
173	1873	1	applied	\N
173	1874	2	applied	\N
173	1875	3	applied	\N
173	1876	4	applied	\N
173	1877	5	applied	\N
173	1878	6	applied	\N
173	1879	7	applied	\N
173	1880	8	applied	\N
173	1881	9	applied	\N
173	1882	10	applied	\N
174	1883	0	applied	\N
174	1884	1	applied	\N
174	1885	2	applied	\N
174	1886	3	applied	\N
174	1887	4	applied	\N
174	1888	5	applied	\N
174	1889	6	applied	\N
174	1890	7	applied	\N
174	1891	8	applied	\N
174	1892	9	applied	\N
174	1893	10	applied	\N
174	1894	11	applied	\N
175	1883	0	applied	\N
175	1884	1	applied	\N
175	1885	2	applied	\N
175	1886	3	applied	\N
175	1887	4	applied	\N
175	1888	5	applied	\N
175	1889	6	applied	\N
175	1890	7	applied	\N
175	1891	8	applied	\N
175	1892	9	applied	\N
175	1893	10	applied	\N
175	1894	11	applied	\N
176	1895	0	applied	\N
176	1896	1	applied	\N
176	1897	2	applied	\N
176	1898	3	applied	\N
176	1899	4	applied	\N
176	1900	5	applied	\N
176	1901	6	applied	\N
176	1902	7	applied	\N
176	1903	8	applied	\N
176	1904	9	applied	\N
176	1905	10	applied	\N
176	1906	11	applied	\N
177	1907	0	applied	\N
177	1908	1	applied	\N
177	1909	2	applied	\N
177	1910	3	applied	\N
177	1911	5	applied	\N
177	1912	6	applied	\N
177	1913	7	applied	\N
177	1914	8	applied	\N
177	1915	9	applied	\N
177	1916	10	applied	\N
177	1917	11	applied	\N
177	1918	12	applied	\N
179	1930	0	applied	\N
179	1931	1	applied	\N
179	1932	2	applied	\N
179	1933	3	applied	\N
179	1934	4	applied	\N
179	1935	5	applied	\N
179	1936	6	applied	\N
179	1937	7	applied	\N
179	1938	8	applied	\N
179	1939	9	applied	\N
179	1940	10	applied	\N
179	1941	11	applied	\N
181	1953	0	applied	\N
181	1954	1	applied	\N
181	1955	2	applied	\N
181	1956	3	applied	\N
181	1957	4	applied	\N
181	1958	5	applied	\N
181	1959	6	applied	\N
181	1960	7	applied	\N
181	1961	8	applied	\N
183	1962	0	applied	\N
183	1963	1	applied	\N
183	1964	2	applied	\N
183	1965	3	applied	\N
183	1966	4	applied	\N
183	1967	5	applied	\N
183	1968	6	applied	\N
185	1975	0	applied	\N
185	1976	1	applied	\N
185	1977	2	applied	\N
185	1978	3	applied	\N
185	1979	4	applied	\N
187	1984	0	applied	\N
187	1985	1	applied	\N
187	1986	2	applied	\N
189	1987	0	applied	\N
189	1988	1	applied	\N
191	1989	0	applied	\N
191	1990	1	applied	\N
193	1993	0	applied	\N
195	1994	0	applied	\N
197	1995	0	applied	\N
178	1919	0	applied	\N
178	1920	1	applied	\N
178	1921	2	applied	\N
178	1922	3	applied	\N
178	1923	4	applied	\N
178	1924	5	applied	\N
178	1925	6	applied	\N
178	1926	7	applied	\N
178	1927	8	applied	\N
178	1928	9	applied	\N
178	1929	10	applied	\N
180	1942	0	applied	\N
180	1943	1	applied	\N
180	1944	2	applied	\N
180	1945	3	applied	\N
180	1946	4	applied	\N
180	1947	5	applied	\N
180	1948	6	applied	\N
180	1949	7	applied	\N
180	1950	8	applied	\N
180	1951	9	applied	\N
180	1952	10	applied	\N
182	1953	0	applied	\N
182	1954	1	applied	\N
182	1955	2	applied	\N
182	1956	3	applied	\N
182	1957	4	applied	\N
182	1958	5	applied	\N
182	1959	6	applied	\N
182	1960	7	applied	\N
182	1961	8	applied	\N
184	1969	0	applied	\N
184	1970	1	applied	\N
184	1971	2	applied	\N
184	1972	3	applied	\N
184	1973	4	applied	\N
184	1974	5	applied	\N
186	1980	0	applied	\N
186	1981	1	applied	\N
186	1982	2	applied	\N
186	1983	3	applied	\N
188	1987	0	applied	\N
188	1988	1	applied	\N
190	1989	0	applied	\N
190	1990	1	applied	\N
192	1991	0	applied	\N
192	1992	1	applied	\N
194	1994	0	applied	\N
196	1995	0	applied	\N
198	1996	0	applied	\N
\.


--
-- Data for Name: blocks_zkapp_commands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.blocks_zkapp_commands (block_id, zkapp_command_id, sequence_no, status, failure_reasons_ids) FROM stdin;
\.


--
-- Data for Name: epoch_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.epoch_data (id, seed, ledger_hash_id, total_currency, start_checkpoint, lock_checkpoint, epoch_length) FROM stdin;
1	2va9BGv9JrLTtrzZttiEMDYw1Zj6a6EHzXjmP9evHDTG3oEquURA	1	23166005000060590	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	1
2	2vafPBQ3zQdHUEDDnFGuiNvJz7s2MhTLJgSzQSnu5fnZavT27cms	1	23166005000060590	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKYJD5uqLAzaNw84ezoTkqtqoMUfahtJUwhhTPc2RZxppuWLbcY	2
3	2va9BGv9JrLTtrzZttiEMDYw1Zj6a6EHzXjmP9evHDTG3oEquURA	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	1
4	2vafPBQ3zQdHUEDDnFGuiNvJz7s2MhTLJgSzQSnu5fnZavT27cms	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLKxXG3yCTXiyngU1vQmEFhys9FYRCqprgGv56i4PRqKHmEyPe4	2
5	2vaYNq61ozBGhpsWY7tzHN1hNvRzTzRocEtVHkVJTdwgHN7FWXxu	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKMhhH48jsKBUkvBRUx2uSUTYdkPW3nrxcyxs5QC8bY6JupeAV5	3
6	2vafkT5PMJHENHKynuKEihox64MJ3dRdqXZb5d83FjfVqJBM1sBd	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLcDfYH9Vri9z3hA1QmB8QF2BcMtxNk3pmuNH4aRaR41jPxWiJr	4
7	2vaFc71bAC6S2XaP5oV4nPweTRxm1qUMn8XZSHktHkbkD2ejmBm3	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKufDWrUwKDKuV5FjbgcuKcJp7rgyPwXwtwd8PmXCNLkFs22kQd	5
8	2vasAFfN6QreTzTEPbTySGZfgXHMTkYqnPTeSjggR6wV8vtMXVpa	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLY71gpjYcdAspPEdjpJSEsVr2G3DZq2HCLkJyCrzhQ99Qr3vQu	6
9	2vb4znJkPiEscMtG5RCaEPpCfKug3pb7XZkWFJ5FQ3HqUExdfxyq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLY71gpjYcdAspPEdjpJSEsVr2G3DZq2HCLkJyCrzhQ99Qr3vQu	6
10	2vaD94RvQpB8ZM7DsmM6Kq8i8jNFgnMhwyX5dvgUvd44JhvhebpY	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKEJ1MgRBtLQncoqNvey8Tm25jy4pWiKAQkrSpja4h1q8GQDkEL	7
11	2vaxB2YrBm1usNNcViiAvAGNs99WyE3gzTYt8ceZf8Z7A8JLFLnC	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLuJJ5VayuHP249tDcD6fvNA4c4Z5woqmnLcwZ9RkXMQyD9r2wn	8
12	2vabBxbj1eLmZntKYaRLSVAufTmSzDnnVRQTVGZG8p8i29VE3Jts	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLuJJ5VayuHP249tDcD6fvNA4c4Z5woqmnLcwZ9RkXMQyD9r2wn	8
13	2vakAdxiVgySPbURh2mXGVqjUu193ck3QtWtZURziL8r9oXvDDkf	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL6XpYnuHbMUbxu1sMEDpk5gwZdSDy16XwjuwLZPhmVafJkfNMV	9
14	2vbGa1qbASHLc3nEwqYyG7FSoWR3PGXKH2NVKqwyeNfzdfM9Dqhc	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKpEmo7d6tfHYaHqJ6B8pvvb3EmV3GkguTooV1TGVh1jAJjZrpL	10
15	2vaKqCwgGN9tf7bAww7jFg2RGS19uDP797xWgyvxStfTmm1fc4Rf	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKpEmo7d6tfHYaHqJ6B8pvvb3EmV3GkguTooV1TGVh1jAJjZrpL	10
16	2vbtEFLGMeStkTCss3owWEPrFSiBFCTqgNg9rKBAETZtkNVQV1WH	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKztAk1ELqVngzW2PVy22FNKStWLJdryC4ghpBcdZNvAbyk2aJQ	11
17	2vaaWw78DdSdEXv5pWnJ2e6XCeDdXA1w8rZ7iyQKkvhgjs4jSKMu	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWv6pZFTHQT49ph415B9SFTFVvRX7gg6n1xHhar5BBAztj41gi	12
18	2vby24tBXaQwxrCuhcsvcQdqbjN6cSi1MDeHFNFWR6oomFRmumnE	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWv6pZFTHQT49ph415B9SFTFVvRX7gg6n1xHhar5BBAztj41gi	12
19	2vb8gpw6KoW21ekw2XkBUwTfjsGNq1AdQHySPJjQW4ouR4PLuwgF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK6WYVkC4kYiUmwnToiFKwoBoEM1dQUBiMX5P7DvAkuCCbdJRam	13
20	2vbXV9TunqYjSQ55g1Bxr7x3iMdEgMN97nKPMGAnrFi8d8Aiw8Vt	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKorEcgjL98MXxj8p7sPRafrTux3vi7aVun2ACLmLRPhB8JBiBZ	14
21	2vbr1X1unaURajggqStxDeYwrB8qie6ArQfzVTxwdpxRzNaXkMnK	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKj41kDEyLbxFNoBLUXLePkXGeBkSs7p1h4sKqnNjSaygWZ6xu3	15
22	2vb1KctCq6d7drJXwGb5rmQM5QNXs1nVoB6iJ3Z7FpzrpquvX9aF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKNDSbmEkpEMrCr9n4DXDaCX3H8kpeEBvyukLkYtj6yKuiRiR1w	16
23	2vc5ubfX9ZksNEiemat59zRyYLRbixWofchVsBBBaSRWjsEgsib5	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKrYGzURCtypvNocFigJ2ASMUgf8JB5PXG6YoX6hJEom1h2EDib	17
24	2vc55A6Q4aw8egRZmCDGToosTHcQcqN2dg8EgmTd34o32dU4Pitp	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKrYGzURCtypvNocFigJ2ASMUgf8JB5PXG6YoX6hJEom1h2EDib	17
25	2vbj3n5hi6NnS1KJT8qJgiQNaWDhreDP28Wam5xwinSkSJZGzS8h	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKdTWpKMrG45oN5TTngfDfJYpKbF9be9RT3T4LZ7hK6fCkLcaWz	18
26	2vbTSAW71sTBv3UUECaGMVukGmcQHW4m8TaLo215iQEAe1rXN5ux	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKdTWpKMrG45oN5TTngfDfJYpKbF9be9RT3T4LZ7hK6fCkLcaWz	18
27	2vbT3BLCcPd8C5qAwstPAqrMxZrLFH5vCyh8nyVCTkU34BWHkCgp	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLfEG2PnqVQcvwMEZmDNHGzSijoH9jyDLaAkrqyKDqQbRxAR2ru	19
28	2vaZHaLS98ikFdps6n6NcXciGefbzFexKJAoMfz43qEbuMB7xCdU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKR2TYjo6Ytd2PjZySXgMTNSJHs3CgZP4rMMNnjSqWWVfbPD2aT	20
29	2vaTAuciwWboCLbNVqAdc5z12G6tUGRCp1CV4pUfBUTaMhoQrzJs	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKR2TYjo6Ytd2PjZySXgMTNSJHs3CgZP4rMMNnjSqWWVfbPD2aT	20
30	2vc17NWbFoAPQ9yLrTNVG6YJhkRBPWTaQHtBy1mPYREQKXiPgyoU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK7PU2JH8UMjctt7H6TLtYs8dHqkFZniGQBWk8Grxip8EHcB1xv	21
31	2vbMG5dBgyuAaHC3SEc3STt1qAo5PCBPCEagLwdGRoeWjEWXNqWc	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLQQCS5SoJZz8neUvRK9GTyFeMqU5ao4FjaHkSvGQgA2a2QooFP	22
32	2vazzm5dZmS1B8T4SJVxauJQcuAk7UcDTCf9hJeuFX8BUYXzhCWt	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKcycZV3Ze6mpb8qJSrsszjY7q2o5Q8xNzf8thU2tgVQeh2AQhr	23
33	2vc3QQfXKFDGSH6C4w4YzNFUBVEkQaYfxEY1qNV3H1mGoDneiayg	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKcycZV3Ze6mpb8qJSrsszjY7q2o5Q8xNzf8thU2tgVQeh2AQhr	23
34	2var53RxH5CdTjhmcdrWhgWpT3HVEqaxWKrDUPPAwQeBU21XHXTH	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL1LeZfKxoS8mwvv3dYGxwBfhrbu6K9x64XpsKNmBr8ENYWbmEt	24
35	2vboZeEkqXC1Z71znPP2Yng7oh4yv7zLoEpxkpeQro5n32qXpLH1	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL5wGFLPU4o5NqMKjAWV75Ryu6pNpjX8wUJRPMSh9rQYWg8vmrt	25
36	2vbddQEd1ArwnUXTA6jsCyaPxo6dd7xNeJuBbVny7UcasfrEzKkw	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL5wGFLPU4o5NqMKjAWV75Ryu6pNpjX8wUJRPMSh9rQYWg8vmrt	25
38	2vbW7DivAK4FboyKGVSDS3tkitvXnWw1WU9EH9UhXBZTWiX9Qez4	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKEiJvoLnnoCxDhZDM5npu9LgHuCyYBiobP7BshkqYHZ5RxBLNy	26
40	2vaYuHtPD2Fp8KZigZ7E5Jp6Tf9UnJq6o3TTBWirDNC1ntpSTK5H	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKyeXLfp1ku1SGPDyBNFMnQ4rqrJFRjgX7HHBgXVnaYQNNvGiHf	28
42	2vaomPYB2bWL7ZPnSTUKPhCN9qgQfitkeDWzGiDd2x8TEWaVHvu6	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLx5o8c1atdVaso3EPboA7tcDxMQhenGXoVp3wmtRhdTpojykYw	30
44	2vbzQ1Xu8CStbZeNxzMJER6DoqrRNvCZqUUwz2uLGZLSNKrFU1sK	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKpEwiqYsHb3uNawoATmxyhGUNq1Zbv8bVhty2QWagJbp4sGjft	31
46	2vabSjNDSyKX4JPQRYnyBM8dB9tvJgTvRdMSaiaJnzGKtCdWTHRd	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL7ujjX3xNqrwmhNGZ8EicNe2Jx3x514q6KbwgNh8wWVzRE8oEX	33
48	2vbyUWJ2YmrkKmFoYyiuscZy4j164MvN8gBqodSmRT47a4emaXfL	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL3ZXiZrm6c7S7srDDhzpBEne6drVukgcGLW9xe4HfWqE45gwxD	35
50	2vaMeReJpYvb9XDzHoqAJiuSd1eFVf6ZUjb6QqShyF19a1NG49mJ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKwe21LacDRT9EY2kpfsbMwj9tM65owRhJMdwhJLAunLGAAHZ7n	36
52	2vaLr9ssHdo7b9oQt1c2NXA4XdcmtDBhgEDcBjyT6XiqDzoiZgs3	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKuSjg1FjCCrWohZGC4bu9RMVQdHGKeoQLxTXu29xwoUCSSnfij	37
37	2vauSXacmCgfGCATY4TD1iapNrN7Y6pBRDfLQM83AnYysa8i8NUZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKEiJvoLnnoCxDhZDM5npu9LgHuCyYBiobP7BshkqYHZ5RxBLNy	26
39	2vaAdwKwBu4EKKXn4QfLV4NNUC1S36hm5bZEiTZr7hgx2ppqjNJn	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL8vVF25CxR5tGTNMsyQhWb2aB4PyJtg6bPhzLKBFkxpCPnxRo9	27
41	2vbNeEJSijt9TMkdVD6tgHTHs7goW5fu7wBsjDZz1eaaiyhgw9NA	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKpVf5cZftJ1WztwhMuRZguF5WXC5ncQAqiX8N9bqTD35jpdirD	29
43	2vaLQuk3ALwJ7u7KYCyPGqWixcKu9TN3WbMK4LnqsF4zaK3mfE7u	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLx5o8c1atdVaso3EPboA7tcDxMQhenGXoVp3wmtRhdTpojykYw	30
45	2vaxAoW62dmrkCDkRvDmRo7hXSFwRzdsiXJsz9A7GXd4x4oNxbiq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLHahpxn8jMkSHc6kMjb5xUVx927FMVKeHwo8ki4Ts6yfoXqA9i	32
47	2vc2pbC5ngiN2zTk8F6ZufnyKyndW9snhvVv8KMcQwQEgA2pZQkS	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLRxXh7ZP7neRYK8KqXbDxKXqy8Tfuet15NrW7dEAbks2LNmyAW	34
49	2vc45N84HofcSv3goXnmbLjYgE6rHoKxiokEC69ioqC2DRLptXEu	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL3ZXiZrm6c7S7srDDhzpBEne6drVukgcGLW9xe4HfWqE45gwxD	35
51	2vamczW6c8KbY5ZFRioVWnJ44ajqxLX1JSxbZehf3hrhqMh9jM1n	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKuSjg1FjCCrWohZGC4bu9RMVQdHGKeoQLxTXu29xwoUCSSnfij	37
53	2vbE1fwRhRwewUNG7VR5zWfixvqNNwkEkRgmd12LLEZ1DojnV33m	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKhpJNxkhRDmGx9cebCmEwQJX4M358UXxWhfc21oWHyrToANLFq	38
54	2vaoAacgiGpPuKbfJpoUy2q6kKfbd4BLWqsFUZgxH6YmpV8iL15i	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKhpJNxkhRDmGx9cebCmEwQJX4M358UXxWhfc21oWHyrToANLFq	38
55	2vaANxNGDd1VegT6ZCgGfbLHvBFkC6TZqkW88EDT79aXdaxkFAgH	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLaEht1ws1nvHXGYET8xzLdidnZgsW91BRiwcTfjq3DwrjhkaYL	39
56	2vbsJBGZJ3hDrZMWj6DqNmEDQic5pKtiYUhtW5bx8QxWG8Ph91Mm	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKTizg6EwR9bfQyLKij74XXK7gAqTmGQsXRWbm2arsvVTxY4KTc	40
57	2vbQ6PmgFjYy8oP5e2Q1eh4XJfWd38pjjVCsZJnUfhPo5m9cQSVs	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL8jkmV6GEWp9nY8H14A4EcJAwE9LLk6QJZf6f9bxNZeeLhVonk	41
58	2vb6BNC8w8MMbT88YhGu8sL5VgwqLnQh7S7FRtzssCDP7v77JLNR	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKmueVN2e8jEMPuwfxe4LijYS7hW2GgkcBhBj5gtzW7vnxqiqLu	42
59	2vahXmDLi2JiFW745Tf4cVFfz4Ej3kW8hieNvRYo6ZLWxs9KpSPd	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL2xj23q9ZT4VcxRX12HLPq7L66hpe7EbgRUY8WYCK41DaMnEy2	43
60	2vbYxUy7D7iZj2W38JWPnuKMJ1Rrc3WjeUxUPJZMRGB4Tbs6gtHr	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKswcMrYnafGdL6c8QyPSyChM75yM9RX2HaKH8n7ocjzTwEFNgB	44
61	2vbxw1Tx5L1TrL5tvkd6keKkRSK8UfCDqjXiXQb1rtQko4b4A4Bh	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKz8FsMhN3BYshzMPvpPsBu3PBY8rKyD8xDfQxWKiXNNQDa3FCp	45
62	2vaZxF1TxKADnvZ9dPd9ynw3ZQaMbze49XoaK26s2ZmrSZPmfezm	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWLEvdp5MAmDBUGMqWQrkCBv2L9jKcUWChDuuSXrDRRUZUo19Q	46
63	2vb9zzmTcXhYvQiAcJWeJuKeFeh6FtMaQQR1VbHfXoBomfDzeFkU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL4PNipRErZPUSJy1gQ7W5UFuC8QcXMmaQ4haJEju8bCirDFGNG	47
64	2vaHKHLRevFtmzGGkMPQHnxJdvL1NndMDLjjgV5bjw1jrfJuKCSV	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKdFPAoXoRr93QtTebXXKyQJcVSD64jva7NriVBYe91YwaZMcAT	48
65	2vbCHbzs89UuSgVsL8H4624dqghwmnh1wSyZQ5xx7yhr9Azzc2Qe	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKE2Y33fTexFaYhXL5kdbo7zq7TMmPQUg9d7MFxwSQpBppo4VEG	49
66	2vai9E5AjGvUoNmrUFcPqNQReKzWLk3kbNmfsiBGhiAc92EnnN97	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLitghzLv6neSQXNNy7dp21kskzQ6WBnYqw6HMnGYBsoALTwVXB	50
67	2vaBHp2pFVismxWV3LcHpBUv8984JQ2n1fA3oKLYTGYGSmb6RGhM	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKutudiEDK7m6RZoMRHTCWAhUR1MLMWc64CJBhkAAhREURKCGoH	51
68	2vaWhRvA5LDyCkzfwtkiCS4Z1yeq9diD8VLhFMdeUqAy9q5kKoS7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKutudiEDK7m6RZoMRHTCWAhUR1MLMWc64CJBhkAAhREURKCGoH	51
69	2varanGkDfqNfoh5UzupjztiSamcVeXKpD3fZJeJC6RdgogZi554	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLp5Waz1YTUPL1RvSNUpQR4oj1Cfkvdy4LcVqhJ7ix3nmeA52Za	52
70	2vagj3vtHpP2NEthjsynW3FdSJVkBr1CeHZiHHoM6hHbSuV1pFFa	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLSAaN8outZkdFsS5fy1xAC4bf6KprHwrtaGYJYHZHcsHg5Q4VD	53
71	2vatuGikVPzBB3xSEDREHADupFPNzXj4mrLLAifFPWFcAw8JzU19	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLwnyfnyrLQokcWP2SpMSFHZqfrRg9NNAmey3yGeGzWLdhjizfe	54
72	2vbe5a3WeoekPfkBdkMv45zSBfQBD7xW8zexSWeHjTCZJeGRxSrd	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK4tp26pCCDauzQoAoNdu1Btm2pAfpikpSVBTe9rgVxdwXmeWkn	55
73	2vbW4R7gyvoRCFntBbZ5D9wnzpTEKMmhL6NNagCNsvMtWyKmDmY1	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK4tp26pCCDauzQoAoNdu1Btm2pAfpikpSVBTe9rgVxdwXmeWkn	55
74	2varr6ZCyD8dBcQvtmM5wDPpqE1ktqrJUACwpLcK5untkiXTpBEU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLxVXVSFx8P1trWVj8uXgQk1HQ3Cs1KDw6aCPGiDtfNnCerMoJh	56
75	2vbSeHGRuSbUfm589bFX9TZDSDwG5aEsU3tEgBW2aBzyXqQf55L2	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLxVXVSFx8P1trWVj8uXgQk1HQ3Cs1KDw6aCPGiDtfNnCerMoJh	56
76	2vayEqL5AMKtp2cr21NdNiuAu8kD6pmkPCphrokzK7H4WCYBGQqj	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKQ1Tjnb7oMqDk6f1QjDcmpiQGirGRe4zVqM4SaHQtyXYGg2KkP	57
77	2vb1ZAeAR5rpwKYLZap4u6zPqGAwdRaPwpaeE8matmibCQfiJE2V	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKQ1Tjnb7oMqDk6f1QjDcmpiQGirGRe4zVqM4SaHQtyXYGg2KkP	57
78	2vaHbGXd4Ffox5RuWxvuny7w1HfHSTtX34FmJYemVA278pwGNk9a	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLwFAaqQ6FQf3WW6Wbs5gHYxkYfdGcmmdCSiBzj4MHCvxD5RrGA	58
79	2vaJRaprrVWV9hePEdWDdxaUXWhit8mBUeYDQN32YVLrFE4AVkrF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLQZSz4VWd5fk3PtzNZeXELipFH1KvLwzdJw7piYwf4i7vV569u	59
80	2vbHaF3DE1H6iQDLaJQv5rsWUibVrtCrN9tNAgtBju6ycYKw8Zo7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLdynrmLjzAcgqFeE2P1hAg7SmdgNuHEWeCCgBotqQtMTPXfae1	60
82	2vc5YZWhFiYxnUwPjkCngVW8K93DbL54uGFdADDn7X8FHDsBwqqQ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLayBmoNTyco638KvtjH9YATELgnp7AJZJDJpXwPZTrdRjeXmr2	62
84	2vbZN4Qkf7UspMfa6wYGNLit5h5Yyff6Hc2VFhdjiwk8P51cX3aC	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKGy62tQGj54RPWvAdAHvSdDKiQrLXFwGR9p6Wby4g5q6YX1YL2	63
86	2vaZBRdvUbmp7HjKyhrf7ExJX75FUzGN887A3JVokrpfVt4dKh8Z	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLpcao7SPnuBpqCzdgsxmPuvt9B5uTqzuXVFesp4qhznkUN7i7W	65
88	2vasp9hgxVCmtg2uHhxDySnCvTUDb4CwMeH3F5nLcrgAQeBC6Y1r	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWgqvGBwkrwvjJq2GqxyuMT2xRfiGgz4nLm9AjzuAXmbsKwfwK	66
90	2vbmQUL9PiARTaz7dbassPixjS8a3uRtnewNEMT5cQk8BQuT393b	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKLbi2uXWfZHfrrTmpbQxDMrxXQWPj6doLQ5JZ4cUCLxvfGuGJV	67
92	2vaPM1taGVZPpLMWvAy4EeEe2rYB3pCQuS1CBsCrnXo2Bb1cBmQA	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLYbos5rhZmn2eAF1XLnzWxBGrGQkkZQ7xkGLxYr4Yvu7wiBD83	69
94	2vbRdQX4JHY7VstnQfmqKxudS2DTBhtaPeN2wJtGZeUQ4uwV71Yc	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL5pTSeiFLabjrbemXxWFcixNoKdrSm1ZjeznuSwmBGrRtjgcFq	70
96	2vaDbxdLL5Qz1VbkWFve8sjwQZTd7s78eEuvwqdgC1ZSkCwQAyr8	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLD3XBKTLoTBt54baqQceMUeHBYkKK9zHnoSdrYbKPgr2QrD451	71
98	2vb5hyF5gnYTJeTM2a8LnqiTmuJgcnKw2GAegyt1ujnHaqhB2eia	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKsXJERS4LiDDLJVjaPrPAfEVfnz9wH5o1S1JQbDomU3UUoLVNH	73
100	2vajo8DW6Zm3Hb65tjunWjbZKG6sayKCB4C99ZW6jBvNNNb73Chz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLSCvaVhk9NUwuwGQMy95PahvheQGGNtT4toE5aNTaDtqXmpJH4	75
102	2vbJKCGjwni3sYrDoCAAgxNaJ2E27fqJjyFwuym51cmP7a683JCF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKYVYjDTV1V2Ksq9vsBhBsVmGayVhhigKHuYZcgdnZFoa7DPxnR	76
104	2vbdTE5Yuj3FqmWPexVhRAgYNHdF6p5a9uY3hdLsrwHzLKVFhoow	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKSMBEkRJKQ29n586gss7GudMtqBH9HhqhVUPUxi4E8ioF1xk85	77
106	2vbwQSnarjuJ1Q3tgDuusEpFMzVWDugyXRaBsA64XRFgVLrCW5SU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKbBdrUjkGBcrrtk9kvmyPRbLnLJd9jDqwhwREzHKK2qzi9X8sM	78
108	2vb8nRGVZh8AJSM7ie8HjARJREn8qgdYUMypDh1QqHYyy9m1TKbe	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLpY5M6mbhQHu4Q9TocYZmXU6424hGsj8gqeTxtoHc5LdvCaGKf	80
81	2vaVTkr9T5cH4YuKfgDmNfwpKF1dNgyZPuNkEbNuB5j5Mt2TZqCk	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKe2JHDtpodL3YnDq1o8FqG6ZieZSXRt93dYL9esAacoGA65YoN	61
83	2vbNu1cymS22deovjnfFQJB9WRtM5moWFLftVRTxLJ6oBntCifqz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKGy62tQGj54RPWvAdAHvSdDKiQrLXFwGR9p6Wby4g5q6YX1YL2	63
85	2vaWPB3KSvcebSc7nYz9wp3M9R2NLMRyfrhEexSs2bpiZqRRZmRq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKwgYNCZuViu3z3nmVF6dDR58CcLcbiuFP35oztUGd1LKy2bpgq	64
87	2vbAWeRai5boRGntiZqsigJ7SfLQZESLASCdd52XHyeZxmAoFNAH	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLpcao7SPnuBpqCzdgsxmPuvt9B5uTqzuXVFesp4qhznkUN7i7W	65
89	2vc4Cx2hJ7xtXE5CoViGkaGTiC8HsBx4G6mAsL132g37QHYvVdgy	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWgqvGBwkrwvjJq2GqxyuMT2xRfiGgz4nLm9AjzuAXmbsKwfwK	66
91	2vaueu1w7GnjXXTCvuSTQErtBf7zwah6SdcfBWYBeji1kbEAFXcZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL1QsccNeqQHq4V7wqWDtAWXiPa9YeheXjFxc9DhAGvgkckAVa6	68
93	2vaooPc3eFAhziiuQFbztvL2nL9x2oCxxKCvCDTTuLwmftSCbC8U	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLYbos5rhZmn2eAF1XLnzWxBGrGQkkZQ7xkGLxYr4Yvu7wiBD83	69
95	2vb5CciC15eo9ANxp3h13HYXdVpYqb7sceHPA1r2noUUwxKfD148	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL5pTSeiFLabjrbemXxWFcixNoKdrSm1ZjeznuSwmBGrRtjgcFq	70
97	2vaThwrwfTkJVbv4jPwUZC6m9Jpt2NBEpP9TQV5CksKBaVKXKTRi	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK361Mxk18yrvfvyQgvZHhKeeDSiHrFhebj95xF65f36dHnvZS9	72
99	2vb2ap8WSMMBU5vVjQaknW7egccafFwYsLwuHtr4KQYCohSiQasE	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKL7eoAEEXRdEB2TtzwZLcawaS2VAsrgBgLzgUtstNCGRnMXY4V	74
101	2vacNyTDZ1CP1YgxsPbR4k7E9wMMQHRr233TmEUeSg6UhgrHZQUU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKYVYjDTV1V2Ksq9vsBhBsVmGayVhhigKHuYZcgdnZFoa7DPxnR	76
103	2vaNnnoT8PQokxVtVAq7P3z8De79YVXzX3hL3TGp1j1jRpS7D5ud	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKSMBEkRJKQ29n586gss7GudMtqBH9HhqhVUPUxi4E8ioF1xk85	77
105	2vbSVvbwQzS7D6f3DkDch8ieGRqny9G9dGcRSuT2WDG6SMSxs6zb	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKbBdrUjkGBcrrtk9kvmyPRbLnLJd9jDqwhwREzHKK2qzi9X8sM	78
107	2vbyXU4AYSeDoBw1ARay5Vus5ygyCWqUBf3g4n8VVXBD9hYhfaAC	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLmAW4bEwUxn6FMiftRXxXQbY2eB9ZRGu5Fo8H5YBKsykgVNyb3	79
109	2vaPck54NfdA26PftRvSzoXe4Xgu1xmNnB9aypnjRbEY8viyT6N6	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLpY5M6mbhQHu4Q9TocYZmXU6424hGsj8gqeTxtoHc5LdvCaGKf	80
110	2vbG6qNAGd6u3QRjP3bYfdDkjj8ygdiUqn8HeoDma8N2vzxXeRkk	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWch8xAVpdjkPL9UzRPA4HyiYjeNvREDftuqxRCQWvEweSkUas	81
111	2vatH4NYNpXACT2sjhGfvjLfTK7JZSqyauYkSpTqbzqu8HP6w1bE	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWch8xAVpdjkPL9UzRPA4HyiYjeNvREDftuqxRCQWvEweSkUas	81
112	2vaCCR1kTSzYo5vLBe6SWD17JLD23KfUJ2S8zA9uc9w19qLFdyjm	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL1dprTPmRjSNCEANWrZBhs1wYWXpzqh1GyqFDExdWoYf8zAupw	82
113	2vaYwptU151YDinJcDRFqA8H74PBBRtNtKhEgsew2LHKNDFTxKyz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL1dprTPmRjSNCEANWrZBhs1wYWXpzqh1GyqFDExdWoYf8zAupw	82
114	2vam2SLv1eZ6H9vPREm4fr4HRWeU2q4sKc2u2ojPdYWviNdTj5mS	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL1GoqM48N4TR1cJj9Cvc1Us6wodsM7KSrnehFKpGCBryuYRkEz	83
115	2vbd5v1RPYTuV2PcRjz9oeMyVP6xLhraGTBTWBArnv8iU9yfsiyk	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK6MNgobMVJAUwkUvsTvkchimSfyxD2C55KnNDYiwkBH7vsLxgd	84
116	2vbNWMFhE4BqLEQonwaVTUv3UM7q9LGs2BS3MBfpez5PnHQcAwAJ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKhw7f4MPTU7GdkCAy3QvZRvC15d2Gds9rjcDmGbBujqNWBhCYf	85
117	2varH6n264Ew8jv3gtjLfvnheYg9GuWRpyXeVLtoq7hEW79rwn1e	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKhw7f4MPTU7GdkCAy3QvZRvC15d2Gds9rjcDmGbBujqNWBhCYf	85
118	2vbgXygpEgueNNjkhWhT7Vr6wXcSd6QrBrVeukGZowumC8X1ypXP	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLJPxH4AVh135u4YFM6uXQEGNachLSS4h59eVnaUBdCMLoGmZm1	86
119	2vc2VCAKSzyq3RoEuN9F68TS44PEDoSNVkPLQPGZ5SQej7VVvdUN	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLMSs4GyXxoXgEbmnTFekzPUmcsH3wxzru8Ei9BWW31u4W7ZSth	87
120	2vbW1dMwWj1wkkhbDrHBusagV4q8kCtdUXMbtWmeCoPrqNCBNbEq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLMSs4GyXxoXgEbmnTFekzPUmcsH3wxzru8Ei9BWW31u4W7ZSth	87
121	2vaa6s7tguifby47qpCVxHjUyfZa3Avtxx9S1bhND3Y1F8gXWwED	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKSxSHK4MvmgkuuR5YeLuHTk65Fa2f4T1qFD3mjVXyt2SJHdmdk	88
122	2vay9Shtdd1e1TxekwgANWguGdknuBYM9z9GJqFuCeibVEKnV1dn	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKsLhnaY56wHLa1LKVQDXkVWHf4wKGNNsT3dytQ7nfPctihNZtx	89
123	2vbQeQK3XHe4uGHhDne7TxtKZpnvnG5hf6Vd2gfRvjW22CHX5BFP	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKsLhnaY56wHLa1LKVQDXkVWHf4wKGNNsT3dytQ7nfPctihNZtx	89
124	2vaupdGdA56iDuc1yyaZx9nVyWbVncV32othWUDju89M7wEiK3Qr	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL3NPgsmr5J8MUU6snZ1TsDwEjw4Jthpt8Jh77kuYJyt89Hm7Xq	90
125	2vbAuM5pCKjJJBXfftZgG8sqeaF5uiFff6pWPEz7JnmTjtp7reTW	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL3NPgsmr5J8MUU6snZ1TsDwEjw4Jthpt8Jh77kuYJyt89Hm7Xq	90
126	2vbVF8ZyLAjvy6ftzUuquYWKYw51Seo22LpyQ4U1z3CEbwzznKHw	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLgAToowRQfjGFPGZzyXU4x3dkj9WVryRTbNixmBWzVMz1rkpNg	91
127	2vbibu4AKZKeYyusVmkUNLbNYdGZJHkuyB12GjoqBneiLp1egQRM	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLgAToowRQfjGFPGZzyXU4x3dkj9WVryRTbNixmBWzVMz1rkpNg	91
128	2vbBUDDDqPrgzPncjHiXFnVoYKbPco9wu46xkmrVPu9bByj3sp5j	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKMoHYXLuqfe2d95HYV1C4jiq2s6abCUHY4MbmBXPokwBR3t74h	92
129	2vbNSsJfr1kMgQ9Z2qNBtUGaeQ3DYXLjjTQFnCqWwYWCQBNhTWyU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKMoHYXLuqfe2d95HYV1C4jiq2s6abCUHY4MbmBXPokwBR3t74h	92
130	2vbJ2KCgHUHNdtKkxuRezYfXujSZditkgM8A4djeB8oCq9NVD4y3	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLxEQ7QCFdiMpEof7o9X2yJHXYPAF5uhhoQbRidoTWV58GNzkin	93
132	2vaYP8Fdx7yBb9Xgsfx4WvhSdos2FfxofEbGByVBYC53eRHByUv4	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKf6xteTgDJih1L8Av3ai2tpJFiAdQDWGSnt5bFbzKq8o2Co6Jp	94
134	2vc1K3FrnvUd8PHjMBoZehdRR1JAmfjRi439tAoyCPD5cUL9JPgi	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLmgCxFd1Fh7SxoEMnWKDXL2cWbBZCoB2HE99FQuax3kPUuhoSH	95
136	2vaFSiPLunASvnyuLGRDPhe3cdQS5okSHSbGdGG22Tc5oPCnajfS	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKRvd9PW9GB6eVtHKyB5x1BVHqTw7QNazof9TvPxVX3kQuWebq8	96
138	2vbBuXVLxryF5AYHAJugzKsb8aJ8XqtQ4XuXWA1nHJYd94bWLCdo	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK82gbGxMnVd4DXgSa3nLurwKq6JxrbPFanUCDsyFaZRvozPQN9	97
140	2vbWG2b8ZbBB5K6WV2FutqWqUKeiH6nvj5YpdiQygptb3Wiry8aF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLTFdwfTEwCq4kQZit7bF5eCDWpXSsbDUBRXg7e7gpPMUwvPsaN	99
142	2vbuwJGnY5YDVKVP4UxgsQbJSD8h3kAmKUWsePFGPpaCWiFXohRz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK8i1uSvkv7kRg1CB5AwRTcCd491rVZbTo6Aogr2WguYcPhTr4y	100
144	2vayV7DyJ31wCvg5t2yqyHm7ANDLrrkpAHumramwUDp2Lnrz3o2F	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLC5sZyYWyyZG66FvP2zXLKDNHd9WDmx3Fq56AgEoiZvc1VDqNu	102
146	2vbLZgm8Q5D4aVonHJQ2iTjm6pp3a9X5ZL7PLxMshFtH4vWoRLDa	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLMFkgXrvPPCVgXrT2wyEjFM4HCRVrB9tRyTFEpWPdP7AKUastb	104
148	2vbYj3HyKdnWUJdBVTzix5myuT6m46HY1FW1WfCZCZz8SUTnA6Se	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKC7K5c9eJMu8HHMr9oWbKtcEdoVUPwgGHrMBXZkYdjaCGf6YrN	106
150	2vaYYpYFbJ7sxcmmF1GvEvHkxBVhUARLxfsrD21YKew9Leh3Ljjf	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLYBQwXjwr2ixYHd3xiQ77UtVbTcX4FxoArSqxoMeUqc94oJsCd	108
152	2vb2xiRzgFQn5Ayb7dQkBrfnVgyECz9Qhsg5eRD7PKx1ZLnuPVmj	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKNaux7B4YQnP12hL849GPHLiVkRUEHb6ibAQimthC6tjdVbRFz	109
154	2vaLKH9yLqbNGST2hLvdBUqUTw2ckqX84aCbrAeM53AFKYxXGgA4	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKf7Md4X33Qer5KFrxib1NZQV2jokRaqC5a9wzVjAu8SXKHtPxv	111
156	2vaHQqbFyNZ1hmyBGisYuomARTBHZ9wQ1X13QeS5XXngsPEmJ2Cv	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLmLgbCscBatWFTcYypyKhUamiTcGg1D8tQhY41BDyRzcywoWDJ	112
158	2vb6BYU5s3W2zssaVLGs5ca7Q3CbmbDun6yf1meS6cZDifyu2Vb4	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKGauj81h5RqpcyzSrMrckZDJmisQXBdYVTV7EBzmL66ZuUscZh	113
160	2vbMswxRseh75tZFHdzXfjHpYum9rYKBcjfnfouR9a5NH1cMpCxH	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKgZNBAL7oZaQp3HWubXKz1ujhmFQnv94zHEUGbXhyeQqCjJ3HR	114
162	2vawCgsw6TuzpdLFVmqm7xMD6zzvD5YjpSFiM6sj5eybYgsU4vV3	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWV3TLVz935Zb43bbzmv2nMgk8QShuB2rUD2thED33Vqkz9YM5	115
164	2vbnBWwk1U52a5BmWW8aqqcpmYF3aFve68bWwVDi6UkRWVZLzR2E	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKFrRtBCnitaeNN4Nz6947ucEMb9w8R4yniFZdhXNXcd1GA6sAh	117
166	2vbBaNocbhnqjSGP342ebKFBmSdFh1Cs8wMTuoH1yBLS41LKP9Ws	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL9yJ97EJePzqH2v7HqwKcmEkAz1KN8C7Y6ogNs3EgAMfNJzT2c	119
168	2vag1QZQdzqx7ohLSssFQHF36xkcMbQkHPtzACHN23on5QKcPSWB	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLnZsrYaP7sRHA3A88M1pHzc94BTvuLMgwGNbSeULwQUYGGjugT	120
170	2vbitT2HU5D5W1ib9ityJ5BZDFg5BoF559dwvmrwKHY8nDq722LS	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKQBbZrcYKnhofcfJbMoMiQXoXWDetgWN1ecatnreYaNamGXqTQ	121
131	2vb8ScpmSzmYdJL5iRwHP87uYAgoNc5nxP9Li6k3Arg1ANGV7grB	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKf6xteTgDJih1L8Av3ai2tpJFiAdQDWGSnt5bFbzKq8o2Co6Jp	94
133	2vaQisxvw9KFzpXhumrr92WG38Y1w4RHX1oytKptnFkMQtsngMSY	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLmgCxFd1Fh7SxoEMnWKDXL2cWbBZCoB2HE99FQuax3kPUuhoSH	95
135	2vboC9zUykQ7K2uvmBM1WQne7dPZ5MAvH4s6PBAuGqgsnkaVumGG	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKRvd9PW9GB6eVtHKyB5x1BVHqTw7QNazof9TvPxVX3kQuWebq8	96
137	2vaMkDqqK3LGoGStzwrWANXrk2pycnaoczuQadUsZ3uegXFyYC1X	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK82gbGxMnVd4DXgSa3nLurwKq6JxrbPFanUCDsyFaZRvozPQN9	97
139	2vae1TK1h2JyoECKYu6SKpnboxHVi4aoypjcUq1u2QJFbsbVKTky	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLFAGbxot8WDoMWDYjkyALPgP89SVa4HRdRmphuzR4ZjW4gS5Zh	98
141	2vbnAKxpPS5ZeSFfWYPKPZDvZtdyCAFNN5sAXs5VJere4U6nk5hP	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLTFdwfTEwCq4kQZit7bF5eCDWpXSsbDUBRXg7e7gpPMUwvPsaN	99
143	2vbuZSTuqtXScTwUDdu4drwRkvbEReTG46ZTC9xoShDCgcwkrYLZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL7dXiH2z9UKNNq6qYxp8u8KGeV1NrYNipv8drhUbKzUmKqkpJA	101
145	2vabc4ByJBMRc8qNJb8idmYXhqSAyo5dDJCXgijN1EJq4VgCEqP9	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKmP2TRECXWdX67YMX41hY4mw5iPXxz2rjxYN9BEdxZFABtsBpk	103
147	2vadjnirBzJJsvDdAv3yxXwzagNTFNHPebKx4HpbZBiDwUzBp7nh	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKsFyVwfox4BAT4Cz4ZFH4K5gYShDQezQKGp4gMn4FfZenpZFFv	105
149	2vbtYQ3EVugkcrCUv9vNMURnfY3HmTQk9Txse54z7ESYkkdNBT6y	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKXkhpwr6pucBS7EdUMsybJbQHQEjWzzWdNtdeJ7fpdauT8m8qp	107
151	2vbMLvp16xtgwJceYLLaVbXQg5phpDr3gMDinr6JhM3B18EpMT5b	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLYBQwXjwr2ixYHd3xiQ77UtVbTcX4FxoArSqxoMeUqc94oJsCd	108
153	2vaXkLLgsEfZ4DEfwdwNoKk2WR4TXAC39fvtzKB9j37fkSjne5xu	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLtu4aM2hod8MbeEd3iR3We3DmG83vRp9y9k6K3vZk1vyigKpA1	110
155	2vaXoPvRp5iKRUCPp2GcYEFpefWRYVcEzfR7i9CEjbrcuSScJR3G	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKf7Md4X33Qer5KFrxib1NZQV2jokRaqC5a9wzVjAu8SXKHtPxv	111
157	2vbx5iriEKpxTeYeDWiN4avL46xCnu7vJpoKL8pxqKmyDjqy2xd9	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLmLgbCscBatWFTcYypyKhUamiTcGg1D8tQhY41BDyRzcywoWDJ	112
159	2vapB1xs7F3Xfd7YyRkqCCU7yNqX5YA7Nto76Jr3T59Zco3BhYoH	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKGauj81h5RqpcyzSrMrckZDJmisQXBdYVTV7EBzmL66ZuUscZh	113
161	2vbFAFEMAHkDNj5BE3fDZD5F4VyN4wsnCuRHQGi69BtPu3pKNoXo	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKgZNBAL7oZaQp3HWubXKz1ujhmFQnv94zHEUGbXhyeQqCjJ3HR	114
163	2vaF1dqeEp89THxLyLBvogFTqX6pXakPRCCo9QkTYxTStJnu25df	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLFF6qyVLp8vxziA6gURw3NLczojmMAFaAvczRBAi7roxEUQzjv	116
165	2vbZUfrss46rfkobShXzLJhLcH9DmEgRf9CRPRcM87tKGBxcMQzL	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLVQUrKPw5JKo5FYu6nxJR1vFouqDH9x1QVWpBJKvEsvWjgDSNW	118
167	2vbrAibBDXcVY4qyGpqFqRrTjgNKaHogUDeyXuYNeeUi4xEPR4jx	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL9yJ97EJePzqH2v7HqwKcmEkAz1KN8C7Y6ogNs3EgAMfNJzT2c	119
169	2vaSBuWSdsK4o9ToeeQf86yhU3jGk1nsRJUonMUSytSgzcv2zBVw	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLnZsrYaP7sRHA3A88M1pHzc94BTvuLMgwGNbSeULwQUYGGjugT	120
171	2vauiGh5saKpyFzAvSS7iTjctvt2JwmGS5J2RJqCPP1EvbuSH8Bq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLA9hANaeXi6QqGfV5UCHecbKj3ZgDnSumSgqsLfYtpHqpCUux4	122
172	2vbgu3arHW1utS3tPhA71cGojspTnpWtr9VxWNPWBzLMbv7YSD97	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLgU8AheA4t5LTioXNDCnRzNFxpeHVSG9nbMVjYWPLdjXSiSZqB	123
173	2vbVJ2ZwveCK1jbE6pjER3yV7Px5HuAccNAcZymWjcUvzWSHrG98	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLe6qU8ECjKUc22UK8JE3wu8iBtLJ76sEZVp6VKTKf9HU1rYwQL	124
174	2vbfW7PTz3QjnUs8zLeKioBKg9NmEULafJAtitDLZDurYz9Hrqe5	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLrHi1LpwLoxUF2sTSP28xLMrsSsnVDgMkAWVSkJWEPtL2oSgKj	125
175	2vabUz3sLUvbacXwxYgXEUCUGu8MKVUuPbyaMTWxSiEFeLPNtbNc	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL97XTEAXxSVCVGazV8aDJNkAbLsGvqqBJRRbj2AdcWehLsi4mY	126
176	2varpmhyqHEK5zHSyJuPKUsKGRR1ZAbyh2iGbRjRpXqgwQXWsyRB	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLRVLsLUr2w782BHhm1zjfvs4fFMDAbw4qZxmnpffn7vmqsuBVQ	127
177	2vbZy1h1HDGfnfehhzsvUXnv96bzXCspizFP8r1idbkAC9UDgJV7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLRVLsLUr2w782BHhm1zjfvs4fFMDAbw4qZxmnpffn7vmqsuBVQ	127
178	2vc5C8WrpfcDW9wYQRaWk1HMDdfddC6bMjY6EpLG1qzPgkyqU7ZC	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKBxUAEc9C6bPAdLGeUzq4VeV62S15mJoSiFFX1V9es2MMUz3XR	128
179	2vbFddDxdfXa3U2S7Ls3MJFskx4NphYb3QsXfPWbECcidhgUXmrH	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK2vJj4NuroGWfcS4jcUasC7KGUz3tQkXyF2Y1Ej9w9gDv3FDxd	129
180	2vc5F3WxbLWCFYDGigZjSRAMwPBJtdcspHC9b5praE4Gsk2fgoY6	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL2iKM2aUoU8DzKYNrW5S21AReFnZ2upUQK6qbdDg4kEbGSNfmo	130
181	2vaKND7bgEm7hBV1Tnu7tC9qwTBKwMXj87guqu57ZxKL17vxdAkS	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL4eyQwc9XkvkmDSUtvb9g5QKW3nxTar9yKSRtoadt777e82bJ2	131
182	2vbgdEg6dbinrqxsbrxL84qZsNKn8FbVJZ3M6i2F7eJHvzmLtK6G	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL1YXShpKrhZNKe1um9nPPPKCXwzUxvu1pbdpjcnaMgExfgQ8HS	132
183	2vbpKpVR5UdgHoKsLGA3N5guhW5TC5cZp4hwcQPU6TnwS1nEZY2X	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLj7iHjnbFE8TbgjmBBjSoeYXESc7qUXMz3fnXThfrxsUSCxgCk	133
184	2vbsMJHX1mNvSshMaW8qqjk2Dw2jTkeNjhPfkL8EFvu5wxY8EYpZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLj7iHjnbFE8TbgjmBBjSoeYXESc7qUXMz3fnXThfrxsUSCxgCk	133
185	2vadskU3ezRh2eye5QcWaiW4SVn4yKSqGzQBZJd5BvEkbingEquu	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL6Uq3DS1oTMh2RwwPwnpND4dGAH4vUGXKwefEhhYuJvPJdKubA	134
186	2vaud8fb3etHFbDfEjVSfjj134V9oKPdhFJUDhBhqn7GCySTQNJP	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLgt6Y2tYN1nerEsqFHs5yRVp2UVCFojkZT1oTV3zHt5rzkpph1	135
188	2vbcGfaWGbpPHBabDSYYsY8BpLR3jgjPCKGeSgDYmrP7BqvFFujF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKW7jpFrVVsbvWcnHJT5SdkJsckYZ2ZsNGL2RQNwu2gij5msL4e	137
190	2vbeojTx5oKPJAA9oVHpDcJmVsE2gYGmpLirKvtJRJ9BJggiDXhS	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLGG5TNA9paaVZc2JZ8Bf2exH3cQnP6hYY9hf5yPiu42yzLPxUj	139
192	2vaCBJmQQxDWJWqoBoosXGFVeLQd1qsPsqgzEL6YRhTwjH4kJNog	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKJ7p2aQWMpS6jUmRLy8ZYi8Pix43D3gNCRMzq2qbSEpbG5BFvR	140
194	2vbJRSrtrotkN5rKqP4E6b6Hbfs6HPUDv9gk1DBcpXPKmDyhJpRU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKPxbxm2bbCcWsDivF6A5g9RBUfiVtSuc7MrpF3Wdp3AkseRQ5E	141
196	2vb9TTfuXLTokKCmSr6xx8sXDGtn7wJvBANWxvTqSbsWE97bPNFZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKs7vPY8gyHtNCxEa6MJNMxN6da96BeBYuBqU1kRLcbtTLytuga	143
198	2vayDUHmUGanWu7e6kMK6ErD1Bk3Dzh3CUuApS6jZYHAoAn5hcY6	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKdPpNn92jGwLCu15gxzL2SYB48G47VdoBrLSSau56fMQw4biKv	144
200	2vbCmfXR3cK8gXULvWwcbwZgq5MuQf9fu88iH8reg2QpFe2r2Uq5	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLHevLcqkkQoZ6TLwUHmBrnoR4ZXh94jE6HJMBAmfJxzNBxUCSo	145
202	2vae2ACZmt34a67QB53PWW67qm3JggmakgefUuZPLNTUwXf7rdGW	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLfjB4Lys2P9XD97d1ao3gpWazdCd1wPRPYAhtKhAazRp5HfYpU	147
204	2vbxtsZpDQbWE4CcGD6yx55ZxoDmgHd8Jgy6HGHkS3UzvwAYZfc6	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLdsSYLhm4Z92BgFhfCMa5qKNZztxuFazawbwb6Ya8H6hAvZ5tb	148
206	2vbLa7vdq5QmJrNy6m5WFYDtdUXgJp58b2RvruwR9oQEySiRLmn4	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL5Kg9iAbRXhLfSfuFsxCbczn79U7kVVLkR75re718zCqskzyQ5	149
208	2vbfByFE2Wn3q4XHcUDFBUk3avpSxUbiEBvNeBwUUhZ6XEgHi5WY	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLnoeoLuD5nUCkDXkpAMBHELesPFJ8FtCVDmtuHmvSRrRepy1Nw	151
210	2vbRXDBMYzv93tHPsvmBZNL9XQeyGgHSS4oWBFFP35aJLEd2aMii	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLn2EgksomoxfC9kmTx98MohABfF7DjvW5HwBEHYHFvVxC7dKB3	152
212	2vaHPdMtei16DMATQJeS4RMLDbJrdXUyngJSE6QG3zt2CADYuMAN	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWY8DvtGB7TAPSewA3KdaRY3BrGWgPLzeTLjw3snrpG4yN9oe6	154
214	2vaT42aCiTWMGAaLWipRAA23L72hYAUA976BdAeiLbF8yg3XHytT	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKwGVUfPjqBrRwvznsChJXsbDpgpvfjHz7HinfKNo8ex55QMJw1	155
216	2vbYujpgvmd4PxNhGAW4UV6HbZuscTSnESdMnKJHGuaptNLpVEZR	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKY5qV8eusg9QN7VNEgPy4W5bebLSMLh4WLWgz8UULNEYdXKEKY	157
218	2vbJAKoBynBuAWXiTdLwGqBYcZQSKiYvfaUmgHUjcTxooY8RpKiL	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKQvB3ZqamdvycbrwuqZ3Y5iSCtTpnCrS6pmF7fvpTdzdHMCRTq	158
220	2vamihRCP8wpFkZVhBFD3nrXxBUhtPyqEBVW7yQEJBT4Km4JAZXL	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLZNVZ6gtSvsGqP1gYdh5ftW6N6uAAJLCABUr5d9if3RvBUymj2	160
222	2vbR5pYhQupBr4EzTzX6J2nsRkkypjZ6PeW7tV8HLx9orz3gF943	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK6PGoupDQTYa7RZ37XbPM18SdbjFmTyAzsCy1oKNXgrt2NeN7D	161
224	2vbgYV1AWrdrjLJdHVZxcYrww5KX9hRwLURfB4GCwtiEkZ9PrtcN	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLwzvUNwZYvPsStErPWUgPhUynPRwsvvSeFrzXJ3RLYvNpTquW3	163
226	2vaF7nsbQrNVeKZxiK4z5e5Q5xbRn811qfuQiTwpP4nWnSQh9yGW	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLrMva9XUG3AZY965VBNHuumNgnU7wU5d4WChYZXus52qs45uRY	164
228	2vbGwmGvW5nX4ivQeevzo4wTQFyEHJSRmnYpYPdJuMzLLRMLonuC	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL82mP66t6PNPSz5iKrzM3SUop7xS3tCEExYLUeHfgTVFM6Btjv	165
230	2vaf4hbvEPFu8iAW5GnVnXfh1JTMG118yPih2zJWtNP8EDvm4nPz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKZN4v9ijnHaCwmu7higA9YPcv7e9bfE4cUFu2FgYbn2Qm4tUHC	166
232	2vb4NejYCE8CGR4NCsHP6f1Eq3Z6FTv6LApQCqeMhyHJPBXVyjPM	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLQqKrhDATnriqeuzu32TaVCkEKwxP17r5CSmtNp2M6JLFbMqpW	168
234	2vbUkPafv7j9y9xxndRSQExZ3tHC9Pheesi4badvYvRcVmc88xjZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKAjZRdauVqnjh1PKYWbRnpjQetNG1DV6z7A7BpYvsudWtDkULb	170
236	2vbzMiS5H95vJtiitMJW3CY6tahYtrtaBnr6dyazfqiQEvvbryjR	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKGo8RUUm59YdYEa5n4g19DzEFd3NauhWhEnLPbiMdiAGoWad2K	171
238	2vacz5KqHmCjQhQPT1QT1q6FFyCntUP2gqrs8nb8P79wTPRWx9Ci	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLwadr7Ab4otwDx6EE1nJnovuEm6yUcmcZhiwewoqqr7gnSeyLW	172
187	2vbrjvm6J3fzZ6ac5ZTyuA6498toqTQ3yRfErnKcbzz1gYNHeVho	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLG8TY4HEWBFbR8nUFdi3oeM8iDWy4jfEPRN6XhB9tu4ufsJbCV	136
189	2vazVwqaqnLomCQEkkg2q8UMkmmAdCQz15pZhjQcmmySmUwRwKkm	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKbzRNHBNtnZWRXE4qfkSo5ffTc6nPerpzNrVmNhYQVuH3c3uWs	138
191	2vbtVTec9HJro1a7Pbupu8u8vyHkjsE5jvvbdovcsBGVA6WgYUnz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLGG5TNA9paaVZc2JZ8Bf2exH3cQnP6hYY9hf5yPiu42yzLPxUj	139
193	2vbyFyT9XQM7nWP8LY6KwBGuRaKQV8cpMsvWYDc9VBtTGBzoBUzJ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKJ7p2aQWMpS6jUmRLy8ZYi8Pix43D3gNCRMzq2qbSEpbG5BFvR	140
195	2vagSQFW4HSMLgeRmehd97MaxzFZT9ScmwkRTb8rTAWwNNza9p9j	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL6HuDtswEf3csTyHRm5rDc2bUMZNHjaEw3Lc44EAf5VgnS1xGn	142
197	2vbUw1FxUAvuHwpqTZiCKCsPHmjFrMUCwngqZHQBM4dcgwc92xQ7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKs7vPY8gyHtNCxEa6MJNMxN6da96BeBYuBqU1kRLcbtTLytuga	143
199	2vbY5jrcWktVm91ZaF8fPhKy6mF8st42NTfjHF3DyaMczLLUGZWx	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKdPpNn92jGwLCu15gxzL2SYB48G47VdoBrLSSau56fMQw4biKv	144
201	2vbpcnPcYwPU4usXhCwgLoWtj6u4FRe74pQ7XDVEXPkSw9CRtDsK	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLPXbx1ft8UG3c66BLSqgs1P9JhPSVkqvxfgQQp3QXxiYjriomV	146
203	2vayLwUTJYGES4DSH4pxwEvRbKWnED1X46dnw4AyS4CCeYj31Wb7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLdsSYLhm4Z92BgFhfCMa5qKNZztxuFazawbwb6Ya8H6hAvZ5tb	148
205	2vaPogsj9RE7KAHekHXXjTo8b4NaAiWYuPVWYWGXo5y2xE5QXrVh	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL5Kg9iAbRXhLfSfuFsxCbczn79U7kVVLkR75re718zCqskzyQ5	149
207	2vbxQJH8bNzgqSC6V1Wy3wtGsBXPS6veTmf5AHyFn4VhMPmpdVDh	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKkCKono21EmTBpfjyfEEacwrYpuCy9NoUXPzC5ZZTZAE7W96CK	150
209	2vbQLzdZodMGnFNE7xTrbr24UiSQbFX4TZQ6JAxKmKz8xoWWmAsb	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLnoeoLuD5nUCkDXkpAMBHELesPFJ8FtCVDmtuHmvSRrRepy1Nw	151
211	2vayzyc144pYoJvAx8Qk3PYEEKxhATmK5bVhArwbtWHRK1a76xad	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKVQk543FXqDFPRodmCj16BhBuQFfwHgFgvsNMhV6E2qeZ51bcq	153
213	2vazXgiaix8DndGBk6gvsdgBr6RGGU7TVis88Y5KrxRUvhhRYmYN	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWY8DvtGB7TAPSewA3KdaRY3BrGWgPLzeTLjw3snrpG4yN9oe6	154
215	2vb7shCiedMjBT3ZKcmDMmyUaYDdRBdiaSGJcgGvo8Qgv4hFXNwq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKPu6mGnaBhgQw9bnrCX9pFaqmtpb1oHM12G2miasuqhc99N8Mb	156
217	2vaGptpiJbAQGs88J8ig4B4ZWuCUWRHqBcG93MDupCeVLx47fa5v	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKQvB3ZqamdvycbrwuqZ3Y5iSCtTpnCrS6pmF7fvpTdzdHMCRTq	158
219	2vbaQxSRM82rHTmHdJ35Gb8bMmnQ5zNcjrWWm1SjrEgasxJx2uqb	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLvbppbKVdmsiHa1K7mrJt9Y5zKU3MgEsqzMXi9gGAJaW1cwjWy	159
221	2vbMuMQyjBG21ggDvWxfjk38t2PRjJh1L2yLpgeDKvuhQZaruoo1	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK6PGoupDQTYa7RZ37XbPM18SdbjFmTyAzsCy1oKNXgrt2NeN7D	161
223	2vawWkXL1VdFK1z5T5Q3zEyiCUR4tutNrQ2XjfJzB3u2inHYsPxz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLwZVzBgNkzRUQjnufmdCiJ81nEi2W7zcXUrs2SRjQNZ4teBaoZ	162
225	2vavXH5HBvH4AbqTgfcCydgQJzk9FxYz8zDwDT3bSozRCT2N69ez	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLrMva9XUG3AZY965VBNHuumNgnU7wU5d4WChYZXus52qs45uRY	164
227	2vaA9T1LX7WHWodFPXzVY8EHQbLA4EKbzsKs8g8psGrB1FXJWZte	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL82mP66t6PNPSz5iKrzM3SUop7xS3tCEExYLUeHfgTVFM6Btjv	165
229	2vbGu4JbRkt2sRUX9StxLtBhVGRvLxkaQtSWfe78PBgEWKL4it5S	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKZN4v9ijnHaCwmu7higA9YPcv7e9bfE4cUFu2FgYbn2Qm4tUHC	166
231	2vazbFn56sK8J9B8T2Nkq6D1yZuiobGTRJJPiQG4tkr9rEbUpRyT	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLt9ZW3Cx52W45G2wGxgJ559DmjnP5aZQTmEQATcXEzJ3Ljhkmo	167
233	2vaLAtpwjbgTuFvWYMUPy5vNAXzS8DHozBrtEuYHppkSfvd3eNne	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK78hd74MMnY3aG1sfpp69gRiVWmLVAn96wQjAR1NSFy16bvb53	169
235	2var4zbuGgXabDccGu5btsA294oFrN7NJH5U4Bdrm6LALtzZ1GaF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKAjZRdauVqnjh1PKYWbRnpjQetNG1DV6z7A7BpYvsudWtDkULb	170
237	2vbGB2mwGQAZMY12ugWas9RvCWUzZDcHLb7H8nxLNGihNzk38iUZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKGo8RUUm59YdYEa5n4g19DzEFd3NauhWhEnLPbiMdiAGoWad2K	171
239	2vauPyd3AYvkafTWr8UjctyaW8gvEb4bL4VnFFsoUGKzLpkHSk9y	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKxpy4JU2g6ssN8ukxauBdjs7KFGRkwE9m7xvvPByubhgM4QzS7	173
240	2vbkyxUK281RYynSsdLjaLUvdB3VfJerDNQkSJ1cJuvmmGTcioBv	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKTJ9d1jDGH2mCKxSQshT4aN1D1G6npMyfSWf7w5wUSDLc2a16M	174
241	2vb3s5KiYuaZGi5tXbMo5H9E4peToeLYgHbcNhknxZxuzFwAekeF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKTJ9d1jDGH2mCKxSQshT4aN1D1G6npMyfSWf7w5wUSDLc2a16M	174
242	2vaxBmwCyiVyLzejid8Rq1bENTuhLb1UTiZW7jDF62sfcz3VVSDq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKMEF99qAwxvDBYfpQ21FpmZU46viJ1igU1db6CNJcttJfnhjRd	175
243	2vbKoobrCJsko6HJfj4jRuWr2KHWTah3DUapZw8rWkhqo6MtWSbK	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKMEF99qAwxvDBYfpQ21FpmZU46viJ1igU1db6CNJcttJfnhjRd	175
244	2vbc9ziPnk3aRgHKYanD1iC6zLz1iyofVd9GmfH4GKz1Q3GkTLJC	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKUSEwi3ZFvBeJ8rzQVn3usujTUcx38eJMdWQR4jFCnzxN9eiQ4	176
245	2vbow3D1assqWccNR2fJPttr1FDcDQoRbmSyerZLcJgb3kjVrjJX	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK7RH3HEVMsTzqadNU3qSyfoCgNiFMFskwY98n6STYwHP2ozGv1	177
246	2vaoxP76Fzezj91XpzB8VijGDL9J8rAatcr4xTbctcodedVNeWwH	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLMxwxs3CGCLKbWEdeuniMQCb5WmjtpnuKVzwU9cdW55k5reqwC	178
247	2vaLtAviJ4iABfLpn7SKHeYgTpw8hWna4CnWfoj4xj82g1crJgo9	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLMxwxs3CGCLKbWEdeuniMQCb5WmjtpnuKVzwU9cdW55k5reqwC	178
248	2vbFAPTu7dqYSTkK2EmB4Yi4Rm3uPWcCezMMnBwouLnDEXbm953h	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKrePSajK1hxrJL2utm7xVY7Mz2RoBEX5eNDw9aSuB34wDDCTmk	179
250	2vbXa4JKqxHkuy1CbvLJRMmSd47N915CCyUDGW4KxmNdG3YqywvZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLD6WqMCzMHS7xZSEtS1uXi6y6yJyaim2X62eo9nAk8AXG1e3gt	181
252	2vaGRCb4TYifEfTqT2EadzT4x5UGx5xcnhDdYXBEwEeUqd1nBeSX	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLrfG495tUiiCokXqH2qiwx7JKXgc5dqD9TEgNiuPLay6yrhpAo	182
254	2vbZ9KduUc6ZPFNqf9hbDWhrefFx6kbuqCU72nvsRH1BZBgytG5s	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLP2FHn2GT628LcA8uzdKXKiRAG67W37bew3h3d2jHGnjdwoQbW	184
256	2vaGeY41s1mBPLZC3KDPGKFAuqMPba8qynT754UZF5Vm7n61QCac	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLDvnqEBjyKs1pqwFVvPSxzpbeQ9LNbUChVspTqU3SkyFHtaKfw	185
258	2vaABRdoCS36zk6y4fVQSASjE2yD5mZ8fAFb1V7G6E5ejvhfnQkN	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLHx66CNg3SmUsbLBfb5b4TRWJt29tDimYESNecY5papeyMnUCW	187
260	2vbmgyucZEaniP6dH6k3J6afVfya4AbQGpa8TvPawzMsmFeVci9S	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK3hqHmkMJMSFpk5DcLrXcjg2U8EpN97ckXWzRghiAgKbi6jo9N	188
262	2vaaYEfAGCNEBedRK2GeVGZmdjTTTCtQc1vKazHBew5JXHW4XP1Y	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL6nsLQcg6xtJprsgHv6pSWJXRdVE8hYv2Xwjqggiw4T5iu4DYk	189
264	2vbYvcRxY8Shuhd5Qv54m2NWcMc4iiBn1jtCf5wJS2dk8cctfyqP	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKP1VrQtZczXuKU5C2siVwKWe4cNQRYQ3AWHaabvN4H2TEpJ2QE	191
266	2vbKtQ75YTjdgTLgSpZkJisvCBQWhEW48LZ9yoVZuaCStiWcZjWi	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKkh96Xu78k6oLFFWwTdeFSQNehU3D62YsRXBt4pjA4dAfaKH9e	192
268	2vb5uFXQUvZodhJ2sHV4z5UK1pHszDK38TM2CDcpMTAFyRaKL1sq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL3VRRCdEe2dCVbKWvnKSAtUBavAzxy2vncwz78Haci8Avra7yp	194
270	2vc2ym4xRezH5sz3gd5pBkfcququuquo9KrjQC9Ygf53gzwMzoDz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL41E8UXHgFiLU3ZArMhNTkjnSQNXTu6VyVrqcDDVdF4dD6NPP3	196
272	2vbcQt9z227iTQuFAMiiHM4Am85wpjkmX8kaNraQCA7SPNZyXUYN	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKV4sorNEhbPi4HmekJ7n6ZNA9cjT2pcYDZesEWk1t9zb4Fd5pd	197
274	2vbXnPQRCq1URtgNqeCe9kHw7VT1HSVfS8ZncTXmXtQ4zEuoKAeQ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLpbGm3wNWTJR4XwF2dq48BkUtAZz93vF4UKXwn3fEuMnsBxody	199
276	2vaDqrW2pWFDzdFmK8iMJ1iRKVq7ANeFi2QX4Qb28kuSYiAD7E8q	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK3BtEFJPRx1qyr3FkGWNNshUDJ1Mvds9wZWDjBScmQK9rPEvei	200
278	2vb86uZcjo3dZaAqjgkkvmwFAWwWbRX6Mkb7s6JuNPs8NkSXLVR7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL2HUfzJVoujoAc1RHi4cq1JHqkQHkjPFoUWdAkwgNeHQR2pW1n	201
280	2vaM4pfArjLpoKorJZ4J89oR3wcTbeoWMgUhyxYttFSALNUtZRTo	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKiqiL5bw7u5YiTP6i1HZodfJH36WyqqMtHudjXU7ct56zkTeGP	202
282	2vbm9yXUTnjipUSs39pZpj9ctsbM9JWRGRUzFRba7NLbCAzJVUsY	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLq4fpoP2f7v24Ya6cqAugtmCfsDnXULZ8NEdxeoJPYPLuYkLvJ	203
284	2vaBQKwfhTZNoXTjRcWenSPutMxZsMZip8sUeZ9eGh3jVTMH3iS1	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKFuuSsJJsXy9dQySQHX88hm9jS3XZ2Ay4W3bHzjFDmhymc1m6f	204
286	2vagqCEi1mhnD8CTaM1bGqdTZbABUoVpEUDEKfYdnTrzMEvjMw1j	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLbHNKXr9vaj9ooqHWfCKmcT35QDbH3i8W7NctHTMttfYDV6ee8	206
288	2vbxZ9TKwnttmVnCCsN6bGDqr8z3TQ9fSdiqLPhBy9vCVsQSD5y2	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLvP6ybZRbJcV8af7p9YPmtHyXXbbmEUndVUJA7ieG6EdL3wGGX	207
290	2va9K3HkkMkBSYG5K4F1MQJSCwuS72s7svBXhj6SJEdZHukMoDsy	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLYTL7pEKu6HueCgNSRzyBNMX6iVtA9BceSgn12VqX1nsAs7XE8	208
292	2vc2mp5MtarjETPHP42nxAjQVeEtgSajxaW263etEcipQgpCXM7g	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK54TskdjRETx1BB8tNuXpPLETrvn3SftL2drwEdMEPgjgZaGL6	210
294	2vaRzK8fgkXSzbhYr6b4LZfYDuURkYjfHp1zqsBFWHJda58cfRL9	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLjdShnS1Po6PdpLkQDwzHjJsuAv6TrMfbKjfyC9kfLt77hLtZb	211
296	2vaKrR7Wnk4xtdF92hUXzsiY22AH9anxBxrg1mHER6rC331hTVqB	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLKuKv1hSs1BEpMMrtHxvWhuJywqL1U3FCzkSWPvY7X2KpmFf4o	213
298	2vc3XjhF1uenE1uvkEvzAPJAbJRTntB581d5mWasxFwCMneibgAj	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKEWrm6HXmxVjwoYtPTczm8cMjRmxdYdJVRDnQPSMTbj7A6QMpi	215
300	2vbrWKpgU8U9spLHU1aCGLBnWc7uuqPAgbFMDUZHwKFsrPsHq8hZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKvHtpYCnJCG1fZvUYHPcm6tF2zfezhgCGbN1ogc6ywzubGvW81	216
302	2vc1zZWq9wK911J33HjzHmisvmfyGWkgn64dNyU2vhMvjCCnyNLJ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKfLkuhT8xMdgf5G1mVdtydbsyLJG86P2aD7GnxkVcjQpTx4CjF	218
304	2va9gYcBvQwDVFvLizKJer1cKD7u41YGk6ey1bWMQX4kFTauekji	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLLaMYPmntSfXjDXQ9ufo87KHfGjVMxAg1NUMERQbGr22GebUh6	219
306	2vae7zWW7Q3rBisM1TCPAQYKAfPBkKPuLw6Cn5ZyznKD1LySjhRQ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL2SVAK61Dxf7645yrtnyCwk7xq13ubXfDkdoWjQMBMpbdBsHgQ	220
308	2vbHWb6wdeYKoAWLdnEZi3jPnrxr8BLf9g18RR2J9aqVaFLL5tSG	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLSKrYLorV7zdrnNBdbKKKUvrV7HkBkyh6ah1fEvzwNkZ8SFsLw	221
310	2vbBXTwcXDPRYSiVWb4kqWfZQ4BHpWszPKfrt6N28oDRHK7pf8Zg	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLdA8vPA1pj6n7V7UZmNaaNhoHzXssL5GNc1yKUKWKukTVyjn5C	222
312	2vaogSJrBX9c68UcbQztdZSvuFmQbmCCRqNQ8LUvRA94L5eKJTop	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKeN5TSugs4g12Mz4a4hbh4GZgnXmDAMqkS8YxNYrQh7rvEsWJy	223
249	2vb72DGjcipfWg6KeuwoEjnYY476XcJsQFHqDvxHoRd1qSocR7ZK	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLKPK9EAYrvAHD4B4gJco6Lkoygyn6gsvJQoS4zcKJKGPsdUDhB	180
251	2vbCtvuoqPrT7vEuJGiGsSwJRM6eKJH1kuSBu3uCWTFiC4jHjDuV	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLD6WqMCzMHS7xZSEtS1uXi6y6yJyaim2X62eo9nAk8AXG1e3gt	181
253	2vaPSCn21SeVPwZ3RuKpYSwYAV3E3Pbqgw8jffPcDr2H2McDfm9z	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLtHt3bCeoUMZuSNush515Yv28QXzaDQpSq8dmBSySkiZwE17eV	183
255	2vakrJ465qYu8EoTxPhgMV3H8eeGqyqLU2rfkiPFMRFmMXDh5tGX	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLP2FHn2GT628LcA8uzdKXKiRAG67W37bew3h3d2jHGnjdwoQbW	184
257	2vbV3JHiL85Q4k23BF94DH5QFsWjUh2FtkHrR1ZQtVwr9hybGTJ8	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLtafAWzWCfVBYJ4X1N57wGgSsH91QitZwE3RomdXmvFLNoyQpV	186
259	2vbt7E8Gd1212ixedeGiYH2YkdHdM2kfuBcRaUiVc2aiKgaNbAY7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLHx66CNg3SmUsbLBfb5b4TRWJt29tDimYESNecY5papeyMnUCW	187
261	2vagvXF976N5oP8hREgCobRSb3qEU2VYjFVemi4bTi59qeVmXaf4	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL6nsLQcg6xtJprsgHv6pSWJXRdVE8hYv2Xwjqggiw4T5iu4DYk	189
263	2vb1QXw6gJBMxh5N35hdTLjgKpFBJ1UWbFbap655EB2exu2htYPg	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKx2qAEETJFYbbAcTNoHBbKbsr6JqA2hHf2TLHPTbesFBLyzRH1	190
265	2vb1WE67zdPuwEDE5WQawsJsxx9ZjADp1wDyhHghdVqdD6SkHVFC	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKP1VrQtZczXuKU5C2siVwKWe4cNQRYQ3AWHaabvN4H2TEpJ2QE	191
267	2vbCrcH6HrxacTJKk4Ge3jukeNc7fvWPNABBBr9XZpq4uuaa69bz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLihiLMqZBxoaE6uUp15tFczNUK422S51T6JWPwEWUx3CGVa5vZ	193
269	2vbteexLhjRNN6VDHRjVobB8NgAKY2yYkwWE3eG48CvTATHXGLWT	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKyCM3Dg2EX3gqK6ci3KuoCyH2KF3MCYdfpzb1f28RUWWYYxpC9	195
271	2vb78nGZUe8XubZ2PMboG3Zf3ng4v3aSY6DFLCKm9M1a9FY4VrxE	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL41E8UXHgFiLU3ZArMhNTkjnSQNXTu6VyVrqcDDVdF4dD6NPP3	196
273	2vbo6bhDDqgsyzb5CznV24qpw1N31vDeCSfcEzXs6Ur8DvP5zJj7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLhbC5u6wifxGcpfaxGt23wBaZM2XYrybs5AGvxC8GbFz8wyVA6	198
275	2vbFRAN3CdKjMkwMvG8aBG7Bu2fEJNXuRahgwKXbvEAUFuUyf7RJ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLpbGm3wNWTJR4XwF2dq48BkUtAZz93vF4UKXwn3fEuMnsBxody	199
277	2vax6HYA6F9shduWDTXv7UjAjRMLbYwE3Ztz4WjG3YrWoemNoGVw	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK3BtEFJPRx1qyr3FkGWNNshUDJ1Mvds9wZWDjBScmQK9rPEvei	200
279	2vbbFbCSZZr74MMEJeG5B1ZV2tin1fgkwLh7wzDy4LPqGnCcM94M	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKiqiL5bw7u5YiTP6i1HZodfJH36WyqqMtHudjXU7ct56zkTeGP	202
281	2vc2QGSduP2j8vrGXuwHBZbGuyXyQdsj4JNdWUiCeahHtHm9Vydk	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLq4fpoP2f7v24Ya6cqAugtmCfsDnXULZ8NEdxeoJPYPLuYkLvJ	203
283	2vaVH1whU1Jr4eehvHEPQBoT9RaKAcDfr2btKJ94rSvXMVAk3oMC	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKFuuSsJJsXy9dQySQHX88hm9jS3XZ2Ay4W3bHzjFDmhymc1m6f	204
285	2vaVWj2ZuLMBGYrdeK83pEH7TffEV8qBQZqKhDqw7QZ2xn4rvA2c	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL9Khg8VRK2evLweHCkWVn9frtWjvoNMVN7xzyJNVUHA91G2nS8	205
287	2vb4qLr8xJF3nic4nt43YoJGDRNAs15wP4xmwyepibf2dStzx3t2	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLbHNKXr9vaj9ooqHWfCKmcT35QDbH3i8W7NctHTMttfYDV6ee8	206
289	2vbxGjkq2oAfLMYJVKdgWaaRZfPhtb7xCFd1McVxhKziA1vFcN8Y	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLYTL7pEKu6HueCgNSRzyBNMX6iVtA9BceSgn12VqX1nsAs7XE8	208
291	2vaAmFGfY6DQJ1hxbH3bRC9yc1zYvzzY1k8sLowvdABMSRZxvgxq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLuBgS2kWugKb3ZY1DZDL5KMkJvSDNAPg5B4kujW8UAG7CSU8mV	209
293	2varrXGVcnYtryVf9TjxuLkvubLSLxXWHFBuaZcGSUJLN1umiv6K	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLjdShnS1Po6PdpLkQDwzHjJsuAv6TrMfbKjfyC9kfLt77hLtZb	211
295	2vazgjQq8xDZ9dWV2YzX68wwmrFxzCXAmgQGAFLTG5t14GbG1KRq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKNifzRNp2T6RaGErUsHN8qYqd1xGLLMqd6ew3nJfemwjoe4ve8	212
297	2vaNFA7ddakkFM3mT7mK9fouS52ADUDAJ8s6fQnhWDYB2i7GGZUm	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK8J2fKUpBGGk8pVrifLWQByvmn8VuGXhyzwfaJEUHp9nGw1QWA	214
299	2vbNZYxK3TGsv54jp41seQyVUYtqF6TAsgW9W8HZRG874QRtQtzo	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKEWrm6HXmxVjwoYtPTczm8cMjRmxdYdJVRDnQPSMTbj7A6QMpi	215
301	2vaC8PxDtziC4UwvGX3CeryzNCfHBSLBoHxncV97bDi1UEeTfukh	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK9L2nvrwfEjZEJyXXtcnUJwsWWzMGLa77znVgWegiw3FYmNcDF	217
303	2vbRwkxPsavGj6RFVS1MzggFKr5pKtJxZGAKUGrt6cQKzQaSigTy	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKfLkuhT8xMdgf5G1mVdtydbsyLJG86P2aD7GnxkVcjQpTx4CjF	218
305	2vbjVdMjWihQmPG2yQAtCGQtcse432Yu6WsAB5gNqpcWgExWmXb3	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLLaMYPmntSfXjDXQ9ufo87KHfGjVMxAg1NUMERQbGr22GebUh6	219
307	2vbnN1xmZUpkNKkJ8U7dRtchwKZgMWJHbCo1uqp8GPdCGjXbZd2o	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL2SVAK61Dxf7645yrtnyCwk7xq13ubXfDkdoWjQMBMpbdBsHgQ	220
309	2vbpy6Q5qvLYAKVj82bhCTcY7MATVVymUz9NEEXPAnAXQnxhVrxV	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLSKrYLorV7zdrnNBdbKKKUvrV7HkBkyh6ah1fEvzwNkZ8SFsLw	221
311	2vamsdzqQJiL3mCjcVV2BZXibucYbrb6TvyKmfdbip9d9XT8it7S	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLdA8vPA1pj6n7V7UZmNaaNhoHzXssL5GNc1yKUKWKukTVyjn5C	222
313	2vayDjQ1T27sBYka8QM8JT5nhX3rKVSBXhKczZcZ2UVqwzXPqeg9	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK3pBJaoFeRGNpK2fssKSaySKRMBf8H5VqTgC4xTmJx5tAWVUiz	224
314	2vbVsL2TZU1K81j9xNFXvRjzrFojtDBRY2s2Y2szsMophHvxnWpg	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLkNYxcdvfL9yww29C6Nrttgv7yqVgSrMAPM1xYsVkm2hGbvRfe	225
315	2vbEp4tQoXWDvcQQYLNkHURRCanGpTiNMAucZgMM1uK5iGZ2tFQZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKR6aoWmGhk17iXoD3uTRJgx2Bq9NmA6835vYcGdyW7cPGMMbYQ	226
316	2vbVHuQDNmExvFAAhSmJXCVyaV6sNGjscAvC1kVvXH3312UeHEju	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLijdazkcmYmnWC3JibiLi96KxBhNwhJfaJsFKcWSVJsu1PaBVQ	227
318	2vbaZ7i5DvzHhBjcQDc5eo69eqgdoPh8TiUkNZWgSQC7toHA1Jn9	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLjdzQtQSGPfBKCSGaJq3MAWwBfJmQs4motRLq4NYCaHA32ff3i	229
320	2vbSqUXmwHi4HTmcQB1jRNUtfgWYz2zCd7TMGnonMrsEws6NV1g9	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLDfNT7wvRZsKnCCLiB4MpkoG6as6UeiBuevZvBiJW8tpRSv8si	230
322	2vaxf4mdh7oVtxVZuX1AJGicFh9rJ17uaCEwbytYQd6A7oTdyK89	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLSQfSwnXccqbJkM9zYtqBdoeC8whTVa2kCFHG8PTdaWKnERbnC	232
324	2vaVE39siuPd2ddkcpRaUqH1yrpFCSc8WdVSqKTU8ozmcqnKkgVo	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK8C7pzDXvCeC1ssddneEe3Pf8cLR2x3oFuMPTrGUyGD7rqAuhX	233
326	2vc1B18Qyf2se9YyQQY53DZXwEci1UYMKfHNggx9oxarGtMcr4Sc	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKQk8KKuEevjEHLeJhkBgp67MKKzmBSRRPxty6n9L7CfA3UGEYG	234
328	2vbu9nT7zZzJmfU2zqgwCfmmp6RL9GTYYVtkQRPhTAQxBdEkcwdb	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK3U5wHaGFoqishLvhPNPW7Dph971dDUybtBm9s6UQdmKUn5gPx	236
330	2vbsVzcmeWn1EfyegdRDiJWPVVYj6uc1fVzadPVhuv1wCe2T8M8V	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKn2vztzDjRG9Kyo3ZGzskieGsxoWR9QxrqR8WseLQXC3LaCfWh	238
332	2vaezEaSjUcEm7M7oLXuRSogWouTJwhZFuSS31G7eLrHVCfndSwu	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKggqZMAjLi1TybErmWsxY43YE8Mn6JtR4ksXXyxvwGt8pAsogK	240
334	2vaaX58YZUxF2MaJ9n24zaQZ3KvZXzLPo32ci7CLSxWgbB8BCcoS	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKaZfwp2nsXPCVotTyVF1vchD3hcCZdsFd9cb3aSpw7rzAWmpDi	242
336	2vbDN3EbEj4cmpj797ZymQtzsc4prmztVWWRCe6Qa19MEreS4VMD	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKBrCnYPd9Lm7AjCSBYnL3yUfU3EwsXrWD9nEeV43bHakkUw5LC	244
338	2vbcuhHtQHuLJDfiprtDxfstoKWDHPQ9HuwqEui1XUsuQpoBnE5v	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLXVtY2bPhkL5YJyX6VHerDELY9TDmePGmsVxmt9VFRM6z3Jx86	246
340	2vbQs6AubLtvjKhQcw1xDudGH2LgrhoCJoKuYnZuBQxMAJGzwDjK	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKfyBw28Mpn3x4HeJGVCV3RakXtqAGnXi94fMthD7NRKJroyuWd	247
342	2vbLt6BaBEkwwojTa2sLTTWY2GyDgMZcvBMeZ9ddtykrsvuG6ppo	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLnXnZjsgqnnovQKCuy5BydFbYWJ5TbHaBcDG7qTvMPz2mtPdPn	249
344	2vamzcppj3xKW4RGC2vKUh4UeEGuPVADoT5iAvrgYqwu2LvN3pTA	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKGKpTsLmVvJ9qsjhrTQKnkm9UDKwmuqec6sSUt4nDzfSGQH5XQ	250
346	2vbCj3LZqMCCy2tjsAuTBBDEtNfksbr3TJscm5mrSL3oABoYfDcB	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKGv9x9s1WP26qvTLHTfwurVEiXoe9ME3GUQhrosnRzgxiWRrKj	252
348	2vavaRjYDprzR2AJ8xfoEbMjyZjUT43EMeCXwZeotAVsAQ5QBX7E	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKtmW677naNkBdfgLHRdAQJopWqpDZxCmhHL6Y2mhT6SA21be1u	254
350	2vbR5ZyofSFMKfEdymKai4YDPM4dWN9NsbfzBcGERGEEizSmNbTE	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLdbTSX7FGz1eP2FAXSs4jtDXaCkjH3CnucTQAxk8qv15tBBemZ	255
352	2vbYPnFW5uNN2SxaJsP42rtL7AmeVudZjh9Nh6wxRTZgsfEy9CMn	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLfBNKRWgSWUygJHJsyBjHu3TXREefTSvFScjBbnsDiqMwS41vw	256
354	2vahjavocD3pj24dNn9SEPAJibMEovpTY7rdgmbDDpL44Sag4oqe	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKzwMWps4rsKkWbhVFuSH1dmxzGXMgpP9pKWXsudcP3fWAyD8PX	257
356	2vb7sp6FUbBRiWQcAYPzrQJnGKEQxniSsGiULU48TN3b74KK11Za	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL8GXjXan3ZjBAYaAaKienRaaG3jQ5cE3fjLRL8L4E5UFUGHLg2	258
358	2vahuV2K9hmvbZAxFSbCUpGPxwM4AaPRAapWTK8ajRb26dfL29mW	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLaqfzct8wxSS3x1KwDcF4UXJqQRWaJxjJ2V2QqbNM1E8su9zXt	260
360	2vaY6Hw1GTaFCQAJDNJoWMBg3PrHe8nF3MbRULK8M8H537XitaFp	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLgQcVBEJPWxuiFubXCQSJSvNnVdvbVwHAub4ix62KVEVYLYWso	262
362	2vaUjtWsYRS6xrNauTYaN3vspe94P1aknG3JLWeN2BWuMS6KGfUy	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKBsUmXF2Qr75dJuR4fWAGTAPsuShrHdHY7pvT2btqLCrzQYR45	264
364	2vaTKec4XRVnoKJtP4s3fuBSLYT4cxT3G2STm7gWAeKnez4P1cdH	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK3yCtqWrpixFzMpJjmerXrvmVhWizNZHz1F9S3fp1ZB522ieiF	266
366	2vaVEpfkssyykh9quwbQ1irT6GsbfX8nfXLfwTzBsFi3XScXpNp1	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL7jcubEBg6A9EzfgXhjYk6ig8ZMLX98ZH6pkBDGK6RJXMKvgUt	267
368	2vb9ZbD7a6XwUfqbhQW9VuHiU5sEpLC3sXj7QP8YJLPJjuZ6sdyi	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKNZbb9728wVn4HAzzYyZvcZbnZLTo3eZ8ioiJ3EWRiwnZRUKS2	268
370	2vaT51ry7QQotg15LabREDRUMhVjX7gz9h1U3cezge7MAefYPBBi	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL2bTFTEbmGeeGQi3utmWrRfpfXE2vy1BgDDqRzuBHCkyDnqQup	270
372	2vbWkr8DM2ukLrFviFF3uDKfWu9aYFCmDfYA6MJt5LzapmqotLjs	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLSjduaXLramRMRptyvLYeR9SPfcyNdintkiUtiVHBSUHVJp9ii	272
374	2vajrDp4mB9DzTV7wAR2Ad2zPRHU9DieCu4MQd6bwbNUKf6BzSs8	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLaAcXYKReP5SpGMz5fuahJMmRnDqR3byt5427raipoirKDS1tB	274
376	2vbTU8cuxm2NgtnS3GKx7mdqg25AxnYcLt4uNMtjixWRE5aohXGW	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLsujzatRYQzXMfkPpiAr1p94BEFYKfHTfbUw8HDQ91VcjJoEED	275
378	2va9MdKpQFTAinZTY94uRWcdN7uESw22dAb6EqCLqLxeChL8gNF3	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLbjjW58ce9sTTCAdReu7FXpEwHT15cdUJf2CggfmcqkzyDf2Ga	277
380	2vaA17PsyBR9Yj8wYDi79z58DgcY6cpnoL3hNUhroo5u17uZft3L	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKdWqJz3XHGDcXdVnM86qMxLmaJW3cQYtBbv5zWQqffDXBEzrze	278
382	2vbZe8aNn8rNLgMgifqEnYmzarjusUhSHrMtKzwky32o3gH2kDPZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK7phXzERGppxN3mqhSfbY1xmvdFkuRTKzxXnJ3H6NewVqAXLdw	280
384	2vbo8i7upMG7k7Hy1rsx9ZRssqcZiyEydToJbT9A1wcmc6wCGVos	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLMSRCr18qNpS72cbWz3PnSpvabUmKhkR2V3XiscX39zTX96wwr	282
317	2vajpBxV7vpmLw7CizRNC4MSDk6PZX7fPUMLhm9BY6mAKBLytrAK	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLtDbVtZJGjyvTWUSKbp2cwh42yu6K457YA73bogXbD3UaQyf4N	228
319	2vbb4EHA1wi6druFFiYuVWnf6Wu1wSk4AdveQ95V8aSqVHoaa1te	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLDfNT7wvRZsKnCCLiB4MpkoG6as6UeiBuevZvBiJW8tpRSv8si	230
321	2vaVUowVyDLNUXSzcqQj3royVzg1pKt6AZjnz8pv4RH7R7JusjH1	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKk3bXFJc45uTxepphLt85jiLib8UbmJAwcV6oTYjhQA56jN3C5	231
323	2vaEy5cudgfVS3wC8KaCyW9yja1oaVjy1fVaSd1TzM8wJWge2iER	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLSQfSwnXccqbJkM9zYtqBdoeC8whTVa2kCFHG8PTdaWKnERbnC	232
325	2vb5DT8c1eA1hhaiU5TZzVFpGKoiMGwA48yNgwCSFiZM4Grjjg5M	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKQk8KKuEevjEHLeJhkBgp67MKKzmBSRRPxty6n9L7CfA3UGEYG	234
327	2vb9cMr1kFemSYjwCQFN6qSP9fHFWxFn6j5X6cMwqi719zGXipD6	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLLhGQga5XroRWXX1EczJS7cedK4JsfzuAAUFpFTfNqXVNZpwd6	235
329	2vaBayT9StvsWjhSqut2tmJuHkcRrkVWmAio4XSwqT5985xyq5DM	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLGCJoMGsm14Lqx4kazx5Ei3ouJPv4tY362jSjo57fSbxjjZc2q	237
331	2vbtBnVjpP3P4Q6G5D2dBTMzd4pgz9neqv9CL1HpFtXgUNsE3Zb1	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKY1Zhd9h18dvv141pTwz6YozbYtbfabHhAi8DjBBX9d53AXrZk	239
333	2vbVKx639U1HUYmUP8RQ8hSbtVMzkxZKkKnkcaYVJ8X3Ubg5zdkU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLTjvcHAi4nMtweT9TC5Avw6ZtWLMuZR2F8uzZ1FWHhrn5B9uJV	241
335	2vbJsrBhqaEVA1D3R7Z7Uw1Ug2VkXyHt1MRi2G2DtrgbZKi6hWEr	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLUwMJLBFkY82CfT1iPBqntYgQYnpRtxYa3u9tWQZmMpq24sL5J	243
337	2vamHEdfFoMtHU66XNYDhuy6N6iDuCHoUK166zVi6XxsaJ9x5Pao	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKZNXKucG1C3ZPRuGChsePjdSUjxXTH1CfX8tJP5ewuA5rniZRR	245
339	2vb2qH6LykGyMNLpU4vLHkrY7f2WkgomgHeFJ8x4Xzv6Kw7gcH38	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKfyBw28Mpn3x4HeJGVCV3RakXtqAGnXi94fMthD7NRKJroyuWd	247
341	2vbh9DQVLwTRvcwZERKL7WwKn3DxNodR3nqwF152UWqpTNkdMpMY	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKeLZKcVVYr691eHSejiALyhCZarbjpYmZpwDJLUVcsbcLmo2xL	248
343	2vbXPkzSVGq6apCQwyS9vrPgro8iyPM4cJbZxZSQ98u4nXt3cWaQ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLnXnZjsgqnnovQKCuy5BydFbYWJ5TbHaBcDG7qTvMPz2mtPdPn	249
345	2vbiYmGZer5bE5BpGJFwAh6GR7kQUb6bNj3FSiydP4wD3rG7MRGV	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLEs4j3QvBDpmLe4QxuEmexChcedDsKLcj1cxdV6tiH5g1Ghh23	251
347	2vavA1yFCix58CnuLXhneVjyq2tw2ByVfFNFXQqVn9cDCe9ERoKT	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKtQTpio7UwvoAHXUS56zHQqcMtBcvAaUbFkmSMgHnLQR6rsa16	253
349	2vbLxhtMUrUnFwktJgC2FvFjPXL1TuPAC7Bn3agu6BBrABG5NCJa	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKtmW677naNkBdfgLHRdAQJopWqpDZxCmhHL6Y2mhT6SA21be1u	254
351	2vbwzA2pqexBi6jRSynDv8fP48PgcEcnDNcetAHTFRyKjdpmgKqh	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLdbTSX7FGz1eP2FAXSs4jtDXaCkjH3CnucTQAxk8qv15tBBemZ	255
353	2vbkGLLTyRaopB4ePLW5i2UAf75zM5v7oBtyHvue9ovF9q7THT4F	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLfBNKRWgSWUygJHJsyBjHu3TXREefTSvFScjBbnsDiqMwS41vw	256
355	2vbnDYTZ7qRCP86iUuiwbBWTC2Z9PBsEN5hLjffed4L8TGpes4xF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKzwMWps4rsKkWbhVFuSH1dmxzGXMgpP9pKWXsudcP3fWAyD8PX	257
357	2vaZXH92gv9D9fQNTdoPJhNam2zB7u9HFbA9V35sV2rwmacNH9oZ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKZGrGxx5aLTKwRLmvKY4Y2BLwSGEtZ9tMnBwFVddxFqa1AvFyN	259
359	2vadimPm4fomCVm9NJKyhuwjuiqGveHdGqp7e21ydE6SdSv5gAhR	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLn25eZXyhCND6UvH9pX2CeQWvBf26fQBqnk5zfMPssPXjNsCKs	261
361	2vc2EWrKsjYpe7anoKMyEKbQv3tLqtsaNzc79Fu8R7aaJAZVyMXV	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKccEG31asRQqWyJWM6hnoijYsq5yTozfgK8v2aytV55gVJrrhE	263
363	2vaJTVdbvBNiNYGFQYiWWwfoXoWpQZB1BkjBrvBMb6tbwJwks4gU	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL5rHSAARKxj8EhwjgzaXWy1DokW4pRqKdPKqa8ar94G35atcxv	265
365	2vaxjR4593FCfBmhwFywB6ZnBjU2p9S6LP8R35XgETkFmiDWXURJ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL7jcubEBg6A9EzfgXhjYk6ig8ZMLX98ZH6pkBDGK6RJXMKvgUt	267
367	2vbXFM17u1ZyH7NK8KxzkSvEostuRL16HVsemVya3mjSR48gYZkq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKNZbb9728wVn4HAzzYyZvcZbnZLTo3eZ8ioiJ3EWRiwnZRUKS2	268
369	2vc2ov7a3vkpk2fXV7qP9cWVHaoL2TNy3XuXJhATnSGChC2SE8o7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKhxKUsgPhAevHuxLEaDvhgYfuUNig4GANyqi9XxSh4oEtptvsT	269
371	2vajrR7c63nmQxDduSdjjnhefg8PqgMzvug9MLGuoZJZvxSc3E8j	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKYxZkGGvL1rka5EQoCvXXoyguUsH3Jzzcy73pS94nGyJ1WPoS9	271
373	2vbGdbcYHGE5VZ1PWE9paYmsfrmfCDAarG4WYivP83xmf9tpS7pJ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLWwDa3VprdUafMVtCMhKNgNNoG9Afcj8iZVgYAAZHb3JgJkiLQ	273
375	2vbe4bqUeUZTZZo3ERg7PKFPyQuutjBDtdyHTZHrgnadba19QwR2	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLsujzatRYQzXMfkPpiAr1p94BEFYKfHTfbUw8HDQ91VcjJoEED	275
377	2vbqTYjFZ3MVVc66FyGYUraEZpRKY5Pu6U8P6qCxwAhLqmRTN1HE	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLakSutYkhiCj2PAMUDeQHavSeVCpggC7mDFRgy64rnEmJXuee4	276
379	2vaDULMfXPGt7UEbPzod1PWRp338aGAowsZZdaXPqWp7R9pJan1n	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKdWqJz3XHGDcXdVnM86qMxLmaJW3cQYtBbv5zWQqffDXBEzrze	278
381	2vaWaUkvHccM3quq9vyGKeopf9Y1JQCmuvaa99NzYF9uNcUmovZM	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLE9tv4AVH2gRRJ8zk57hHQew4Xwxj4WEGahUNfnUTdZsNgGQkH	279
383	2vbErD7sTDR7ew9Zqvs2X9BNoLAiwwM6Z6Qzk2b2WWkQe8ex6E71	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL8rWgoaorWuxM8oEfqZuVKpPzchKwTwJxFZDbfLpeYhGShdhzn	281
385	2vbmrpPrGDUwkPDF7oY6TDZ9h3Trt6G7ugKZvmvq7TJuHxm66pqr	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL1KzDcdg2rEoA9arc2aV9BwJzvVKccAFWKNy7HAChBcnSHUjNd	283
386	2vajFTzCJN7sD4z5SQE2GqALZLBJgBPoyMTjYwp7MR66v3UELd8F	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL1KzDcdg2rEoA9arc2aV9BwJzvVKccAFWKNy7HAChBcnSHUjNd	283
388	2vbETPbp6kmrU6GUDz4uYqtLzTgFJMTHQabZd91XKq59ZQwUBNqP	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKRiCr86grVFn7T8Uwm5b5bM5zSMoz9tBk4Gx2kzLqxoLFZnjhW	284
390	2vauLCKcsdpENjKT7mMZkVQ2hxJKXbgjs2kHKxesB3vUgDFH9m8k	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLyaCYAwa4wBRyZZPZFcCDoHjYxPdXTqZ54f9Ht3iJPcQ53QASA	285
392	2vbJBnDRgkJJTDrFkGHYAMgqVszhuXQBpF2XkkrpxErz1Qr9C5Tq	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLiZz85fBTg8SCV6MNJ8rdmnfmDxk6UssCjwfojyZT1js64wjAR	286
394	2vaNufohPjnWYUu7gTuZkVRc24nRtW2UTFtUx5xR4fRaBaknWAuF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLsv2ZqewJKRp8DHqwXm4ZiHyiBK31pQLQCwnL8cRrRdg92RncB	287
387	2vaGdu9GThjab7QyNZMD2W6RGjfaoEZ5sD4JVXNCJ8Pgb7pPhZYw	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKRiCr86grVFn7T8Uwm5b5bM5zSMoz9tBk4Gx2kzLqxoLFZnjhW	284
389	2varVZfQnjv9bvGKhEhQtfU1qrUL7wpr6HNUwqukTchGBc4r4DS1	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKRiCr86grVFn7T8Uwm5b5bM5zSMoz9tBk4Gx2kzLqxoLFZnjhW	284
391	2vbdwEG155GxVBDg8XUF7rRJruhBxmpoDsKLNfKSceu2eER69fvr	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLyaCYAwa4wBRyZZPZFcCDoHjYxPdXTqZ54f9Ht3iJPcQ53QASA	285
393	2vaHe94F49gxVnGgxcrAqA7JviUon1z5RzkzoRgTUjjQSqTzkxKu	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLiZz85fBTg8SCV6MNJ8rdmnfmDxk6UssCjwfojyZT1js64wjAR	286
395	2vbQh84bBH4bnCvLgGs5BVEJDk3FVmLFRfYbbB3ouDH1DqgRkJdC	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLsv2ZqewJKRp8DHqwXm4ZiHyiBK31pQLQCwnL8cRrRdg92RncB	287
396	2vboBLbxuWc4diQ2Y3WncrmETzcQLXnTovydbdsBtLK1U8R7S5s3	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL5PeLuQRvfoeWqJQiBJ6LBbbEmTZiyg2yGL441fA32paux2dk7	288
397	2vbXv8ud3wh5bJC76qr54d1ijtZrGyhu24zphrNr5gHFrTMHLLfi	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLPVbYq7kWC1DrjZRo3REXpg98QGKR1Dbeomo3RokbNLu7MPGsJ	289
398	2vbbs4x6aEd69hs73iQ8VsvHnYeiHNbrMEeh8xYQHkHS8uUQSumF	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLPVbYq7kWC1DrjZRo3REXpg98QGKR1Dbeomo3RokbNLu7MPGsJ	289
399	2vaGzpq9YzwvDJuMi5FYZHcgCdxgiwv27z8XM2VQXXr7S7LZW7FX	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKKWcC8N7mdmZkB92dveH5NQ5NQvActZC1QcsGqjF9Ap3cRRgvY	290
400	2vbdWQMoCs7axchBDSHzW5j2nqppDPsXWqwMDmYELfBR8bnmdrKR	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKKWcC8N7mdmZkB92dveH5NQ5NQvActZC1QcsGqjF9Ap3cRRgvY	290
401	2vbjn7PmjMvn789iH4YMY5t1RbbcSh9kdcPgo2weFgCc7gWZp7B8	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK8VQ3LSbvuFYkJyxmf39ZEioS72oYs8TPX42K4M1eBfCDEhagn	291
402	2vah5Be4jHfaohWT7nruhsjJS9qYY322KhRWmnHbffgBpKBGM1sB	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKHAzxXaUwe1GCNkEiBrRJE6WoqhNwevP8VFsNYtJy94rWbArsn	292
403	2vbAG8XX8dnD1GXrQbJed9SGeEe6TxmAK1pcbpq9xnXdAeotxyrW	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKHAzxXaUwe1GCNkEiBrRJE6WoqhNwevP8VFsNYtJy94rWbArsn	292
404	2vbTPYbjrEK5LNF3s6n84MPCC3wuGU86sfgfrRftVyDLB7xmJVAe	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKPoYs93yYkiXhzjANC9eAwRm6Zgr9LkpLX7goC9A6St3WKZLYo	293
405	2vaCS1SKeyDUz7kyr2J3rKiHFVQfM7SgfKsMsob69Z1pEcUsik4h	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKPoYs93yYkiXhzjANC9eAwRm6Zgr9LkpLX7goC9A6St3WKZLYo	293
406	2vb7GZz7watiqfYjPJhpwtau1qmVtPwrGZcii96w5FvZcBxDuiep	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLChsTTJ3XveQBGWF1YGBT66e1UUH3RaMAn4v7h9Y1GeACkFTVM	294
407	2vb4jWm1QdCCnoAPtGfSGZ5KHxJQkDDdDBQQ8MpWR1fbV733hEJV	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLnMcPE78aDAYU8L1ReTC2K6C9rcqeq5kywH929BP5jp38SSUT2	295
408	2vbNgEfqPP8q2hnML67fbkKVBwfmz6KdKSm5TShohNLv5FjaTqhA	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLnMcPE78aDAYU8L1ReTC2K6C9rcqeq5kywH929BP5jp38SSUT2	295
409	2vadJvFUibLLMpigQ75nKaVMb6Mjcx9m1o2C2QUnYosscz5uPqeW	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLXsdM1Zt5FYgaAx8oKqRvUQgLdUL3yotR8MsgZaJ7ZhfUnHRPf	296
410	2vbeaiR9UKhCHv3v1M56Ct6EFoDvXVaRgNxoJFZGb4XGDKvtjwiE	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLXsdM1Zt5FYgaAx8oKqRvUQgLdUL3yotR8MsgZaJ7ZhfUnHRPf	296
411	2vadsLrZ9oq1ogpEedbqTuyiW5DFVpM4EYjriFT3jPg6YkutLU3D	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLTtgGykC8qJGwGwuXRDoV5nHiKAgJ1ShmLhGWTTtaYMd6UghSu	297
412	2vasc7GmCuvw1uTjb6rHQGw8goaTv5cpTQnzyFtVGBFwKbCXADaA	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLTtgGykC8qJGwGwuXRDoV5nHiKAgJ1ShmLhGWTTtaYMd6UghSu	297
413	2vahbFUTgqL3C3DDiaWGgnpBPZZEUktKWqyppm4CAYq6RF17NBJv	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL9YPLyjdfXEryksMKvQWm9XjNnun3UE7nmuFwvj6YWuzFid448	298
414	2vaeREdWbMVA11AkFDYbxGt3xmMJoBQnFPBzmNUjeGJHHnYMJXEp	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLQvXgAryySavY29bi4r3KGvJsSVF4sfypD3cdXbovFQet4ncqB	299
415	2vbAY2ApRmBaRN6PgwsZ2P6sVTBqZ7hadsq7Lcj52KuoFtDXqg5E	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLpnWhBbM7uJjHtYeG7KagsCYQTdA6FRgm7Ku6xccCazWTMxGhf	300
416	2vaTf5cDP1xdDBDziYkXLHoUbi3ibTDuPJ9xUt4i4Y3DfeHuwTY9	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKQX882VYAqUBdd1aBHJrh1MnD7A3Qoyx2uTMbWD6nbSdY7qUaJ	301
417	2vaBhqK6jLNf7pxRFWXde1mZpAR2GfRz3eePVZ2tSfa2ReHFybZs	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLoRLyW8QJshSUbmWAV2VAgWRjhrH3DDHHX4ijm12iimB7WhMk3	302
418	2vaqgzfzL62AXbzt1Mn7x8Tn15mteiiHiwmqQXApmSM9rdpB7kfM	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLoRLyW8QJshSUbmWAV2VAgWRjhrH3DDHHX4ijm12iimB7WhMk3	302
419	2vbtBBRdgwEGSYzRx7eoXTeyMut4XSCkT7XUJxFkG4P9B2K2iLRT	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLu99z9L4eHA6gfxH52uZzJRwqfuAq1NuhUQWkpizpnKgnySQks	303
420	2vbgDSymgi7BPRe8Z69t75yS5PaqAJXnRtm3WUMe9sP6JKHdfkn7	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLPSLmC5xmKNXugX5i3hRWrb4U9ZZHJLbxsYD5r7y8tFBgfAiyP	304
421	2vam2Vf365JHt35T5GAc6zTo45FcMMtit5aU5rMYULfkqMmf6Ro3	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLjWLkcKRhBWq2n4drT2ENATbN1a9Px2hxHEaRDne6a3FQrwPmi	305
422	2vb42g8LW7G78zsWToqgxcwu29hQbQ56upoz4i3wisxyodsQcfRn	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLgQ5enAXQeY8RZNwpGTnKCT7caX4sJHdVEuHt5W4w9vxZLiAj6	306
423	2vbTmeSYkpv7wKGiQjrmpVQtJLWq2r5jQ6eVMxsgSLKZTS3pQGDM	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKBKUVSzRSAVEiN4mDsFEeqBL2S6VUkeS7gBKBw2XXATiKx8oFA	307
424	2vbxBKoz1qSMdVM9gUKKAyS8sQwAFaw9GEqgUUe1wWcvk9UDDGko	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKDGRekLJK9PHadeZnxLBUvY3Q4yvhQiEm6Q8FtZABesXUfZTxE	308
425	2vaWRZnYhbfiJ5QUDP5GxGWaiLQdokDaNJQugMvz7iL5UDuwrarT	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKDGRekLJK9PHadeZnxLBUvY3Q4yvhQiEm6Q8FtZABesXUfZTxE	308
426	2var7bmpVBfgemJbkQNCZyxj7Rc8UKaRxMysUojwi1qnBAbPvdD5	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKZGKS6CWZt1v5u2fKtAcMN2qE9EpeVhg7AQhA72Ree7DMVX8hj	309
428	2vaFUu9ZkfFZh8dGcscfGPbPyX5V1NNHJE8K5PyWjfb5B7cv5eyb	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLr7Wet39PhbLbuvV2yjdbqkie65bVdmtJSD663FXizGFjzq9W9	311
430	2vbU7RhruL2qJbWVB5aeU6eSuPkejHDbWVL8MXDNDpfTWK4PZs3u	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLfUBWvH4ELw5iQQarbcvpYn9RbyMN6fhakiHg4qHdqyuCeCPrZ	312
432	2vbfiiKD394K9RtLiR1XckEXaC9MNQXbmsPC5bciwfgi61kvmbxW	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKgrDqoZkhuEC94ZtcmA4iHvKbTwXihDfYVSzUZCpGqmr31yXtz	314
434	2vamv9xMomVeWVT2bxZ6uhsCzBNUwEYYWiPV9UvhJVB4jVyiCbSt	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKbnoTbbCEtYhUnuGNZNbszB4qV5KCjMhS7eSoQ7nxh5Pbs1sQK	316
436	2vbAb5DZCPPWKStecFTPsnzE49kgSugt9NmCju4mnwfXd93E5U28	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKRT7Gz3z916mCVjeubWjTddyLhHRgeGdvtDHHbRSzBKZ8433dV	318
438	2vbx4Fkx9bsAzRN625gRdYjnKEs8pqfnDAHfPA7T8Q7squCEmQRc	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL7QiekAoaXtzcEZ58s5YYGD1Gsq2XrgbK6scMcgGDH34raPLfa	320
440	2vb55M3ypPbuUY1zkT6xMn2p59REJQXWT7rDChGALGYPoUwQGb2G	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKJb1doKYHwpw8YcTuruuTSfHrpf47HpuQUBJ8BFjxvzFQw28vL	321
442	2vaDbqFQ584y25seWLxSLaQvK6WNXNZyzgT59y55628PF6FYy6AA	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLXf7FcuPFVsdVvmFktRTuSQXT3SkCWpcr3U34HgDokuEK1xEmE	323
444	2vbAXih8jMZEF3tfgWKheXd7mAqak9HjKyApbNQMhnHC993Mh8Jw	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKDKU7npYshYURKMeLbLQHa7iJBrP8opwioxnBh1ATACwQQ9WMs	324
446	2vbxJaCgJzmS8PLSZcfv8vFY2FZN76EYGVpBVijCvtcZ1Fv4bXv4	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLMJRjWHdW8eeAXC6CX5f45CyZLVpeQhekEQGCaRWaz7UMDKMet	325
448	2vbVG3Km1KTejJZCACHGSExzc5hUZPu5ukaGxboU5cDHmye5NWBE	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL9ybSM6AEVzXXssvGfnF3Uh5RNAx3ANe4reL82iKgJUm3oC9vS	326
427	2vbzimyeG2JmDzHkzdb4adNbNN1Y2taNjFBPoXwU8PrsF866ci3B	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKiq1WGFsEvEFzz4ERy8jCwz4PcAd7epaqWujJkhEwZUAJE9JvP	310
429	2vbWi4yn8bahp7ivfUK9g7A1SWtUxdoCg7QNXS4i61DqbVRb6XPQ	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLfUBWvH4ELw5iQQarbcvpYn9RbyMN6fhakiHg4qHdqyuCeCPrZ	312
431	2vaFXFWPFqj9fYXSAX4G96BAtQdzWB9aUdW1wh7VGUW3i2twjNzB	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLccwsEiP2YSySq5NNb8aGfS72ETtG5kqWVr3FAWxbm5tQZaTfD	313
433	2vbDvDhwWDNdxoyib6ukeSw3WBoDnATrW9J7kMke3fhthSbuEbmg	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NK8k1umhCVaJswH4bw8CbSFGNQhrMEUcHCptXeqPCB2K1kbkyqG	315
435	2vbkFgoLtbYim97RYLXXZPGFvRUx6ifv7cf44m9hjNpraAoGbYGS	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL94D4vxyZrY7VDsG9C3QE6eKeRnHXpaCtRAnQFbGCP6tPUgW58	317
437	2vaNzEE8TU6U14yFARPTP5kJkUHwJjKAk3JYKUp3bmf7C5uqgEuM	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKkd6i8HZ5mcyXe6UeDHJqWxKgfpde5wd1pLEdtRYVxgBWEcvba	319
439	2vbNkyo6YdCxVYTTuGp4gFZ4NTS6ww48tMFRvTeyTVyJgcCKUceR	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NL7QiekAoaXtzcEZ58s5YYGD1Gsq2XrgbK6scMcgGDH34raPLfa	320
441	2vbZiHZzJaatt69s3ChjKaBuhMqBXqhMoKwo6FH7kp662QdVCkA2	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLAQ2VGUTpJTD8jueQLa9wPer2eqL4JqfHPbu6Swx56xZZ5TRPf	322
443	2vb8W9jFYsnsSqz7WDLByvYCqG9bwL885LtG6tS3Gn3F3uH5vXNE	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLXf7FcuPFVsdVvmFktRTuSQXT3SkCWpcr3U34HgDokuEK1xEmE	323
445	2vaj1mMkCvVT42QmSdJHxfP2y6pPyBdEwP6XMzjUPzu569vn64zA	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NKDKU7npYshYURKMeLbLQHa7iJBrP8opwioxnBh1ATACwQQ9WMs	324
447	2vaQ3ZfHV9AH1vBrmMjUDP2z75Nb2CKYtjVuwQsYdyBGAqxnXaZz	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLMJRjWHdW8eeAXC6CX5f45CyZLVpeQhekEQGCaRWaz7UMDKMet	325
449	2vbCS53WTTkWUZc37ShXpDzEGdqNfYKzDviHRJ2Ea6ZsJWTZjGi1	2	23166005000061388	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x	3NLyXamPK5Kxz4pt68k4AkeuNggzbfURiVAogUyhbUUi3JLQ8UVc	327
\.


--
-- Data for Name: internal_commands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.internal_commands (id, command_type, receiver_id, fee, hash) FROM stdin;
1	coinbase	96	20000000000	5JuubTiuwNt3unvNRm9cZby8ctRY5XtpP8NCgtvoJMuMmx6CoZqW
2	fee_transfer	96	500000000	5JuzDVKVg8uEDnXBUVCpSCMwFaNTAA8mr6JQkrgaPdReQQqSBgDZ
3	fee_transfer	96	2750000000	5JuPUV8FbiKLFDdB37cWtxMeaft7S54PawLqTYzLz1EeA5srmVLk
4	coinbase	67	20000000000	5JtVTHus5dTcjGE4mYyyWS9xfLPaWurHTCp3kpSVAxTd3MWsNgFJ
5	fee_transfer	67	3000000000	5JuJvP5PECsCVcpTwqqDXYSDBc7hPGwZYiBr61KkQKc97qeXcaZ3
6	fee_transfer	96	3000000000	5JuKoUdGVMGDnekf28RYa6RTuaS1anLUjn5cBmzobfPutiBnJEzv
7	fee_transfer	67	9500000000	5JudBqarhP9xQQsBbonyvDjjYsiT2qSrjw51co2cgVALVd6F2ZYt
8	fee_transfer	67	2750000000	5JtdGQSnFvt5RkKF5h2u9mcezfN6M2nu38G5xbhG7xU6qcZgNwEN
9	fee_transfer	96	250000000	5JuzfEbG4Bejfynoar6ADanRZVtbod4d1AmgDq6CdnS5aH6SfTLR
10	fee_transfer	67	3250000000	5JutZrjDdhxHr627gFgcS518S25dhrJjRrzm5Mf6TQqoMTuCyWdg
11	fee_transfer	96	3250000000	5JutxpsmnGQ9228DXZJ7qfd1YcUavYKNm36Pgwt8zCXqfkH9JZBS
12	fee_transfer	67	6000000000	5JtciHWQTCLemjsR9gHcMWQFSJx1DSzMGA6WzE5PPM82NCmnmWRa
13	fee_transfer	96	6000000000	5JugE9Dfs1TG6jctyfotXwMkZ4zp8kY5yeL7NnN8gGqMCKffYwhm
14	fee_transfer	96	2500000000	5JuxsPPEN3Ty7jaUutui9RJEdJTvEwQ8Yemh6izqdA1Zh5jdFtZE
15	fee_transfer	96	6250000000	5Ju6bf37iJx2fiKZXY5stGcqBSqN5q3SioU3k6jPVjcVATVsTFPH
16	fee_transfer	67	6250000000	5JuGX8HEEnj4KJBj7c8fRLDq449PtCDKf6PoW8VVPApmDMxASqjR
17	fee_transfer	96	4500000000	5JuZu5oK69mm9TNAQe1UBW9RVWNNQhAatDsHtHmjZj2CAfJ93nMK
18	fee_transfer_via_coinbase	242	1000000	5Ju8bgzeGYZ4VmWE2cPrW5jSsccUDKkGWsxTBgoBegQPTvFuK68i
19	coinbase	96	20000000000	5JtyScoeZwxEm1WSxoihQapo2CpeWkU73y7gjpgnBXciHL2knfxR
20	fee_transfer	96	1687000000	5Jv76ZRhzo8gUCct3q6FSbubrMUe3LoHapBm2M9HHV8NqXhyhMKn
21	fee_transfer	242	63000000	5Jv3omybR3hnQ3D4PjhiReLJVEHkq5WML1ju8HW1figWR2XyHFCz
22	fee_transfer	67	4500000000	5JvJjj4QfndAY8EAe7oQGKbwfuFAuHi2LCQ61rAjpewaygFpbRLM
23	coinbase	67	20000000000	5JuuQz6kGesfJxYxK2rTL7GGtapqJordq8EkGZMcytnHmctppcBw
24	fee_transfer	67	1687000000	5JtzFFbvE4gnxzahTZmocrB9TfNDunvDp32dyBXz441yHjvycSYT
25	fee_transfer	67	1750000000	5JuzmU59czAeTaEP5hVmZ2MtJv15Tjm1CCfAzexYUnB9dUWzFoVw
26	fee_transfer	96	1750000000	5JvPyZYgngjb3TuTReqVPEHgdqsHdwsRvfuWHFuwJ6XpQTNCwuDR
27	fee_transfer	96	5750000000	5Juyg6uP3f2x14xytZjfK2kn6U1UTChfUFxdFpZe2mLUbhMGM4e5
28	fee_transfer	67	187000000	5JvReBS1M8QRk8Z7E8zsfsxUaTfg2VhHwc9iSLPzW6EYbr4v6QA3
29	fee_transfer	96	187000000	5JtodULx6eKgGJZCfHF11DywDtt5yZTgqRiZGS8YmSxNKHgSVihA
30	fee_transfer	67	9000000000	5JvFAxEaT7Z6tU8x8osfGwwderoWUMZ28UT8iCJ512ejbUgL4eDG
31	fee_transfer	96	9000000000	5JtamN9HuFyVwDAUy3CUYY8qwrfsQEiiUT8QQtwauwL9kqTzqK5A
32	fee_transfer	96	8250000000	5JufvfvxXLweuh1JpbrAksoVkBz7qq7re2LmdxyS52H5EeVCcHRb
33	fee_transfer	96	937000000	5JuMzEEFUFBwszQJdQUqnBraafEKgd8TRSDeB81g6yr7TzE81aWy
34	fee_transfer	96	9250000000	5JvRF1juyFmGx6LTDWUfjgrW3vDNZQPmPGX1GJXJ6hsA7v2ShV7Q
35	fee_transfer	67	5905000000	5JvJHCJ1u3ZBaw5G8XtDDmdaGjfMz2xUEmz4riaPuSmeuA2Tvpii
36	fee_transfer	242	95000000	5JvHkmv5wZkU4dzTw31w6geSoFLHYpjnUy2hb1LCAByvdPcantVr
37	fee_transfer	67	1155000000	5JtaAKU2ZaDrwAmuGsosoibaAYUaxcRMwWHfwayy1bpms5mJaDgj
38	fee_transfer	96	1155000000	5JufcTDLq2NpNc9vuYtvESCrcE27Qoh8dyWFVETAnVcTZ4jiWs5o
39	fee_transfer	67	2905000000	5JuqF6WRPQTNHTFyt3gebx7g3x8teje1CpSP3iuuPWv9bbVrR6FK
40	fee_transfer	96	2905000000	5JuSrUn2N8kY71sC824WMa8VGANNyUkhL9pDWWZidbSbQwgzo9PS
41	fee_transfer	96	1139000000	5JvBe5ixh2uii32NE7E8bdqgEzSYDtLG1cxrbp8gis9MYqAc6rAk
42	fee_transfer	242	111000000	5JvLds4K4yJkwvvyx2EuWCsGKjVy8zAGPvT5ASTdgiDqQRemjRod
43	fee_transfer	67	1139000000	5JugnT2h7BgjXF3P7MvZMiUE8Mv5hB11uLipksx1MkGxDgJAJuoK
44	fee_transfer	67	5750000000	5JuJJxSjG2SKprjB4xC7akJuRnkbjWTjezdxUpcT293FPhsec5W7
45	fee_transfer	96	2639000000	5JvC3eogoxV3GSdHqaPWUAB2Mg8GJUf6NptQpkpGdBV1FkkhZJFK
46	fee_transfer	67	250000000	5JubwwVPrKoWWgmCHZUhE5SbT2SCQxD8QZcL8V5taRj1Bzh4p5uR
47	fee_transfer	67	2639000000	5JuSVKH5Fz9adNtfwPadAMzcYx399DNVgRxFivaNmyDo2W3QWBSi
48	fee_transfer	96	8750000000	5JukhTSBBSWr2JYfuDm6JAYRpNusCvae7nYjwh2reGf7PipRttvo
49	fee_transfer	67	8750000000	5JuQpDDoqrysGYmwWyenVBEdCqqUVMNhthKfCSMQttyRAqweVdqa
50	fee_transfer	67	2500000000	5JteoNHJyFqaKzCKxDesbgA2RkjcqFVSKJxznFAFnbTjpdq8XRKL
51	fee_transfer	67	389000000	5JtsW8n2nfym7bbqBdRX9BcQXxn9Pu3kKNydmnyQpoDHFRa1ZWEg
52	fee_transfer	67	500000000	5Jtwi5FHdL15MzkdZAF57aPBQNG3GXkTvCuSaPYTRv3ChPybLupY
53	fee_transfer	67	2381000000	5JudQNFof37oeRxMQJr8rrzKb9CicusB8Hj9Uc3YSY28WFgeWpsg
54	fee_transfer	242	119000000	5Jv6Tt12uSuw5RjTifkNMKdKVSNwMC7UkyZkz7a4FeVPYpeAaKsn
55	fee_transfer	67	1500000000	5JtpU8BEAea6sYnsno3bhc3zr15n4JoRjZrqFiSWA6Sc8pvCxUjX
56	fee_transfer	67	1381000000	5Jus6gMt3PAQXyy4QLhY3pgLEbpaCyVP4wt6Px8jYxQs2vTSvFSE
57	fee_transfer	96	6500000000	5JurfrwrTRZFDsHgZgfNonjfJStVKU6DNw3HWyHzgw6UZKu1bism
58	fee_transfer	96	2150000000	5JtjAYBRYikbuCnYRhCjYcGA9djZWmyAo3siRhvfxUDx9YLgboTY
59	fee_transfer	242	100000000	5JurntWqgoGbra7czJ3KoHLkSFm3E7MGywu7x7PpQvsRrZZWQxNB
60	fee_transfer	67	6500000000	5Juga5egc5uqjYYe7DmgH1hzJxPbSBqqYmz6RTj5xoyaQLthGbWr
61	fee_transfer	67	2150000000	5Jv8X7K54vQpDYZsUoQSbZx5bUHYQPZeL8kBuokwMin7couhe2eV
62	fee_transfer	67	2982000000	5JudRNNmwGeSYrj893gVyMj4cWyvb2ff9PnUXoKv3YsLvaq6dAWe
63	fee_transfer	242	18000000	5JuXAWR4SJozkN39QrsD3iXAAdRCbadzGGzUYq7oeNzP1FazFEd7
64	fee_transfer	67	5877000000	5JuKXTDotJkn6Hj6KpPFuuT9mS8MvMv2uQcsZAZybUL5QoeNCM5V
65	fee_transfer	242	123000000	5JvJdtzwavo8zKAY9XbEE9ttLXnmXy75ko5zWepR11B6jooUuMp2
66	fee_transfer	67	8500000000	5Jv1n1d93W49oCJaKfKDkAdnnjqMNnmAgpbqQfBsZrmeqqPd1NVk
67	fee_transfer	67	2908000000	5JucVywsNEiGNjVgnEKM4BSGHCdVqXtAoQx94K8h3Dry6USBWb9v
68	fee_transfer	242	92000000	5JtjuADkLy7Vit3k7cc3E6ezNV7sv6VEgBzypf59n8KtNKEp4ziq
69	fee_transfer	96	8500000000	5JuWeU9uDtT5xqHbtnnAvoToaK2kWZn8mSJ4j6Go9zrfZrcYPmDd
70	fee_transfer	96	2908000000	5Jtok6K8xq4y3U2rJFB75GHHinBgHm9ao9hFpUEvdWsAoFz3DSsg
71	fee_transfer	96	2720000000	5JuqrdasMg4TCJJVsWkq7qi4HuntydNoQYJPvNQ2eQBSAsM1wq8D
72	fee_transfer	242	30000000	5JtqunFr5PJRNRmUMLF1EMEJwcj5hBVNASkxv9KVBYAMJsBKgZZC
73	fee_transfer	96	1000000000	5JuPyw7shfwdpS4mN2x3t59fZLoy1WVZYdg7Q8o1RAh7io5Xucic
74	fee_transfer	96	1878000000	5JvEZvpqrxVVApNhfb7DTbGo4yYiK3QxoiH5FhaSUWaaxvqwVMJf
75	fee_transfer	242	122000000	5Ju1aWQtvSk3jz5dsSHjp1ZSS4NGgdWLyYiq6NjdJbacF7sscAVK
76	fee_transfer	67	2250000000	5JuTpGxNHgFU37q6GDbcQvzPkApF6BB2wZSubVyB18Wi2cQpXRgi
79	fee_transfer	67	1250000000	5Ju8SV1vSCPaAcXfoWJwNAHczgcTtUtwJSCffjNhmKhw9hbHDRAG
81	fee_transfer	96	750000000	5JudQY1RYP239p4swwx6Vhikm2qg2JZaYcAwBPyrMeuT3AwCNAQo
82	coinbase	115	20000000000	5JurmM65Pf1yK1dqynj1jJHXmLeojv3b6xrtfCVdQyF76uQ8aU1V
77	fee_transfer	96	2250000000	5Ju6nEdpYm1PPits884GtcqDcJFXdtmGNxmc6aoQPksoXqYNArjo
78	fee_transfer	96	1500000000	5JvDfU1m19hwzqNAZRqmXBh81cki9RLDbb5y9RakDxKPBcG2yXxs
80	fee_transfer	67	1000000000	5JtmuuDFPY85pLm4cXNPsGqHXz6gMtSCNmHDFVzNfEuMENoQdp4c
\.


--
-- Data for Name: protocol_versions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.protocol_versions (id, transaction, network, patch) FROM stdin;
1	3	0	0
\.


--
-- Data for Name: public_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.public_keys (id, value) FROM stdin;
1	B62qiy32p8kAKnny8ZFwoMhYpBppM1DWVCqAPBYNcXnsAHhnfAAuXgg
2	B62qp3Wu9Ayd7rkDrJDvoi6zMKciG1Jv6imE9SRUJzdUbQHVttKPWPF
3	B62qr6VZXBDXUntN5bcwu69ae4oqsB7J7cHYaUWKhWygfujRCtFu4C3
4	B62qnFJWYYYbTuDWQ5oCRhP4hT8sc8F1xDf34wyxhvTzosxnV6UYNDP
5	B62qmmV9zHiWwXj2Do14t2bUtT7onfHwsNa7KSJxrFhpXbunUd9gLEi
6	B62qnzUQLreTeYj7TkkKyFR9s5REY6GTKc4sVK8K34Xvw8dfRPAUByg
7	B62qoxkuzRkqEXbw2D7FS1EJctSvrKhFDjwo1s7UqaRbzAC9wW9CqXB
8	B62qk4Y4VLT1oUbD1NjPunSEUjz5yVNbiETWCfNTvT5VLrmbRwnKcMk
9	B62qnsdKhWmeQZjvas2bVuE7AcUjqWxSjb5B6pFqyVdtVbrro8D9p9F
10	B62qqDcNXt7LK6686QQ9TvLaFF5as6xRRSMEjfwXJUEk3hSHVXksUth
11	B62qmRRtdPM1XRnHpchjrVdVyRtUKFX5Nmrhu7MWSs3wDVsLuTQ54dV
12	B62qnT7rV3ZQ71n6Z2RaPZSn38zEniZq1A8CXEdArxrF7q6sTTWZdZc
13	B62qmnTkaf43Ctbxq1NgvtakVwKKcB1nk2vee61bMAcPfDB5FR5upJN
14	B62qpTgN6VhfdCGimamFjarhSBfiK1oGEKyrqHN5FHejeJR8Z2vgKYt
15	B62qkaFHyAx1TMzuez3APX1hG33j2ZXCTXJFFzeSxgt8fA3henaeT84
16	B62qkCd6ftXqh39xPVb7qyJkSWZYa12QCsxFCaCmDrvfZoTNYmKQtkC
17	B62qrEWSxSXzp8QLDpvuJKeHWxybsE2iwaMPViMpdjptmUxQbtDV178
18	B62qnUCyUPAGE9ZXcu2TpkqUPaU3fhgzxRSEiyt5C8V7mcgNNvj1oc9
19	B62qiquMTUSJa6qqyd3hY2PjkxiUqgPEN2NXYhP56SqwhJoBsFfEF5T
20	B62qm174LzHrFzjwo3jRXst9LGSYjY3gLiCzniUkVDMW912gLBw63iZ
21	B62qrrLFhpise34oGcCsDZMSqZJmy9X6q7DsJ4gSAFSEAJakdwvPbVe
22	B62qo11BPUzNFEuVeskPRhXHYa3yzf2WoGjdZ2hmeBT9RmgFoaLE34A
23	B62qmSTojN3aDbB311Vxc1MwbkdLJ4NCau8d6ZURTuX9Z57RyBxWgZX
24	B62qiaEMrWiYdK7LcJ2ScdMyG8LzUxi7yaw17XvBD34on7UKfhAkRML
25	B62qoGEe4SECC5FouayhJM3BG1qP6kQLzp3W9Q2eYWQyKu5Y1CcSAy1
26	B62qn8rXK3r2GRDEnRQEgyQY6pax17ZZ9kiFNbQoNncMdtmiVGnNc8Y
27	B62qnjQ1xe7MS6R51vWE1qbG6QXi2xQtbEQxD3JQ4wQHXw3H9aKRPsA
28	B62qmzatbnJ4ErusAasA4c7jcuqoSHyte5ZDiLvkxnmB1sZDkabKua3
29	B62qrS1Ry5qJ6bQm2x7zk7WLidjWpShRig9KDAViM1A3viuv1GyH2q3
30	B62qqSTnNqUFqyXzH2SUzHrW3rt5sJKLv1JH1sgPnMM6mpePtfu7tTg
31	B62qkLh5vbFwcq4zs8d2tYynGYoxLVK5iP39WZHbTsqZCJdwMsme1nr
32	B62qiqUe1zktgV9SEmseUCL3tkf7aosu8F8HPZPQq8KDjqt3yc7yet8
33	B62qkNP2GF9j8DQUbpLoGKQXBYnBiP7jqNLoiNUguvebfCGSyCZWXrq
34	B62qr4z6pyzZvdfrDi33Ck7PnPe3wddZVaa7DYzWHUGivigyy9zEfPh
35	B62qiWZKC4ff7RKQggVKcxAy9xrc1yHaXPLJjxcUtjiaDKY4GDmAtCP
36	B62qqCpCJ7Lx7WuKCDSPQWYZzRWdVGHndW4jNARZ8C9JB4M5osqYnvw
37	B62qo9mUWwGSjKLpEpgm5Yuw5qTXRi9YNvo5prdB7PXMhGN6jeVmuKS
38	B62qpRvBE7SFJWG38WhDrSHsm3LXMAhdiXXeLkDqtGxhfexCNh4RPqZ
39	B62qoScK9pW5SBdJeMZagwkfqWfvKAKc6pgPFrP72CNktbGKzVUdRs3
40	B62qkT8tFTiFfZqPmehQMCT1SRRGon6MyUBVXYS3q9hPPJhusxHLi9L
41	B62qiw7Qam1FnvUHV4JYwffCf2mjcuz2s5F3LK9TBa5e4Vhh7gq2um1
42	B62qrncSq9df3SnHmSjFsk13W7PmQE5ujZb7TGnXggawp3SLb1zbuRR
43	B62qip9dMNE7fjTVpB7n2MCJhDw89YYKd9hMsXmKZ5cYuVzLrsS46ZG
44	B62qmMc2ec1D4V78sHZzhdfBA979SxUFGKTqHyYcKexgv2zJn6MUghv
45	B62qqmQhJaEqxcggMG9GepiXrY1j4WgerXXb2NwkmABwrkhRK671sSn
46	B62qp7yamrqYvcAv3jJ4RuwdvWnb8zFGfXchbfqR4BCkeub998mVJ3j
47	B62qk7NGhMEpPAwdwfqnxCbAuCm1qawX4YXh956nanhkfDdzZ4vZ91g
48	B62qnUPwKuUQZcNFnr5L5S5mpH9zcKDdi2FsKnAGQ1Vrd3F4HcH724A
49	B62qqMV93QdKFLmPnqvzaBE8T2jY38HVch4JW5xZr4kNHNYr1VtSUn8
50	B62qmtQmCLX8msSHASDTzNtXq81XQoNtLz6CUMhFeueMbJoQaYbyPCi
51	B62qp2Jgs8ChRsQSh93cL2SuDN8Umqp6GtDd9Ng7gpkxgw3Z9WXduAw
52	B62qo131ZAwzBd3mhd2GjTf3SjuNqdieDifuYqnCGkwRrD3VvHLM2N1
53	B62qo9XsygkAARYLKi5jHwXjPNxZaf537CVp88npjrUpaEHypF6TGLj
54	B62qnG8dAvhGtPGuAQkwUqcwpiAT9pNjQ7iCjpYw5k2UT3UZTFgDJW1
55	B62qj3u5Ensdc611cJpcmNKq1ddiQ63Xa8L2DnFqEBgNqBCAqVALeAK
56	B62qjw1BdYXp74JQGoeyZ7bWtnsPPd4iCxBzfUsiVjmQPLk8984dV9D
57	B62qpP2xUscwDA5TaQee71MGvU7dYXiTHffdL4ndRGktHBcj6fwqDcE
58	B62qn9R5QocBSRu88fnt8Vim7QT8ZyKpwuvnzBHDJMSVqfUjUgh2taG
59	B62qo1he9m5vqVfbU26ZRqSdyWvkVURLxJZLLwPdu1oRAp3E7rCvyxk
60	B62qjzHRw1dhwS1NCWDH64yzovyxsbrvqBW846BRCaWmyJyoufddBSA
61	B62qkoANXg95uVHwpLAiQsT1PaGxuXBcrBzdjMgN3mP5WJxiE1uYcG9
62	B62qnzk698yW9rmyeC8mLCKhdmQZa2TRCG5hN3Z5NovZZqE1oou7Upc
63	B62qrQDYA9DvUNdgU87xp64MsQm3MxBeDRNuhuwwQ3hfS5sJhchipzu
64	B62qnSKLuJiF1gNnCEDHJeWFKPbYLKjXqz18pnLGE2pUq7PBYnU4h95
65	B62qk8onaP8h1VYVbJkQQ8kKtHszsA12Haw3ts5jm4AkpvNDkhUtKBH
66	B62qpt3yCBwVKue1kesW27zQz3MuZxvanCDWn8NPLqsCiGJnqA8Kbe6
67	B62qozAxjr29EaJKYcSzumziUHuFq9H3ASrvbeB2qndYt2WDY2LwqqX
68	B62qnbQoJyaGKvgRDthSPwWZPrYiYCpqeYoHhJ9415r1ws6DecWa8h9
69	B62qmpV1DwQvBMUmBxyDV6jJwSpS1zFWHHEZYuXYhPja4RWCbYG3Hv1
70	B62qiYSHjqf77rS6eBiBSiDwgqpsZEUf8KZZNmpxzULpxqm58u49m7M
71	B62qrULyp6Kp5PAmtJMHcRngmHyU2t9DF2oBpU4Q1GMvfrgsUBVUSm8
72	B62qpitzPa3MB2eqJucswcwQrN3ayxTTKNMWLW7SwsvjjR4kTpC57Cr
73	B62qpSfoFPJPXvyUwXWGJqTVya4kqThCH5LyEsdKrmqRm1mvDrgsz1V
74	B62qk9uVP24E5fE5x4FxnFxz17TBAZ4rrkmRDErheEZnVyFmCKvdBMH
75	B62qjeNbQNefZdv388wHg9ancPdFBw6Dj2Wxo6Jyw2EhR7J9kti48qx
76	B62qqwCS1S72xt9VPD6C6FjJkdwDghRCWJnYjebCagX8M2xzthqKDQC
77	B62qrGWHg32ZdFydA4UF7prU4zm3UH3dRxJZ5xAHW1QtNhgzuP2G62z
78	B62qkqZ1b8BkCK9PqWnQLjYueExVUVJon1Nn15SnZScG5AR3LqkEqzY
79	B62qkQ9tPTmzm9oD2i8HbDRERFBHvG7Mi3dz6XLa3BEJcwA4ZcQaDa8
80	B62qnt4FQxWNcP49W5HaQNEe5Q1KqTBQJnnyqn7KyvSfNb6Dskbhy9i
81	B62qoxTxNh4o9ftUHSRatjTQagToJy7pW1zh7zZdyFYr9ECNDvugmyx
82	B62qrPuf95oqANBTTmvcvM1BKkBNrsmaXnaNpHGJYersezYTHWq5BTh
83	B62qkBdApDjoUj9Lckf4Bg7fWJSzSnyJHyCNkvq7XsPVzWk97BeGkae
84	B62qs23tCNy7qbrYHBwMfVNyiA82aA7xtWKh3QkFr1fMog3ptyXhptq
85	B62qpMFwmJ6fMm4cUb9wLLwoKRPFpYUJQmYqDe7RRaXgvAHjJpnEz3f
86	B62qkF4qisEVJ3WBdxcWoianq4YLaYXw89yJRzc7cPRu2ujXqp4v8Ji
87	B62qmFcUZJgxBQpTxnQHjyHWdprnsmRDiTZe6NiMNF9drGTM8hh1tZf
88	B62qo4Pc6HKhbc55RZuPrDfzbVZfxDqxkG3hV7sRDSivAthXAjtWaGg
89	B62qoKioA9hueF4xhZszsACn6GT7o69wZZJUoErVyvgP7WPrj92e9Tv
90	B62qkoTczRzwCUr6AmSiNcr3UWwkgbWeihVZphwP8CEuiDzrNHvunTX
91	B62qpGkYNpBS3MBgortSQuwV1aXcK6bRRQyYz3wGW5tCpCLdvxk8J6q
92	B62qnYfsf8P7B7UYcjN9bwL7HPpNrAJh7fG5zqWvZnSsaQJP2Z1qD84
93	B62qpAwcFY3oTy2oFUEc3gB4x879CvPqHUqHqjT3PiGxggroaUYHxkm
94	B62qib1VQVfLQeCW6oAKEX2GRuvXjYaX2Lw9qqjkBPAvdshHPyJXVMv
95	B62qiXiZY6V6qc1J7FXyWzWPPGk3c78T3CgmQXn9a87MDXoerx9WpFa
96	B62qm7inagjjw3Yg9gc8cuz4jbJVGVrLwrUtDY5VZMVHZtyenvCsjtF
97	B62qm5TQe1nz3gfHqb6S4FE7FWV92AaKzUuAyNSDNeNJYgND35JaK8w
98	B62qrmfQsKRd5pwg1EZNYXSmcbsgCekCkJAxxJcZhWyX7ChfExZtFAj
99	B62qitvFhawB29DGkGv9NEfGZ8d9hECEKnKMHAvtULVATdw5epPS2s6
100	B62qo81kkuqxFZw9cZAcoYb4ZeCjY9HodT3yDkh8Zxhg9omfRexyNAz
101	B62qmeDPPUDtPVVHqesiKD7ecz6YZvGDHzVw2swBa84EGs5NBKpGK4H
102	B62qqwLQXBrhJmfAtF7GUf7FNVS2xoTPrkyw7d4Pj9W431bpysAdr3V
103	B62qkgcEQJ9qhjwQgt2XeN3RJpPTfjCrqFUUAW2NsVpzmyQwFbekNMM
104	B62qnAotEqbcE8sjbdyJkkvKnTzW3BCPaL5HrMEdHa4pVnfPBXWGXXW
105	B62qquzjE4bbK3mhk6jtFMnkm9BdzasTHuvMxx6JmhXeYKZkPbyZUry
106	B62qrj3VHfVadkyJCvmu7SvczS7QZy1Yk1uQjcjwkS4QqDt9oqi4eWf
107	B62qn6fTLLatKHi4aCX7p6Lg5rzZSq6VK2vrFVgX14gjaQqay8zHfsJ
108	B62qjrBApNy5mx6biRzL5AfRrDEarq3kv9Zcf5LcUR6iKAX9ve5vvud
109	B62qkdysBPreF3ef7bFEwCghYjbywFgumUHXYKDrBkUB89KgisAFGSV
110	B62qmRjcL489UysBEnabin5be824q7ok4VjyssKNutPq3YceMRSW4gi
111	B62qo3TjT6pu6i7UT8w39UVQc2Ljg8K69eng55vu5itof3Ma3qwcgZF
112	B62qpXFq7VJG6Spy7BSYjqSC1GBwKLCzfU8bcrUrALEFEXphpvjn3bG
113	B62qmp2xXJyj9LegRQUtFMCCGV3DQu337n6s6BK8a2kaYrMf1MmZHkT
114	B62qpKiUdvStYeqNRxvn1aK67gGwYZmoPLNd4T81ZU7UfWfXb4UPwdL
115	B62qrFhWS3Mnb32mvkorCmXLka5wNGFVkHwGGDmxa9dyYhfVXmQ5KJK
116	B62qpjkSafKdAeCBh6PV6ZizJjtfs3v1DuXu1WowkYq2Bcr5X7bmk7G
117	B62qnjhGUFX636v8HyJsYKUkAS5ms58q9C9GtwNvPbMzMVy7FmRNhLG
118	B62qoCS2htWnx3g8gFq2ypSLHMW1jkZF6XMTH8yKE8gYTH7jfrcdjCo
119	B62qk2wpLtL3PUEQZBYPeabiXcZi6yzbVimciFWZSCHpxufKFDTmhi6
120	B62qjWRcn5eRmdppcsDNudiogbnNPzW4jWC6XH2LczMRDXzjK9AgfA2
121	B62qjJrgSK4wa3HnZZqmfJzxtMfACK9r2zEHqo5Rm6UUvyFrk4UjdPW
122	B62qoq6uA96gWVYBDtMQLZC5hB4hgAVojbuhw9Z2CE1Acj6iESSS1cE
123	B62qkSpe1P6FgwWU3BfvU2FXnuYt2vR4DzsEZf5TbJynBgyZy7W9yyE
124	B62qr225GCSVzAGKBYxB7rKE6ibtQAcfcXMfYH84hvkqHWAnFzWR4RT
125	B62qkQT9sAztAWnYdxQMaQSxrA93DRa5f8LxWCEzYA3Y3tewDQKUMyQ
126	B62qieyc3j9pYR6aA8DC1rhoUNRiPacx1ij6qW534VwTtuk8rF2UBrk
127	B62qoFyzjU4pC3mFgUidmTFt9YBnHjke5SU6jcNe7vVcvvoj4CCXYJf
128	B62qihY3kUVYcMk965RMKfEAYRwgh9ATLBWDiTzivneCmeEahgWTE58
129	B62qm8kJSo4SZt7zmNP29aYAUqETjPq6ge2hj5TxZWxWK2JDscQtx1Y
130	B62qkY3LksqsR2ETeNmAHAmYxi7mZXsoSgGMEMujrPtXQjRwxe5Bmdn
131	B62qrJ9hFcVQ4sjveJpQUsXZenisBnXKVzDdPntw48PYXxP17DNdKg4
132	B62qpKCYLZz2Eyb9vFfaVPgWjTWf1p3VpBLnQSSme2RC3ob4m1p8fCv
133	B62qkFYQghamWpPuNxzr1zw6ARk1mKFwkdQWJqHvmxdM95d45AjwWXE
134	B62qnzhgbY3HD19eKMeQTFPZijFTvJN82pHeGYQ2xM9HxZRPv6xhtqe
135	B62qroho2SKx4wignPPRf2qPbGzvfRgQf4zCMioxnmwKyLZCg3reYPc
136	B62qm4jN36Cwbtyd8j3BLevPK7Yhpv8KtWTia5fuwMAyvcHLCosU4PN
137	B62qk9Dk1rwSVtSLCYdWNfPTXRPDWPPu3rR5sqvrawP82m9P1LhBZ94
138	B62qnR8RErysAmsLHk6E7teSg56Dr3RyF6qWycyVjQhoQCVC9GfQqhD
139	B62qo7XmFPKML7WfgUe9FvCMUrMihfapBPeCJh9Yxfka7zUwy1nNDCY
140	B62qqZw4bXrb8PCxvEvRJ9DPASPPaHyoAWXw1avG7mEjnkFy7jGLz1i
141	B62qkFKcfRwVgdQ1UDhhCoExwsMPNWFJStxnDtJ1hNVmLzzGsyCRLuo
142	B62qofSbCaTfL61ZybYEpAeGe14TK8wNN8VFDV8uUEVBGpqVDAxYePK
143	B62qn8Vo7WTK4mwQJ8sjiQvbWDavetBS4f3Gdi42KzQZmL3sri25rFp
144	B62qo6pZqSTym2umKYeZ53F1woYCuX3qHrUtTezBoztURNRDAiNbq5Q
145	B62qo8AvB3EoCWAogvUg6wezt5GkNRTZmYXCw5Gutj8tAg6cdffX3kr
146	B62qqF7gk2yFsigWL7JyW1R8sdUcQjAPkp32i9B6f9GRYMzFoLPdBqJ
147	B62qjdhhu4bsmbMFxykEgbhf4atVvgQWB4dizqsMEBbmQPe9GeXZ42N
148	B62qmCsUFPNLpExtzt6NUeosa8L5qb7cEKi9btkMdAQS2GnQzTMjUGM
149	B62qneAWh9zy9ufLxKJfgrccdGfbgeoswyjPJp2WLhBpWKM7wMJtLZM
150	B62qoqu7NDPVJAdZPJWjia4gW3MHk9Cy3JtpACiVbvBLPYw7pWyn2vL
151	B62qmwfTv4co8uACHkz9hJuUND9ubZfpP2FsAwvru9hSg5Hb8rtLbFS
152	B62qkhxmcB6vwRxLxKZV2R4ifFLfTSCdtxJ8nt94pKVbwWd9MshJadp
153	B62qjYRWXeQ52Y9ADFTp55p829ZE7DE4zn9Nd8puJc2QVyuiooBDTJ3
154	B62qo3b6pfzKVWNFgetepK6rXRekLgAYdfEAMHT6WwaSn2Ux8frnbmP
155	B62qncxbMSrL1mKqCSc6huUwDffg5qNDDD8FHtUob9d3CE9ZC2EFPhw
156	B62qpzLLC49Cb6rcpFyCroFiAtGtBCXny9xRbuMKi64vsU5QLoWDoaL
157	B62qj7bnmz2VYRtJMna4bKfUYX8DyQeqxKEmHaKSzE9L6v7fjfrMbjF
158	B62qokmEKEJs6VUV7QwFaHHfEr6rRnFXQe9jbodnaDuWzfUK6YoXt2w
159	B62qpPJfgTfiSghnXisMvgTCNmyt7dA5MxXnpHfMaDGYGs8C3UdGWm7
160	B62qkzi5Dxf6oUaiJYzb5Kq78UG8fEKnnGuytPN78gJRdSK7qvkDK6A
161	B62qs2sRxQrpkcJSkzNF1WKiRTbvhTeh2X8LJxB9ydXbBNXimCgDQ8k
162	B62qoayMYNMJvSh27WJog3K74996uSEFDCmHs7AwkBX6sXiEdzXn9SQ
163	B62qibjCrFmXT3RrSbHgjtLHQyb63Q89gBLUZgRj7KMCeesF9zEymPP
164	B62qrw63RAyz2QfqhHk8pttD2ussturr1rvneUWjAGuhsrGgzxr2ZRo
165	B62qmNVzYukv4VxXoukakohrGNK7yq1Tgjv5SuX1TTWmpvVwD5Xnu2L
166	B62qoucdKZheVHX8udLGmo3vieCnyje5dvAayiLm8trYEp3op9jxCMa
167	B62qo51F51yp7PcqmHd6G1hpNBAj3kwRSQvKmy5ybd675xVJJVtMBh8
168	B62qjHbDMJGPUz3M6JK2uC3tm6VPLaEtv4sMCcrMBz6hnD5hrET4RJM
169	B62qnyxTMk4JbYsaMx8EN2KmoZUsb9Zd3nvjwyrZr2GdAHC9nKF16PY
170	B62qrPo6f9vRwqDmgfNYzaFd9J3wTwQ1SC72yMAxwaGpjt2vJrxo4ri
171	B62qoZXUxxowQuERSJWb6EkoyciRthxycW5csa4cQkZUfm151sn8BSa
172	B62qr7QqCysRpMbJGKpAw1JsrZyQfSyT4iYoP4MsTYungBDJgwx8vXg
173	B62qo3JqbYXcuW75ZHMSMnJX7qbU8QF3N9k9DhQGbw8RKNP6tNQsePE
174	B62qjCC8yevoQ4ucM7fw4pDUSvg3PDGAhvWxhdM3qrKsnXW5prfjo1o
175	B62qnAcTRHehWDEuKmERBqSakPM1dg8L3JPSZd5yKfg4UNaHdRhiwdd
176	B62qruGMQFShgABruLG24bvCPhF2yHw83eboSqhMFYA3HAZH9aR3am3
177	B62qiuFiD6eX5mf4w52b1GpFMpk1LHtL3GWdQ4hxGLcxHh36RRmjpei
178	B62qokvW3jFhj1yz915TzoHubhFuR6o8QFQReVaTFcj8zpPF52EU9Ux
179	B62qr6AEDV6T66apiAX1GxUkCjYRnjWphyiDro9t9waw93xr2MW6Wif
180	B62qjYBQ6kJ9PJTTPnytp4rnaonUQaE8YuKeimJXHQUfirJ8UX8Qz4L
181	B62qqB7CLD6r9M532oCDKxxfcevtffzkZarWxdzC3Dqf6LitoYhzBj9
182	B62qr87pihBCoZNsJPuzdpuixve37kkgnFJGq1sqzMcGsB95Ga5XUA6
183	B62qoRyE8Yqm4GNkjnYrbtGWJLYLNoqwWzSRRBw8MbmRUS1GDiPitV7
184	B62qm4NwW8rFhUh4XquVC23fn3t8MqumhfjGbovLwfeLdxXQ3KhA9Ai
185	B62qmAgWQ9WXHTPh4timV5KFuHWe1GLb4WRDRh31NULbyz9ub1oYf8u
186	B62qroqFW16P7JhyaZCFsUNaCYg5Ptutp9ECPrFFf1VXhb9SdHE8MHJ
187	B62qriG5CJaBLFwd5TESfXB4rgSDfPSFyYNmpjWw3hqw1LDxPvpfaV6
188	B62qjYVKAZ7qtXDoFyCXWVpf8xcEDpujXS5Jvg4sjQBEP8XoRNufD3S
189	B62qjBzcUxPayV8dJiWhtCYdBZYnrQeWjz28KiMYGYodYjgwgi961ir
190	B62qkG2Jg1Rs78D2t1DtQPjuyydvVSkfQMDxBb1hPi29HyzHt2ztc8B
191	B62qpNWv5cQySYSgCJubZUi6f4N8AHMkDdHSXaRLVwy7aG2orM3RWLp
192	B62qism2zDgKmJaAy5oHRpdUyk4EUi9K6iFfxc5K5xtARHRuUgHugUQ
193	B62qqaG9PpXK5CNPsPSZUdAUhkTzSoZKCtceGQ1efjMdHtRmuq7796d
194	B62qpk8ww1Vut3M3r2PYGrcwhw6gshqvK5PwmC4goSY4RQ1SbWDcb16
195	B62qo3X73MPaBWtksxR1vqUtcTbjrjURmiP7XCD975gQupi19NDdQgS
196	B62qqxvqA4qfjXgPxLbmMh84pp3kB4CSuj9mSttTA8hGeLeREfzLGiC
197	B62qnqFpzBPpxNkuazmDWbvcQX6KvuCZvenM1ev9hhjKj9cFj4dXSMb
198	B62qpdxyyVPG1v5LvPdTayyoUtp4BMYbYYwRSCkyW9n45383yrP2hJz
199	B62qohCkbCHvE3DxG8YejQtLtE1o86Z53mHEe1nmzMdjNPzLcaVhPx2
200	B62qiUvkf8HWS1tv8dNkHKJdrj36f5uxMcH1gdF61T2GDrFbfbeeyxY
201	B62qngQ2joTkrS8RAFystfTa7HSc9agnhLsBvvkevhLmn5JXxtmKMfv
202	B62qrCfZaRAK5LjjigtSNYRoZgN4W4bwWbAffkvdhQYUDkB7UzBdk6w
203	B62qq8p3wd6YjuLqTrrUC8ag4wYzxoMUBKu4bdkUmZegwC3oqoXpGy3
204	B62qqmgpUFj5gYxoS6yZj6pr22tQHpbKaFSKXkT8yzdxatLunCvWtSA
205	B62qrjk6agoyBBy13yFobKQRE6FurWwXwk5P1VrxavxpZhkiHXqsyuR
206	B62qr3YEZne4Hyu9jCsxA6nYTziPNpxoyyxZHCGZ7cJrvckX9hoxjC6
207	B62qm7tX4g8RCRVRuCe4MZJFdtqAx5vKgLGR75djzQib7StKiTfbWVy
208	B62qjaAVCFYmsKt2CR2yUs9EqwxvT1b3KWeRWwrDQuHhems1oC2DNrg
209	B62qj49MogZdnBobJZ6ju8njQUhP2Rp59xjPxw3LV9cCj6XGAxkENhE
210	B62qpc1zRxqn3eTYAmcEosHyP5My3etfokSBX9Ge2cxtuSztAWWhadt
211	B62qm4Kvpidd4gX4p4r71DGsQUnEmhi12H4D5k3F2rdxvWmWEiJyfU2
212	B62qjMzwAAoUbqpnuntqxeb1vf2qgDtzQwj4a3zkNeA7PVoKHEGwLXg
213	B62qmyLw1LNGHkvqkH5nsQZU6uJu3begXAe7WzavUH4HPSsjJNKP9po
214	B62qqmQY1gPzEv6qr6AbLBp1yLW5tVcMB4dwVPMF218gv2xPk48j3sb
215	B62qmmhQ2eQDnyFTdsgzztgLndmsSyQBBWtjALnRdGbZ87RkNeEuri1
216	B62qqCAQRnjJCnS5uwC1A3j4XmHqZrisvNdG534R8eMvzsFRx9h8hip
217	B62qoUdnygTtJyyivQ3mTrgffMeDpUG1dsgqswbXvrypvCa9z8MDSFz
218	B62qnt6Lu7cqkAiHg9qF6qcj9uFcqDCz3J6pTcLTbwrNde97KbR6rf6
219	B62qoTmf1JEAZTWPqWvMq66xAonpPVAhMtSR8UbbX3t8FhRKrdyTFbr
220	B62qiqiPtbo7ppvjDJ536Nf968zQM3BrYxQXoWeistF8J12BovP5e1F
221	B62qpP5T35yJUz1U25Eqi5VtLVkjbDyMMXaTa87FE9bhoEbtz7bzAXz
222	B62qqdtmbGF5LwL47qj7hMWjt6XYcwJnft3YgD8ydLgf1M59PFCHv44
223	B62qm8TrWwzu2px1bZG38QkpXC5JgU7RnCyqbVyiy2Fmh63N5d9cbA6
224	B62qnZXs2RGudz1q9eAgxxtZQnNNHi6P5RAzoznCKNdqvSyyWghmYX6
225	B62qo7dRx2VHmDKXZ8XffNNeUK1j4znWxFUvg48hrxrNChqwUrDBgiA
226	B62qke1AAPWuurJQ5p1zQ34uRbtogxsfHEdzfqufAHrqKKHba7ZYC2G
227	B62qnd3TWhbQUxK5YXUYuAwDRKgjDiEdKNrEUv43CuZ4jRBCKRf27b4
228	B62qjy64ysP1cHmvHqyrZ899gdUy48PvBCnAYRykM5EMpjHccdVZ4Fy
229	B62qjDFzBEMSsJX6i6ta6baPjCAoJmHY4a4xXUmgCJQv4sAXhQAAbpt
230	B62qrV4S63yeVPjcEUmCkAx1bKA5aSfzCLTgh3b8D5uPr7UrJoVxA6S
231	B62qnqEX8jNJxJNyCvnbhUPu87xo3ki4FXdRyUUjQuLCnyvZE2qxyTy
232	B62qpivmqu3HDNenKMHPNhie31sFD68nZkMteLW58R21gcorUfenmBB
233	B62qjoiPU3JM2UtM1BCWjJZ5mdDBr8SadyEMRtaREsr7iCGPabKbFXf
234	B62qoRBTLL6SgP2JkuA8VKnNVybUygRm3VaD9uUsmswb2HULLdGFue6
235	B62qpLj8UrCZtRWWGstWPsE6vYZc9gA8FBavUT7RToRxpxHYuT3xiKf
236	B62qkZeQptw1qMSwe53pQN5HXj258zQN5bATF6bUz8gFLZ8Tj3vHdfa
237	B62qjzfgc1Z5tcbbuprWNtPmcA1aVEEf75EnDtss3VM3JrTyvWN5w8R
238	B62qkjyPMQDyVcBt4is9wamDeQBgvBTHbx6bYSFyGk6NndJJ3c1Te4Q
239	B62qjrZB4CzmYULfHB4NAXqjQoEnAESXmeyBAjxEfjCksXE1F7uLGtH
240	B62qkixmJk8DEY8wa7EQbVbZ4b36dCwGoW94rwPkzZnBkB8GjVaRMP5
241	B62qjkjpZtKLrVFyUE4i4hAhYEqaTQYYuJDoQrhisdFbpm61TEm1tE5
242	B62qqXEPxsvnqfYrYSvTYXFeKssaP6m9KD2Ji6ADqpCDtcVMpMjwD7d
243	B62qrqndewerFzXSvc2JzDbFYNvoFTrbLsya4hTsy5bLTXmb9owUzcd
244	B62qrGPBCRyP4xiGWn8FNVveFbYuHWxKL677VZWteikeJJjWzHGzczB
\.


--
-- Data for Name: snarked_ledger_hashes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.snarked_ledger_hashes (id, value) FROM stdin;
1	jwhYGrqGPozYQH9ncWRJTNZwt9CY1yodauaD1hDSh7xdNb2fGo3
2	jwM37UFsXLhedxf8XtCBZCNQCL49GdLQzqVuysP9Jkz8xuvYGqy
\.


--
-- Data for Name: timing_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.timing_info (id, account_identifier_id, initial_minimum_balance, cliff_time, cliff_amount, vesting_period, vesting_increment) FROM stdin;
1	1	0	0	0	0	0
2	2	0	0	0	0	0
3	3	0	0	0	0	0
4	4	0	0	0	0	0
5	5	0	0	0	0	0
6	6	0	0	0	0	0
7	7	0	0	0	0	0
8	8	0	0	0	0	0
9	9	0	0	0	0	0
10	10	0	0	0	0	0
11	11	0	0	0	0	0
12	12	0	0	0	0	0
13	13	0	0	0	0	0
14	14	0	0	0	0	0
15	15	0	0	0	0	0
16	16	0	0	0	0	0
17	17	0	0	0	0	0
18	18	0	0	0	0	0
19	19	0	0	0	0	0
20	20	0	0	0	0	0
21	21	0	0	0	0	0
22	22	0	0	0	0	0
23	23	0	0	0	0	0
24	24	0	0	0	0	0
25	25	0	0	0	0	0
26	26	0	0	0	0	0
27	27	0	0	0	0	0
28	28	0	0	0	0	0
29	29	0	0	0	0	0
30	30	0	0	0	0	0
31	31	0	0	0	0	0
32	32	0	0	0	0	0
33	33	0	0	0	0	0
34	34	0	0	0	0	0
35	35	0	0	0	0	0
36	36	0	0	0	0	0
37	37	0	0	0	0	0
38	38	0	0	0	0	0
39	39	0	0	0	0	0
40	40	0	0	0	0	0
41	41	0	0	0	0	0
42	42	0	0	0	0	0
43	43	0	0	0	0	0
44	44	0	0	0	0	0
45	45	0	0	0	0	0
46	46	0	0	0	0	0
47	47	0	0	0	0	0
48	48	0	0	0	0	0
49	49	0	0	0	0	0
50	50	0	0	0	0	0
51	51	0	0	0	0	0
52	52	0	0	0	0	0
53	53	0	0	0	0	0
54	54	0	0	0	0	0
55	55	0	0	0	0	0
56	56	0	0	0	0	0
57	57	0	0	0	0	0
58	58	0	0	0	0	0
59	59	0	0	0	0	0
60	60	0	0	0	0	0
61	61	0	0	0	0	0
62	62	0	0	0	0	0
63	63	0	0	0	0	0
64	64	0	0	0	0	0
65	65	0	0	0	0	0
66	66	0	0	0	0	0
67	67	0	0	0	0	0
68	68	0	0	0	0	0
69	69	0	0	0	0	0
70	70	0	0	0	0	0
71	71	0	0	0	0	0
72	72	0	0	0	0	0
73	73	0	0	0	0	0
74	74	0	0	0	0	0
75	75	0	0	0	0	0
76	76	0	0	0	0	0
77	77	0	0	0	0	0
78	78	0	0	0	0	0
79	79	0	0	0	0	0
80	80	0	0	0	0	0
81	81	0	0	0	0	0
82	82	0	0	0	0	0
83	83	0	0	0	0	0
84	84	0	0	0	0	0
85	85	0	0	0	0	0
86	86	0	0	0	0	0
87	87	0	0	0	0	0
88	88	0	0	0	0	0
89	89	0	0	0	0	0
90	90	0	0	0	0	0
91	91	0	0	0	0	0
92	92	0	0	0	0	0
93	93	0	0	0	0	0
94	94	0	0	0	0	0
95	95	0	0	0	0	0
96	96	0	0	0	0	0
97	97	0	0	0	0	0
98	98	0	0	0	0	0
99	99	0	0	0	0	0
100	100	0	0	0	0	0
101	101	0	0	0	0	0
102	102	0	0	0	0	0
103	103	0	0	0	0	0
104	104	0	0	0	0	0
105	105	0	0	0	0	0
106	106	0	0	0	0	0
107	107	0	0	0	0	0
108	108	0	0	0	0	0
109	109	0	0	0	0	0
110	110	0	0	0	0	0
111	111	0	0	0	0	0
112	112	0	0	0	0	0
113	113	0	0	0	0	0
114	114	0	0	0	0	0
115	115	0	0	0	0	0
116	116	0	0	0	0	0
117	117	0	0	0	0	0
118	118	0	0	0	0	0
119	119	0	0	0	0	0
120	120	0	0	0	0	0
121	121	0	0	0	0	0
122	122	0	0	0	0	0
123	123	0	0	0	0	0
124	124	0	0	0	0	0
125	125	0	0	0	0	0
126	126	0	0	0	0	0
127	127	0	0	0	0	0
128	128	0	0	0	0	0
129	129	0	0	0	0	0
130	130	0	0	0	0	0
131	131	0	0	0	0	0
132	132	0	0	0	0	0
133	133	0	0	0	0	0
134	134	0	0	0	0	0
135	135	0	0	0	0	0
136	136	0	0	0	0	0
137	137	0	0	0	0	0
138	138	0	0	0	0	0
139	139	0	0	0	0	0
140	140	0	0	0	0	0
141	141	0	0	0	0	0
142	142	0	0	0	0	0
143	143	0	0	0	0	0
144	144	0	0	0	0	0
145	145	0	0	0	0	0
146	146	0	0	0	0	0
147	147	0	0	0	0	0
148	148	0	0	0	0	0
149	149	0	0	0	0	0
150	150	0	0	0	0	0
151	151	0	0	0	0	0
152	152	0	0	0	0	0
153	153	0	0	0	0	0
154	154	0	0	0	0	0
155	155	0	0	0	0	0
156	156	0	0	0	0	0
157	157	0	0	0	0	0
158	158	0	0	0	0	0
159	159	0	0	0	0	0
160	160	0	0	0	0	0
161	161	0	0	0	0	0
162	162	0	0	0	0	0
163	163	0	0	0	0	0
164	164	0	0	0	0	0
165	165	0	0	0	0	0
166	166	0	0	0	0	0
167	167	0	0	0	0	0
168	168	0	0	0	0	0
169	169	0	0	0	0	0
170	170	0	0	0	0	0
171	171	0	0	0	0	0
172	172	0	0	0	0	0
173	173	0	0	0	0	0
174	174	0	0	0	0	0
175	175	0	0	0	0	0
176	176	0	0	0	0	0
177	177	0	0	0	0	0
178	178	0	0	0	0	0
179	179	0	0	0	0	0
180	180	0	0	0	0	0
181	181	0	0	0	0	0
182	182	0	0	0	0	0
183	183	0	0	0	0	0
184	184	0	0	0	0	0
185	185	0	0	0	0	0
186	186	0	0	0	0	0
187	187	0	0	0	0	0
188	188	0	0	0	0	0
189	189	0	0	0	0	0
190	190	0	0	0	0	0
191	191	0	0	0	0	0
192	192	0	0	0	0	0
193	193	0	0	0	0	0
194	194	0	0	0	0	0
195	195	0	0	0	0	0
196	196	0	0	0	0	0
197	197	0	0	0	0	0
198	198	0	0	0	0	0
199	199	0	0	0	0	0
200	200	0	0	0	0	0
201	201	0	0	0	0	0
202	202	0	0	0	0	0
203	203	0	0	0	0	0
204	204	0	0	0	0	0
205	205	0	0	0	0	0
206	206	0	0	0	0	0
207	207	0	0	0	0	0
208	208	0	0	0	0	0
209	209	0	0	0	0	0
210	210	0	0	0	0	0
211	211	0	0	0	0	0
212	212	0	0	0	0	0
213	213	0	0	0	0	0
214	214	0	0	0	0	0
215	215	0	0	0	0	0
216	216	0	0	0	0	0
217	217	0	0	0	0	0
218	218	0	0	0	0	0
219	219	0	0	0	0	0
220	220	0	0	0	0	0
221	221	0	0	0	0	0
222	222	0	0	0	0	0
223	223	0	0	0	0	0
224	224	0	0	0	0	0
225	225	0	0	0	0	0
226	226	0	0	0	0	0
227	227	0	0	0	0	0
228	228	0	0	0	0	0
229	229	0	0	0	0	0
230	230	0	0	0	0	0
231	231	0	0	0	0	0
232	232	0	0	0	0	0
233	233	0	0	0	0	0
234	234	0	0	0	0	0
235	235	0	0	0	0	0
236	236	0	0	0	0	0
237	237	0	0	0	0	0
238	238	0	0	0	0	0
239	239	0	0	0	0	0
240	240	0	0	0	0	0
241	241	0	0	0	0	0
242	242	0	0	0	0	0
243	243	0	0	0	0	0
\.


--
-- Data for Name: token_symbols; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.token_symbols (id, value) FROM stdin;
1	
\.


--
-- Data for Name: tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tokens (id, value, owner_public_key_id, owner_token_id) FROM stdin;
1	wSHV2S4qX9jFsLjQo8r1BsMLH2ZRKsZx6EJd1sbozGPieEC4Jf	\N	\N
\.


--
-- Data for Name: user_commands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.user_commands (id, command_type, fee_payer_id, source_id, receiver_id, nonce, amount, fee, valid_until, memo, hash) FROM stdin;
1	payment	115	115	115	0	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvNVTPWZxfsenncyFeATWzpo9zDBUjvjtaasoyrgBYYiKvc5zph
2	payment	115	115	115	1	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju42dNr4Rt62CdW8bA8h36N91bPM1JAGA6UkpbxHPRWc4ssvEYY
3	payment	115	115	115	2	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuoXn7B3MdiBNzoq1zMnCR9GqGCsAZRaGdBGxJbTZXmQWVHp9pq
4	payment	115	115	115	3	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunuVyVfk27wzWoLc4ftKv61spQ7WESiMEbtWf5YbrwTvVtNsk5
5	payment	115	115	115	4	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvExEp4gaga8Fkvvz3bY5DbUZ7nxSm4xeggDdQy4JRQFsty9gik
6	payment	115	115	115	5	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9Rna3cZ6NCPDQxujmJfmsyvh4LA5xsfD8xKMcKCBdQmYzsagj
7	payment	115	115	115	6	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGGT24bZizwRkMFZompFaiThYpreUyzZPHXt9BTUWgyzckYnfZ
8	payment	115	115	115	7	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJcPyjbX39nrCn2Tt2qWA3w8oTb8Kr1X8JQaiFxWQcJAn2Enxm
9	payment	115	115	115	8	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtk37L9HGK7q5i4Be4tRgXnTgUw6uyGhAZkUXFyfiwGBRywxEoo
10	payment	115	115	115	9	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtewmtbCk1TCHKupanj6dTGEXWmvZ9htGMm1QMkHrR5VEMAgF8e
11	payment	115	115	115	10	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttehyYadvVuKjxHZM8uXeKTaMACXFRaaT552PoEFWi7N2jVXua
12	payment	115	115	115	11	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jukq62vPYPW9rBoH3tc8d75AcnKYWyCKQDJZoQP8aLrLwZY4bgh
13	payment	115	115	115	12	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvG9SZYZ5AcJ2AnuwMGB2QwGuKzJcWdqnVFuUJM9pHPCc9RVLsJ
14	payment	115	115	115	13	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuByUchCxQb13TCnCyetJy7Fevnv6EJ8xhQLYqSeDasFPxkQKwD
15	payment	115	115	115	14	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuruheKzF4qRQagjy8gyCnThNQpRLHVrqKv691nna9RJg4TXwns
16	payment	115	115	115	15	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcZugtz7UaJrTgcvEvdY1qdYbPRWbAEaFwA3wKhGgUKu8MfX7E
17	payment	115	115	115	16	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuC23BNA7Q7EGhE3LBUgtMqkdiLtRHgVKuQLcMfDzyXh8sAs9gF
18	payment	115	115	115	17	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAGoithUpxYKaPtwhYJwFyQb1rfQ6jpATpSQ3UtbtX9cru8xsK
19	payment	115	115	115	18	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2CQgFBN8CzosFn75VEAPwCi3VuNYWcuDBqawyUkGSJ3Bz8u7B
20	payment	115	115	115	19	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtyza7fjjiAzQ1ZJZ1o7kghD4xf3uZuUM1MhgX6fQjBD1YpkMao
21	payment	115	115	115	20	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juv7itf2exUSVjeMPpcQqBsX28jrVjeo4U223U2Qi5mGwEqVEDf
22	payment	115	115	115	21	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusDa3Lo3nPKRD8rLuqhibTbBvYMjUnWgJv6acPcBf7vXPzqEVG
23	payment	115	115	115	22	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1BisLvFc5afcFmgua9VzwRtesQzfYcuefVdCB826P5nv87MFs
24	payment	115	115	115	23	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtyNacRWhz2bWv9VNMZh1VX4kqNeDbAJot2hZPMe8jAk2NErFz8
25	payment	115	115	115	24	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcReBQ9ZKo2kUG14i4fR1pZk3indncRryt7P5UhNZGSXomyZBt
26	payment	115	115	115	25	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutQQvHGTRVSz4chA4cpLecFtNSZ7Kvv9UKvhyxjpotXbfs2JiR
27	payment	115	115	115	26	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuN167H2DqsyA5UVNUcLz341s5DYkzMC28TRZmAHxdnhwL92KbH
28	payment	115	115	115	27	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juf2Ggm2omE75FVao6mLcDq93NqQ6KpSDCWZkDmBngx4uaGskrE
29	payment	115	115	115	28	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juxs38jienQWEtD5cKffg5GKZawDkrPej4seuzbNGy2knZW9TVL
30	payment	115	115	115	29	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jur2ZpDhoMejVWSEyoQHGttT3drKjnyGCA9TDVLJQCjETH93ZXD
31	payment	115	115	115	30	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3vTZHHBtk3teXk6PvVitREnFqeAkaLucgLM6JHS9rrNLNEcRe
32	payment	115	115	115	31	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jusyc1QL7vrafuQU45WmrTrFjQfwjwrSUQxvELxRcnv2Xtby6FU
33	payment	115	115	115	32	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJFksPte8WUYBhzHeiJzsWjfxYRiGj4Se4EkP3t7NJ6zGpcx1B
34	payment	115	115	115	33	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvL5XC4hNDkVnoWTjBSPYw3UdVWWL65683pmGGG5j4BAQXidKNo
35	payment	115	115	115	34	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtv6KVsG1N7MhufNfMQK3L1ccGFBDMfzSjQPr71miGKpByFRV83
36	payment	115	115	115	35	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJXc48quzXpbUQjNoDrwsjK8ZWr9dTDbBzfEc6YigipH6bcMmd
37	payment	115	115	115	36	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMUAC8L8MREDhJ8jEd5pJAZ2FxegwWGn4ahTBsWGBivvrRyQAc
38	payment	115	115	115	37	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKraKcLg4ejAXx91txqeX9Lz9vD7nANdswMAhUwUCb2j6TcnDW
39	payment	115	115	115	38	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jub3h1zVTZjjfQRJyyjXRWAPeK5FSzzRivpzFKknUvtvCCYRsc8
40	payment	115	115	115	39	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcQab8zqs7qGGNCYG4eQqGZZwrWaZeLLoo2xShUg1Fa4ha6UPY
41	payment	115	115	115	40	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZfP2Yv5VVHsEfejpo3PhYyCrisd8C5WDzVnUMKcrcYkJTxPD6
42	payment	115	115	115	41	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtgqyW2PmMUPJCEX3ZQmDXWNnmZjnAWdhg2MREz3GXKT5aEGxu7
43	payment	115	115	115	42	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9uD2jyWm3tjr7NZAu4AJKYFY5RG3Tm77KgeTF8tookPAtzKNH
44	payment	115	115	115	43	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuaLR3a2TL3E8hoHpsgb7Bdz3B5UUrD3GqeyRXR7ghNMubzbg6m
45	payment	115	115	115	44	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtt2XvNSxL5ujLSPd8bNWvgTnwXqmaN5hEnbDXeNQ5DbjQnmaeF
46	payment	115	115	115	45	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXaEEg5xGcLh9BY87hyrEDi6Y1RwW85mY4uAwbkbkNNkLujRM2
47	payment	115	115	115	46	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcoN5LBRMdEVmBS9nLApbKYiPqscZ1NaUSfBWUDWo8BEuDn8s8
48	payment	115	115	115	47	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYpBpXzFXWWU3ozgdsnor8Wgk4pMrdFkGmUiNoj7qBhAE4eorc
49	payment	115	115	115	48	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdqPuT3XvSMhKrfBvNXiTTfZvxByJ6rEHSmbV9ioBRHrxz5vDJ
1217	payment	115	115	115	1216	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSscBXMwbkSEAp73H2uaKjWZgQK3njKdVhXrK67aWxvbrzzVJM
1218	payment	115	115	115	1217	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuocS2yY3SqQWAaq5peMqELTLjJDCwaT1tyxxmYJ8hKNTj1zwT4
1219	payment	115	115	115	1218	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4eRnT9SWyp8fVsckGwtzPQbQqexjjARuc14HewgneDPwqT85M
1220	payment	115	115	115	1219	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnjLoqfvQkMQJySCu7wsva6Fv3K3J8HnUh2N2YL86s2mUDyKuV
1221	payment	115	115	115	1220	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9w64GS1U1ddjMdpfA92923tHDMrWH4NgjdVgW4TWgdEsjrHrT
1222	payment	115	115	115	1221	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVb8JaShXFXsJtiHAyuNndADysuZvWuYRuv8zmWp8tyNMpjfpM
1223	payment	115	115	115	1222	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhA6SCX3sUP4PHvyiacLLMpomBGTMtS3mgZi5vFxjNCfGNX4Eo
1224	payment	115	115	115	1223	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwRro6e2cih4mk6TVQ1ex16qjR9kGb5EGt3Zghq5E4Ki4PL6YD
1225	payment	115	115	115	1224	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBa7faQ8tbtasHsqBtAnsLKMbvW5YLkreGXjjYFTb8iww2BViL
1226	payment	115	115	115	1225	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxYw9mhyDa3CQfUjA9hJjEyfgMGLpmbJgcRRmmuk6cbx3W3RjD
1227	payment	115	115	115	1226	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutPMQ8shoxwjPVLCDwGwQD9W9MA7eA1NHy8CacQYbiXZeDr6hr
1240	payment	115	115	115	1239	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDSHSDfcCNTkF8XGGMgQJuSaiE1NLk238RM59qwZjyC5KYZjKc
1241	payment	115	115	115	1240	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBN55fHreSDfvFW9pdKm6E49evv5miFxCxnVgUvV8ChNUZyYgS
1242	payment	115	115	115	1241	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubEG96n6YN1uQeLdckrb3cjraPVu6vqFNSVDegQ5YJQtR6Q2r8
1243	payment	115	115	115	1242	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCQts5qBVQHg9WHut2YXGRHusPAa6tEQy4sbNUcmEY7zi8h6Kz
1244	payment	115	115	115	1243	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJF1JQwsbaRNzcjn95RQahra6pfzYHWGXcBFWSSNV6KiBvaPyj
1245	payment	115	115	115	1244	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju35K8v1qVfMpZTHvH9PfFp1qHwDD55RZkPnL7wkbUjdjeEd4yd
1246	payment	115	115	115	1245	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDmMubL8usVNyJZG8gpWFUbSUcCTZUutpCxk8B5DS3ej8USStQ
1247	payment	115	115	115	1246	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYKrqgvjSFL8Kx1VTJBkn9qj5XXMipmGhtkChVLuDthdP8npQF
1248	payment	115	115	115	1247	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juv5jMf7LWPCQYeXdeqJpBV98cKF1LjDYBLU8DLjJoarWv6KEQM
1249	payment	115	115	115	1248	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxPZvopeRLpwBs79tK554ssCst1WBfv6zQQtZCJn6XCZTbis8r
1250	payment	115	115	115	1249	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju14i6mabCX4SMBB8Jwgwe9pUHReDU3R2FoH7qJpMdsDCefpDc5
1251	payment	115	115	115	1250	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDorkCUxhPuisiszAa6r4y9PGn4AomyFUM2B43VRBeTYGtynMF
1400	payment	115	115	115	1399	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juec3E4BLxKF7FarsiSS9BJQaXG7k2a9jvFcFuzyqT5XD1hW1Ck
1401	payment	115	115	115	1400	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuufgA6Q8g84GK87ZNCE2mnE3B5XuwBFg6dLqFwhiLSXgqrkf6C
1402	payment	115	115	115	1401	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWM6TFxsxv7nvZMBP1WCerHziVMPU3wxjhCfUbhdXg212WBbTB
1403	payment	115	115	115	1402	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDEe3NGX6dcwLTRB1wpNKfh2hqSHUW8Kt3J8KT6HgFPSgg24JQ
1404	payment	115	115	115	1403	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwX2NYcr7N6o6Vf8iucvTyjKRukV1wQ9sLxoZmzv23wtu6xxD9
1405	payment	115	115	115	1404	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2Y51nbi7KfMVoLGudXFjsprwndHwvKPCC2K4ZH3mtUDtS7hDV
1406	payment	115	115	115	1405	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZoiws5wu228uakb8aFNFWsqy57ZZxZbS1RDuNP7FGD6wotEV1
1407	payment	115	115	115	1406	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwEeAb8c4GAWyzA2dDNBHyumGQnHw3JECjEbzm7WhiaBVQtts5
1408	payment	115	115	115	1407	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcAyiiXHbq62r4CvfSjahJyXpJzTgWbcGwoDTqqUzAtixk96xQ
1409	payment	115	115	115	1408	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuopSGFedsL7tJg8SBB1PX5cbnwDp7MnqC3yL7TqvwUCn7h89Zz
50	payment	115	115	115	49	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEwwEujh4kyVUD7j3L8yThC9QkxAXgqspkKpvUCNdJuFFo9Wqe
51	payment	115	115	115	50	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLY85D4S3eTnqE8oxVQeA6WXMuZ2GVJCge57Rgtu6HAn1sado5
52	payment	115	115	115	51	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8HmWo6qijovfnpYxvMzRdzegigiexW4yZMvLZ2Ga1agCTceJk
53	payment	115	115	115	52	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGKRYykq7mZMEKT88264iUknzng36iLrZ13QsSP9kYuVhWWqHV
54	payment	115	115	115	53	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtgauaiQtVePiVGSy8KHU75aWEji8ZwCLP8Hd8gc98ae6nn4aaw
55	payment	115	115	115	54	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxGN2hjuqLAP2a3Y7gU9fk5KvfFfsoNc9vophFrkBe9vwRtohR
56	payment	115	115	115	55	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuL6PXMpZfwv7VjsTjEbtBoPfKyDHnHShjS8iLDsmcUQP8HJSmR
57	payment	115	115	115	56	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvG46qZ2zmABvehZeipai9bQJthzzLHoYHftYFVEqX4pZQcj8BD
58	payment	115	115	115	57	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNH14RyVA3vBkhJuG3Ks73uZSrCW6Zkep1SHQejfEqXnrVYvQ1
59	payment	115	115	115	58	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQd8HJmm2Efb69enAGuZ1LbnCvotGMykJmabqHthrCvxzSTTYX
60	payment	115	115	115	59	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5yUuiSndavbUfE1Ey1bQKZkWatoEqhfvtjjwFjfmLpzG4M4T5
61	payment	115	115	115	60	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJRot9J1N5DFbPEhD79Z5oQiWKnF7E5K2vSchtJjBZy1ybTgKq
62	payment	115	115	115	61	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudMAajRNdKVzKFzBacCj3DBQZJoUUjF3DmYLRszk6McSWi2Adm
63	payment	115	115	115	62	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvK8frA9Xah9ZNaFfYZaYGSGT1o89xvxz5gNphqqwrm1y1ZbGPA
64	payment	115	115	115	63	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzTv6RW1MbXVeFvi9r7fpm1zp712LHa7uNf7rqPooY2FFnrDk2
65	payment	115	115	115	64	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuY5Gg71koHA2PQu2gSZhW1av3pNhzthmspv4ZTWpxbyTYxdiGu
66	payment	115	115	115	65	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvR7RwtVoTX6P46QAbwUo859Y7UZAwoQkRygegVpbA3xab2AanT
67	payment	115	115	115	66	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2B72ehDJmRs6dB9jqvYmefK1JRapihm5TNHGWhF2Jc9KFgvrj
68	payment	115	115	115	67	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurGhgX8nUsp34ZPzyVMMk4wdZ8pe6EsBVrw1RWfv6obz5hksuV
69	payment	115	115	115	68	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumsJV4Bm1qV1eez7Hv3fXfRoZXWJbdREw7nRnu5G9CsZFXnkMR
70	payment	115	115	115	69	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4LY4MJ2sJWxa4CH8cpb1sS14UAHijGNwhX5zkv2482sJ5rWNZ
71	payment	115	115	115	70	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvL3TyE5xRZ7e6asLrFqaKwotPtcRXES8YS3ESMDqQwNqSwD2y5
72	payment	115	115	115	71	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMcmoLzg5LNUBUnTAWiwMvdxABoehcaDDinm4i6pHRbjmNH23J
73	payment	115	115	115	72	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwKoG4KjQ8xoS2wwg735UNXHnYxFXpPbPNzuCk6o1KAcboFFaE
74	payment	115	115	115	73	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkNYp1zUQKsq64byWLnwhYkhAeJBDc5pKUxZYq9bxsJ7EZE5Wu
75	payment	115	115	115	74	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtk3B2Z4AZt2BmfYXwNG2jXyW1v7axiaZXEMgoFvCUb8s6i41oC
76	payment	115	115	115	75	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juu3oL4BBXLYTR7MDAj1JvGVX7uoQrvgSTPB3aP2TtFr52pmNQi
77	payment	115	115	115	76	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvC3tT24rLYyBnrLrrCDVorWiTYBD3ZmeJrRZwJ1HJzjc5bfdmj
78	payment	115	115	115	77	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtg12f2KFjjaf8NeVp1XBXFMUjrq3CxndGoNSnLwqEaA6aEkXW3
79	payment	115	115	115	78	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJdpnsJj7R4bXZamJRS3XvYoCgWMN8m9zPUQyZEixARzVn6LY1
80	payment	115	115	115	79	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEsSTKh4NG3WKKdPhrBATF9Q4ouyY13y8sWPVGuoG6cYP1M51p
81	payment	115	115	115	80	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVmszRajXMAycAsvgoU3aDnTRZY5wGX1TWqP1QSto5Q6XVyx7A
82	payment	115	115	115	81	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju62f641zQTraD5hPdeYeq1rnDXDeghxwf6GWCYwa6pMnUwyJjD
83	payment	115	115	115	82	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdDuhDCkdchYBzsXmcuCPiTkZSQuKSTodq3WUAXsZ5eNEzquHg
84	payment	115	115	115	83	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jusp2UzSQBuTAWWt8QLKJoG75BFALH2Q1VQUAr8bZurWcXPAgW5
85	payment	115	115	115	84	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtw5xKBwbjDdr3K48r1LwuAmkUEs3BYAUBrKAY4CwSJ5B4kHyq6
86	payment	115	115	115	85	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZwETXSZUvQqNxhsHwWfoR7qso7VBWszqHzmXbzHBmHh9mYKJJ
87	payment	115	115	115	86	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLtT3oCv4nixsD3eJrwFsd3e6fcrG5wwGReNcCbs3E7WSqwCRs
88	payment	115	115	115	87	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWnERPB6syTDvt76v6eQM8ePQ37FX57Rxbt4kA8agE3AyYHhD3
89	payment	115	115	115	88	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtw5pZLgMeWQzyMH9Fu29awUk78VKuJsMoLfcX56zcHXnv3PXEo
90	payment	115	115	115	89	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWjDZKArPP8XS6dxz3pBtndaEewf5g8SoxkBrLrNnMbQUF2VbR
91	payment	115	115	115	90	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwcVpKyzeDPthodhTc2QCdHCPztBQi7TUXUNUPx5YvMuj4BtSg
92	payment	115	115	115	91	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7jNZkb76VCUWcHK1v8nmmtoRkbJU4kruUTY98E6QrteaiZ5wP
93	payment	115	115	115	92	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3ZwspNh2czeQVQpLCCYPCYBNdBsLLRR27vmixqrE36K9uW4nP
94	payment	115	115	115	93	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtgAgnU5PpFMuT3MEkjK3qf1xp3RtyyGn3qoCo5bN27mDicFig4
95	payment	115	115	115	94	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtyyhiPSpnM4hj7HyBPThMwTUana33VLwYDXUT4gSVPutHwxy7V
96	payment	115	115	115	95	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuZdMLa1sYd3daaPEtrdtb6PEaDogsN2fn31L4qDMWUrEwBDdq
97	payment	115	115	115	96	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVvxTEFUCxSf2FojJW2bY7LZKHZ2r38Eqa2J9cobdLS7YKureU
98	payment	115	115	115	97	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvC1wPh2hSf5hmdiQqCZKk1NKrCShQBEnwq7cAda26SS1JYZgfg
99	payment	115	115	115	98	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurKz3dzb2pvVY6J1rL3Rf5RgBJMWT33L5MYsrEYvzJ11eiD2md
100	payment	115	115	115	99	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuB13Matwd6FGFrrtBA42FaGDHvYBangFTPBfwFWvdUBWTLFhEf
101	payment	115	115	115	100	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtgK7fa793Tg8Y8aHnWqTF2Zmq9735hkhYDgzQFWhSMzejE7jNr
102	payment	115	115	115	101	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvN9Kj6Y5MFRF8cBXXKQQvr4wNtZ3Dbp8N6GtgjSGVeMTGahpaX
103	payment	115	115	115	102	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteG2pd5vgT8pMm4SRuAWim6a8C4qA7JB1N5K5WA3Jigh3273SH
104	payment	115	115	115	103	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtogwTFqGtGMNvjoWsKtxe6BQYX4DBk4dViCFovSJLBuESYX2C5
105	payment	115	115	115	104	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMDoSXMqV2f4w7e1V9BbjiWgYUDmyXNQyN28CuGYFMKTVQXMMH
106	payment	115	115	115	105	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzFetsFN23GXGZhjyRTgGQoPxEZLJgwNGTZwL5d6w5EQWNgEF5
107	payment	115	115	115	106	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteXQagBpDx7GGpLr7jkCM9wmFvZ7J39STztkA43iWrLERFpH6M
108	payment	115	115	115	107	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5a15NLDmZDK8XFXUeWy9N6AKFFdN7Ab8BKpWMui23jK59Vys2
109	payment	115	115	115	108	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtv1N9rpNyM2dqUKqLpLuk88RVp1oqFkzA6aCMmowWs6s9s3QL9
110	payment	115	115	115	109	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1rER5gpmsfUMurTn4U3X15uUuoM23TSbHo3i7zWp3GJraGcFs
111	payment	115	115	115	110	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4QLy11QbihUc2QTXMibxUeZR5eWn5hmd7Li4gxtTTBjPDxN5n
112	payment	115	115	115	111	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJdsAfrs9ztiTXnVtTw8dy58WLyab37Aemj89x25mE4vbvHF1R
113	payment	115	115	115	112	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtq7Fb9BM7qbJHSQmoJhnXMA9utKpFn1pXjzbkt3Gq2gq9ngnyM
114	payment	115	115	115	113	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4sDqPom6BkiLX9ebMXNpvkHetToSKWNEjgrMNSwYoYFCUQiWM
115	payment	115	115	115	114	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQV92ymr6TKFhco45hRzbRgGs4569SW6dHAtjeQyni4arx5our
116	payment	115	115	115	115	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtv6jnzEA99Q2YAjKGQNMpGAc3GDGiefBYYGnBQxopsYhA9C2BF
117	payment	115	115	115	116	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPGfLp5QA9JaKBX8NL6nkPXCryeKLT6RF5U4XF7W1AZons6D8d
118	payment	115	115	115	117	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQLsifK8hHvm8f96xBn5YKCP6KieTxbUZijLABKU6UKpBCFR9w
119	payment	115	115	115	118	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurGN4WhsCWj6hwqQ1yR1YjzawbunuXmcRuaMJ5aXhGmo6uiHLK
120	payment	115	115	115	119	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuyB4onBQxG66dqWYBVHCXeygrPzpV1dVgHWYUDu7TN3t9P1GuC
121	payment	115	115	115	120	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxBxdRx3Sqw9WDjZWKp6tbLhmBcU6jQPeUr4kXMTh3wHP5HgaU
122	payment	115	115	115	121	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuURnFu2ZYSvPyVU7pk49orXzqyDA9ykFH9z2JcanxThBnNz4p4
123	payment	115	115	115	122	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuX5nhnDJSm32BqJSwrGSW2CXQMSSkBgn1DvDVUX5tqPGMFqR1w
124	payment	115	115	115	123	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1Yy3cwJCchNLF9C51TqJJaintfCJDa9PRkCvbw7xmU4g6BjBF
125	payment	115	115	115	124	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNjkXiwNHJm2yLZYdRekAirSeXvtLvdQ65rsQMA7sEv6pic7wB
126	payment	115	115	115	125	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubZKZDhZZHG7QifYBu36mWzJq8DqBBczuyeyakj4SnApzQoA6F
127	payment	115	115	115	126	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHciYdb8L5Djh1acXzVP3MQPSX9fLbPvqQPUhE7Hpna2LP5Zfa
128	payment	115	115	115	127	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7vfcZ2gmYv6UwNMwzASpvsasr1gsNT8Rggcf2e9MTFXerCHWV
129	payment	115	115	115	128	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFA5AbMZ7sjxbFGWxm1XAub5FXZapTgGiakcNqgPUNbELkfygW
130	payment	115	115	115	129	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPEnR8WRH4PvqfVBZqUtYLXeMLgftrYrYCDzAjhk6h4iyuoicV
131	payment	115	115	115	130	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFoAvsM4sCzVfVB4eJTc7Q9aWFXB8yVABEuyJfQW3fhgfZPeQZ
132	payment	115	115	115	131	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRbXGCaGG9vepzdhLs85jrxHAWPmeMwSGuUQ8eXnToEmTVAXcv
133	payment	115	115	115	132	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupojCCcshShqTLGNKnv9boN9qpcFPqZwX8MNBC4d2uuFgdcMqd
134	payment	115	115	115	133	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWWbD49QhZyGMu9sZDFDJSmAvk62LXPhQLMm2T9CYLj6WsCJXr
135	payment	115	115	115	134	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttzrEKTxP9PmQp1cYSWTCMPkTibCWN9qrsBSyt4oLwVapLXNmr
136	payment	115	115	115	135	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuhR1w26Ymb64y4YpvD7LxuPYFxzte7oxXNXovBBw9t4EHehaF
137	payment	115	115	115	136	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPEtqmMvcqnudLvyt2DggL8VHr51wp3w55bizbE7vzwBHDXXGN
138	payment	115	115	115	137	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUSziDRigLaGvBWgMQPEfpBjbumXvGW6DzaCkAjmoj87H4JxHr
139	payment	115	115	115	138	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtg23jLYWKcWybwSqRYDhyDaE7jvVxVE6jjXjitDybtPAFEQMwU
140	payment	115	115	115	139	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujBPMnQ3ey77FWSTsAf4NitLn7cQm4nkJAo1jSt7U4Q5apxwsH
141	payment	115	115	115	140	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzwGrj3cUZvfwqPNwUKbqgUPM5PRJQ9AJ9QaqFtoM11rX6ByQD
142	payment	115	115	115	141	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvNu4qoKJeHHFHFktVM5PA5L9HQYaVwG114My4i4BNeMHok1dpF
143	payment	115	115	115	142	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwfEUda5jsh9tPpZ2x3gKjcDovPid6E42dwxFmfRZiakBYUDpj
144	payment	115	115	115	143	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7mF8LGMjTtqVY6vKP6fcu1MU11WSiQq6RqogYSBvWCnT687wv
145	payment	115	115	115	144	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLAdKGwzc9Z842zec84m53UXersd72R8zZVZpsAA8UvaQi8aKN
146	payment	115	115	115	145	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEnRq1mSaugKLQXqkQ7CBqQYPBcbsT91e9FjtPsoa97codVu5M
147	payment	115	115	115	146	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuGThu9CfnAYxtdcpGbh1QekZh2Jxv6ZXVtyPwBdeDAHH5UaVg
148	payment	115	115	115	147	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtbsS8Pc3QnKyXeT8iLcW3z7FkLJHba8gVeg74C2Tcfjck2Ji2K
149	payment	115	115	115	148	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jux1VzdNTQMnUG9gCGvrA2d9GshHcrsHy7wwFpA2dX2fKCVtbSZ
150	payment	115	115	115	149	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju21Prp3RJ1Abje6AjNb7cHmX2FcjFyns5vw181RKvKkHdEBZAA
151	payment	115	115	115	150	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCcj9d7jz3n8TUYUoKPjq6dqEoMZP87GhxR7UL1eSPVsLMJ9yJ
152	payment	115	115	115	151	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTC46LwU9KbrJGqytF4toEr2ujFZU5oqHb8ukasaKT55AbdmYd
153	payment	115	115	115	152	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUx9Lb4Ji9N2XHAQ4NR6pdoshdwvT5AU6hXyK3MHyJAtgwkYwL
154	payment	115	115	115	153	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoVsZtKfhMMnBfQAVV7cpreUvD6aR9cfZQb3Unmtm1utd3J3hG
155	payment	115	115	115	154	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDwBBXhWssY7b4Ng8bqFtA7UjdDU6gwMJYZrVEJymcoRHFpbJe
156	payment	115	115	115	155	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCZEEKZzbbeVq7eN2rMbK7AXYMHRR5BsdVS778BLdq8KzeGfHk
157	payment	115	115	115	156	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGE2GjNXKFVXhXv7qNzKsjSdrCnHNyk8hjb6Mvp125D8CBr2sL
158	payment	115	115	115	157	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCCCaRj6ZFnFVfWq6F4fgteJzzvtdf8w446bQvFMkNuau35dVq
159	payment	115	115	115	158	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJfzurfJD2QEkZiS8T7QdkPeZJ5VM2vPwnzvmoURB8YQHTayXv
160	payment	115	115	115	159	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuDv4p18AuvbvrgPCyNNUbxD3mCeoXujUAfUisq5qqdeJ8JXZm
161	payment	115	115	115	160	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFAtL7P6RWuXQidyYtRCBTVuYf1kSogJXjWnddQFAXsfWR1BUo
162	payment	115	115	115	161	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNDZ1phkPtKT7Ndpff4CXLGAqPDSGPD3Ac5TpTVAyeEMR9dgWw
163	payment	115	115	115	162	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju15ASye9A2F4aNBkhyNNLLm652wPyZC5bxxZsFoqLYttom668d
164	payment	115	115	115	163	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLCfhbusRf5qAp1EqdHLjUjWKG7heTPUWY9WCwSTMXoonhUdUw
165	payment	115	115	115	164	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwUXNHNZAGSYQSk3u7yDEEjVUgEFsC1MjK4fhFFD1X6Da9MSq4
166	payment	115	115	115	165	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupFXykrKauq3oFs5QmFQzXkGZ2TZFug56eXJdCi4DFKLuunAPn
167	payment	115	115	115	166	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvD4L18nD2LvSBPxHCtWmFxLeRme4V3FiwBCJFQ5csjMBkuNGuw
168	payment	115	115	115	167	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6jHzkQ9HxJebf6Z6Sm2d9XoevDPMEe7bvfUcSWNhVYk5umjUP
169	payment	115	115	115	168	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtarCHeoBzhipZcUvEpM9LofJiyFFNSRRGCxcacMXtvxHsutBrf
170	payment	115	115	115	169	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5BqdBZJuJCzGoFqoyKec3jqP1Lg5KT5r8b2yKZLyxxMRps8ua
171	payment	115	115	115	170	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsTde45sMBZco3TmQM3pZrTiZn7LX5qLP58xaZWpXZVNMHS3Fu
172	payment	115	115	115	171	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcvYYSdRHY15dyf6zFaQ2Tpvc72JqDjTg699vUYws7MyFCq4ae
173	payment	115	115	115	172	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdZ4birA5QTx6wtrchZww5V39bMrHYKvDmvmX9WWhkzQF9gNUz
174	payment	115	115	115	173	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAK5djRhTfk1aCqAPs4ADf7PqXmprftQvz33FY5NWqL1VMKEXR
175	payment	115	115	115	174	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9TkGTpMMArtNvaBrz22zfu7GViD4hEmWNCdLs7t9cz7q3f1vz
176	payment	115	115	115	175	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuyfbXj5FWeXHhrhxFeUSJoMfkHmTDSfY1zhD1hCVYUrjWRwRwb
177	payment	115	115	115	176	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jttrg8tWpPrZFPJ64xDJCpf6kGRzAEn5bVa3ifRcYpMhhFHKoCX
178	payment	115	115	115	177	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVwmsgmNeW9gBuUmV8a7HvCrBJCwsydPVxtFCsTUKKATyGusGP
179	payment	115	115	115	178	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxTjuuM3ULgAQHrWwYX4gBu83tDDbEyn5VaUqzYQeiYFgyc95d
180	payment	115	115	115	179	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwtCrRW17kN41KMficzLwB69WAJvdBWT9C5Gnn6xycy82GzUwA
181	payment	115	115	115	180	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurS4MyJngevPRdo9wFcfSLRYtxERBtyoJ9CWyVeWtsuKFDF6P2
182	payment	115	115	115	181	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5ukXVymmH1bCeCkPcE1ahdwi2FETvJgNCam18H6C9LSqbgDv9
183	payment	115	115	115	182	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugbhagoJgzPnVKidQUFedE8Kv7GoCdBB6RGyUemb4qLGUtbpaP
1228	payment	115	115	115	1227	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumSxDTay9UGg5dywwsr1ViuPPLzRLG89UeaMFvA9WZrFH1cWXS
1229	payment	115	115	115	1228	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugWsT7FDv6wWULfXwQXFyLQWvhGireYCJxj8b1EwcVMJVKZmTH
1230	payment	115	115	115	1229	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1wXfXU4994dkTR1Heuu5QyhwKGYUP2nV52DzWLs7aTNRKwub8
1231	payment	115	115	115	1230	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGvSiS1V45UfMH3Fwng8mXGG3bdnfFvsybFUfKT1Vm5PJViZY2
1232	payment	115	115	115	1231	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJ5oARWbNwzVdpaFv96debKSWtXgjpkqNy8DrSoWaZUksZZMBP
1233	payment	115	115	115	1232	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju35c3rFJ9e8fAnsq6VTG3zQuQVZKY82goXLHQEMYWuiPXsxUnV
1234	payment	115	115	115	1233	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6xfSAx3WRywFfx79HTc1hMNkZpgTYb9a1i5xVAbj162tW9m4q
1235	payment	115	115	115	1234	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jut35S7QizX3soYnYp477z596bdFKXWfxcDAbMmJA1W3AeY3TPD
1236	payment	115	115	115	1235	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJRaFMLwuXvnU6fEwxU1N4YooahJFHpPWNp8YUTY2rfVtwCZ7W
1237	payment	115	115	115	1236	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6oJER1W6Lg9vKsNi4ovofboW2Qc7wyXrz5vLM11w14NrUMMa1
1238	payment	115	115	115	1237	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2yaF8jx97TDFRxZ1u4NUspF8D5Z8Puv9QfH7k8wnFkNpDMgEV
1239	payment	115	115	115	1238	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWt2VyKKohkLHSEebEmERAwek9mTjupZA9swNti6wB4CEwArLy
1410	payment	115	115	115	1409	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtmw4bVcsjQtc5DJjgbuyGnQfjasmgB5Ywr1Z83cz88AfmVjoC9
1411	payment	115	115	115	1410	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRiGBZ64qx2s7tnXo74YzB7jZ5M1W2bXyMErJaj7SWvmf5U5bf
1412	payment	115	115	115	1411	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2revAs3Z1tBBu2xLzXGnApS1RWzJuzQDQk98RHuccENHvcVHA
1413	payment	115	115	115	1412	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juw2eb8BwJp9gMZN3DVVf5B39jKt68QhfGWqUC7tVD1Ny76jEYR
1414	payment	115	115	115	1413	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvP4xPF6LRsq1j9cj6RYSTx2ufGFAAHsv4TkbkbXwa8Uo6YexM9
1423	payment	115	115	115	1422	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKkLi5X9xqAY568CEfPeWhfqVNEMHgWZ33EbYu6kgzDCWbXsjk
1424	payment	115	115	115	1423	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtd1DH1DMXCaVetibcRQFAUbdkg6nWWUSqnhnTWFw1bGGGwCBur
1425	payment	115	115	115	1424	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvUpups3ZNedgEoD5gYmWGFt5LFukm5u2mLKkmkmQMnPQUoZ8R
1426	payment	115	115	115	1425	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNkiQ76wm6bvUtDBpTQYjvLybeghX5o6saT7DkazsvNGAnQDGa
1427	payment	115	115	115	1426	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubmVaaAM62D4rfEP5SHXYNvxeR1dyJpK71MqFSnpC4jLnfQFTM
1428	payment	115	115	115	1427	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juj97ExZehZLcpincjpHGXR6Mm34Au6JTwSFgdvrxwgUdtGxGRw
1429	payment	115	115	115	1428	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttM3yLfEBTmbnLyfKeuxm8x54nFSKCXCYodjdu8oaE3MVGena3
1430	payment	115	115	115	1429	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFrh2gipoDwscikGcWk5fhacoxihCkcQCbGvfHkMcvF1Lc3A3g
1431	payment	115	115	115	1430	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYcJ6ZpCfrNEEPYAhKxauyAwN738qRU8qXFe5FVzsUcLhBctoD
1432	payment	115	115	115	1431	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBnVz6N4f28k1T65e3J1Ti7hQWYsikjMrnvNqM3Ms9GT6NDWk4
1433	payment	115	115	115	1432	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtimtQyEAorkGs5sPP2xyWjq7KmHWK472mNv6ZahcND5zzRA8F5
1434	payment	115	115	115	1433	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZZoJ2QeMu43RVQeonhgsmy865YvDQq4eteEttWUYi8Rup38Vw
1435	payment	115	115	115	1434	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBojjtwLYu1gJW1kgCyKXFhRomxFTe7h4JwRiT8eFWTsWeUpg8
184	payment	115	115	115	183	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHtyuDoYdx4VnM24mymzRLX1CHzaHoMNkFB25JxZtQheeiX7QA
185	payment	115	115	115	184	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juov3hcqddYmXDeQwYtfmvaVMW5EFL1XxLSnu8icdujQFzc8Tmx
186	payment	115	115	115	185	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHeiV4HFSPJ653yifkMGi9TUGQuWyJ53sx1gW7TXgVBVBCTZqd
187	payment	115	115	115	186	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNe1DmcfBMCvxv7Vdeue2NxJ2BovDsWMrmAsszbgCvREwGTo1D
188	payment	115	115	115	187	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8No4EFTtYf7MfpNzV3gv1wojVULq9RY6Vb7EHsFRE8vSKhf4E
189	payment	115	115	115	188	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtz3UoN68JDnSKDjcZMiRfKJTEhkb4g5cxRdh5Xq8HnnUJa1EFb
190	payment	115	115	115	189	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVQYZafcLNm2pAk72gnP7jC4XSgtSEo11hFTT1BU7wLXZk69yH
191	payment	115	115	115	190	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtx66QXC57JtSSXUFEzZnx1w66TiNgW7EfmxrayUP9xJL7PDtpa
192	payment	115	115	115	191	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKwTfCxJrDEpvYh4j6t4DBhpRc23j2fFYcGmoFpyPXYUwoUqfH
193	payment	115	115	115	192	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXZ8Wy9FbEmZJZrKHWtFi9yJaPN9vVX3bXQaskLb1AKTciodYy
194	payment	115	115	115	193	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtY17rLWD2WXZSeJ2oSpZXDEjfUwcbbHVsqk6pkW7rYgmt1NJju
195	payment	115	115	115	194	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7mKXqPRJPLK1Vfjbh8UU6dRCUpg5audDxu4R8iKrPNi5gLKoB
196	payment	115	115	115	195	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuWGBMBwuMpAWF3Zuy5J8ZqL9HTyHRA4MwVMJPyLQqxHuNHmwR
197	payment	115	115	115	196	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsvzZxAic6MxhdJt1KdevxLKdiUiwwh2siSBRxVk6wXezdAAfL
198	payment	115	115	115	197	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujW9tjpyPKGDBP2Ug24Eiw72AEtSpep4KUabDrse2Xs63QcTz5
199	payment	115	115	115	198	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJ8EXEyVksi7t2i6rdvYZ5mKi8bxf3veh4Ek79uUoEY5ALUYgK
200	payment	115	115	115	199	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jun2y3DaAb9rsfSemrsxEioVegpo99c7NyZHz2SmnvUfjV3DGVf
201	payment	115	115	115	200	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuX4yRSxuWJKJQgWEZ3Fc851U4PRjEo1baqqXxYLW9FhD57AzLr
202	payment	115	115	115	201	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumM5uM6UB6i6qH3gP5MFmVMifNB8ubtpRkdPoozJTcD7nwSBrP
203	payment	115	115	115	202	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDhHPncVEfi6pwSu2GmzoeDBcft2BZsXqwvj3qfb1eXfkcNPWh
204	payment	115	115	115	203	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juf29P9wETStjtdNt6TpX8RMQ7B8Xrm934nvxpfyxomNzjjDtLm
205	payment	115	115	115	204	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudY1uirJURiTHMLHLAQ6XGn7VCPukJ69E7CcfEGvyp547JgHW5
206	payment	115	115	115	205	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAsrj1uCJKDZEP8yGCAo9pNtR73KCygoGq63zHkAkskCu3kByk
207	payment	115	115	115	206	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju72YGdcRvyCLxPTV4a7UHC7EAU68gFw8awJSvzPASPVu9fAQrc
208	payment	115	115	115	207	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVRVJQLkFhMTEHmTYJw3yoP6mRefo5MTSiJS6JfCrsLkEMh2bR
209	payment	115	115	115	208	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYaatNAM9w58njb9LJVpW3TZ9PLxcKMTaiaRNKfr68sfYd841D
210	payment	115	115	115	209	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtqcAPqULgpQvENdPhyUpY8XLfaNk5x9gnR5njUJn3MzoxDL3M8
211	payment	115	115	115	210	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuscUNb43LNrEfXm7CdPBZsTd3FrFk6o5f5ZARGkZF7AbkhnA3N
212	payment	115	115	115	211	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtom2hvpXdewBJAsFzYMGrKChqFUUZeELZ6G9WfxWKy3UM3n8cq
213	payment	115	115	115	212	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQRQS4sep9qBAbgWAfkKHC5Y5X7RbYYvKaW938b4VuSDYyLdr3
214	payment	115	115	115	213	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvE8FaeaKZjYfhxwd4GmugJ5TF8JUsAbk6uTEb2b58ZLiwF88Gf
215	payment	115	115	115	214	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtitNJeWYw5UCo9Re8LXgzfdsTpYq1MPDiBfcGTJr3ihdeJ2MxF
216	payment	115	115	115	215	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiPNrn17CGGG6dZNtEB6mqtqFKRoBN5dkzCu6ZYYRaca2kHeUE
217	payment	115	115	115	216	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLYzZDLm1JqKuYF2ZUBV6kWiuGKBmPvMBgxq1GjLfSZKYBkFfC
218	payment	115	115	115	217	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRErJykveUPEHRiP1v9WTtGP1rgQMAoQkHs5hqzmSiaYD34jRL
219	payment	115	115	115	218	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXPn1AAJ55rDTr1u8XicheZLrJn2BuG6BdhXbmgbZBdgpocXJ4
220	payment	115	115	115	219	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6z4LusEoYc8drWbBFa37bPCRFTZU2v7GwPs6kseNbVXVYx12b
221	payment	115	115	115	220	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKmjAg99TCujREs3JEQpnufshgwaN7BpqYAYMXRvhK3hCa9eNK
222	payment	115	115	115	221	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtpKqErbHsrQENAwiWRkmKoeH7LRwdauf5JpFZqzRUF2hjw8cJY
223	payment	115	115	115	222	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPHaNyhUS5LfhyxpAgSY4DYqRc3bTq8Gy8Z7kftfFT2nL6oA7z
224	payment	115	115	115	223	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjZk6GMcdM6oX8FPKDzWjmo3ekWJDXzVNR7vWufnFGFo2sHXmb
225	payment	115	115	115	224	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4asS8n95PMg7bCzfa3cP2WeJYddWVwfvP5shNKCf6SSuNGxRr
226	payment	115	115	115	225	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jukr2tFFehF8aaj897gh39pBPeJYoXXMKJvsruV5rFMA8feQPvA
227	payment	115	115	115	226	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jta2XgbtHV5qCHuyahFxwFd6khyus3dzamqXSPL2Abbr6NQfAnV
228	payment	115	115	115	227	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1t6zzrbD66TcResDzHNQNrnzpfS3Zqjb1w8DLsqcbwJ4av5sq
229	payment	115	115	115	228	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHHksWLZxBULniWDS7hgmF9LQ7vixrdGLSxbpn4Xmb2vCCxFed
230	payment	115	115	115	229	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCjNCrpgu4ExQn7EfVJur9oFZr6h6Eb6XDaB6LNka3HqrMxTE3
231	payment	115	115	115	230	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBuyx3B89No8KXgWGgHMcqbWayCHV6p6tf4i4zkKYKY5XQcEfK
232	payment	115	115	115	231	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JthNjrh7QurxpwdgmkrP9VG2tTugHdYtVjvA3Z8JBTbJwGvgztW
233	payment	115	115	115	232	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuphEi245tARvqixockVXpYY1ajCfa6ef28iMFTi7yN6EbTjBd1
234	payment	115	115	115	233	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBeKee7WhxJTLD6Bv53VrQ8Nji1VSHti5uHimkyoHEiz81pVkL
235	payment	115	115	115	234	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtrjgecutjFntELrkekvc7sD7doZm1RBzB2di4qFZwBj13fmvwr
236	payment	115	115	115	235	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugkwY8EPCrjLWX961i8rkKB5ETHpPoQMpyoxNCefbiBCTJFPX4
237	payment	115	115	115	236	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYoqwWXMn8xZ5P5ockASyvViqx8ukWS67RcvFSzmeEvEXwPnfW
238	payment	115	115	115	237	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMSs4vAzhAEAwhe1xqCVLuL6Jj78dcQncPdjoQkRE4QLyej27D
239	payment	115	115	115	238	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3LdXG6hzREnsevxcZpZP2tBoeZ66XGVqrKQZ8e13oqn8F5j4a
240	payment	115	115	115	239	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucW3PMHpDu7QKdcLeNzUDK3rWRuAsNRP1M5Znhyk6ujzK2mh1J
241	payment	115	115	115	240	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHVefBzCoc5WMmuE81Up2uhc6kJENXvWZ4mUNfSdqYtcUG2PM3
242	payment	115	115	115	241	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju412cMC5nnZ6T4iwBH2FWzp4wYZ8XJsnHN82Px7F4LeoChzAAw
243	payment	115	115	115	242	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNV7tT8dmM7168w8D13cSSfuZSaYpMwZk2BJTdwDRMVYvU1Q9P
244	payment	115	115	115	243	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQcN8WxarGAHSmYZgHfMpdBVcYH4FFe7qdmmdHARcS9G7EVbub
245	payment	115	115	115	244	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvA7ceV3PXp1CG3HHyCsNGe1y2DEuQFT8Wss543gCics9wf7uvn
246	payment	115	115	115	245	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPSX2iKpepyeZPCSch9UuLkNa4syrtpdy8jZFT4cKPXnW9D9GL
247	payment	115	115	115	246	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQFWwckPaiCJrThkDXXnPJJhZVzpd4cojZNGZJDc52yPQFRMEt
248	payment	115	115	115	247	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXA16iWYoMnrWCyyH1tMZjQuPmFFtur3dEQb7niDnGvVeuHhmT
249	payment	115	115	115	248	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtv4Y2exLfnjBrTyrrbpY53ZNaCb1jJVeXmVMmsKgXWbks186N6
250	payment	115	115	115	249	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhbGUzPRrw8cskwBHUKYuM8hdKrvkYnz7F9wxjm23UyLayUucP
251	payment	115	115	115	250	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKBFhHGcXvPzopsji8yBFyUKEXZ8wSh7kZUgopZ6yT6rpTdGie
252	payment	115	115	115	251	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXKhmjtcWTYYxrqPtRPmgtgvZi3yJdMoHMKSmoj1ffuJ95BQUW
253	payment	115	115	115	252	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBj2ud3VPxuUQ9tnrr9DFDFwFmrNa1ZpRFepgLuhHAJGqnb1FS
254	payment	115	115	115	253	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmkDs8pQjoJm3CzJ88ukKroqpVDnkX3x5dSRxhT1z3B4ywobp8
255	payment	115	115	115	254	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsZZMxpyjANVYAer3sw95eA3fQe9vzJUC3cpiWS8pKBrFcxFzu
256	payment	115	115	115	255	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkiR97Bm8bi6qSPkQ6Nr5y87uAGjB3zjQnsFXFu4jPdyUuy3fq
257	payment	115	115	115	256	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2BqeY2NmnzJ5rE4XMMYCEhVS48sb6fMSPsjHcfUJafc9ZfLRZ
258	payment	115	115	115	257	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMiqetkiQsfHtiUdJDE9QG4CHH3QYpKfQfo9j4cTdn6vbJ79FT
259	payment	115	115	115	258	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jts5S65FrU8TMfe1KqCmWEAeYvMNit7dekyjK5y1tQf11nKv6G3
260	payment	115	115	115	259	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7fxqfzRHoe4AoNR431Dhj9bXbRpBbj9NN3LHtRQ4BHRuAyiga
261	payment	115	115	115	260	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAkJTcWjE8U9wqyLnCsvJrGY8Xa32FKjP5UdCxXCRmVZdhQoRX
262	payment	115	115	115	261	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDtTFk1ejwDPNoUs9dMuW8MQvBMBsXXJZiJ3o6x9uYXtQe9Z2e
263	payment	115	115	115	262	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumeMdpLkAxoUxip2kJrixE2FGzgURaDNFqybckD6rw8J4RV5T8
264	payment	115	115	115	263	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcGtiw86YUyE7pd1yCcQkie9wTSF5XPMszNeaWtw2KWB2iKxBC
265	payment	115	115	115	264	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtyY7HPSVgk25cwQjAYLRpjwv3vkuYEwb1RpdF8vuAJ5BZGv548
266	payment	115	115	115	265	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucbATLeADiNjSmagC59SVFdvvkuRH34AzebFxQJvK5sxAPWQyd
267	payment	115	115	115	266	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3LCJX71KMhDYCyKRXMvMdE7m7kKhggm2MrfDsoDNruQ2u4fb2
268	payment	115	115	115	267	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugxWNKphtY1jGDNPS7imrq6w2iPASgRYi9MeEPXcXFqz1pzvZW
269	payment	115	115	115	268	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEBvS6XknY6yFGc6SYomvnTHGf7HqugFRr3srPSF7mCKxDdcR9
270	payment	115	115	115	269	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jut2NPrym9eFk9eDqEsjfFR4ibniaws6gMkRxQKQiaixRxJJ79i
271	payment	115	115	115	270	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfHC6pcx4EpDxcPAmMjoN8F1wThuLDuN2GXXXCqGjf9gJamK3Q
272	payment	115	115	115	271	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCBj7kxehHajEbCAMyi3E8pexGvT59FkqFVtFb2Vg9ykns1Pjz
273	payment	115	115	115	272	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9343EYM76PFKmHU9FSZ3bMEsU4EZjmVc3EUEoFA7nbiwUMnrG
274	payment	115	115	115	273	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumgeM9S6rMsM3ebAv1kf3r8dajtRjDU6XRMNFWWDYQH4joPYCn
275	payment	115	115	115	274	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFPvA1YCPUxY5V9cQXFua3f9fqn7NZVKTTPViWvv7T7V9hxayj
276	payment	115	115	115	275	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9AMvKCEZsiMS7Khkd6ZW9qqtsTbBnTV1oewibiqqKth3CUkzM
277	payment	115	115	115	276	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubWN97BmN2RhBLUSPFWuoZvb4gbfrdrq8DbNcAjSYsGZbn1GJX
278	payment	115	115	115	277	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7TW2s4hk9h42tUxKFfJvCR9scKFFoQiioBMXUvuajLtCfUDg7
279	payment	115	115	115	278	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVpdrd5xxf16QFBRxWWZAj4GP7BrnmKN1yuCxZzhjEYq9zKkfB
280	payment	115	115	115	279	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3Womw5Wpjyy5S7kq43yFQhN3gBXwpRocEJBbHWxU9ridvJUxJ
281	payment	115	115	115	280	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnUJpwFQZQASamXoezr187mPdsmEMp2jrW6yvEGXxVFf6gBkrQ
282	payment	115	115	115	281	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jts3KJZrYVapLVcniCBiPcYqCGLbuXQVCnV2uBNQxSV2BGjtPUE
283	payment	115	115	115	282	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQoKH7wdGMZeQwARNcdY9S9UHndiTnv1eFXwx9dqWFiW7UCxUt
284	payment	115	115	115	283	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubWAAFm4CvWXHNmDgfr837J7xrLSgfp9hHT8G7Ft6YKsvrJ2vd
285	payment	115	115	115	284	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCSqASEBzHxiz3pXix24JSuh1tgdMaG5SNjWbkABGgMQxs5MVo
286	payment	115	115	115	285	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jttd8KSqwndaoKd5GrKETVqd4LPxagKrPwtjf4dAQCrQwh79KJZ
287	payment	115	115	115	286	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtiphupCYZ21AE5v5gk1SNtvDzCGpgLo72duFZW5BboRuppYz1J
288	payment	115	115	115	287	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4ZyPpZNun2HAUDZcTxjj4BUhEV7GgrEWv2HBWY4KaHXXyxiNU
289	payment	115	115	115	288	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFeCrCF4AwfgvfPwwwEs5JXJzGAD3mxk2GKWHeyy83k8FmGQjg
290	payment	115	115	115	289	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFuYeuT8UYM1GuQCG5JWrgz8goJRv9hQJULkMtoXkSjB5cCR62
291	payment	115	115	115	290	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtW6b8WsPxhWZpaqvbd8Uox8BTAgugTHGKrBH9sbdUZkFFQaZwp
292	payment	115	115	115	291	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jup9BQzRcM5RbmCq97VZDdfwq4Ac3VewuEbB69XBkNsqeNAABrn
293	payment	115	115	115	292	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jucrb3avrq86JFribEakTafyVYcnakznJu1DCT9vGTcdDE2q2C5
294	payment	115	115	115	293	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFjPxmr919MiS2xcw1kJUSLdPyTKp7nsqPWmPpUFnmAGwBRMeK
295	payment	115	115	115	294	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZp9xoU2wVMQVg1Nf4vKcwK34CqPkE8P42vZVyAuzqgMfamKoR
296	payment	115	115	115	295	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtshF3qcJxYa9szC3rRv1vuA2zdDvLxUg979vbcbCGkbRs6wsQP
297	payment	115	115	115	296	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWDZrTCk4tWDAV1BEDUnHwz31Do1vMt6LDeA7A1p9smvxB67nY
298	payment	115	115	115	297	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3eWTTvSMFoHVP9rUqnFuVG7xUpL5VhSnRtmBVVCEwvr2NxW7g
299	payment	115	115	115	298	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwKevbEVyeeYwA2S24Cs6k8KXhbq1W381eHaRnAwFo5Es6mfwC
300	payment	115	115	115	299	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucjJf8yYA4TM29biQNZn3Dtn4DZ2X8FJ1zMjWhLiwN82GUsLwv
301	payment	115	115	115	300	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMcNtfRQo6VAiEEgK48C3pjC7ejTmvPqVn5PSL9uThDrRfWi2K
302	payment	115	115	115	301	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAr88K1raXUgfbJ1h6ywL3GrQAd9EWiNLB9E1i8kGCa8sAjE98
303	payment	115	115	115	302	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsnhfhoLSoQKhS63rurj3qc52itTgaVVuuQVK5tMmcEzjkxory
304	payment	115	115	115	303	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupsW7DHH32XQ5A6JwyGca8gcUjwrkRDrMACdGwYkqCtVGEjMwb
305	payment	115	115	115	304	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzBDyJfPvLscJNDfpekp9xFuBFE33ghF4v1EhRKg7JUCuRE4v7
306	payment	115	115	115	305	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuN7Pq2bYovpUbnGdcbo1ZCB3SX3k4cD2tQjqyzsUsZFz49JjK5
307	payment	115	115	115	306	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBUAAVT6u72BZsn2GKQDtkVoTrSjVUunTAEbZjSJYY6Bwn7K1C
308	payment	115	115	115	307	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunUE8MDRp4Ee2UxAxeNWCoeHqpoKLQ1XYbuYSaW3j2Ma1GkuPJ
309	payment	115	115	115	308	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9H3zrXsnADNa6zf1sZqkNM1ozTokPBnCxmE2qyvGQBmxphK8p
310	payment	115	115	115	309	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXszDjAxr6XKgVCCHGA3zjx9eMW6C3efeNAT7Y4V26Skn35ZQB
311	payment	115	115	115	310	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxWdu5p7hizfkvmhqPrgFtb6JSGb8Zdp95FhTcyex3D1m3XKer
312	payment	115	115	115	311	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuF5bo3AH3iPWzXrbatJGqgVBRuJWwzbKqJdtjp4poskdMBYMPL
313	payment	115	115	115	312	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtx9Kp7vf4WXjUogU9j4pWWhYJLXcqQJChTuP7HmEufeDtXSURA
314	payment	115	115	115	313	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8DWcySXFWsGg1fuUSJvCvpxdJdiq25RjtNMNvNWW8jSBpebeV
315	payment	115	115	115	314	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuK8rMaCj2xNLjBxwGt4eja7nKtyDLJ8BPnNAGgEvbgEAet7NNb
316	payment	115	115	115	315	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXcTMFaYWtJUTD9tR9aueYUVQxju6xTHniTukqnk8jtGLnfn4r
317	payment	115	115	115	316	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jufy1TaGMRDWd6EgjReARRUnGDwuzGAeRUun5iWiQtJvvxYw7gD
318	payment	115	115	115	317	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQurQihqbuvThcZr8Sh8ohvt7s3RuKcQD9zEAPb5heh846B8Qk
319	payment	115	115	115	318	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGjW9k2ye5cjy1aqJgVucACBN5wMYmaW5vNxXPV4z2KzgKEW3J
320	payment	115	115	115	319	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKv1sggNUsgdFDtXmduoESo37LpH7QEFaP3i2eYKsscR3deHGL
321	payment	115	115	115	320	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju72ooDcZGRgid3RiuHkkfgXizyaPnsM6japgjhJa59vgAQC9qD
322	payment	115	115	115	321	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLTrywCwZfPpdmBgLA4cBDP1TqHbuhZRi1C4yTqEYDpDKvzKpD
323	payment	115	115	115	322	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfoHnXuc3kL254d8oRio8T6pRJu89iYVDzGcUfKjsBYAN28WvY
324	payment	115	115	115	323	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvNq1EXxuuiFaWoGJ6fF2oxdLbCQJEG9uV3Ga1fNapsHrPF2dxB
325	payment	115	115	115	324	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4hR1bG1WBmzwDL6gAFQXymtgSg6po22YKhCNtVPuSr6jNJ7H8
326	payment	115	115	115	325	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZejyYao6gruaqAnfoLY1JXi19xR3uFYZ6R6br2214wiRXfvA3
327	payment	115	115	115	326	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZBfBEkBcmES9RnJkEvLWPU4PWgvR6JE3ydGGweFFLHu3sxBRS
328	payment	115	115	115	327	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9ffSrTPou6XHK9vdyParEwxxsk2Xchd19uyBs2vA11gF2oUYn
329	payment	115	115	115	328	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZVe3JXgw8xNxSFVishS6nfTVqfi7LTf8FHT4CKmiJNYsxVWMC
330	payment	115	115	115	329	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuR1z29RKfULDJKZHRjXHecxM9rxUpUX5GujT2DAAFVGfZDYPJb
331	payment	115	115	115	330	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurnEv26gUhmi3guEjUf5Si688PLqC8P6CRDicbUQGSrYW2H9Na
332	payment	115	115	115	331	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHcFps8wVrRuE5uNVcKTatsvh4z3fjYH3AU14XYCZVdYCyqHuu
333	payment	115	115	115	332	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwJqRqzhadMh3mky7HAXdbAefBBoEQNLj1kLXpsQD2od3kCUik
334	payment	115	115	115	333	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzfLCHkisSnvbFwyjNDXXuzvkfab8Rjr9k4ucAE14E1LPui9Df
335	payment	115	115	115	334	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWP7FSYaXhe6kCgJk4dmSL1rkV8XRggUQvGcwdjRcoSMJoezPy
336	payment	115	115	115	335	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jush141zFcSyuCbh9hZ4agieZajjgHigRE8d8nKQg6n1pQevz7W
337	payment	115	115	115	336	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudRUe3FMUwg8Ej8J42rM7sX1jA6iJQJtyo7CxpsNdVzYaipRh2
338	payment	115	115	115	337	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXVkRZ4KBbscP6adJXtK7cDsFfRSf9LKzvrdMRMiNcxkptu55L
339	payment	115	115	115	338	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHK4MuGMFwWLZhzNcMezpaKRsg9VnPZFG45YVSRx6uYBNtShJg
340	payment	115	115	115	339	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMSdB3587seQQJkLWPZCwSnBjVp4698u3cFYEQky42RXWAJyrW
341	payment	115	115	115	340	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiynmCraSSQeyczwSyrfqEStLrVCXxKs4KDNKj4HY3Y1Qe85ix
342	payment	115	115	115	341	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6VMJPyWQd4Vs8eidy797Wp8t9ZHgcaeGckkj86j91qhq8BeHX
343	payment	115	115	115	342	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQiSa9ozKERTbhrhfKyARsp3KBiE3XLeMZD7VGTsnB3ERKVCBe
344	payment	115	115	115	343	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jua8KUpiah4gAp3BjFegApQA4r8k7SkYTr1e9jpMaqxSiMYNUKb
345	payment	115	115	115	344	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWeTeo3BZgLFDfN11HiAy1Vqusxm7mQXUYNNfGS3TWPXS2PEGk
346	payment	115	115	115	345	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVMMSz86ncVeK58Eb77xWEsy8RzT4f8TuSG3LDfuZ3fo6XPgxP
347	payment	115	115	115	346	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFFKjfKzCDLMxqL2gbfeVTddX6xTs2PQBxhqaDqSM6YPapqKDo
348	payment	115	115	115	347	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDAAQW9sGe3mew2XBBa4rnPCVVzqXBa6MweA8k52hemRBSca9d
349	payment	115	115	115	348	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jta9vvR9KkG86NNzY1iStYkoybvcaMbSPux17M9Cf5VwuNdVcnE
350	payment	115	115	115	349	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEZMLifW6q4CvFy49om9pmGou9JbVTpgDHktFSNE5qizE9KgwQ
351	payment	115	115	115	350	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuniPdRPWRg9ckfapEZgRUSiBMCNBwxF7X9PSbYuPgL2uEP4ror
352	payment	115	115	115	351	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusxDXYnjVjkhmfbPGXptPrxiBARspiwjmsoU9CPt4jkgpC2Rbz
353	payment	115	115	115	352	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiqJN6i35nDbAhS1mxn2r2bjuWd1VdsD1j3oswZNunVNSyMT56
354	payment	115	115	115	353	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvAKPRDhJurRXQ18PGrmczkbRGnS32CB9itgrpFticwv6M6pYVx
355	payment	115	115	115	354	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNPFENbXXtiyicn29gxYFK94XVP2ivBd196ryWdspbqxWGN3mL
356	payment	115	115	115	355	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2RheRoxhGydgvr7qX8BqaVe7gzfxc5bvwVkJbFF6BcqYZ2pqW
357	payment	115	115	115	356	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNqyNzxtjQJyudc2SDuzbvUPJj4sH9wKomMx6XQyCZWSdZuWea
358	payment	115	115	115	357	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMS9R4UHxvY1g39AhTWb7QMJnkAFPFqEXrUy5cTPYEyGGmSdkH
359	payment	115	115	115	358	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7f7v2rPJBiQaRdy7JerjkVb1AM2hYFTZVBtnTo7FPsTgXnPdN
360	payment	115	115	115	359	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtpSKjBxzMBmm5XDdpHskX3kDFREXmwLmfXhyscyRW7XnBCsz7v
361	payment	115	115	115	360	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtfs95RvbQSoE48moLKeuuYt9tbnpwF86yRsKu9Eq34vC1xSYkY
362	payment	115	115	115	361	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juu3p1J7Kf9k9KRtzstZNt5XKtUUpHF4p84YxThQLyySCQsYg1n
363	payment	115	115	115	362	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXF8cekqMrhfZREebthHt22cMUs3ttpeKGyo22cPNU2TkjzF2y
364	payment	115	115	115	363	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuomPrX6gS3tukRHHcwy6YFiYDrBPCp6b86u3vtftcE9HqTLyxh
365	payment	115	115	115	364	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JueCtdsznsptmhPUN9m2hsQVUyxibB2spoQgmWEYRNN2ZLxDSZT
366	payment	115	115	115	365	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusfkjRpqQwxfcsf4fykN2i3a7mdqrE1QBtPT1orwj38ivz72Wp
367	payment	115	115	115	366	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvNRQpiBJts18USEtn4CgPTvqeGo5Jt71bYv5tU4rhVFmJxPZeE
368	payment	115	115	115	367	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqBXSM4YWvbptbUeQKkn6DuWw4v7mQKVvxFGZjwdQu1zWq15RF
369	payment	115	115	115	368	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWEM4UxNweQCuf5sgBKaMxyDiGba2W9jRRcNtaVxi2FUxSaGmQ
370	payment	115	115	115	369	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtd7TFrGDeR7MWQ7wMaSEW1FbVUCr6kXHHSammkc5u2Ryeevow4
371	payment	115	115	115	370	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuebGK4hGzwAHAxay2k8AHr7uWFherRR8WUF6Hc9QTETeYs9c8Q
372	payment	115	115	115	371	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHstUJkphbnKwvFxxg94AGAdcFGNdBcmUDUQ6J6xDK1yuDhFeE
373	payment	115	115	115	372	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5fBzLxxuNkukUuvCq6yfcM1CSU27yKpnEpdmUXb3C4iwD4LVs
374	payment	115	115	115	373	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKgW5dWnYLxLXsqMGUSAzNav5nZy9XNiuftg3vzCMyBEppknoZ
375	payment	115	115	115	374	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDNPTSNj2NgZRudFHJuLSdRqpgLeaWFWm9RLsBU3dyMvFy692V
376	payment	115	115	115	375	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtacaN6PEEQ4xeaqrQhVgmFhqXMj7A9CmRyACHr1msRNe1gRATR
377	payment	115	115	115	376	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtukAnqV2rKfddHS4nZNP9H1LVvJRqVxFNWDqzkTjuCMqifbCVk
378	payment	115	115	115	377	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPNGaXEyU8BjLuaEuwL7mQ54TWGSc6PvzokjQJUYG1quVwVeAC
379	payment	115	115	115	378	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWpx69AVyqrVd5zUNXV3yjoNZCmaF721YKiUNM27t8FhdhpruG
380	payment	115	115	115	379	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQqbUHKg7xQFXRiXHw1ZvYYbpDRZ2k6fq3LmqPRLLjfX8bagWY
381	payment	115	115	115	380	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwEJxZWTKcZnmk8JP62rW4fwWVKU64RecyDvGkwDqgzCwFejpW
382	payment	115	115	115	381	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDEp265Bri8PjZKPpPaorGaiqwETyNHeXGnhBvPrej6o3h8zD5
383	payment	115	115	115	382	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju583vCkyLWRDEC6McUDPc8n2BiYWrqpqUmjSrrjy5ztePRh5pD
384	payment	115	115	115	383	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZpvQ9BZvsTTGhxnNP3NwoVSYfrWdELB3WPbbg4mDwTG1yiBG2
385	payment	115	115	115	384	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjoJuBKnZvvDhWCPULzrNJnaz432ntpZH3m9Da49oyoiD6Jwuo
386	payment	115	115	115	385	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtk9ymKrCV2MKTtmP7BAXUx9ifkvw6TsWgwiLYmxY9ChqXRhKom
387	payment	115	115	115	386	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtcu46sohYppdRxZ991FfwX72iMUehKw9mU5RDbTFamK3U645b4
388	payment	115	115	115	387	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuointwTmEp7y2d6WNqdqsAQ7zcPSdtFvYmpXsu8a5M3rxXHi2E
389	payment	115	115	115	388	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfyHSpDrKUsEVV27ZNX3gDH2AVv8vz6ZMtPCnGVFtSEqPQWghy
390	payment	115	115	115	389	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzhAtBK7yQCNjr7rgWFnNuUAG4LyVyQKpaLTinabJocKKJjs8y
391	payment	115	115	115	390	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1feh8Ksgy7RyhKmUzHfEkhAWVKN1HHFuCkyyUy3fgr2HadQXL
399	payment	115	115	115	398	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYcV1WMxjbHLmSk6mpL1h9jkR81uax52LUDubcbq3ezBiW76rC
400	payment	115	115	115	399	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunE1wG7FAj3Hxdv6Pv6NVLhgrWt2Ee3eVmqvbRYtDqq3abpmT3
401	payment	115	115	115	400	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvNLoxzxBUGTSfAcwiTCWFsQ4KixGG981RjLpJFRVuEH8J2jBM9
402	payment	115	115	115	401	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkaLshzgPJGJjdA8ynjTYxuM1EhnrJ5kTbcjd1qNtuEfMuQE57
403	payment	115	115	115	402	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXjA5dUzgsgUnfDmzJQBMrSGnb6uDQHnuhtqmkCNVkAPDEn7pY
404	payment	115	115	115	403	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JueJ3rXP8rayjhy98TV4mxuzGxS6EqZ8LFkUPM8dxf8oV6224AG
405	payment	115	115	115	404	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQi43LSRXqpYYR3VCB9mL6ug74He38B8zQw9f77ogmzX3MDKz3
406	payment	115	115	115	405	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwWgKusSzK9ZpKhWofpMcQeKHQasWpxJCeZET28FXGQndBvDsP
407	payment	115	115	115	406	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutXeAQitnQgFEL9j575hA7Kq7g6nudkhpgPamgyszLnfzkYQ8d
408	payment	115	115	115	407	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2NHmiNXpXnih7vQQhbPBz8kaZzTz9bNXEXboG9HzPZRzSZ6HT
409	payment	115	115	115	408	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzZWP8eyRY2XkGiNuHaoQvpF6uqX8wwQoQSraYQKkQc2EEurpU
410	payment	115	115	115	409	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7jMYd4VwHGe5R4oQaQ3f1n7BoGRuPp8FDKyTZ4gqBD3efe1aa
411	payment	115	115	115	410	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutucpdMXtWMJVtMUiKusbN9YyEUYtSkJbAQEbcgiUKpjaPZRfT
412	payment	115	115	115	411	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JthGpCY9rM31H9e8AqLGmz29d9XcBeSefUhLtMemiJ34PCyZ7B7
413	payment	115	115	115	412	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvD17JxQCjcKNJWAEvwpC5rKKCPePtae48QXnfPuiPPH3YAvp5P
414	payment	115	115	115	413	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5gLNoDXY5xxUB7ADj3Dpz8qnthQbr2yrm75tvmgJRGe3eWubg
415	payment	115	115	115	414	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jum7JaPqp3wpE8bDjc2xXwG8qRST9jd4tgP5GMRK7zCBXohLje5
416	payment	115	115	115	415	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCAYiWJJKc8165tG4pmAGGPpLmNXXFbnekKU6GQRbcD1zD8KZu
417	payment	115	115	115	416	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwyCS822S2zcLPGg8vA1K4hKX83DN4ZsXRoasMKX5N742wVuPY
418	payment	115	115	115	417	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juvy5zFWpZRT7wUP53dVbzaJ7h1myzxjYTVLsbsXe2LVVFTcJwt
419	payment	115	115	115	418	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWbxZN9bGecNHN1QQCgsSZadUXa3YcUcVSgavqSNCZDeDVbxVy
420	payment	115	115	115	419	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuTFhzFGcPApbx8boiPoEpnGRQBU3FHPTdeXJCdPgzTojH6Aj7
421	payment	115	115	115	420	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3SwSD1SXwdKBv7vTKm1LPd8ibLkyRpiDp92Dq1JAW7B5t2R2P
433	payment	115	115	115	432	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtr1f6TsNUh3HE6FSG67UNpUArRTiAKW382sQtDta52RUe75dKx
434	payment	115	115	115	433	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupA7GVFXmudLQwywZAxdUsW1EWdoHmf6jcciGJyoZXK2sBiaw7
435	payment	115	115	115	434	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHAJNPDxtGsU1aDoaZrHTAVapBJL9Y8mWQPYHF1BRnY8t1qLWF
436	payment	115	115	115	435	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2LCoJfbfeoD2dhhMo4zRTjEC1BW9zBmMJGvYRRgRg78sWq533
437	payment	115	115	115	436	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6uK3ttZcrRpk1GchTFah3zFSE3ZDf5HUUCDuvFgDyiErcDdP1
438	payment	115	115	115	437	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHhMvA6teyezB6mvgRptxbxAanXGsaoNk8pMbr6nD4jvfVniAd
439	payment	115	115	115	438	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtt7aqiUHvChocxZJLtsBVy9y5AQRfjVEFuei7PPGpy5PTCFxe5
440	payment	115	115	115	439	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYdyFhrAHhPkBnV2HS6YMM2pQdxfq4RnfzQfUiSM6V9NRW3zGD
441	payment	115	115	115	440	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2KtByEpR5kZqkbcXoCsaY2UqU5t8JN2e7Hm3LNZ3TRDE6F8sc
442	payment	115	115	115	441	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusNAtvcw9tHjFk92ixR3RxbzJM7k96ikNPbiXWTv4agLumebeq
443	payment	115	115	115	442	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2PgUAJqsRxeUjy93y2XkJMD84YYzzDTSKUeMneKasuxst2iZC
444	payment	115	115	115	443	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmPgRzNKHyWormdDZM1UGFQogVnEK9ogUCBSAtaCWXPfpmBsDw
445	payment	115	115	115	444	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtwr7TpqUf6NwMLGuVT6tCK7dffN9c4uDsvczkSktMoWhtDvVzq
1252	payment	115	115	115	1251	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvphoQcYfq8yQ1dxw4N9ckLXhEdhi6LdnKEgt5By2rTCompbGo
1253	payment	115	115	115	1252	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWCixTvBysCf8sJpPqG6n9FmBrM4cSVNJVKa16mD8V7f4fYD2n
392	payment	115	115	115	391	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juh5UtF65XMoqd5DKHU4bxkWevsAbNsWtaFjjquEsxKBMZ6m9W1
393	payment	115	115	115	392	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jum2o41Qhwe18JU7YDC79owNSDC6ymCbPWgnauScDut4jckK52a
394	payment	115	115	115	393	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmKV9V5hnzkV8MCSpirNjNLPjNoqBzM1dFTShHccsUR1qFm9qV
395	payment	115	115	115	394	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMyDuHuApEWWjWpFjQufD6N5eu711829nbu7zU5yiBvJ46n1MH
396	payment	115	115	115	395	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkaQzPHGZgGP2ge5z2o8XnoSp4Fd39EcrxHtR7ZMZ8zisPTPcD
397	payment	115	115	115	396	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNBeue1zonvGddcTAdSaMeNjpKYCPgd3462DYdT7F4X8v74ovi
398	payment	115	115	115	397	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtf2aT81qWUqWsmNVaGo4bp6Vwapg8e3UykSubYjvgoxi18aeoa
422	payment	115	115	115	421	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzWZYqwcLp4o4JGNcTBRDjUpcPQx2adL5BkWUtZkVTL4Lz5Ga2
423	payment	115	115	115	422	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmXdKw9y6VTtPgQC1nDRmjcvvx6YkmsBaWM8g2DfiExCTJBRCH
424	payment	115	115	115	423	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuN7SMUX2MiZunwvoMweWfvacUwEFzkgxJT5Nst1YcEyfYq2w4j
425	payment	115	115	115	424	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvD7XTpwXh2E4EwwcDGq7neQA2Fc9CoT21yUbtyN9rEGjcveGGH
426	payment	115	115	115	425	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumLjFx9kJNdoWHFdNS3ng5ehBUDbZ2YshfQh3b7jdT4d16DfB2
427	payment	115	115	115	426	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRMNUKZWN5NtsAHf5hEUWRP6wQUYJ15KawRq9R6CXPCENeJCnm
428	payment	115	115	115	427	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmfBvevPNBp7XLr79fMqeSFeiifN8VC55QWZSQbAnBDFjThT2F
429	payment	115	115	115	428	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuvFyaqdF77NxdLZ1G1SPq4rYMcft4svviqAUoGP5X88NdoKfWZ
430	payment	115	115	115	429	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtm3u81FmsfejtbMKhujDtfSy2q55psEz94yVBmHCtJh3b8A2Co
431	payment	115	115	115	430	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutXLGEfcAV9Ktvz18HDdjMb83EHEufZZz54wGrwJ9qG3M9geT7
432	payment	115	115	115	431	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMdV5teNsjepWqh7LTrP5VYtQseYBuqja4E3naMkD9B1fgNqnP
446	payment	115	115	115	445	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLJLgWCB2pgx6BGpLJeM17e4HEgiEhBCNA7DNySZ6JHwwyMtPC
447	payment	115	115	115	446	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWncHjmCtM4K1e8LkiZD5xU21FsATx7Y5burQGT3qU6JsXvGpi
448	payment	115	115	115	447	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfEtq8e83M42a3yZpD31GS8iFaD2h5TZ3MNUmfCkXRyEiWMQBf
449	payment	115	115	115	448	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtpLZGFNP83NMHE2mHHR96QSh7MnpdoUKLSycuxHWEU5WixF8tT
450	payment	115	115	115	449	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiLFzbT3rZ1EeyS7w7LE4nzKAocuBZg8SWhjVkYtzCi8AwTqe3
451	payment	115	115	115	450	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusDmS8X6beJTvEwHEPG1nBmQ2NdPadsv1oEnWPwLzmBayWSYvB
452	payment	115	115	115	451	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juevu4Go16cL7Yjudzkk5qpTHMhh7RhRUSLm87hkM8VgVVHPpPq
453	payment	115	115	115	452	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNn6mAsZgw9GxVvM5To2JkzgAMsEz1NeZLYC4HeQt6ZpLp5tNQ
454	payment	115	115	115	453	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JummXBijESRbvtYAgXmd1YC1NfdoboMLCqUEBGXPDQxWNJw31Yh
455	payment	115	115	115	454	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXQPaoAsRf26TRNHBAT1T9ppoh9JZ4CcxPMCuX4zWp6GF8ppMY
456	payment	115	115	115	455	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuK4D14tAhW94JgvDmHkmLy3SM9EwitVP5DPEPYmcGAtQv3ExXU
457	payment	115	115	115	456	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2iAFANVGjgZPLMraZ17ru2nbPmzmLE4rjYHWLAxwaHbJyZDqa
458	payment	115	115	115	457	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jur29e9fhZmjZuxD5EHPfnTdHPo4q6o7d5JEewByFPxUw94gipp
459	payment	115	115	115	458	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPhrgbY7gXwvekDVcgaTGdobvnJmrZn4dQoo42kYhMJx9mDsWZ
460	payment	115	115	115	459	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7a6Bzs1yhYCfCMpopuU45NDrCFVCG1kN3JfYW2ecfcGDynVfz
461	payment	115	115	115	460	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtebAc8atwTawgvB2ooWYJJRy94wXAndxw16fpWYjLZJ4bUUEkJ
462	payment	115	115	115	461	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8hsXR85BYXdCmUsAzfefDmNquhsnhHPeiAv6Qmy2KFZ7VX1XM
463	payment	115	115	115	462	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuS1X1qxg9Y59WjSK9LLBrS1Bxqmi5PMkPiwSNjzYEePiBXuC5Q
464	payment	115	115	115	463	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXU7VyXHZzbbM5QAvNmcvfnqWv3QSPUE368dfkZbfqkYKn1Tg6
465	payment	115	115	115	464	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusEiXGQr2jNvzHQKaVAnKBTPHK7tQPFWhvGhhP8qZMDanbg95y
466	payment	115	115	115	465	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjLTmtt2edqFLeBFuowwn8PFt6xaqdfc4URaxBPGujYimX3MJM
467	payment	115	115	115	466	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtubHWsaFiv11sRyKszAtDfAQu3W6uFK66DYuLk7EWPv6k2ZiTf
468	payment	115	115	115	467	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsNLRrgFR9XtG98kmTN3TPjdiwKKwcgmxfiEYj9W8J3wUSVe95
469	payment	115	115	115	468	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYTEvwA1JS12UyJdNCBR2o75Ng3T7yufRvzVdTpD3hPumjn4GW
470	payment	115	115	115	469	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWE8r5w2A3hnEVwkdpMtCwVdpgPfAHoS7QqFsqNf5ZoUN5JfRw
471	payment	115	115	115	470	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLhWPr2UbYF14PgLnRPye52xaiz8hYJLPeoL2YA8Qw1aG2AoFb
472	payment	115	115	115	471	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttjNHU5mDAiRFPaVmCDL95c4DYdH4rAoinNJic5kqfRJLNmiRK
473	payment	115	115	115	472	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jua5jLjKfcAcXpaCKBsLndG5dx7LMY2LDxLuiXWBDMeao6n85Sx
474	payment	115	115	115	473	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutXX9mJV1d47eFmypGVR3b5JNsocbQ9G5eDUajKZB1qS7B1ykQ
475	payment	115	115	115	474	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLaK6NvxmS9dzgRp2PgFvZkQaEjRUYDdqDDcbc1FbV11zPkFDU
476	payment	115	115	115	475	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtj5FPe2w9KKA9sGbbPzgmrfDkoiBznSYcudoCGZ5gnodqqkfQv
477	payment	115	115	115	476	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAo3UXk5ZSQ1ZXLL756EAFnm4ZBr9RfuAPPat1fVQ43jxXbTfS
478	payment	115	115	115	477	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8WJ3DPkfnbYKzVYGghJDje4orMBrGDkkgmfbrzsHE8bmt5sVv
479	payment	115	115	115	478	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCKLXR27Y5mkGQAtsvX4vrjN2r6RHNzSoiKZvejMocmH4Kp5Vb
480	payment	115	115	115	479	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurRpJrTVoSv1WPiWnLds4FHy6pTXQasK8AD3UHbRbDWp9PQbjx
481	payment	115	115	115	480	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuasNxpJtAKWzeKMDYPLkUa3B5gvJ18WP6a7ZybCPmEdQG7zPsf
482	payment	115	115	115	481	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8YUWArpHV42z5GJwNHRoDrG8ms8E41iu5sv8NWBrQTt9gMXZg
483	payment	115	115	115	482	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMJ44cGNCgZJLadzA4JdEHzXXhTznq4SNPBQQWTXzb8MHAsx7g
484	payment	115	115	115	483	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCSrsgnUkQ6qQcVjKEceRURnscV3kGHFu869dxj8s8WHyXkf2V
485	payment	115	115	115	484	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JufTBCCjMJAniZN46jzA28ULinBYPxQNVNVDXSkc29WTA72MFLX
486	payment	115	115	115	485	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKW4eQzABA1xKAorEfZseKoAD2WYY16qSoP1a1hf2N8HfhPndj
487	payment	115	115	115	486	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNKBPc1EbWuxahaXuuTitX18FwGqtW9ezRfT8z3Eb8WYZWB1iV
488	payment	115	115	115	487	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoRJLEBkdkUvEgxgajaosJ5TzvMkaAXW6T7QFu2XTiyi5w3sAR
489	payment	115	115	115	488	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHFsqARBmj7Hhv8eqDcPgyLpGFurccdtrzLTzwiiLnTVunZQRL
490	payment	115	115	115	489	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfhMdJehjnaXn9fu2vJYaT4ZDJtqoNeH6fnoNobh8wKC2NFahm
491	payment	115	115	115	490	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1VSj9mbMDhfDD4sVYVLeTR5y4GHZxAuT8fiwCw81ya6D1bdQz
492	payment	115	115	115	491	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDNLwbxzs6sbqBfk6kfhErnywtUfiqfUp4ZbGf7uMdqK3kiZfH
493	payment	115	115	115	492	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuoXxArf2bqhSvwUBitHvn71T7LYBsUqvkz4vbQB9F8izNuNXAF
494	payment	115	115	115	493	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jud4iXv4KZbVF2P2bfvDPGwrjnVFHeP99MQ8TPy2bya5QAL3ALD
495	payment	115	115	115	494	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHSvMLytvovbswva4xwPFK2Q195zQLnbwAPXfUz123XXNGUt2U
496	payment	115	115	115	495	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juf2WPpn69UxsY1vQntvgewJtgrAYK4ErxYhL6t55329WEoXSUU
497	payment	115	115	115	496	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYgmUikRW4XPxVKqzqY3vBh7yBByoE9vLZxCgtB3nNwzdFoiZ6
498	payment	115	115	115	497	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcyqUnshXu5xi9Yih9mPJ6byDCqX2P1Z7SApkBFf7cpLQLM4sR
499	payment	115	115	115	498	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGnEFswHvkQ2T4wPEGCL2TqtWbiyn6eRNU37LE5fM7hR2i3dwU
500	payment	115	115	115	499	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttiycPG9Y9gvbXEjgMVao5L9tt4jE1hGfmss1pMJFx7DqbYQXb
501	payment	115	115	115	500	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBDGY97vD5Yfq82gTKsc4q9QMBwHw1EJ82H8MXLp8B57FHyh6e
502	payment	115	115	115	501	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5g8YJPJiaQMtrYPvrcVQ3totMdmSkzEJfQbh7iLHVCKkWXjzU
503	payment	115	115	115	502	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxuFTrn61qRWQ5g2jskBUsJuf5TAqJGeNmW19TFZDPXhTXYvDw
504	payment	115	115	115	503	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqrZCpWhRhgwVQLR7JyUDMoA59cyca9CkdpDvzRxVebgpHP68F
505	payment	115	115	115	504	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuboveE71yk6Rdyze1Sze6vEjXqkvXK7jX7xpniGvx4GrMyrEFo
506	payment	115	115	115	505	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9e2VgcdBjTkkReQqqguqtH1Vx4ecukgxSRy4tFn4JrSAvep8u
507	payment	115	115	115	506	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHBevsJQ4ixvHZULB9BEFKgHKFFrVvBhJq5zGA6x4gbk3ZhmWe
508	payment	115	115	115	507	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2P8oBuU3oLaLSZDeHh2agwWRLDWeCFu4cV4GbkuPiN78aioa7
509	payment	115	115	115	508	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdjbXphLdubP4otYG95VhwqnTknV9NGEaLd4WHLBsZYx2UnsXp
510	payment	115	115	115	509	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKPv53dqzteVCdeFUHC4oSWQtXysx1QfANMjDHLNxhoWzQEBsW
511	payment	115	115	115	510	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtb9SWm1HBzZype6tDpJgPzASSDDHivqy9LuH4pL2YHD8i5A4ri
512	payment	115	115	115	511	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjVjBCfvadtwejngECWKukpJg1RcMmXtkzFB3AuLE5qi3VYuPA
513	payment	115	115	115	512	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupQvamyVzFatVgCt1H8XWbMJE9Qi729y4CLdrppiJZxwEHiBjQ
514	payment	115	115	115	513	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMwNrXX6LZG9V2Ge8cdnRfJszbMjhGxPsbVGnMKNEsrKF5sV9G
515	payment	115	115	115	514	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNefffddyrW2VAM1s9r1atHX4mSHv3UohKAM2f3qc3vaPq5wEN
516	payment	115	115	115	515	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtx9zBpyrCoeNRaGvCzymEMhYkk83xs18eUcv1PEn4SVR2GtM4f
517	payment	115	115	115	516	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWNB1yzxHMNmsDQxGeUay9q3HX9Tq3Gu827TQyR9fTkzmwBvUd
518	payment	115	115	115	517	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jum8vQtithF7n8yinwtNZPPHRQ7ji48A3VoDKKcicZNYyk42KjR
519	payment	115	115	115	518	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPe2p2iHcR2HYQmuh79RpJCKf3rJVvN2dWMDDLspQT1cAzLgdZ
520	payment	115	115	115	519	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunbtFCaXT5TWHQbHFjEipATs56dtwrjwbo2VeKfV7UiYzWBxcD
521	payment	115	115	115	520	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEqDXBLzeiULnfXWFkk3bySHKDfA5QAa3du9JUTQ7Z3SjaJ8MN
522	payment	115	115	115	521	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDn5AxFR5w5er6eaccCqrv3BgGTinTZGTf79Ec5SBYUgCWKhXR
523	payment	115	115	115	522	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKkVxhTZmikNahzjFzbzk5pzieakaHoNJgjxGnEgUJ8NUooCoL
524	payment	115	115	115	523	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtshvZYBNZsA5TrGvJCX3R8hybHYJXzuuu2Dd2Xqkm7BgvUbs6N
525	payment	115	115	115	524	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjfUrWKEnjURHXJAH6pBEJ6B9RzgpgHHZUyBu8LZJ1h9J6vgfa
526	payment	115	115	115	525	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzYBjZi3k2xuRFyeYAfmkkrSbrULF2C75W8t1bcWLtTsW9qBzA
527	payment	115	115	115	526	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJTkJf8B6X3n6daHbjeTo3ZNmgwc7fURb1qq4WbjkAVKTt8SVb
528	payment	115	115	115	527	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1uLVUD7XtwZ82XgrYkvJ6MoqehnttdpfZ1kHDGTEhEGDCfzSt
1254	payment	115	115	115	1253	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnoVefuHYRuyXnYD2E3xnkyCcLjC61o7HEvDJrbxVjKFEirNCv
1255	payment	115	115	115	1254	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juu56VLXay5DfFWd7v9msPnSqHmFhTM6aKYrfQxF48uz4pXUmqJ
1256	payment	115	115	115	1255	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvNbsXFEnXtuCzwM3ZFRH4p44dCs22vok6fmhoeFJaPv99tiiZb
1257	payment	115	115	115	1256	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnKgnqJnRER7Xmvua1wq7sJFRWtAGCcwGsCqE7R6euptaZ5ctu
1258	payment	115	115	115	1257	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5xnxLAJAJwd8D4Hu3ZkP6XeqhXYRATAC3nusZBTdGfWtbxmHK
1259	payment	115	115	115	1258	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAve5FERmKBcGLZwgWQjpiKbEc8E2xpy45sgwUAup73b1NWwpp
1260	payment	115	115	115	1259	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtiDLG3ZpVuiTB7j7DPQUbWD98jg8uwBNfSmfKsV5Gx9nta63fc
1261	payment	115	115	115	1260	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtp32JDHWkF29n6NnnaYfmbwZhr4aREokFy8qq6nw5Be8G7pmWL
1262	payment	115	115	115	1261	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuD5whqWhGYwcRe8gBUChgUedqsdjLxU1DBPTmUzDkGevewta7Q
1287	payment	115	115	115	1286	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju17NeUQxhUSEkboGLNmycjfCXnzkrsesnDsyGX9Pz3VsjRGAVG
1288	payment	115	115	115	1287	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtyNZtzZmtwV9wkAhTEfNtKd9e5vSjsE2RazS4feumzntKL2E3L
1289	payment	115	115	115	1288	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTt4ajvo5RkdgD1GbvE5jmXGtxxzAa8w9sREYxKUzhNyVTfkuW
1290	payment	115	115	115	1289	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDrKwiiZ6YGYscUmprHmrdbDnKktqb3VDZKDgBudTMBegfjKZx
1291	payment	115	115	115	1290	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4R6aKfG8qiK6NFHBvqMxtGWq3HA5TyyPtM3P5BchHq8UczyWL
1292	payment	115	115	115	1291	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju11vZLjbqwYtUHTSTpk6a7r5fr9XCW6sH93rkozKpKKkqbaeA7
1293	payment	115	115	115	1292	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxF3ZT72s1Km9x8zdYqkBydy2tsZYXp2zyfVMBLsNekcj4fE4q
1294	payment	115	115	115	1293	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYcM97gzjskf9rdCTgJUZJyDbCXgVnc2w4fuByGHbsLAtmyqst
1295	payment	115	115	115	1294	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoHDS79yaZ9Ap4c3piUER1Wt7n7yMRA9n1jvdk7iRnnKB3jKVw
1296	payment	115	115	115	1295	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiXSiQpPsqThYsjZyJoXz5zJahy6TXuPWAqe3PKejy7QZJpz33
1297	payment	115	115	115	1296	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcbPinLVYSrqtqsVAnCRSa3CXm86YuwmcuSsraAATLgN4XngaY
1298	payment	115	115	115	1297	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvtJcVC687dgszDyyDenfouNbuf1JGFJGW49TnD3ELXHffHpHn
1299	payment	115	115	115	1298	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juegu62Vdq2KFFcX9iUCqGGxMQeMSzzpEmuwj6hKDe5aJNhvZzc
529	payment	115	115	115	528	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudNK6iNiWwVjUWRdZEch3EkkSY3St3n4qRJ5YDggkV5JfPHJ3M
530	payment	115	115	115	529	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6gZ8AojT5jxRP7WBFGQY2czAAKQEK3fmogV3ngwVyX4juQ4ky
531	payment	115	115	115	530	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuziXfGu37bMhtf3BxagKxXhCpdPUVSbcNpW2eYYFoVdWSzwaj1
532	payment	115	115	115	531	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDMhiAqiVQmN8maYy5bFnHmaFcCqLUKQvKJEuPZFG8teZHADGr
533	payment	115	115	115	532	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juwwzwb1nD9e2KZg5mD3tcuH525gQ9KRz9ENCXR6xzHwif8vEMB
534	payment	115	115	115	533	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLM5Tinb1bFhDqai6pttfVggK1JVZbfmrTSWgQzFGEDEKWPs2o
535	payment	115	115	115	534	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDMtccbraep5xbfJYhVmnFVLDfHJowAv7nZZhvbVHZYrhzUbxx
536	payment	115	115	115	535	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudNZLiXFcp5WwwowjjiU53Av3uJziqeXDwi5kEVr6ieh6EwWwK
537	payment	115	115	115	536	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRgNzwq6XGesSQ9XX4NFGPuuVbCDSABYhPL6LySsSkfHrZHXCE
538	payment	115	115	115	537	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGRvYc1avKHpDnsAVySLnS3AN8WeB7aYkCDRmpS1yGz2X2MQw8
539	payment	115	115	115	538	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubMxsEFUw1nnK6RSeSCALJtoDbgXY2vJr2XZS1yqrEdz4w3THM
540	payment	115	115	115	539	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHGjsHQxifnqdhBPTRJ982qsKxGipAJmZjULD5k92c3zf6Shob
541	payment	115	115	115	540	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6egQ8Qje5kgZeksWhPdMVzyzG3vKDSU885nWyBJPE1oR8xnyf
542	payment	115	115	115	541	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmnxpkoiSkCBbwv4NmrMTaJoG9yAghFaASAodvcojxFNDXGfPN
543	payment	115	115	115	542	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxTjHK8J7CYsdmmHjvCqhgzDzTMcQyCrUeKeUgMaAp1xuwGvAk
544	payment	115	115	115	543	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtpgzKSzr8o2hj1rWiP7aqmj1nyzEo3TGq3hHtuzRFWtWPFPKbE
545	payment	115	115	115	544	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYSQmwDUeJZErERs8BUdAPCEkf5ng1HgYEyikUPMidMpRcW5N8
546	payment	115	115	115	545	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTsrEAAiC86ANLq23USzXwnGWXRRaGrkkkRwPeV9Pc6tafcUQi
547	payment	115	115	115	546	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juo7U2izP1TwhQwwNYGdzXLfJmt95iaAzH7rzYq1tQT3nG8xdmd
548	payment	115	115	115	547	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuqjybLW4QGt5Y3AZKAsn8fitKkYphgytDNiafmzZuqa58pjdS
549	payment	115	115	115	548	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuM4X5ZiCoZdM6QXVNhhydXUhASPe47yPeonLQCmJjUpvX3Zxs
550	payment	115	115	115	549	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMUmtXxZe2dKgQfb1zGLwkcHzDmf2tHCex9AdG37vKS6kL8KcT
551	payment	115	115	115	550	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jurh5VYipMQduchAVtBxXTLoR3bC3DpLsN49qSszhJtQovYqKKp
552	payment	115	115	115	551	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJLn99P2TspeRKdWTJFu5FxNBsa8rG4h3VysXmqPM5HdrGAeNP
553	payment	115	115	115	552	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuwmFYKuRUKshYyk8X71HmoVrzsRr9sk1YQR2zBzNAE8G1aNE4
554	payment	115	115	115	553	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6DpK997S3y3hG9vnJZy3R7JE7XKMtTEUT4o5PBZXAmGZk6TiE
555	payment	115	115	115	554	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJEp17kbrHckFomQdPgQDswnJNimdZVLzyFXdvjgZr3zzenqSr
556	payment	115	115	115	555	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5djxP8cgDPDKSNj5QKnBgQbVFHYBRmhGp2yLjZy61KVvwxdXW
557	payment	115	115	115	556	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGE9N5GjNxH1rjXYNhxSaLRWwXqGqYBpjh9FgVMLYPnFRQsnGH
558	payment	115	115	115	557	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuA6UVjSmqP24xoyz4DHB9b8h2m56TEF9uGzTNj4jRwnhvAR1oA
559	payment	115	115	115	558	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9io1Jw6M8jCyzvYnYNkuQ2Xr1eFp3MdCy3QAhukzkaZ6oBFNa
560	payment	115	115	115	559	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDp8uyKPRX1kTMPk59v64tBGzQKh48WaaGVZAnp3Kv3UZQkRmm
561	payment	115	115	115	560	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juuzb43k8KcuGbG5z5bT5o8hFSHG521F2FponfHspQHHHAci61c
562	payment	115	115	115	561	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtiJLKR7KYXSVAocxpT4crjCV7U5tEtTPB3ABCUgcAg1tcWgvfg
563	payment	115	115	115	562	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYvbxsfWLAwDJFAnDiHQVtb6tBsP7GrX2h5hvgY9CXD42vtzso
564	payment	115	115	115	563	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVPQ236N6ta4YixK5pek2QzPAzf9bpBAMWuLgVLLcWP9Cv29Un
565	payment	115	115	115	564	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juifj3Q2iZLiYtSTdtdVkaMTgFUQouLhrN7Y6D4gx7h3XSyk7CU
566	payment	115	115	115	565	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQqFMyE8PaYYH4E3mnTsRZgC2MsqfneiYGUmYjz4RnhWbbgXYL
567	payment	115	115	115	566	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoTG6cepqESeFFi6ZrN9of9HsjmoUga5y23SuYsavZtcCBqHyf
568	payment	115	115	115	567	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8kWjrpYQxWixnxVoYUce4pBXtiz7YFJPp8ENgUXy5XkepLuzR
569	payment	115	115	115	568	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2tQEPSnyybh136XXcTSEZ8tWD9LyukdLBbWo83a6f5WEmGA46
570	payment	115	115	115	569	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRjBjb2x9rqrbrnERpxr2GmivGsejENg3YCg2hphWu4DLQ4WaL
571	payment	115	115	115	570	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnWKdDLeicYkq97eLnJfvzQTqnG48KMEMsyEZ33nVWNVeLkfXX
572	payment	115	115	115	571	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZdy9qEcgPHGhF8WowYzW4mat22if6ou2iXR419cijgb6AhQUN
573	payment	115	115	115	572	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGRjmoUiifeSEKQw8bn7Y6qbLt9hxGJUGzjnv8yWiMopgrXFqZ
574	payment	115	115	115	573	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXCmFMdvrTiEv5c6LC8D6qazAbFK62hyi5hSmNLPeeNHRRUdge
575	payment	115	115	115	574	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSjZR7k1z9YeLLy77wo8jDtvuVirCifHPischKn6U4xwajK1B9
576	payment	115	115	115	575	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtz4gLKWjocV8tcjwDcdDXMyUSJtv1a9RdF1exxfLvkbdNZrmit
577	payment	115	115	115	576	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuaBNidTxnsBzbp6UwEtUhqbfF8PaMmCqoMU39BUbwaNdFJvL1v
578	payment	115	115	115	577	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSKm7iPnx1T8zYagrNgvLHqNyoMvCvs8XT15jnPrC5zK8AQ4KZ
579	payment	115	115	115	578	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunRvwxwfCmXjY2KraSYXUy9TknR2AobQCaPqkqaRiZ9iLqGAQW
580	payment	115	115	115	579	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZtvuPADprdvZMbgLSw9WVmrCm2bvLji7Yk57cQyCrtn7dgaHx
581	payment	115	115	115	580	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvNbx3jHWSFsg4FADz4gNchdrgqDRgD4VDY5ixbgx7sZc4zFoW3
582	payment	115	115	115	581	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwkMEY9S2a4vib3kTY41AuMCk3bx96fZcAs22MR8ayGtAZ17fo
583	payment	115	115	115	582	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdyPQCzX7BgmpKBVYpSyV23ZbbfX5KUpuvBbqKTGHUDB8LuVMu
584	payment	115	115	115	583	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubYGBXQE1x9UXBrQftH7x2U31oHKbH4hEaKDTuNyaj3zyDbR7G
585	payment	115	115	115	584	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLH6cM41wTNzp9ZG77jENi1wXGMnN9F87fwW6JxeZGUvR8xQEw
586	payment	115	115	115	585	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiFjx5iyMytwJNvko8UtLuJawhhkf26Snd4JUswE5qunG6qcdX
587	payment	115	115	115	586	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVDtJVz7kFESTPTXdTeexTnoRMj4c8aEYatatjMCMqrc2Xbs9c
588	payment	115	115	115	587	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKVE3uSp5uzXGKRqgqy2aAwfJXqTLQxQQo7YRr8JS266jLJYft
589	payment	115	115	115	588	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujFVHk6CYWaMTMHD15o4vzHupBEHcfGQUwz39j6aUfkW3VkVT7
590	payment	115	115	115	589	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4M8pKwhYZmSPeV7UUuUC45SpGms6smDkt847keoPM1x8fzxRa
591	payment	115	115	115	590	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPEgSbjAaFXgwnktYyGm5ckuoAMDXYQYypbxiw8ud4wp9qFexH
592	payment	115	115	115	591	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqdfXkbUNkHYjLWFHAFovGty7GvG2f5EnMHHco38bFVWHzuh4a
593	payment	115	115	115	592	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLbsKievzFmB1wpXbCdPSouhWUYVqWm9QM2UUuLxT2k3p4XdEn
594	payment	115	115	115	593	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtgLCLXhhjDDoFZPzWFSTuMjmcWvisHZaXUxtsvfFWxo2ianNQQ
595	payment	115	115	115	594	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHBUCLHHxw4DfMKanQ5D2eN5XnCsaCATTwFRHvxhsjmzaa4mD1
596	payment	115	115	115	595	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLhjezsWB9cPbhGt9x58XQApKzcsqM2BwkPpRUvMoMYyQm8nPu
597	payment	115	115	115	596	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEW7qXMqQaSotmuH84Qn3HE7kNNteKhhDrLM9tNmoio7SBmF3T
598	payment	115	115	115	597	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtef3k67SjhgJUmSU19eWEj6YRTMwBWyp3jSGtcpeVhJx6sWZ9b
599	payment	115	115	115	598	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsyHT8wgjgAoUq9n7fkX1ZXNVno7gMmigLBQeafULr1GpVVMMc
600	payment	115	115	115	599	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUJAbjHhg3cR8c2P7LqxMpMjo8j48EVD7CSEQeHeMhhxPo7aCg
601	payment	115	115	115	600	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juby7U17AgnpEEqTiZRe8zidiW8C3KT4yX95Gu7N6ow4mhaDW1n
602	payment	115	115	115	601	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPtjYHxdyFtw34EiMnocncuFpvohxVrysPvo6AG7aSdfWjX5am
603	payment	115	115	115	602	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTdUHvDGM1yeuYKPymfnii51RoXjGtvexk3V5XHfgpUWPgV2cM
604	payment	115	115	115	603	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtujm581enNYmsXNYghyiTfy7jtvkS3e6hmaAMqhiLBuQNyh7FN
605	payment	115	115	115	604	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juf1H958KRtt5zuEDhQib1R4oH71wvneGstvqt78KxmKzjs8DQU
606	payment	115	115	115	605	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtqrTKcs2a3TpfGnEm74GgJNqiHpiEswkZKagFRrWCuvC417SJq
607	payment	115	115	115	606	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9UzuUj3SM9Hs2m2MwRr1EN3186yeWyHSpg3VWraPXnBsn3Evj
608	payment	115	115	115	607	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjUycLd5AK9byDQopKuh7SQYvfyMXmTrKdKjiJGMmno8bpYSxj
609	payment	115	115	115	608	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtaGKP8k7F7Ge67TSEy311ch548hRUjPjTs9yKoyAw3gagMUvfK
610	payment	115	115	115	609	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvA4vf5ii73Mat7KXUoKKeTTQAdypV5in2Sx4SMPbdkbsDyT8it
611	payment	115	115	115	610	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcmmH2raDEt1ohFdyssJkn7jjZq21EfZzagWjPBf5xxBjnYmx6
612	payment	115	115	115	611	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLVoB6Rrv4CZYknPvPr6UiyyesCVpkiYjYTC7rQrj14Pa1UrZB
625	payment	115	115	115	624	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHaXWuwTYrDY9G9bqLnHFg8EbQxeQ4deTNYLNYyQFW8NcJYZW4
626	payment	115	115	115	625	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jurhgzbz9D2kX4QDhVSWFT6caP5LJX21ZPYMPExPVgxSMpNRmU5
627	payment	115	115	115	626	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujYA1PtJfbgjqXF1c8ToFUED5WKM22CKprP1ZCWmJXd1TvEVUR
628	payment	115	115	115	627	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8ao44TLbYoc9RYqxu4Z48MkqfSo84MBWma7gqLNkSTceBE1wz
629	payment	115	115	115	628	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuV1SnZFUDvWcW26yhPhsG3fiiHL2NkTF7aCCfPtNh5T7WgAGto
630	payment	115	115	115	629	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFiqxYZGDHVCujbPzy8GKHbCx6RTP31xmCVN183ygLnDd9RrjY
631	payment	115	115	115	630	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDDAVhvWMKXNtPBgS5CSQAdANWK6GRdSG9wfBLQQtcdeWqXXed
632	payment	115	115	115	631	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJEmdFpcCtk6xGt2a3XvyrPgoJbk9igpisgGNRXXufzmHAi5SX
633	payment	115	115	115	632	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jun1WB6Q6cmViSBKup7DveWbHaTntvT8w1a3daKYxeNMCWSYFcs
634	payment	115	115	115	633	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJwt8cLv5v9jwajtLSRy7NeKCGms2r4Ph86kM8stUFbfdkFbxv
635	payment	115	115	115	634	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1GsviRRLCNU7gPL1MH45BAu7FS3eEP3az6oYUFwwjWmStsQ1P
636	payment	115	115	115	635	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAqbDBgDvngn4Chp568BgpNbBcgHQ3xGNLmXdEPTBU85pj1UaG
1263	payment	115	115	115	1262	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtd1wPN2eSo6N1bQGVnrzRJZ6uuzptodzQMjDKiurr7snVNBdAa
1264	payment	115	115	115	1263	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGXEAHSrtvHnAm6uDiJs28w1Xxp1hKYYRN63JkYqA2bejaNb55
1265	payment	115	115	115	1264	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9QKp3abFCELfnyDiSHSTR46b6qsxycFHzgbkWR1h3aMhBfVRp
1266	payment	115	115	115	1265	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuvsdxK2uuT6JBByU6tS1bPn6k1Zw6p7qBR2s3cY8jXzMDrmBbX
1267	payment	115	115	115	1266	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXQWfSHjdwUrhaEcNh8myD5ruy6KF3YYNu9ADW7jHguYkJfYNh
1268	payment	115	115	115	1267	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxEBZ84gH5HWSG32RjCsHmddNuv6iXaz1W5PBNmHNyXp8G6scy
1269	payment	115	115	115	1268	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYPsh4BtPwgF6WQzJmqMmwjLdcMzEzVzQG6ogCzbtzxbfo8A3s
1270	payment	115	115	115	1269	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JthMv7L39pUbkjCpbwwXjzBFXFsbkKWd7tJQKQ8KJrRtEGWhDGg
1271	payment	115	115	115	1270	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3KtK65ob8ZjEzRovkcTEaJvRyUDxZ5HGKEv39TZjtAwvQK5Nr
1272	payment	115	115	115	1271	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZJG5yHsp7H2durL4C1QGbtRnXm81HHyPQcKEpaMebmXQbrm36
1273	payment	115	115	115	1272	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtrWrY4DKqUeBRxYJjb2u9SYbtFhBkMJwbkWvnc9DTrdTDiAv8f
1274	payment	115	115	115	1273	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZEtQ3JPgN7UbcRhodYoXJ3zXGU7oZQXswrJU6kv8sB62o6Gcp
1275	payment	115	115	115	1274	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJtUVm2jj4fJpdcNCqnE3QdRCpQDQFrgKHPCp9pAaTq7uVHeYu
1276	payment	115	115	115	1275	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvB1pfMmDgabZ8vcxqTjeaempP4kPbrU6qzy5HrQSx6LGQWcMyK
1277	payment	115	115	115	1276	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtViiso9TT3DL5MiMkx8rmHnqMWU6vSUs2gNZFyh4TmBZfht2p2
1278	payment	115	115	115	1277	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtwf6V8yP6BK2FaeH8qDxXBc9WiKTY6BiGdYHFcEic66LNRt47m
1279	payment	115	115	115	1278	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWtuEUZhMKqeVwRJjjCUTFYcQBxpBK27g9Jg5TN3qp6sQ58CsJ
1280	payment	115	115	115	1279	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQBgAYxgzVoVw4ESJb48zrVTSAjhbBFT4WsZkfqJDhsvHwqjTs
1281	payment	115	115	115	1280	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunXv2QeXFGNXcgfyYSwAzrimBvPkwAGDVPWDq7vPRFry8E8kbA
1282	payment	115	115	115	1281	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujKevgGuK7owMPRQG9cJgYdFRRfMFb4ZEvfwTGDKjj7ATBn7e7
1283	payment	115	115	115	1282	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juj7fRurYU2cXJMr3RzsC6Ezs9kGuo6sJJMQUcNGFvkeiTHhpXQ
1284	payment	115	115	115	1283	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtehoURP1XXS4Pcdp4UZM1DjupGcs3tBySm3EVG4GdsSpd2kRCb
1285	payment	115	115	115	1284	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDPQovTJ5WKMLii3CeVNL5apRFSNNjzpqz1eMSuhqCF2knJ1D8
1286	payment	115	115	115	1285	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7UwXNREcYfMdnURCuYGbfSy6c4838gNzsTbv4CKP2giteFgwL
1357	payment	115	115	115	1356	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5yosZShRVEqbj6QeWeKPTrNo44VVU9TPgh8sti3TKu4pa3MHt
1358	payment	115	115	115	1357	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfmLf1DmoAHVmfuHKo8j3ySikCXSwyT9ndf1kn5iuzUWjuCwwj
1359	payment	115	115	115	1358	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtaoFQSgJmKseojbHEqMuRwqipQ2PLaQeTZ5SeT5kCgkfKNoSTZ
613	payment	115	115	115	612	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4RdEm1L3ReGQwLpMaBYSagrYTtgtDSKnUbbaCRxBFc1cp4RM5
614	payment	115	115	115	613	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusnAZ3s7CiKqjHij3v341wWnTumkzvHFottMuGvyoGi2gApHsA
615	payment	115	115	115	614	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunJCqQKMxuKWwALoxxeAWwWnX5trhijzM9JBthu81WzEDxAum7
616	payment	115	115	115	615	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoyGzGcrbhQ6RWcvT45TU8w1hcrZTN7VPVQFUUc11BSJiGtU7E
617	payment	115	115	115	616	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLh2FGFFZRZ7h5pHFJUmSq2vdLUQuQkfmdPc8e6NNSzRykNnAB
618	payment	115	115	115	617	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucQaP8Zn8jNbUSHAYCjVSbLVRqqvRSwWCBYsz5p3LkxWmJP3ix
619	payment	115	115	115	618	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttENXpXqA1zYbzRJnXLCFtypq5aLizY2x81qw3CmJyoXonfp8p
620	payment	115	115	115	619	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWbvE842vABX1nyymSAscurV4T5tmxJZ5bk61JBsz3xu9sLZyF
621	payment	115	115	115	620	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteYW4o3te3e8QHTjEzw5S39fozqoTRXz4tTcytyVEGFnk2vC6o
622	payment	115	115	115	621	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKfXeDv6FFxoAXPqHmkQxaVDRgui8MxxxwSeGbXM2MabEmmwfv
623	payment	115	115	115	622	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju34AUhZ3uuje4E5ksBzcvjeXDk4qrKzwnu3RwS7hw11mNeDufw
624	payment	115	115	115	623	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvB1YpxtCLf7WcwUojLdxPL7gau8sA6DPLtr3vBN5EpfnyfEpYE
637	payment	115	115	115	636	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxYZHyihx5X8y8Asft3wzCZWUgVbTkdFZnH8crJMbq5SHQbBnT
638	payment	115	115	115	637	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jucw4TBmpscCpbTWT4JL7YJSaNkLy8xLNWXuiZ33Zg9x6JzVnPX
639	payment	115	115	115	638	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJiokURVHAAfC671cRKeSCcya5xfxrPp99yVoDi9MsGFawWzSE
640	payment	115	115	115	639	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JueWuoWGaw6Gbqwau5oJbrFvWRCej6mFjX3UkMNbfMaJZybcUZH
641	payment	115	115	115	640	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtooZvHDMJmgBQmxgX72whZkRHhUaTi7StqhnsdrAEeH5Ko5Ja7
642	payment	115	115	115	641	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtn3ue821YyTqP7867LzdLtB4VSLtxzHDZdtXTRSs6ixSjuGSES
643	payment	115	115	115	642	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuP63R5eSgaq9AXq6jMaRK46aZ7ugy5z5teBgwiqgbKUrRDk6gS
644	payment	115	115	115	643	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFLArvwbvrLjiFmtKLz4AereuFsABhPkGqa1JzkRT8KffENJkg
645	payment	115	115	115	644	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKp6aJxsEPdmjaR5724iMuFpUNq6L7CU9C9WhMFRPjaTUTsGes
646	payment	115	115	115	645	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juxm2AWxZTnuwvLc4kC4GYadTCmZUxjkoS6zrTnaToJHHTm2PHc
647	payment	115	115	115	646	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteBTDFabAdyzQ7YC3mFc4mdyobBpHrCeZtjmeTUxbPPMamH6uf
648	payment	115	115	115	647	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju19zp5EMfDYe67euQrHQJgZwj3QRuaeckrT4hRpRXhzqsA74GW
649	payment	115	115	115	648	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JthczQ6LSts9a71KAzFuJyqQgUxPvRXuDg9as9JYnvnxCeZwHAt
650	payment	115	115	115	649	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudfFa8BqpA4KhfdGN7QadQ5ivnWdweGsM8Gu3LL5wxqYiJamqT
651	payment	115	115	115	650	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCsxzxULNNq2LvKunxVfhS2qFY1Kf8i1dY6Ye6e4eQCx5K6NDh
652	payment	115	115	115	651	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJTia57A3jiFPeKZ3bNrkcz9NYokyUzRJE9kxAkRStRjdSCurD
653	payment	115	115	115	652	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCMdRdcPNfCCjQxrFZZT4onRWLWfVuEKkdUP95wb78oVst2du9
654	payment	115	115	115	653	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttvWbcGfeQDHQTeaM8RHg9usM8QrJAWPbCidnYefNjiqynfkTL
655	payment	115	115	115	654	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtiYBbJwiGboSottqcRYTuzzWf8vg5wrbj8trNqGyzcQkAHwrTo
656	payment	115	115	115	655	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMa6JKnhnXPZHo9RHCncFAW8qWwqZmhAo1qg39qZj1JSqv6Ynt
657	payment	115	115	115	656	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jurjcmx5jc4aBuL35vp5CMY8rKUtNnHhtqQDVA3sNgpGN8Pnk3j
658	payment	115	115	115	657	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQ5D1qbnLWzi7wFMhQty4QfKJBYLPM8P4oFRv852hxCTGcMFj3
659	payment	115	115	115	658	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuodyhXpeyJ6fMgca9gG5ZmUYy7G5HSCPf8K7Z2u8GT4TJtNhw8
660	payment	115	115	115	659	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXnYjuj35FkbY2pshvLru1PTw5jWct8C3BNh7C8oKjVo5XU8L8
661	payment	115	115	115	660	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumRVRvA7NdjXv6jBtQd1cMZ6URbwCmjWiWYcL8V3sbWx7zXNn4
662	payment	115	115	115	661	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHNLpDAb94fTCnmzzKjyf4STxR667s9vBtQVToxC7fT4vmEwSq
663	payment	115	115	115	662	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBUPuQR7PkkcpVjPWnKCcNMqmVY7jQ8V67pGKp2TD3rAzEck5w
664	payment	115	115	115	663	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmfeNns1fQFCfG3TZtiGgmHbG7243xBqhNhY8QcBCXpnLHCbsG
665	payment	115	115	115	664	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvExXAuB2Ljcme2pe8qshiAvqyN7dLkcoQNxzYZjqcbJSZuz2My
666	payment	115	115	115	665	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuG8JapWFWrPdcSMLBRVmRu5hbeQXxz7cHcMNNLKFSBVtkxm8gY
667	payment	115	115	115	666	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juafh1ivhdzmWicS7YexLqghyDq3L7ijrgRUXP9W9H7RKghhLct
668	payment	115	115	115	667	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWon4R2Rq9R1qR5NMChDWNeafjfzHFgKq1z4osM8Ug6XFj1LLw
669	payment	115	115	115	668	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juo4AD9aGcdnBozfx1HKGaJsZZ8GWfAmRhNqXTshBGvxB7xTE3S
670	payment	115	115	115	669	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBgqMwkHEREQtLF5BdczEFV339KxmHbJgRf5AC8P6am2AcwCu6
671	payment	115	115	115	670	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugV2HkY1GkrEv1kQ5gA5UzkPXvxrYocrUHswbEyixYxNMoJFXW
672	payment	115	115	115	671	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8yAn5fc417RVe5iNgFsGERuWvLgSPFw13FzAyMUihc4ssr7fh
673	payment	115	115	115	672	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPg82zKMwqPBhjWLXgRhdHGYpXSycXgmMk5ag3af8dzgBzu4nn
674	payment	115	115	115	673	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7WxbirWkGhQCUPctQZFcPnLf5bVs3uhMEZENCsPfQxzzzPBiQ
675	payment	115	115	115	674	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtur1199E2ySLSy2frqg66cucUjE9uhj818QHWWgAsXt25HWcVV
676	payment	115	115	115	675	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtz7ohA6oPmxevb9NYtZadtA25yTLwdMMRDQhLyogs3vfDPwyPS
677	payment	115	115	115	676	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvQy9LdLL8zzdVikgQEhhypAfcjVQ6GQJv2EdtttrkuwtsHTGo
678	payment	115	115	115	677	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvXHDm9cRcutEWsL1G8EG39UiEP5VdWpY2hyBbWMu6dqJ1Cy1g
679	payment	115	115	115	678	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtaERsxTDqY6MdoVfxB2fPAFvwaQj4SKNMkuJZXZ56GJT6uhfQK
680	payment	115	115	115	679	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwaY67s6DRZHvYBCew6JVv9sH7SdayVuzcRbjdSrZKJ666SUK7
681	payment	115	115	115	680	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9RZ5k5UbiVmySgYHVNQpYTsJoSiF2hj5soKQoG7UmwpPP4T7K
682	payment	115	115	115	681	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZt6oYHPdzSgvCNYoFR1SfujJiuahF1fLYx9a1Hv3eYz7BSm5i
683	payment	115	115	115	682	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPHNwH5u6NGwWWiYCSBZp47HSbFmSitAhTaGqarXsxmHhafc4C
684	payment	115	115	115	683	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jus9oH1zuLTKnoXMgVQvGWVL8zSHD2tvatHYTSGDBx7GKQ76RtM
685	payment	115	115	115	684	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZ1EGR9cpXvBEofBqx26M3t9oq33sPMEDWBMCDXB1T4iUQtnTA
686	payment	115	115	115	685	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvDRHYpvG9u4zwQEo1nx4EdVxW37kgbDGLMmF7ELGmRpNtzbXM
687	payment	115	115	115	686	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVQaJCy6pkxEBiBHHXxPUBqKA3swgty51o31xYUEiMWHMMEFa4
688	payment	115	115	115	687	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFTyqoALZXBfUBqVvQr8CJXjwHRBb66B7guPYtfhDtgiEAfYTG
689	payment	115	115	115	688	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucWGVRoRYAjsYZ6WXY1A25AMASATRLTe9De4D8Y2wFD8T5YvDa
690	payment	115	115	115	689	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLt4V4pBgTYCHz2YBSZJBdDrRf33dczi9L8zqgGFm8qK4e39MZ
691	payment	115	115	115	690	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2P5KLdEqkiZ7XJH6FuHBHmNQhpaUaYNhs7uc2HNTAoyjkbCJd
692	payment	115	115	115	691	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtbxSHsF69Rbg38BbMRg7ULnzxDNHbnnwWt6mBBjum2kS1WQNRB
693	payment	115	115	115	692	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAW7KT6syhXG7Kywt5Bmzq4CMLLjLsUMcerC9z4n9Xu4GLFmFo
694	payment	115	115	115	693	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtd5TcaMa2XqTESsPn76ugNK66GnUFajLBFVBjYGd3yYQVL7ZjW
695	payment	115	115	115	694	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6DWf7hXLsoteJuJWG4AjViTuNDi88VWcf3cq5oVyDwQc45o3Y
696	payment	115	115	115	695	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLNZq15ExKqnGdcFQY8D7UFmTmppSUcuaZvbFvsseY8Lmc52CZ
697	payment	115	115	115	696	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7eQSZ7oXmkJ891JNBj2NGJDMgjBBnYCsTi4imxHryMHbCKJyR
698	payment	115	115	115	697	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3H9DAeDWJUcqdqfJAhv1hQFxkZeq2uZjd4N4SrS4yotavUptf
699	payment	115	115	115	698	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEAWE8fPfgTPk4HjwEJHARpDH2tXQbivYQMvqXFRggRvoe6oNR
700	payment	115	115	115	699	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juv1FiJn8gABfwJhdkZAv2TkMcKwok1DB5jKHsWBGXgq5GqHYLh
701	payment	115	115	115	700	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1HV7nN9jGy15bRHsEGoPJ2YNhAaeg5b1fegeppJGcnc6Gi2dK
702	payment	115	115	115	701	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDNGoUo1jcHPRn7QGGhD3MtiQLLXVtVrByYR8dreJXNRZDy8B2
703	payment	115	115	115	702	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv54F8YzogUaBLybheDUUsovFJ4uyTki1YTRSRE9wxaxJD1DVAv
704	payment	115	115	115	703	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3Su69awisEGQfNEp5i1DuESnakQVPSB1qwpJftW3Mx5dgXLBZ
705	payment	115	115	115	704	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLxfQMcDK4bbH7VLJwJvkp9JJQxTtBf1n46QAu7c7KA3s1gQRL
706	payment	115	115	115	705	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtjb9pbbRWZ35LTFw5kzTvzPnZq6jkJmKHFoHME7gtZU8GCmpvL
707	payment	115	115	115	706	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvaAEcUyWhQMpwiKXwTKokTM9V8tdXM4KMXJrX1uUiNLPAfmTU
708	payment	115	115	115	707	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupcjTyDAFzohWTG4dK5am2QTGMdVFfNhBiBfjwwyBKdcS4fhj5
709	payment	115	115	115	708	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMm6wSbgXgcfadWvXjmd8mqA4TCyWJiZnFXKRNRyw8YpLLfYbJ
722	payment	115	115	115	721	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQG6kDbJteFCtJxA8gjh1xpJvv93F9rZqAS6ySLfHTvuWx7N4g
723	payment	115	115	115	722	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuRiAUfbi66owfhDfWSxDVtNRfmpaqUskxbQBvgUqrSqQGx94FB
724	payment	115	115	115	723	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtc7UXBxDhaTkB5wVP58YTBub28vGqHvBMzz5uL8q96SxsKqnSn
725	payment	115	115	115	724	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxY6BRtHvTPpqBWKDT9Nhrkx1TZv7wM3PmTQXJxpYDEUto5Dfz
726	payment	115	115	115	725	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2gFNQ85edndLvj7HQ8C493Sc97ph8qfBkz5iVTUTiCHd2KGko
727	payment	115	115	115	726	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvS7D5yZM8ZrczJ2UHfyjfqHdsS7aDw9gkjnrc9qnsMrHqoi4RB
728	payment	115	115	115	727	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvAZULUAFJa5LnjZL8JWiDj193Vuv1iMGegC3X1E5S9WY1EVJAW
729	payment	115	115	115	728	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudrB8tX3D2FbDiQhJg6dw7s1RTZnz6f6CqTECFCjaZ55V53Cm8
730	payment	115	115	115	729	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNawxkUYmPu2P6WsDWEz9rSKHqFTrbhMeTuqyvNbyVvAbL4Kpd
731	payment	115	115	115	730	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvK8HAXTi4aFLrZe28tFFMkFWLVsG4Big7XVaH6Uiyo5KzdUvsp
732	payment	115	115	115	731	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3eDiJXbXL3w9pjw7ydZJVrtT74Z5ofYvaq55UjBPJ4g1kLBct
733	payment	115	115	115	732	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2QUhg2BwYiotmQRhCS4Jr4i5U9HbiP6c1gJjdLZG5jB3VHcLX
734	payment	115	115	115	733	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7mBrMemXtqAvrja67Q3EWdjSLkhTunCRS5wKnTemiLbN1KQuv
735	payment	115	115	115	734	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRrM31DzafGQxxiax5SnwMymGQjtHaZWBLxT15XQDkAmGWtkTS
736	payment	115	115	115	735	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuaDJojtQV49YmqjwUxK6YALWCZdZ14XjbbFT3HgDtKzmcCBni6
737	payment	115	115	115	736	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1Y1thP3PDqKpTkbbZqMx1Mp63VrmQad5Qd3qYBkAZi8aQV46t
738	payment	115	115	115	737	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtz81DCUU6dXY3SGjiXh9d5q48KWvJf2NckH6VsTSkLsPa9xe12
739	payment	115	115	115	738	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVmgpBgkqwuXgSWEzmHcF4vQgwtCE4TTJ4Az2S5C12r7V69ry6
740	payment	115	115	115	739	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQ3j5QL3trwQUf2BRU9ayoDwj2Y7mvngJ3b4xsKxLuABwuUGUX
741	payment	115	115	115	740	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvD6TXfVMNG6pfNh8UeMEPAffi3B3gs1hLfVvNWZKmHKg3uY3KW
742	payment	115	115	115	741	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juyo6f52kusjwJYYPwhH1Vjv72v4X2w7ASeEx6aJ6C6Fh1JLm1X
743	payment	115	115	115	742	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCe2AR3bDqJbByqtNrYfw4py5rHvoqfNWBGD9afMaeuBzsc8DF
744	payment	115	115	115	743	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHexNmrsba6o3rT3oQQuxjDAP8Dcbe82B9LarXWdCsV3mHsT7C
745	payment	115	115	115	744	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juxr1nGQ5BVhYyeaeYFvznrkC6zwKccMNM1ce4ogRKPCAKU5BHB
746	payment	115	115	115	745	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juhuin8hHsRn5pMdaVtVGfyQ3TmbV4Q3hs9C3R9bUVuHFvCBJnx
747	payment	115	115	115	746	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubTfuf2vDfeQ8vzbswNwm63PFCx8Q4hKJptwKv5Vn5Q5XGhHeS
748	payment	115	115	115	747	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGyZAZ9Bhsf96q4RvM9u7LUrvyChigED3dfiURpeqsF35ETTdG
749	payment	115	115	115	748	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuA44cs4P2bAhFD44p9oc8FY4PTYCHCG9v4UTBFZVtCsQjsygyU
750	payment	115	115	115	749	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYsR4vP15wk9K88kW1daQQbZmSzsiGQX95Yv4htoZAb1zomE4K
751	payment	115	115	115	750	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWyNjcoE478yahwWrLvcHm1sswm9cPxrwrwQvGXgTbwgaq6fPX
752	payment	115	115	115	751	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFiJT3qFr46J1j1K587ysPcNyFbCH61CoTDBfG93fqjpfnSzaz
753	payment	115	115	115	752	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGbkxRiozgZtgBEErx41uhPmrEqnLMyCjqP9VRhdqHY5GyCYCP
754	payment	115	115	115	753	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUeD5S641yuekZucXEer34TL14yDQZFFRd2nnuPYNhwviYXnxh
755	payment	115	115	115	754	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvER99ki3Z92E6i3UPnsFYNGypaAy1LPfxjQ3B29PtPXP8MuGpT
756	payment	115	115	115	755	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuX7kQDLEmEkYWGrHnywA4vymNQpTKLaEodhkbZoMGasRrkobAa
769	payment	115	115	115	768	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBFurHPgsigEKR9n4dB2h9WWnWpTvhdmF4Fp8y8ZoQ8bXMJEKe
770	payment	115	115	115	769	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwTryQ8yQfVhQ2FwjZTrtUQ7VQYJ9axVusMdzUiMutKvwo2yGo
771	payment	115	115	115	770	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuT8fyaz8e38kYLh7f6JjmSXBNEjGWoExVXAyjECsR4qBn6ZPY4
710	payment	115	115	115	709	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZgDQ5j9m6GXMyScrdyPFmgmE8BWGMXStXHxTcJBinASE8Upxr
711	payment	115	115	115	710	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3VCugGDWyBCs2rcpsHigZvFPruCssSJcPS5ovU4rCSNL5yZus
712	payment	115	115	115	711	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteQbJCxY4CoumvkkL4okmhnSj7R3HYWa3s2gKk91d1Ftrz4oE6
713	payment	115	115	115	712	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4kYsTHkYrpSqDwPEwyiANRNkpghQiZEsy2ojYhR9QdR4ddrvv
714	payment	115	115	115	713	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNq1BDvJKfQx3exbaqsMhHavcGxe4XpqsnJsv2n38WNuAotw3S
715	payment	115	115	115	714	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtyW8ewGmp7xdFHC23abcXaQXceDWPCruGbbUcWRmG9sSX2aFjn
716	payment	115	115	115	715	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPb4vt1jvZr6xzMbR6kvdcE4BamTY5RNvKWQ4Aib4TNLffdJBc
717	payment	115	115	115	716	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYfTdnuA4R3ub7fpf5aX3ra5STpv6HYUUueG5FEmaua2mnnQVA
718	payment	115	115	115	717	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6HYL3rXdon6k1wQp4uG4uye4r9Hdr8VG14M6GsSTHMv4BsJiy
719	payment	115	115	115	718	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutFawSZLENrrZZvatz11pr5iSFK8ELFsW7petVRyFXThvJRFA7
720	payment	115	115	115	719	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5j1dotD2h2YSSc4L8MhBJCDQaqWNLJd7VuduFXVBMadLDsX4j
721	payment	115	115	115	720	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtniHKn6njeW1NZiPRk8X9JmKeykrmxxWvnXUU9tqxU6DTP6qDQ
757	payment	115	115	115	756	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBKtsR7DRoYs2jae9qWrTY4jDrNMBwEnw8RSuVJ4n5vPyvWiia
758	payment	115	115	115	757	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juy9LaCJvWpng7JQE8qdhSdgYp4p52qKPWqPt8qGkgTv9opjP8F
759	payment	115	115	115	758	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJBfVEoGa9uVeSCCtbLqZfqk9bewnLxuxJKEFiSFxtLHFP4oRj
760	payment	115	115	115	759	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCgf653jZjfQU3Lw6P12KQZgu7nUX5bQLqp5JffCegRMpxZGp4
761	payment	115	115	115	760	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoEBcuonDownV3mgv5wFUzs2rXdb6whqQ19jfMF8sM3DUbHq6b
762	payment	115	115	115	761	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLk85cJvvcvp3TYYkgN3hBMSmiSPTHjp8FrcnE4P6Ko2HxpWn4
763	payment	115	115	115	762	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTheKsoKaSGkFbJmtgFBWfUHrYwgkq2zVrGoQRGwKbxifQ5XdF
764	payment	115	115	115	763	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1pK6gNHqwa2iVjD47YhhojkBrC9dosam2c3QLpA4zVPrcyRAU
765	payment	115	115	115	764	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKwxd4GBHQCiSJwhxj3vt4MscMVxod2oknsAj2np43iL6eZoPv
766	payment	115	115	115	765	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmNFk1LTPCvoZiwmkJeZgrorYUbXaE4ByXvYd7FzsDjUpxA3Xx
767	payment	115	115	115	766	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDsR9ZEZe8LAFc4pa6xLTftQsM52tz7RADvXqTvF4Mpb8XCdK8
768	payment	115	115	115	767	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwSnd1GFtRjEXBnoP3cm15b3QYQ2gkySFMgciXjkRYkMTYMu7n
780	payment	115	115	115	779	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6WT5boUsjQVnGxCjgg6Lqwm6BpNnUWZgW6cPw5FNCeGvdFVDZ
781	payment	115	115	115	780	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7ppqnoedXpGMXjN8YH4oK3BXvvZCMXJYPRofLfgoSdzsd7jYz
782	payment	115	115	115	781	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWdsL8NvxdVsaHDGp2ader3eA2as8novd5WqeEG2rFsg3A4fY1
783	payment	115	115	115	782	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuE9SaEL3625cfxX1kQgBeaw2YJZE8M6fZ944W2TKXE1fPxZEtZ
784	payment	115	115	115	783	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JueqKbwuea1HSvGU8yxJWxTDiABWj2THfoCYbynvE3z43ckZvcd
785	payment	115	115	115	784	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvAbuJTbifYErwH6qjCXD8tdJGc4zWRe1zivDhWb6eJ7aa2GZFE
786	payment	115	115	115	785	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNRf6zRAWoCx7AzzXCDyYuXcJ2VjiL8rysHK5qwZYgYEU5Sdmo
787	payment	115	115	115	786	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8VEBqo6izDbY396PZ6nCBDXnfJoG2bLo7ejAPaRmivEhAXbGG
788	payment	115	115	115	787	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtf3rxTPggPGDerFqeXB3KAsXoAs4UNbyTuJmRjaJDx84ffVrWe
789	payment	115	115	115	788	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6Rn2V33NzGFtKm6sbLCDu3phimruMwQgQwYz1zvuNBhv4L8yj
790	payment	115	115	115	789	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtbYkjzGZcttg6wcZZfyFCXtzkHzXYVPNDNMQy1rwDKqjBc7iPu
791	payment	115	115	115	790	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurCwBgM9d9SrWoVjMk2b1jYfBBwnNinkuzqphERoV5t2vbkDbo
1300	payment	115	115	115	1299	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtarqMfTjAU5BpXUfwYPVe9GYghNuyDFuTiwkn59DXWvw17v6Ei
1301	payment	115	115	115	1300	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutiXTLJi1XgV1xUR1itXbRaR4e6kW1vWHzw989v9gSGNkrdTka
1302	payment	115	115	115	1301	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugLCPkSwKsPJfWGxYiuiDQJ2v3XtKyL6kgeLZNhYZ38zyaZ578
1303	payment	115	115	115	1302	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuvnhsA3cS1ZCV4MKCmFEFeSHM2T9etdP8Kgf2vPhSKjayeJro5
1304	payment	115	115	115	1303	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtj6CKfTwt9AhLKPU5C3DxFa73rLGhXWH35yxzySuSKRYiqaLEE
772	payment	115	115	115	771	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuvCmhp2araCH2QDtz5UBdu25uQd3MXH6MivCiK2LpFWCy24Lkm
773	payment	115	115	115	772	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8RibHcrHdekvj1NyKpRfQ57jNntTgmCqodmjmgHq6Dg5NA9XQ
774	payment	115	115	115	773	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvK5zh7KcKEke21P5i6dUYKYmzTTxx288UqoTFRpNFjzbZMp8Kt
775	payment	115	115	115	774	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8MnVP3Xi2AVGbeX2AhBDhF6NiUcwYf3Dk5KeNUg5cTk7m8kn4
776	payment	115	115	115	775	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXEdamM9scvkvLngGJk567iMZa2x88bgdRzg6r6EKg7zsPPdV7
777	payment	115	115	115	776	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYD93gamjYBszFnyUJx3UYpWrTU35QywExho8DU8CTtqXA48Xi
778	payment	115	115	115	777	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXTzqBpJVdHvsiveGREMmzay99pid5LwiSxubV7VpwE8Txz6AN
779	payment	115	115	115	778	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTZiQGJUixKres9JrFREQnPFXd5nCUs3Q1JQdPFUbEzJqmPXE7
792	payment	115	115	115	791	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jue59miNmFsFjGaQPF3QKqi3VWmKnVE921VfoKSByQ7LfEh1P5F
793	payment	115	115	115	792	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDZqmAChDt5f86zLt7bm5UqrkD3KwSWaDuzjMzgbXvFLq55i4R
794	payment	115	115	115	793	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukfeevJ84vvJqSAfsHEwnKUzEFzrDUdspm368rW7dyne2TTJuM
795	payment	115	115	115	794	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWGC4TzxH42bxreCXVKVxo3w98JuuN1fSjbK8raQcXZSBi9sdS
796	payment	115	115	115	795	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUzDN2751BV4WSbC6NnQXZq6KLT2YyeYR1gi2mtZQS43PkL5Ak
797	payment	115	115	115	796	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtznpLaTXfn2SpGxN1mKzPxCbHdFWgAU8DFmLUhsG5eCCBPYP9U
798	payment	115	115	115	797	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtd5yYAzjFELLs9xdLVMe9LssQVm5Gyx4VFM2H9SEVM9jUXVeo1
799	payment	115	115	115	798	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5omdRtNqSkHWsm7nAJNytAgwJcQAiAdqHrmx45DbmdYZ1YW5R
800	payment	115	115	115	799	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzxY3WcDr34ikUKg22bmbGoF918rfB7AbUi6iq16vvaz5pxJ6H
801	payment	115	115	115	800	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3tk5qxtuPzuU1hfjhRn1Ngjb1vLoNmarTMLBvQpzL1t8jtkRu
802	payment	115	115	115	801	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnKfns1knFzKkp78tc8ttLpqDpJr7qUuTorFRJ9zWtujBbKj9A
803	payment	115	115	115	802	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKCExEmSrfaeXVHXAgcE55AUo3pwudW1LpwAuKKXZQ5N9hL2aB
804	payment	115	115	115	803	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxFEbiV9xUURgP4H37mvZBRWbtmyt55QMwSmJyMBWrMphUGJfb
805	payment	115	115	115	804	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuARnNERYews1CkpGYE6M35Vk4JyJ92bbpPrsdkpkK4JmVwZg5p
806	payment	115	115	115	805	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuutDZWAWyksdjdkQkcQpxeUMTC47LXpzfShqiYDe7ww9uRk2D6
807	payment	115	115	115	806	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYiQAEfCTNMqHUR1HdT341cphsMmY1eW8qkqXNJSizXWqbLxMX
808	payment	115	115	115	807	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JufZxL4CdiNzeY6NaYrfyRFMhTAGxAPjyCftFRFi7sZ1ZA4TbZJ
809	payment	115	115	115	808	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucK6izSsxFuPv9YpSHwrN8Qgy9faN5kH1hxJB8CPBJS3mk2t1q
810	payment	115	115	115	809	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteLP3RUKN4KSSzNKiuGvYaED59b59DQWwrF9PmvpBBBS7kDMXN
811	payment	115	115	115	810	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JufYK8FqkPeqnYfmGK1YZkJqdrwLquUBfRay82eJhrpz91wLcmy
812	payment	115	115	115	811	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusNDH8JcF4imiAFRsKAmo6kJZ4oyQqxUmLC5bDMVkekui5JkvQ
813	payment	115	115	115	812	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jto2g9aQEMD9Aupcw76m5jurKi4sjv5yjB22kLHvSA3EcHXXcaH
814	payment	115	115	115	813	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7y6tZB6st1mWx9FeMLkxdmwtzQrDQy7r8JdbRfaB8KpEFfY7L
815	payment	115	115	115	814	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvfwyYPMiwzfZ16fBXfLezvfH7pLPyR41t1heXy4TaGZZRpBx2
816	payment	115	115	115	815	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEi9EaaGZDTv3xyHNVkdRjm6sHMohWwPLKAnbLw36JPUNXQn7L
817	payment	115	115	115	816	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukchwRCrNaZR9SUBGgr8CeHc4R5hcZYsuyvvP4qmxyrz1GazNi
818	payment	115	115	115	817	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZgMsJ4wgqCrWmsdPPSa1tsaRqLuC1kVuWgqqTw7XLG3862AFs
819	payment	115	115	115	818	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2fFzBndaCQrZBmVMF8h1bHwNsRou2cYnYHWdtxU2aQp7wSMRm
820	payment	115	115	115	819	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQFoDA2vibAYVFahLg1q6BxpED2x2gYyPWfNkre6weoUVkEd8v
821	payment	115	115	115	820	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzP5u7AKpSKfpodNKbyQHM2NvP9eNbCD4BisCGj4rWL1ArZZCU
822	payment	115	115	115	821	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusZLUcLi5p6y82SRV5PmwTA8Yp4aT6UycHTDvYcsduELycgXRD
823	payment	115	115	115	822	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZgVrmM74rqMvYX4DKJnmL2GcJznzY2keswU4EoTh5Syr8gFLK
824	payment	115	115	115	823	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhvFYDW8YxBSgMiwV1w3fk7qxrL7WxtHfMM9LGruJqJXZpSTYA
825	payment	115	115	115	824	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtudQzhx5voz3pc7oEZ7zJo5FSKwF8J51P7wJpTbi943G7xuUbj
826	payment	115	115	115	825	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCwRPG44rj1oqZmDL4MuVho3n4wuFyE4sXequeQSqHiWCNnF4b
827	payment	115	115	115	826	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHAec4WPaSgB1b9aUeNfRKgon7D5yWXS9Kvi7f8LM17p56chXi
828	payment	115	115	115	827	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQUUoV8rPdd1Wgr69i5JAuzmP4GgyX4xwnKEw5Ch9HRghf58vd
829	payment	115	115	115	828	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtd2NKBwgKJ3SHHFeQGGLX7r5pL3mai5woRnJtVRKruGYuFySAQ
830	payment	115	115	115	829	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv51go54Wx375TaTCQadFS7bYKdfsxwiXDk1Q63NhH3wdpJG4GH
831	payment	115	115	115	830	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv35b2UyKndEsN15iqyzX96b8K5tcx46DmSjCgMDyib2wgPhAS3
832	payment	115	115	115	831	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv359JMpTFqqHyEZ8bdqLkqiN8N4jAQaH6mQVMMdyhkiKBsbr67
833	payment	115	115	115	832	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtgs77D85S7CcTb5AaUnZyx481EvayiWFhwedQRrFqT2yVcpoir
834	payment	115	115	115	833	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKukbe879gfCpjgT87WoBe6STQ3d1tehS8NscEpFJVzHMgjEu5
835	payment	115	115	115	834	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juv41dRevhLH3S9AnRNMdjw1s7sVuJhne7zB756mDDEG5KsBRZ9
836	payment	115	115	115	835	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtqjWMRPsuaxJPoMuPX8Qf8C2MLLMvWoJ6L1Bw3GUpZP5AMQiFD
837	payment	115	115	115	836	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuM324KCv9VWTgzjofCasvUxDKLgTpY5KFxCQQxEa2Ce6BJSoCY
838	payment	115	115	115	837	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4wr6bFT4u1M98FftqYED7Sf2YEyKb5fGdDwEQdjadMFFLy6PV
839	payment	115	115	115	838	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8TE5LsQmmPQZsnyt4r3zVycYL7EjixKdy4SXdzUdGbYenz3oz
840	payment	115	115	115	839	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juknoa7Ni265ZDiQmabiLU2CY6DhzXow1igYhmxQiZF3615YK8K
841	payment	115	115	115	840	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3zRh7jRdqs2VEaV8q5TSamUVBoAUCkUZckGyKcMYJXBURymFz
842	payment	115	115	115	841	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHo4k4yJ1wFxqSFTyVeFDE5Xum14bJdtQ8muSPMuzhqAz3Xtcr
843	payment	115	115	115	842	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzYqgUxrURjfJfkEVpV8H6Aiu5PC2nNo4CWEp1jXLLDxBSKDwy
844	payment	115	115	115	843	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqU23xdX3jupN3WCU6YBmgmyQVpqi8C53K9JbzFjytNfy9TXmK
845	payment	115	115	115	844	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumVqKRJxDBZ6brn5BfWh4Y2nDFiB8EJLg5zVP5thqJGLK9vH4M
846	payment	115	115	115	845	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnvpZtEHHUNDBSfQt3RELg2RKsdEtFqmmdiTZLAUpE783EGRJk
847	payment	115	115	115	846	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusMhPQfHzP9sP1pWxPmxyCXUxiTvZidoJeNfG3BFRxZ9Jw3fnK
848	payment	115	115	115	847	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jupiww7SJugw2e23j4QdPPCk42cuetJFUcPqRhBpS6apbDhjVW7
849	payment	115	115	115	848	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju31U1JSGn1Kh7tFmaoXf1cabvtxh76RsUA1eooskZutqC5rjKm
850	payment	115	115	115	849	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLRioxZoRwc1gYvWT1LKN4vXbSuBw16eSxdBCGS5qivRyFbVCe
851	payment	115	115	115	850	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvAR4GYCbRNkRRwLHicWuRAbEb9sjmcVuU48vvyBbgdew1DsqgT
852	payment	115	115	115	851	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtpinN4xbtDTrkwxT4mzhgfuL9Y5ChdSxQCbdxAy6eiTcFSq9zJ
853	payment	115	115	115	852	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JthQgpnFaXQgJ28T6UPAMmbqLgV5dxu5vfXmFmZSgWcKArE66wG
854	payment	115	115	115	853	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JthH574RToWufXL6Y4WKuZh157ueXcPuLcNokTAH5Frpo6Yhi6u
855	payment	115	115	115	854	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKWWWkfhxpFPCWJVPMPgr5WcZqYujnQZBr7HUsWyXt4WKThZSi
856	payment	115	115	115	855	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwcTJhFSG46HmneVY3vymJrFF53Ko8xgkcPvR8DAdY7yirjEnP
857	payment	115	115	115	856	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv46SbejqUP3eKNaGoGFk4jazyhYNPrqcbn62cxULqR11jZ1xki
858	payment	115	115	115	857	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtqCtihr16Bm2jeU389xGut9YWgv8o4jYJpniTrjigx6RRNC5j9
859	payment	115	115	115	858	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiYJWH8UcBWkmCxfFWgxb5uPF71fw6FoNEJXnGJBJZda5tbtuS
860	payment	115	115	115	859	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkjMyLsnp34hMwaoczD9N6hh6y2L2kSKGhhpV9ffCKW4Gm22Fo
861	payment	115	115	115	860	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCGYGPgq9Dzmfo2YSivhooGnWsJXPMb9r4gcSSmLaFKmaNfU9j
862	payment	115	115	115	861	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtrZMoKgki3r8PTgtFcSxMVzbMfixA8Gnwwiqpube1LWqL2oGKg
863	payment	115	115	115	862	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBY7VtKYrqSTVxjkTJ7hLuM6hwjM3MFJUMzkpFZPs3zSBmDM2n
864	payment	115	115	115	863	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHdoH62mcoWxPWZhxi9sAUuKaVubHjJ6ZkusfVcCv74ghCsaXy
865	payment	115	115	115	864	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuD9s1rBfmdX8UXw8HWkkNeXRx9ydp1Ndcn7bg55WLsP16amPc
866	payment	115	115	115	865	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAXHbmYY5NuFYhJgBe3yfQSW749SXZPQkE9wFB3TGEBeJU1SFb
867	payment	115	115	115	866	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwitfJssw92pY2jTmFhwcb7QgJDyGgBfv2QoKbyCdopCJwNFVH
868	payment	115	115	115	867	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjDmqLX7L7v9JtDSm3RoRoHcCP4uyyqtsKqnN21WenAT9g7QdA
869	payment	115	115	115	868	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jup6YKGse1Y1ygZd6jHDn6wypYriT1nfn1nHW9kV26gMe7B31T8
870	payment	115	115	115	869	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYLzQE9fNe2pEWL66JMHfTq253v5BdgiGzCkZFhtBFR63j33vK
871	payment	115	115	115	870	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKHUbP7P2hFZTfqDkyARZ5CZcqahz6nV1aU7XiB9PEXEocQjbw
872	payment	115	115	115	871	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv89WMQXkCmaGTQDaU7FPk1bu6hFFC1QNJkd7bpLMjsUbDAdyzy
873	payment	115	115	115	872	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JueNWVfuSXnN67hhEbnC39crpXRxtmFy1d6VnFNig5oWxRJ9TxL
874	payment	115	115	115	873	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYy5hJ2WYHkuJHZQZTZg7Kvdqkd658x2RsZnRvhysNmj6SQ7Bj
875	payment	115	115	115	874	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7Pr5mJtoEsWZ3Ki3mLC9SY6RCz6H8cj7YV6HwcEQ6muJnW55m
876	payment	115	115	115	875	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtivkFrvJbVTZeRPvRs5vVc2ecSYn6Hc1dguKvk29rrrHbqwWDR
877	payment	115	115	115	876	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEcY6kLt3TBtS2XQCSKp8hR1VdNvQm944nTJ3Ajo7iBQELJg7s
878	payment	115	115	115	877	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtygX4o6rDxTXKBMDZhU7kFNt8yX313Z5bRRh9NFTtF7s8BZvNV
879	payment	115	115	115	878	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jutpd12FqNDuo8F2t5koEiCxXYXFTjov7qKtZauXrkkSjSceYgm
880	payment	115	115	115	879	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4pqwS4L92fTq5CWNsHaEdnKpvsNLC2c5KqAuqtyMoy8vQ6fr2
881	payment	115	115	115	880	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCvV1LxZRupLNYRHT2rqr4HxdJDdbh8n65Efg97eS1znw9wogc
882	payment	115	115	115	881	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHKjsvfDUEmtYwAKGWSw9KiBNFuU9wRTimFAAo3nAGk1kuNBtJ
883	payment	115	115	115	882	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXKMFr4PPtJzVSaSWx1SJ2FqMMXDRSkP7iwRTh8bA4GCrLzxvq
884	payment	115	115	115	883	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1AK3ZZ5S6xSF6X4NwehJDy9FZ6ZxHuc4PWVaVcsSeDmEn1TSx
885	payment	115	115	115	884	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmUQdvdMmnr8ragc9HAA1pJ5ZMHDg8edPkWA92jb2vcFGfDByS
886	payment	115	115	115	885	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucY8kgXvjJzappWZREQXUGmVkkHA4tThqZAskhTf8ZH5MKzo8b
887	payment	115	115	115	886	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjCoMmvaiEpcoFQgd1baij3iboH4QhoiaGf3qBFmRrzPXtzESK
888	payment	115	115	115	887	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5AppRL33PuYxs6vJK6Jef72owGW7Xk8SMEHmG1Q5MCh9Mn4jr
889	payment	115	115	115	888	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunrUnBgfxVRysJpRYvBSstCFx1XwRGuek6QEo9v1X6ip83EUgW
890	payment	115	115	115	889	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7UoMEMg6DJvP5nWuvu2LQYmB4EaPNBcbW4s83AcnpEVgzawag
891	payment	115	115	115	890	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2HuL1N2iexUbgs9UcT1zaLWorgjgULY2Qv5XYCaKZjE3v6XzT
892	payment	115	115	115	891	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtiwdodBnb1vTWLcjDLWUrUGXfXjSgfasmqtJGtAXsfEHJetkAU
893	payment	115	115	115	892	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudBf3hiG9hCgyGzxND7YLPVdVQ5KjsnG6RDdtBBWwg1bFVQ9Xw
894	payment	115	115	115	893	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv36V1Tz2YNenQHBzeB14EAaHn8ir4b454GLQaiQShxhg8ib5se
895	payment	115	115	115	894	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Judfr8B13iJheDHoF9ExiakSS8hWe9cWsngt77kshzhFz2WCN1E
896	payment	115	115	115	895	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzJzmjVwzZ2baFdRPneqyw4AWMzBdksApveJCuaTcP4H4UFT85
897	payment	115	115	115	896	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugrBnmWPLc5hBTr3n7NrzxLBoNUtrkZpDG18W897iY2wVFh93v
898	payment	115	115	115	897	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqUcHTvqDCczHkV2iuBTtd7ao5EV98mezW4K7AkbmdqPTq1iPi
1305	payment	115	115	115	1304	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juy5p5VM2NxdZqm4nAD7eeNxwMLycDYZtiCf6WZvPbob6Cwsbu9
1306	payment	115	115	115	1305	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtczXY6fcaSHfSLebfxvzdXWkhpiRAZqaHBH4aeHvSwewPKA3AT
1307	payment	115	115	115	1306	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtgmRCFrjQBTtugKc4KXMxS5pmyyA2nD5vTEdATzoXxcSLPwAU5
1308	payment	115	115	115	1307	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5WzcLyPkCdp6KgYW6vST1RXUPNje4qagXZjAHh56j7JjMGm5C
1309	payment	115	115	115	1308	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBUo7psrBt3YqfwgBV9nEmiFSRvdy7ignePpcW7YKUe72yH6xS
1310	payment	115	115	115	1309	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juof2K6kYkFrRHhTbEKEQV7NyCv7pQg97UaoensZtkbghLhyr2n
1311	payment	115	115	115	1310	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3FQeDqasNiYiaWkcEsG955uDM9mEQkcWC3KjP7agNyBJBwzN5
1312	payment	115	115	115	1311	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvN946ipazhbE2P8jT4EAx5L6hAueFxHm53fmwWLG94nTfBzrEi
899	payment	115	115	115	898	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuP9ahamw33RPve1Kz5xjqwAA95khm6yCc54nnH7quUK2GK4ESZ
900	payment	115	115	115	899	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtojBgcbB3BiNUEcHHtGJEkQo4PTLj3iXBwyCNhCWVBtaJAFruH
901	payment	115	115	115	900	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuR4TZrw66nFDJfV4qhAd4pYb3tDsMF1TcqFoP3ou1uAjPJmffj
902	payment	115	115	115	901	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCJVQA13JcvLXf1noSbqsVuHZXd5jkwWKUtjdxQLa7NNjfu9uW
903	payment	115	115	115	902	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXXYkYAY1Uq8eadJhNdLzxzg4vNR8J2jeK6Nc55fvMedSzNbnb
904	payment	115	115	115	903	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsenaYzREt4pRAWekVN9rEurBcXMHyHYSNWRJH7J5MaypUXGB3
905	payment	115	115	115	904	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLVLfc1rL6YKqdk2P1DDAPKx5FTvRh27xW72ZBd9GgcjMDRKzA
906	payment	115	115	115	905	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTjUffDX5VQLpu1phFFyxfT8fELDu7pidKxww251mqaQcydf8j
907	payment	115	115	115	906	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBQSTfDzgCzUhWd89PBF3mc2RtsWYdBb4WbitJaaSZKPhxoDVq
908	payment	115	115	115	907	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdeyUJGgv3WG4PmLAKmMNVzKZtj72iuHmDQf1RycRoCPwEtTYt
909	payment	115	115	115	908	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1m2G3XafMUevnUbZe6QqsFzX5mQkaw2n6hBFuwBwqwA8Lwwo4
910	payment	115	115	115	909	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBh8UQT9436RnKCtf6NNbrnd8DVLhczyJ8XMsbfR7Ya9S5dCfC
911	payment	115	115	115	910	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukvxsnhEQGCeKvjq54rYjVYinH8UNZ2bwENp2gbf68efFdE12j
912	payment	115	115	115	911	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1rHHNgFGYDzEK1qy9Wr9xUM2MNPrpT2oZun5PBmV7tMm42g9D
913	payment	115	115	115	912	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSMWQ8anawVWjD946oaH25HpwUYitKKCGyvTEMkhtqtn8szVQ6
914	payment	115	115	115	913	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumDGkUAfmh8G5jnrJhkBMFtsZ2gAh3gFJoaw5WLw58dZNLVXnA
915	payment	115	115	115	914	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsEgASUyBYPqTkWVzVHYtARM9VMNwsJtvaeXZA1TQnoNpE2PsZ
916	payment	115	115	115	915	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDDjkDxtdTeJYzchMz9fa3SSEtfvCpQ1vKh1oU4mT2GxFDTzA8
917	payment	115	115	115	916	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKgc5zxXBy3WLXwRCqo2jJo9ivt1otqrfAgUppMVLPyELfTfv7
918	payment	115	115	115	917	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju51zhwj4FtrUTwovPVVb9e4VxJUrvQZRSD8sZRwrmWECGvzDkL
919	payment	115	115	115	918	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jun4Pn1PbK7y6V7Y97Pf8vSPgB7JtVYQcUgMC5rq6dqEakou4eA
920	payment	115	115	115	919	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudESJ6oh6eFm6uYApsBq1rbJjaMvDFALAcw5fBiTEVSqhjDhwC
921	payment	115	115	115	920	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtkj6E3BLKV1aSNxLpq6FbyDBdNo4wxDJRznrgQsmgpWq9uP6yK
922	payment	115	115	115	921	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juv8nRFPvgiCSWzR6z9u65VfKbfyCZcQgriYsK2CUC2rs58MjQT
923	payment	115	115	115	922	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhE9H6FeUg6nQT7FTx7ZjjXQNzqgbCuLSRXBnFWuUDB7ht5zwC
924	payment	115	115	115	923	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuTv1qMyoS8DmZ6d5ZyfVaek1soajEGvstph7syYnDAvC4kRA9
925	payment	115	115	115	924	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurmruTTyLH7fiLvemVGfg6mvTPmsnHFevyjhL4ubdQ1BCgUwmQ
926	payment	115	115	115	925	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNywuyWYC6FGdhCydbEjt92NGDcUAay92nrkHF8HGWz5sUgRNe
927	payment	115	115	115	926	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJwGbYLuDSFrYajR9ksYdSeqYEzgwrGy86DuJGv1EHDkZb5qU8
928	payment	115	115	115	927	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjBjZsHGcJNTs3BDeBSiyEKoMknK2DBGAi8JYkScHUWbQSqaZy
929	payment	115	115	115	928	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFb3cxTLNKdap67Nnz4LCgcW5Dg22oSLhp7UMKuW17Hs8jWh8U
930	payment	115	115	115	929	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuAJh1qC1v28HfYKdAWB449qggYgn6gUGnFcxkaqJcMWmou4Ej
931	payment	115	115	115	930	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWjsz9cCsYEjjKPq9vyZtdHnNr7Qfey7Q44Gir3VVnvwjj1o1R
932	payment	115	115	115	931	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwRHnJUTCULdfFJ4jfUq5EADkuUKjxc5vfgygrCcKSe6prrEP3
933	payment	115	115	115	932	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juw4Qxh2euq2cji8e4nB6jd5VnFJdW2NsNhNK4YR2QAuiRZbVLF
934	payment	115	115	115	933	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJ9TBuf27inQZ5nAUZy9HBpXo5bSAbptpiFFERdxLU5W2ARfRR
935	payment	115	115	115	934	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfqhHi7CHGDHLha3XJgRAuntSTiwWknRnTxJtuEnSCw6qsmhcW
936	payment	115	115	115	935	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdNhhjU4bNU7AC9FamSKHiBgPd6HTTzYo6MbJZ3dhbvoEvt2fB
937	payment	115	115	115	936	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvCuZNAyURR8RFqEN373nceVdL6tGBDq8mVtDYr9gN6ZQ6rokV
938	payment	115	115	115	937	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWCQsrvzUzmGFQtgyf295jLuqdow51F8KgiwEMzkBPMc8Cpr3h
939	payment	115	115	115	938	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jthw7cP4pp3sRKcvvYTC9Ki9n8ytcUQv3nmtFhSgjgoXPWKF5um
940	payment	115	115	115	939	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3Caca3F2zSDC7iSvny91D4d3Y6HNJ1bSu5xjvvS9JzUsAMDot
941	payment	115	115	115	940	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju81n89ufALefVedxX1GXE7NruKPxgtQuGf7M6b7Qfb88cVRSLM
942	payment	115	115	115	941	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXEMykS2Pd6jwtREPooYEFyokDab48aPBgvTXzHvp4uPDunvhF
943	payment	115	115	115	942	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwCHKQJaBWtbrsPERh3PsQzv5rNwbajE4zgRdMdwgTUC8n7SHu
944	payment	115	115	115	943	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4SPouuTyK5rxQJkoH8V1h7EcoZinUPFqnVtStJrNe73tCSY23
945	payment	115	115	115	944	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juj3EDU5Pei3X7bBsBBmYu2SDHuQLNp3ExEwbH8vcKZ2D9zRom2
946	payment	115	115	115	945	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtefgvnmWp4JjjHDDEkUWHqvBcr36hfnvDvCmYBLyqX9t2F5FUr
947	payment	115	115	115	946	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuyYVrTNurVfHPrdMy4BX93z5WfV9dkeN3EJEvxWAuSMLvsM7bd
948	payment	115	115	115	947	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRfirM2hbPF9sNpBFviSaXao6YVDfkaxq92APrBqdjCh6nmBqg
949	payment	115	115	115	948	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtiQkCa91V2RUyJHfJDo7pzQ2tEDmMBg8KDT8cXSwZDd1FRq5e2
950	payment	115	115	115	949	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtt7ZfhXGHXagKCNuQdwne13ATCk6ZfuogTsEAUGwuxBytq3bU6
951	payment	115	115	115	950	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv75sGeXoL8tRT315kYVJitxrDfpBSsob6JPSXUY3pXGV6aYHcF
952	payment	115	115	115	951	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNR3vPSpQYd9RyfFxQfjrjn6YvnbvTQ4xRb23AcdxmF5tNsDc5
953	payment	115	115	115	952	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9smsbats4QpspMyudp98WqCzg74XS7RDDM2wc9XchhJkzf2PT
954	payment	115	115	115	953	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHRytmiTxAbWdE5zwQXJ16g5ZRWQP8XaZrQs1ZRQ8zaLym4K3h
955	payment	115	115	115	954	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzCpug4BapdXZ5FdR5fcXYpvDxBZePMduqesEux1Yf4XLGEXKk
956	payment	115	115	115	955	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSBDeFQBVhiVMJYCkN2KF8d8PphbtKUGXPnuLFjkb67mzz5y5t
957	payment	115	115	115	956	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8wYVYXvyXyYfLGnqxVkYo5z3VnmHhtuy3XJgmEzqFVpx9ZCwo
958	payment	115	115	115	957	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzcLahFCde3qnMW48AcQnXY2PVDjGdieTbKrgm6Q3Xq15w5Tb6
959	payment	115	115	115	958	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDwPpDLK84z7KAQzmWRp44r2yhfAerpkxpF9QymcTgkdWGwWWS
960	payment	115	115	115	959	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVU76AJc9xUAfF4RE9Tzk9GeCxeEPRc6ZcjpiDM2S34EYPxDWd
961	payment	115	115	115	960	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiKk3FiWx8q34oDdiWPwRSJUoZEYks9zow84AWGaP6pmugXvvg
962	payment	115	115	115	961	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKD1Ha5EjzqGRXxxPYvRusxJGv4B9EcXb9sAQNEv9nxenEr8ta
963	payment	115	115	115	962	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYWW9Pb5S6xsqsr2Cbyipze1GrxxXLjQKezaCjD5Af2bzXFwkp
964	payment	115	115	115	963	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvATNFqnBfFQd1rM6HqvXwZUeGBGKssJQXFdSYcxRdEFzMuWCAu
965	payment	115	115	115	964	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGDwJFwhQ3yvyD6LPvbkBMJZXxXDHVc63iCS1EbBziV7S4Soyn
966	payment	115	115	115	965	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcbpgSgkRueRpjfaccSDdzMdzNjtwmRNrzMERxaDocNk6t5Frm
967	payment	115	115	115	966	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JufVU5Zn55uRJeRuH5inDFxVCxhE2W24LVFWizZbiPsoBaQfrPM
968	payment	115	115	115	967	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEnvjZWeQcwWtpAEsfSeTw6v6FWL1L46ZXBCL8EsUW9ZsSV5AT
969	payment	115	115	115	968	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuMCmBvAGV16rNp3v3TYVFgzoSkRQUCdrrNcDejGV7D5xfmRCa
970	payment	115	115	115	969	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGiSZRRpTE1w3iUSya6PDVLxeuVRUKQq71ZSZm1gKCjkLuGKqW
971	payment	115	115	115	970	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWRDrqfaRp4TptQZhnk1HoRFA2NXRxSp8ASpYPfrtTAPG3hTxE
972	payment	115	115	115	971	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8eH7hBoe94We8hcEGK2Qp1yJ59Yp1ekxo9bRgfWKoovwL5E5p
973	payment	115	115	115	972	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuD52w9uB1NhFCiQY6FW6mSLh7XvCtZkLpYw77VMgTSug6VmRXP
974	payment	115	115	115	973	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3DFo25CNmPAwpr7sMhZamEEJq9o5aZqMh56eM5LfKnqU4eyfi
975	payment	115	115	115	974	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVvnPAxZx2pu7FTUr9gbwSxbXdTcuDyuwfUeRiEXpRsY1bMU2D
976	payment	115	115	115	975	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVxyvpMwzzBDnpVRpHLQXU1iZb92otnAoyqtj2UqfjwPhi83ty
977	payment	115	115	115	976	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuK9Ab8k4mzz8nAvU6cqqcGqMC75jJXw4mUqgNYjFYVsCsHsGMs
978	payment	115	115	115	977	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6hdWm78s9K5SAwszwBGXTccE47cVBFSyxjt3D6eauyyTSymG3
979	payment	115	115	115	978	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEHoyNbHfSAiM2zn3qw4MBBkQ8VjuftqGq718biEAbut9gWH6D
980	payment	115	115	115	979	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFGLeKpRpTa3ScFt4vQiU8NfuC6FFcSzN8UKed5MuT3z6a2hVN
981	payment	115	115	115	980	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunxxXKgsD8RvV4Dfq9D7sHFY7hNDbK34YJRRz8Y6wp3MXVnuUu
982	payment	115	115	115	981	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtrgYuCF9jRsDpmFkdeBGUf3Edvb5XP9Uhw1GtLqhpWTx3PTciE
983	payment	115	115	115	982	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuRE3w8weHHTxgQyeGPrftRxQArRsK8MT2Aa4yhwYphziLm9gJN
984	payment	115	115	115	983	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAGfJLHhH9RyVDQjBtaVUTv6UJJqdH3HPgSRYQKTPu5DX5dnit
985	payment	115	115	115	984	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQAig8fJkcmZrqQvhNvgjBTc5jCxStBmYoxG84LiJEdaDePpwb
986	payment	115	115	115	985	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFWDLfMsPX62Fu7LeZZuMDUwmwLwPSQ9mTPZKLMzHwuosr4LgY
987	payment	115	115	115	986	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDd9Aj4FuRSfnWg7ANV2aheqQTY3eH6Hi2rShKaMJsiGCxY5q6
988	payment	115	115	115	987	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPE545MrmiCic59QHkH7DcJKdwPBdTuE8NeZvzwzgL9tybUXSs
989	payment	115	115	115	988	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujLFUoxN4Y9cj2KEybtAdnNPTb8mt7ZXLzGJAKpJ4GofgM9td8
990	payment	115	115	115	989	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuaLVGACpNXspEjWkHwCJ9fmZ6y1XWdVhKUFkoRq9KsDHyiwp4D
991	payment	115	115	115	990	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwfmLGV6qtL4CRZMnQcvYenwrZqW8GonznsfbyCVQDoFNYqvs5
992	payment	115	115	115	991	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkWSDCvpTgRSRsbjQj4qiW3EjweMdu4GzNW5GFZduL9us926DV
1040	payment	115	115	115	1039	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLGnQYj21YWsTwHg34a7dowtw4NwpLFHqPnisrcreYqLUYVtB7
1041	payment	115	115	115	1040	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwCFvhvCkCgN14hhEUqAfZZ12dowzHVScXmMuoZ1ftVvDFeNu3
1042	payment	115	115	115	1041	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttyfbWSDbVoHp9BBYxr4Ncu6j7ZpL3EinUCiccoienj7bx9bVh
1043	payment	115	115	115	1042	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHyojKZMLJD6cp3SzGTi6jQC1X77fdcii95sEhR2LCzLZiksH8
1044	payment	115	115	115	1043	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jto58hCA2AZEaFVoMQXuCo6uBpcmzQ72ChFi98QbX7hcdrSHS13
1045	payment	115	115	115	1044	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1LLNMaKMEm9984YFL2xyMgbxQPYm7sWSHaWXN9xq1amaUMjDN
1046	payment	115	115	115	1045	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdV8DDDZhJc8DiVEZESGSxRTtbLvUfZ3vp4v43vqsL1hRTHB1r
1047	payment	115	115	115	1046	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZokDuH1fo3c5VECBJTsBBxZGMZvzsBoTT2mNaNBs5HH2NQy4z
1048	payment	115	115	115	1047	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujUoYHgSPxYwq2DGo2tuhpmXdQrV8N4RyjZ2oLjEqnjuNqQaKu
1049	payment	115	115	115	1048	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuExhLnsnGjiCCnXJgZ8G18Cdre8Df32MstoNpWoSHPod5SqMJu
1050	payment	115	115	115	1049	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuaUQ1jB6XRqEJbaLL2bVSRC7tdGcZVBPdtXRxoErMRuPS1tnpV
1051	payment	115	115	115	1050	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFcviJVF9dVXxhjHT28z8zVMvuHyEFFozR5EdKaeN2Rq7r6qGa
1313	payment	115	115	115	1312	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWu8eukcdHuxZiMo1pLLxUV2LSKqdekJRdJoQc6o4gZieTfqv2
1314	payment	115	115	115	1313	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRuKfvzdXE2uXZE2eEwbUUadMTudACeUvn8kmzTCHUpzYUSQ1P
1315	payment	115	115	115	1314	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKMrcV5QstWHccrMjAsTSFZhg1fuRaPiQjTX5tC51sa8cohmQw
1316	payment	115	115	115	1315	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHKeJMqBkJLMhXPsMuR9PjugkRWvXECmoKkbrJzwk8xfPhaxt7
1317	payment	115	115	115	1316	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9nzRJAjxMtpY8ZFDo6KEJXSiheSmF7CmhEnbWPmyDtqw1M3s9
1318	payment	115	115	115	1317	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jto6jodxpGYtyKzcYgiAEWdnqs32AdNjMzUptdXkmgQyxrJA87m
1319	payment	115	115	115	1318	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDvbPYe76BFiJqxvZCyVRWseyxyvBRBYyptZNkZVCNN4cjf8hn
1320	payment	115	115	115	1319	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHeSCvuouYxtD5o2TU28Cp7ap7hkpdy6Cxrmwtrp8jBheLR8pN
1321	payment	115	115	115	1320	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMq43YQtDuGuYi8pq5Vk57dF9j41mLYsJxzYg3bPReqmJ7R7MA
1322	payment	115	115	115	1321	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2NX5jKT9sjiB3gnYZrEQFF7zALWruYz7hQg9BF8jG3fEx1oAs
1323	payment	115	115	115	1322	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv39MkWow5njiTgmJFKTBa36bzMiUdhSy8fC5u7nX5tW9XeLYpo
1324	payment	115	115	115	1323	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1tkLG7jNyzsHQjW6R47YyEdXYCTHWqH4j8EGU8dVti7YjdFrN
1325	payment	115	115	115	1324	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJZsxTzCKfPeVPvgGLZzrSTibMp7UMQPJmSworm3bfaaBkGpLE
1326	payment	115	115	115	1325	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoHpkfN1m824NXiFwXaC87sAC9Jm5ocqt4GkiW9MzDFQCYvU2E
1327	payment	115	115	115	1326	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukhkFygnDySszeTvY6e4YcEi4GFBjSj4uiP5QGP2g38CMXTtRH
1328	payment	115	115	115	1327	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JufSgsJA3xw1vPPLkaD9BbUhs3qsU9HSauGQebWyANwZ8zUURih
1329	payment	115	115	115	1328	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvG7RbEjLzedaYvWq7P1jkSYJBMCNwZdjzSvHrMeTW8v8EbmVB
993	payment	115	115	115	992	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju82ZixvQUL1XuiXzh7YzVN2CtmR8yLZbAtemLrQ5tJAmhKBoWu
994	payment	115	115	115	993	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2a8gJxGStjtXh5D5rfQxR8GszDiim1F7grWaTzSUh7kvRXCb7
995	payment	115	115	115	994	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtyeVw9VzUuMKseLFxuHtjDY3gJT3gE7ed5Tf7S5kPvqdoPsrVT
996	payment	115	115	115	995	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFwqmDD3zP9wnkS6vijuq4KTeBsyYV8819GQbaPGYgymY4vWfs
997	payment	115	115	115	996	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuetmXrN1bAPdkqGz6fj3jXXbD2gfHneXksL85LbvjxWkCxqwic
998	payment	115	115	115	997	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1dV1HGCYSGwV2hUVNkxCaTE5xVEZ7FjYS4rUvda4bTc4iuwnm
999	payment	115	115	115	998	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMXGcv62hCNmE3oQFR9xt25kEfQuvnYKM9y83gL1oC7vpgMJXL
1000	payment	115	115	115	999	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXdQWFqLPfFUNtx7j6tbZ3VReDgXefMgv32fok9FmhKZDKA9it
1001	payment	115	115	115	1000	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juaxs7HrRaSgodNwqZt7LmVEtgNyMkiTdWaXwCh1tekxaS6YDvt
1002	payment	115	115	115	1001	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtrBduQomU47CWCp9uR3SN2PuAMUeu1wKadsE5qUYewCHFMhjmM
1003	payment	115	115	115	1002	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuRcN9PjUdSo3Gg1cmvPMuzpxnmvQvsk1xQZhussRaosYjpsjqR
1004	payment	115	115	115	1003	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jth1Xed5DFYQ1jGCDfRgxsozAs3Z45kEGBiEWLi1NVPE6EBquyh
1005	payment	115	115	115	1004	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9uhXVgbiLLNRLjZoZGT1TeZTzvw1u2htxFbqXXgfg4ikerQGa
1006	payment	115	115	115	1005	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv78XngDLZoAG8uc3U6ySfsHM3soabhe7Xjbw4ij5cUxU2DgPQo
1007	payment	115	115	115	1006	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5RyKDt2wveFRTfBVqy5fTX4Nuw44sVg4mSMmfRkmUYwTtJuvZ
1008	payment	115	115	115	1007	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutB7PkVUzqFihKZrXaVEzjH1RxUzmjV2WRisNAG52QsCddYSgM
1009	payment	115	115	115	1008	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtpdafXrx9BNLBmcnKUPDHgjJLuekfDKVPZkHywmjfM62YGHQHf
1010	payment	115	115	115	1009	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMaR7oQCnUTkzycBKXvfQ8B98VutmMgJ3HNB1z5caHjoVXUdZu
1011	payment	115	115	115	1010	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8HoKnUiYsszWN4UqvPUNAPcykVrhS5pqKX3Cz6vFUqjRCc3Vo
1012	payment	115	115	115	1011	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxxMktJRFr8gTFmc2fXUNAoDtzNy6dgxedpKJwoCqwMEK9GSVc
1013	payment	115	115	115	1012	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtgYHcNn2Yp4446gLCuM9WEsQsuePFWagMPwnvu5Z7gut7MDSyZ
1014	payment	115	115	115	1013	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteVN16PjLNP49opRVXyB95kbhA4SEDyyhu9eUkGeq3MqEaovou
1015	payment	115	115	115	1014	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuoW2TRkgycurLdLEgkM6gALo8G7Y8GHAjKZF3fkemaie9M4TZM
1016	payment	115	115	115	1015	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGpD8pj5sz98FWXeVdb3cJbJKB2tzXvSgXFsCav11pJ1hDf4mu
1017	payment	115	115	115	1016	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxUVBoCr7HU7eEQsH6Jm2vS384T7QFEFRnkGoxft5KpN6v7eFL
1018	payment	115	115	115	1017	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juskb4GJoiD2gKfMu12hR3xdWoSNXk5twXE78TScGRTZ42BEGNq
1019	payment	115	115	115	1018	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnkiLAz9g8xCqibU3sSueKB4ZB9TyYNT8HJuQovJMTL2MmWGHJ
1020	payment	115	115	115	1019	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juy2BAK2Kw9etnMGpFeR3TQ9TKwEYZTXQBgV5gx5d1ymUeK8y3z
1021	payment	115	115	115	1020	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBDwH1RmQu9Kt876PSfgumX6mQ1zP7Tt6J5c6tGPPCujDEafQ9
1022	payment	115	115	115	1021	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtbRzq6MKc9F6ycnZpXv518PjfS9xtKsWzJZL4zmYBcXrRid1Dg
1023	payment	115	115	115	1022	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4fNh67Y8RVSdG2WLXfqh8MqkULCvShnn95GWXezSqvYRrwjgc
1024	payment	115	115	115	1023	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtd3pPCvhi6uy1XhMFrEQXT3zqCV1VTHQQ5JzNwCLqzXh8R3ffC
1025	payment	115	115	115	1024	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDaxXnGHspN5RBfbwWqR1e9FD4kZFXSi95N2RWwSbC3TWoxk66
1026	payment	115	115	115	1025	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhDthmv9jESG1uPi7dWXLGBdPHAW8KaW8WetYFkiKjsLzU5bTr
1027	payment	115	115	115	1026	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHwtDvKXmKYq2ZMW9Vtjz863oVUbrEUMmx4WjTQgyGZ1LduAC8
1028	payment	115	115	115	1027	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttYMHtpgNXELtgdUbHXiv7aKeyTVco8PTFUBUDJYZUpPD4J7XP
1029	payment	115	115	115	1028	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtmt4Crx2kADu9Y3cHoFLG62zCmend735uKtreWhTkfTa76sCB5
1030	payment	115	115	115	1029	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZ7Ug9KmCqbUAAEDVLbvj6hwRkxgG2grQsVRrwJfQwDUeQD4xS
1031	payment	115	115	115	1030	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJMWaNsEbHc7FuUQMELupNqYQRQvfrXVZ8TesXCG7avkabLtqU
1032	payment	115	115	115	1031	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2RX2CNMLJh7VNszZVCp914AG7vJn88mV3wVFmhbQx1PScnrTc
1033	payment	115	115	115	1032	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLeQm9xeyEJYhQ1qFstEqdcTEYquJWsYpQSwcJz9goCYfwreUn
1034	payment	115	115	115	1033	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfdZFqoDEY1CC1pTMsnxCnuf71h7WEX6UcrnGrNbXvqSQBLhcs
1035	payment	115	115	115	1034	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFrUv7nkoNiUA3PB4Hed6JYiShDVWSJMx6WEr8tkwWqNNfsmm3
1036	payment	115	115	115	1035	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucSVVqi8C7cYf4h4rVNd3aAHLfgoXWsSHHRffAwCS3v7kRWsjS
1037	payment	115	115	115	1036	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZuNfBhoZqB2dqYsEzzJY2H71NAsybMVQWW8vEXaNgp4z1WgnW
1038	payment	115	115	115	1037	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqqkELmmevZg1yfqzcVsaCMn4TN5MYB2mMYKwzFzaeqZGCRJUY
1039	payment	115	115	115	1038	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7bM1VpfSULoZAFn773z9i8usXomKGNr8JPQfJHExY3UHJ9jPC
1052	payment	115	115	115	1051	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRAXyWV4CWCNxHya1PRDYX9ATiymi8d2inEUdqMn8gyhKzzfCk
1053	payment	115	115	115	1052	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv91pJYV9AX2L5ueJpzVrf6HazEnMgu8u8xeBTa31CEzYLJxx8q
1054	payment	115	115	115	1053	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juw1dJhGFduzxuGvTEvBNC6BUhfgXFRuvWDGCBbmTJRWWTbmdep
1055	payment	115	115	115	1054	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3p8B1qJcvQUMFfEsjSU1cdpSXFv2fSewDmQ4jjhYnMewWKvxz
1056	payment	115	115	115	1055	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteXhYXmTRZyB3Mmf3ARQzT58cJkk3wMJrr22EWU9LSxqAoTaJc
1057	payment	115	115	115	1056	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHAn9RVDZwZmHGi3YbdbeQiJJ77qVspvE1xRGUyZ6z7C3ucB8M
1058	payment	115	115	115	1057	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jutt44CMQ1gGqchRWpFGqcyF9yLdkL9ZFxhDefXTUndVtyHucNt
1059	payment	115	115	115	1058	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKDAgdBm8Jr3EUuXBXHicLcwZ9Dj6zT4mhBy9LbJUsLCGBHdYS
1060	payment	115	115	115	1059	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmJvmMUtZmPKWykT2qwXcxT9HxAUAmJVYcB3PEBMAjkXLJDxxj
1061	payment	115	115	115	1060	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuScE8tmjSqTmXL9ra7QhxgAFsJctfhSyV18GSPQ6gQTfak9w3q
1062	payment	115	115	115	1061	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtc2fFFpNWABFmuUDvf7WPEMzB9abzYBTq3v76P7oVfVXRES9gv
1063	payment	115	115	115	1062	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv84rpKL8kXav6WcRuCBr1kUDNwKssxiH3wWq5h9ajUe4KYvXYu
1064	payment	115	115	115	1063	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuyR7Q2scvrPUiSopvgstmxxpGDs3aqmen54qCtvdK8nSwMzpFc
1065	payment	115	115	115	1064	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juk1mXz4jhhYyA4JsZVZgSRaNPQtH8wyRnMbhc8sKckGbP5yfEC
1066	payment	115	115	115	1065	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMZ5cgS12epTk5w2Ks9APCMrxrzXoGqQAqE4kTuJgWtwxWSP9j
1067	payment	115	115	115	1066	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWEAd3H96QBVoEbvmELoV58WSkrnamWxqNW2nUH8hS1xb2Cn4i
1068	payment	115	115	115	1067	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoFvrPWTi3zNxW8v6MW1fMkSaHNrAiiGe6snbSYW38isNLMhXB
1069	payment	115	115	115	1068	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jur8iLqc9TB8eeokUrY6qNb7e6nKu5BHpzTZeBeUPpW46dH8gmf
1070	payment	115	115	115	1069	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jugo9gaXi2PXttseV3WBvMngkaftdz5pzev3LWSWyfr6oFXQNSh
1071	payment	115	115	115	1070	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuccoCGcGFYrrxHghXnBixwERbQS2TGgAK5CCpj55er4D5TNd9
1072	payment	115	115	115	1071	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju98Muxw1SBAYMZj8WRn6kQE69k1PYP4yzJJQ123fwxM7T8YyLv
1073	payment	115	115	115	1072	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8eQGzXTTLRWDVkpTEHfjqMqFDHu8sirUyG7BgzCLVimbsKfBB
1074	payment	115	115	115	1073	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunVB5T4gTAeHYZnXwSiHE4hKQT9HZtEtPc1N3q27BNtDZeK2QD
1075	payment	115	115	115	1074	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Junxq6vzE4QMHNppnTAMHiJgQRnDCgRnrrczT2vZimAmpEE9axA
1076	payment	115	115	115	1075	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteUewcEpW3K26qNCvqZDY8pSSghq42ffcDu3eNywj15iqJZ2pN
1077	payment	115	115	115	1076	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLfoWdakWPopRqJKw763BdbFUDgFT65dnvqUeMH4TErSWyekVc
1078	payment	115	115	115	1077	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9zv4fnuuHBSbfF5MbHfj6x3toPnrDuEHKesJyd3omSghmTtDK
1079	payment	115	115	115	1078	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmywZcUS3Gk1hdAD4ZDJzbLAb9GU5Rz9pRic9H8XsyrMUiYt21
1080	payment	115	115	115	1079	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKbzeLMUvZPUwaznDjGQ1PJxrmrKqhxttR7tvriEWwjEbhujn2
1081	payment	115	115	115	1080	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuM6BYjv5YzDQGAN5XUJUEvufcxS9YwGc9sBKHUcw2ihNuXyUtQ
1082	payment	115	115	115	1081	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsH5WfYY7RW5bVmgYTVRTEiyECQLuw7L1rQnPz9L3LtrahiAJT
1083	payment	115	115	115	1082	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJad6jMFeEGx2sCCCCk1NpoYmF39MWUn8S2X3Q7G9yhN5TWKLo
1084	payment	115	115	115	1083	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtyof4ggAKW2xzzVFpNUTKMAk8kVLJTaDAh8deRh2zQHf5qEoRS
1085	payment	115	115	115	1084	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9R21Xgonfitno72RFEH6df1dqwuzbNSHum8Njr5s9i15w8yvz
1086	payment	115	115	115	1085	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttzgkSqtYPrEiWjv4DFc47bDJUDwQVDNBt3erJAbQdWXjKDCQW
1087	payment	115	115	115	1086	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMfvCzgzGp9SdmpPXnZuKXfEptdpfL3yDy8ofP5VMXKZ69nBqr
1088	payment	115	115	115	1087	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4qA2BqAhYMmxi8EFCDwiT1zsuVzBXAHYYPgGhh4sFVGnzyowS
1089	payment	115	115	115	1088	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3idLbCunN8U3mUnb8Q8QmmCos7MPx23oBheQtCoze4Px94Ao5
1090	payment	115	115	115	1089	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJsGhj24EaYqZqGgfQchmMDCLyX1Qk7oStHFgfHfVuPNCjACXi
1091	payment	115	115	115	1090	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7VRZJ5kNFGNbGZfWAGbwwv8HVybE5YUU5cwW1iroRHSNkf9rn
1092	payment	115	115	115	1091	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJgtKP1AYFPSowfph4j3Uyqo8CdoTkYifjdrhAatqVadM1Jt1e
1093	payment	115	115	115	1092	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAbimdscwZsTTG1KRrRjDDu3eYaMVFpWuUdpP9ZHykeLriJ4gw
1094	payment	115	115	115	1093	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuABvxynnDcLgYeqE8fqyo5igUEWRw2JP7VqyHxouHvF3TyP7nW
1095	payment	115	115	115	1094	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRn1gABNHRgum4YWQU3BN3ZebSsbvTdu5JUZJBTEXZcLjkKNWR
1096	payment	115	115	115	1095	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtpmtivhr41h3NAeUVSso9JPDyYfUU3gkQ6qHw58icRp9QRJ41S
1097	payment	115	115	115	1096	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJAwCiB76yMYYAWbFEAigWyezvTp8pNGPekomRvrUd7LJGyE77
1098	payment	115	115	115	1097	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYigSroCQC9xQsUr5Df7vpgUJ2c6UL2se78EkKvEu4NcQR7MLJ
1146	payment	115	115	115	1145	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjUeXpg2ZpEP6qpdrWFP7ukoc2Pvu9yNdzLBUKtBwPn1asofSp
1147	payment	115	115	115	1146	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVoPxbTKNu5pPLfwbAmrfuz6DLtN2TQUGPVySiTbdHr1oTUoDP
1148	payment	115	115	115	1147	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFjREvhdhL2j8Wr8heo5ULFoDyXKCwexppTjBoFSPfp3c316ky
1149	payment	115	115	115	1148	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8Adbz9Ttpmn19bnbfTc5yPVKxzEDt8wXwDc1yaJFBy4WRMvcK
1150	payment	115	115	115	1149	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLLffpWSb78QLXBHgHjwPttdrRzv9zcmJE3CuQL4gb6euuxgAj
1151	payment	115	115	115	1150	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMLuHacdx4T81RpSKuGMpmaCkU8DNZ3YqNzX5bDNnUyA98mi3Q
1152	payment	115	115	115	1151	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGRC8m7TLtrucqF6WVExUYtddDv6dd3kiKJS2jAVpruJDfDWbt
1153	payment	115	115	115	1152	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsFcPo3Kz2gAP8jrtStdnHTJMgynvV88Enh2eB3KwRVdkunDJv
1154	payment	115	115	115	1153	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuRe1wiCCA8ZM11fmGnGyqyGCc4VbnSDfUhenGJ6dhbaPcH2niE
1155	payment	115	115	115	1154	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuSpUmYbKNeyatNspMxRdbKHitny7PzNp21UTnRaGmrGN1khR8
1156	payment	115	115	115	1155	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDKfQQ453riYC9naMJ1WTLF6p62sMm23ZCRCA8T15assKoXF4q
1157	payment	115	115	115	1156	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jthn7Zt2JXDLi5WaBoo758R3vfAP7pJLsFCqafs59a9RMyMZLMc
1158	payment	115	115	115	1157	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmyJ398rqCxsyXpzYv1GxWH9NasVSH6sVQBznuNkRz6Wyzm53G
1159	payment	115	115	115	1158	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju79rUqB4yPqApMgnDeWHAsCSj2Jw46qrt5NhmDApKcQZeEibc3
1160	payment	115	115	115	1159	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jteco2wjQGYrGdt2gu6m4CaaLDSsnT8kq2VwzuHcYfy2dbwpy8b
1161	payment	115	115	115	1160	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8gGtDKRojWaFWPbfzoGd9znt7jqgjD5fuhhxkmQ7nxpT9bNBF
1162	payment	115	115	115	1161	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtzu8f4ba3yXrHSE8HMY5dyf7XYdr7BdAVjcomdvzoLTwJh8oTp
1163	payment	115	115	115	1162	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFadEapqCTvDsTnJLydQh2FZkSK7sXbmA1n3E9HwYfDETeN3MT
1164	payment	115	115	115	1163	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuudNiKXas3Mj7Xz1EQwyzdnHYQjHhR64uc2hAP4wSAziSN7sEd
1165	payment	115	115	115	1164	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2TYHeHnfuU6nHhs4x7G1L7RRrw51AjwDfmugkftPUexYMCnku
1166	payment	115	115	115	1165	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWxnLBffncKKuTYycwDAJNg934tDRzz7eNkMgKcg28uR9X8mbL
1167	payment	115	115	115	1166	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXSHsiDrvgj2PpYPurBd6JFFpcMVwi9pB4znmxpVVPtNPpXeS9
1168	payment	115	115	115	1167	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7N7Xx3R3urJubLsmcxLGqNJeNTbK5qoxsjgsR35yTbjWyD3dS
1169	payment	115	115	115	1168	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZnYCRXEPK52ahywHaqCjBXBTtTaSMJs9ko22kZ5WZFvPrYApD
1170	payment	115	115	115	1169	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtbHxv5J6ZpUzDogoFfK1GsrQ3rzaHCQq39vgNin45qLNLShjz6
1171	payment	115	115	115	1170	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmB5uMW1LDNmWJjkYb1LpegvCJ2ZkoKcBxsmPS6qHh1YQUJ861
1172	payment	115	115	115	1171	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunKqiPHww35MFh9P3tB62hhjCM1fEnHwj5qDn4xCNgqBhtRKFE
1173	payment	115	115	115	1172	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnZ1tnqwimyrfytLrYiqQFPoy7j7feRuEdGRtyFozRUgKrGvS3
1174	payment	115	115	115	1173	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuypL4z8QJt6aRYMFAy2Zb5dTmGdg4Ku62Bgh5b1UstRpPT6kja
1099	payment	115	115	115	1098	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPc91zJs1Hua5iX2UFbWuRCnwnxtswffyzEzMcaU3uSytS97ca
1100	payment	115	115	115	1099	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuExM7cuEwdTk3LxEha6Rh5TBoURFKkTAVm9mnkbVdE7BgKNUAB
1101	payment	115	115	115	1100	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfWaUYBKeFCeXnsMfzHcU1EmQyMhWoTntePUYMDUVjZ8jR6Ro4
1102	payment	115	115	115	1101	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNVDkeGgubbzjJ92hJWUz9tXa8VguiMBsaX1vnhi6oNTJ62sNd
1103	payment	115	115	115	1102	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJU78Dvj6FosfG4URynZVaLL2dPFEVCJcdcu6ixbHqtkWn7u3f
1104	payment	115	115	115	1103	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWbanAfwPBWPdDYYJsV4fQp4BBvRPEC3jH1KFumDdamHP73vzG
1105	payment	115	115	115	1104	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudCKb3pf5BJQ3fmMuVSEoirXmeTSPEFftdWmanAYVJyfTKZqad
1106	payment	115	115	115	1105	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTy29a6DnVtmJg7HsZEWpNnTNyRa5gH2WkN2AsVvHjHL7ZGY99
1107	payment	115	115	115	1106	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju62RC7q1mqjosd3ij5sQPZdhpfX7pzQuEdwnpZzJYthiQDcWXh
1108	payment	115	115	115	1107	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusETk1Rva3BQExP9gZPrbJVM48X2h55C94NkzDNYwWwFN9BxcB
1109	payment	115	115	115	1108	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteN9oUk2dTMYr42c62CGtrSRC9R8b43Ehmas639YtHfMcLYtqP
1110	payment	115	115	115	1109	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6LLEMW6uxbobZQw3FackNWUrtvK7oGuMv6V5uEykPsdV6wkuB
1111	payment	115	115	115	1110	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwoFVSdtvH4HdFpYVGUmrDbpRHqB4CKPHKRCSi4smZ5bchtweY
1112	payment	115	115	115	1111	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsNL1giBk6ww9KaCKZ5fbMu1pQ2nYiezFqwkGpviPDAz9Vf7bh
1113	payment	115	115	115	1112	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKsK7weZNLxqEAfgfwJcYTjL9zkB9H2AD2bKnRgGKMj8pZBC7B
1114	payment	115	115	115	1113	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtgqa663ofsZnsSb7byN6SZNndwf7NqE2Ph1L7wkyM7S8xzMMFX
1115	payment	115	115	115	1114	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQQqsZ7rpMxids7u3xsoaix32VJW9mS3TZMS9Ww4xD7dtfWua4
1116	payment	115	115	115	1115	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzapgNeb1UCwjJ7daSRFniqcEBPgN38mzAXxkNqVMvSjqgNiaG
1117	payment	115	115	115	1116	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4SxJbsg6bfUsRxyvafreUsL3zPBBmTQBJeeidzqVphsvYC8kv
1118	payment	115	115	115	1117	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jun6gH7jzcMqU4LL9isXiihqV26LogUXoJzXi1fKMucdPvxiVj5
1119	payment	115	115	115	1118	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvG6hMc2ELshJhMxP7QGdqziyNyLa5X8nvjodDaRzoJiUc3nbKw
1120	payment	115	115	115	1119	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLBbHrRvmarHziYppp6QHTG45heMmA1Sz5sHRG9hCwh3DxiHwN
1121	payment	115	115	115	1120	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtgHFAXtVif2jwDiaeNjyDSFHe3Vb5J1qjDYZo8hfrNo6mdgQR8
1122	payment	115	115	115	1121	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuG1Vry1ME1pJ9SSe83xjCPivkRJXxt86v1adAqRAyxg9Ah8YPq
1123	payment	115	115	115	1122	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jub1c89hsW8nbyjGhi196eBYgDSbuNSKMQrXtzvzLNqaFxRgj5j
1124	payment	115	115	115	1123	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju54iqTarc5noUPHDzfdAJU4XgFcNJ2x7vbsXk6agfrpP1VCEYK
1125	payment	115	115	115	1124	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtkiy75UC8AHruVC6BXa2f8NtHYhoeB73eRFUVe4AeDAmt8BPCZ
1126	payment	115	115	115	1125	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5Z8itrM7V3h3H3CFa1b8cdFhbHAuVD51RiLtW5hVcSjzAptfb
1127	payment	115	115	115	1126	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcZakGhSMx2fKJ3Xx1nsgbuy98wowDHPCuremZ5D7iN9ZgN481
1128	payment	115	115	115	1127	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWmRh6oPQdj1spyG2hbhgHuEKBuJV5exsGNbyLHkg6LoHfpbua
1129	payment	115	115	115	1128	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuoyQCs7kSB1ZNRNcFNeeFdJhxmzWDrzKAEFbMs3zH3SJfqGJ7t
1130	payment	115	115	115	1129	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtrf538cWQsw7Qb5621oMSqkSKSJErGUdnKmjX7Tw5tNin69W6m
1131	payment	115	115	115	1130	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1pw5ovsyewPHctXbUBgnEACsYWNwbu8vCpNkQtPXqZJEJVcHt
1132	payment	115	115	115	1131	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6d79N2boVWFsNXNjPjC8hGkxKck37eBnx58Q5syETUZQTfY1q
1133	payment	115	115	115	1132	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtst44zrbTrKKfixiU5ncAhzhUfdCsJHjbn75MbaxzRANWs6JGD
1134	payment	115	115	115	1133	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtepDRV5sMJLznw7pu95Vdn5iHUUbNSkh915Ndcbsq7xc1UMurW
1135	payment	115	115	115	1134	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkPd6ovYDiMsTD6cLwaUwfKVNgBwtbm7wWofBkhouX8fTt3D7Q
1136	payment	115	115	115	1135	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWj6GyPb1SEkNYtpoUQVy2FHn4FgCZGGGurGp15HjKKRurWDWF
1137	payment	115	115	115	1136	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBS5fgy3DEbx5JCRTHf9DRk1nsjc9mARSUrRWb5vo8bQCfAozt
1138	payment	115	115	115	1137	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFS9MzZwWgUMZjCKAR6saxWcQcj11Arc8wstmEXjTA9iE7eTQg
1139	payment	115	115	115	1138	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6a3cgGWfMUGqbR2XQ525DBehT5Chv6AFo5LAU4hZ5yLWDDKEL
1140	payment	115	115	115	1139	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9uuisnCJ8P6wXhgbyPFhWgb514uVXpQULXQcccFZ9jRKN4GGL
1141	payment	115	115	115	1140	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukFA2XUhDNDFVFJjHU3wzqTv8DWE5ydj3DG1AMHCJSgahaBFEd
1142	payment	115	115	115	1141	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JthCY4WsYJUoDgmLQ2JAnER1Qa8aoLSEitHmwjSMezKRPAhu6Gu
1143	payment	115	115	115	1142	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv76JEp13d3aMPXeRSAWsSEunaDAYB7f4A7J2zQz7ubdH9KpKBs
1144	payment	115	115	115	1143	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv793QpkgPsjM1jgLgRvv8aVqgXvZJiJ73LBysfcnJgVZviFoZ3
1145	payment	115	115	115	1144	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtpNMMkNY1RjtwrHUaWfxiXDTFnCtN399NNH2J7YyC24kriEiZK
1330	payment	115	115	115	1329	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2LAQA8Lu96v2n5pJ9ZtCCQcsRXXrv328MF9834xuWHgpgL3R1
1331	payment	115	115	115	1330	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8nMaPJ6rWSARQ7pjKhVQQFBhYcZWUg5RiG8QQSPPt7b9NL9Dq
1332	payment	115	115	115	1331	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucmutyPq11ymNhNMDNn6k2tNmFZZPwdXDN2Qi9VGbxGSjEx8Rw
1333	payment	115	115	115	1332	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jun1MJNbtmxCXRQxHRPhGkCUQaGXDZSo7yFk8t33UvwNv32r2tP
1334	payment	115	115	115	1333	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4wrRn5PtQxy7YU4VeyhZ4P4uJurohhuGzRWc749MSxMjFSf1h
1335	payment	115	115	115	1334	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuW6FVokMKWVPLXpqpqbFTTRcYHoH4M1taxM3qUdibYa2pk9z7S
1336	payment	115	115	115	1335	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtch1EQH3r6tP2N3kaCoqS6fbmsDJeCj9Z5zVyePeJbo3Z6z2hf
1337	payment	115	115	115	1336	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuV7h8NVJ2D5dy86pLBK2RoKNzRy6fycrR7NS1xE2u9rJ7mVee1
1338	payment	115	115	115	1337	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuszMokDorrSKS3JptydXDAtTfdji8M9254CpKdZuEATypuxUbM
1339	payment	115	115	115	1338	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jth9Mwukgx9t7YRqi6TRV8nkNxFdhy1HNv9x3yiojyqzi9KU6ez
1340	payment	115	115	115	1339	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1vbdCWNytQCbi8ny4q4GrQWybxaAQ39tfNpoJ2UA9Kgnwr897
1341	payment	115	115	115	1340	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvJraV2gaorgTme7AMMcfC3BQA3eeEJrABt8fkJ32zQs971nD8J
1342	payment	115	115	115	1341	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwTYpK5NTNUzGyaw7eJk2SDQ26h7toqQXTKtTa1KMoKQPSs5it
1343	payment	115	115	115	1342	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtiJBTffywAnKekLTpLyFCYuQpC1A1asnDgwBSVt8zJxU2Ziibm
1344	payment	115	115	115	1343	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtwpyn6DT1uWJiJLmmVJseuUcX8K22gXJzKayTMXDKzm4q5gbYB
1345	payment	115	115	115	1344	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteV732bZvcpAvXzxaQ9oW3fzYAHN786wwDVUhvXiynjyghxa8Q
1346	payment	115	115	115	1345	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9nMitj5roWFAwspUEhDdpFJv1mDwkRrz4CLCn6DeJNUfKB1z5
1347	payment	115	115	115	1346	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuecXpRkeBLK7k8SvsvLrSiRHYuj3x63A4QFvjNPu1HamKsyAR1
1348	payment	115	115	115	1347	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv61jG1xWM5udxyMns1seZxihoyGmtysCarS9vVWw1hAmJLtD14
1349	payment	115	115	115	1348	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurH4TXyw94oXjEgCwf9k3G199q8eNDoMTj5vmgBXkQVgeUk2pR
1350	payment	115	115	115	1349	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuowpmKSz9EQh2cUcNqBHpaFi54x7L4up2U41kAmJLRqjhAfKvG
1351	payment	115	115	115	1350	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuRuXYsCF4FTgceqxFEuPjXLSAbZpqhk8ZxS5MqbQH9sk839aQF
1352	payment	115	115	115	1351	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9MgHxrGQLvwnn78GZYMbotZW4roLFbAERAXuLVanLkwK4ELXc
1353	payment	115	115	115	1352	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusQM1GRcnE1cFrH8Q6LQpFB21QyYjv51j53bUwPVJb5BPYc3Ci
1354	payment	115	115	115	1353	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupvkCNfhcvTUvRV5QR8EJAGjNSeyZ3YZyPxL8nVVzg2xr1mjof
1355	payment	115	115	115	1354	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtntKmBqHghXS16vCHdMZAsN4vGA6FnG3aSs1cM4uRTMfmcfVTV
1356	payment	115	115	115	1355	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juh8pqDsRQ6dcqUq322ZSzchBQmxeVK6je51LN32AAXTDBnP9po
1415	payment	115	115	115	1414	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunY2XDSZ3MThKiQ59hFq6WgLUG5gNtKmyZcYCXxbVZoCKwKp46
1416	payment	115	115	115	1415	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju32UU7GZnBZ6CykUzA1NxC3DrrKd3jrq7z9mcUj6yjmwNg9VHW
1417	payment	115	115	115	1416	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtezhgKrkHZcRk9bGe5QPXuYEKcQKJpV9ZrXHS7v28r97hnwAE2
1418	payment	115	115	115	1417	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuoYmBBmLYZGBF6sAkumCXsD4zPayDQM5Rs2oD5V2rsTHXj12ZW
1419	payment	115	115	115	1418	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFX9rpVzXKVc6rk845hvhU9vPtzQRS1aV3ZSb5mP7Enygupfwg
1420	payment	115	115	115	1419	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmZ2J8S2KaobVjhTotHxAHXgnirzuQaPqN5JyikEKrUHkYCoBd
1421	payment	115	115	115	1420	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6m2Y5pxYaLBovYg2xikpmhfDVxym8eXmxR7KVu2Nkp1tZv7QE
1422	payment	115	115	115	1421	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZhwMHu3FxFGnm4KJHwZAPD8Jd5eG211nW8pcAFMtyrvemh5oi
1175	payment	115	115	115	1174	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3Xx2H4KnxY4zpy9jKeMmzfpzE9uydFSwLQmzxL1dbVkr6t8bo
1176	payment	115	115	115	1175	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEGi8HfPxWf3Pk6FQzafKghwLUsMGzqR2JzVoG2YtYRbLBQLCy
1177	payment	115	115	115	1176	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSJgNfN2wZE7euhD5kJAthei6XHrTGrSzAJus17vE3Z7k5M8ds
1178	payment	115	115	115	1177	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxWEWLz5C61bgD159ryER5YGKx16BVh4eEEFtsXgohDq82M3nN
1179	payment	115	115	115	1178	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuecACZdRtobmUrf2DJQPoZHSarAojrbT4u6Y94QCDfbVJVJmVr
1180	payment	115	115	115	1179	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvL7iRqtUbbY5V79YEL9Pq1qKRBt3NhUEQmcrkSWQkWc3Ang9pn
1181	payment	115	115	115	1180	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtyjCx9jRfso2snA4yCyvbx2m8UoxwwMYpZVUkCF8Y4ApDJ5sBS
1182	payment	115	115	115	1181	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju94V45ayHASsRakEY1p8Uxz5q2RCKaLVyUZuYT9x1QzeGz2W9k
1183	payment	115	115	115	1182	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGjtJCnDLnREqbK1LBmgtosr5e3PfSHKJ2BgCocNtxHmFPWVpT
1184	payment	115	115	115	1183	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNXsWsWSE9d7q9eZwBohuZcCmX8EUVZBgmQ1V4EyxNrPQ99W5V
1185	payment	115	115	115	1184	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWvVgeyFRT8vKm6TumZw53GaG6vpTrW4WtKEi9UvwFcHvjXoWu
1186	payment	115	115	115	1185	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juzye4x7XnquSmoFbpyPCxJUqse6KYfsBxys17yxmMjULFzh58H
1187	payment	115	115	115	1186	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3K4oxyfnXS4Av5WUSzb1HuHuzZiFLz5qTwosY4RSVmjDVRU2S
1188	payment	115	115	115	1187	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWUMZ8n1i6GMRZH9vEv6jFLouW6E9JBpG1QTwaRuukavahoUUg
1189	payment	115	115	115	1188	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudzyUNXbYLJcJSZ6siLuw56vF6jKvjeED6gu6twpadMsmmRDXN
1190	payment	115	115	115	1189	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHhPoGA8i9haMeWPknx6EwMz4dACcvxeboK4J1g7DPAmd3LEjf
1191	payment	115	115	115	1190	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7RhndbWMZojwsrRtNpKJDyVZAZAWFVx3yK5oWGmQPAAVYcjjS
1192	payment	115	115	115	1191	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5tAa2kpKavgc28fr9i9FCNkFHapmWQ8wXmqgGTojLn57FbAwE
1193	payment	115	115	115	1192	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvNLjyNy23bNCrJydnK9fCd4XzarSyt9sKz1SB2qoAxBRqDQA2b
1194	payment	115	115	115	1193	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwTtwGs36joUpoowT8BAWeopQFsi3Q2JiTL6LtPXXvauSL4s4z
1195	payment	115	115	115	1194	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuGSosR7Ru4SwgghiNriEmj1U3ep322DLbksdtACvBy6QFZ2mk
1196	payment	115	115	115	1195	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8k57AoQBNXBUq8KRo5zXMeUgWSVnkhPzrdfMZfxsswgpqyznh
1197	payment	115	115	115	1196	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtw7mbFnHFQDLfYVRLMrbvzzXgdRikdcjw5R5nHPLQi7R3PZrdj
1198	payment	115	115	115	1197	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEJstwR5qu9LgTq7zLPLwKkL9UE6ZU9VYBdozHysfDvGHj8KPJ
1199	payment	115	115	115	1198	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtcw3wYEi1F5beo2rQs15agJY4C38FWgkQ6XKTRS49WJMQHKz8D
1200	payment	115	115	115	1199	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfWoFeDNkwui6w3ZQt8RBhzGvzszDq88N1gyN4iEMzYeXFN2yx
1201	payment	115	115	115	1200	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMmWL8AG65o6DpcgzAen9nscSKbctpEh86QDT8Tfqun7V3ToPS
1202	payment	115	115	115	1201	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubdKsN7WrEWWBopa9ghWqzfxA1jyWXpeE2fo3g6cTVeh9Y4UX7
1203	payment	115	115	115	1202	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCtuJ5pGQW1KeeSDokMPDiV9NL4g8NQ1HiJ64CTFXDzAsUa4Lh
1204	payment	115	115	115	1203	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupBhnWJoTMyZYXDYEsrytd2CTnvBu5oDrbABiWb7XDcrsomKtC
1205	payment	115	115	115	1204	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtp9GdpmVJjztamrGu5DYGSv8UDDRYFYs2J4cHMbS4zeTKhPt5E
1206	payment	115	115	115	1205	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWQ26W9hJCcp8Mzyr3Gr1EnwWSfPUB3kMK3cudUZdoK9zTqGqN
1207	payment	115	115	115	1206	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPu5fBcSds1gJgQdK3HwVYvUjsSv6F7tKdKSQmF6ZoPzSMrh2H
1208	payment	115	115	115	1207	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3cM3aehC86oCuYBzWgbAEaxKJXWPNGaiwmXit4w5Uhq3vFtfp
1209	payment	115	115	115	1208	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnwrrDcA9bQijqZ66nXsx2LL74PK1gTgqtX3YCENGmKs3FE6DE
1210	payment	115	115	115	1209	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8ftDpJbwqi7Qi49iMymUHqe54KKyfm7TSJbQH32u6f2Pa4nwr
1211	payment	115	115	115	1210	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtz2RsaVPHkNJ7i7b1aRHn11v8MSie8FBxuLaoAiJ3gY5oHxdZt
1212	payment	115	115	115	1211	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTADV6UusjUa7u4pPi9hoAnm94pwQ8xp7QeZNCj3dPhLf6sdBh
1213	payment	115	115	115	1212	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtaopu7nArXcnBFg3b61QkN1fyXYAVNSS6JxZ1dRf79cvWWuAsJ
1214	payment	115	115	115	1213	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFKawyzfzGqYi5r8zRW4iY15UQVJB6HVqwgXmXuxk3539gVNhQ
1215	payment	115	115	115	1214	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUbRpZFPG3hbRy7u3yS2VQDngguwNXWfVLJ2KBtww9KuJL2SjQ
1216	payment	115	115	115	1215	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTrMeJZtR7UkG6K6tSyMY3DiqjDTVHQjUCVphfdjhmeSkQs9WX
1360	payment	115	115	115	1359	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkbB6Wbr5Yiw92Y8fg2N4wLPZmLZnWcjQfWuN5KZp2p2WgA8L6
1361	payment	115	115	115	1360	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuaMEzH7a43AWWPb49VuEGCqzXy9JskCgjYLCmEUC5AJ6DK7rkt
1362	payment	115	115	115	1361	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuYGKC99gPGg8bfzp3WbzjxUkb5bzRV38ddDbrEGfARD5NqAnx
1363	payment	115	115	115	1362	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1ELKkFMKqNdXK8QGV3KrLeP76htKkTYMPDVnTMzTECSbMqpXt
1364	payment	115	115	115	1363	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupKj9yzZueqxJmWLkGoLCtt7GKJ4i9y53chUrEfb9GS7yKCGZ4
1365	payment	115	115	115	1364	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv36UCmdgQHidRsdweLsUxZG8suoH9HuDxj3uUKJqdz77LHgbZ7
1366	payment	115	115	115	1365	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLoDbMcyRPhhxnXCd6ki1aaYR3RAZGdS6GRT3NwYdEBCEHmFp5
1367	payment	115	115	115	1366	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAAqr55fmdfT9u8M2zhTCvAFoV35nusGXYwLkes6mZwnV3V6vq
1368	payment	115	115	115	1367	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5cAXpz8uFpJNyjWzYBqaYgbvd6a4gkUygD2Q2AbcmwhgN9mEa
1369	payment	115	115	115	1368	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfC8AsiUzYPvHhKZeVzkQ5c74n253DDScb1fT6i7nmPKXPbPxJ
1370	payment	115	115	115	1369	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuET7kaQH5kPoJDjcjq2eA4jwo3NC1afUuCZ3yUh1P7XyoxRz1h
1371	payment	115	115	115	1370	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzNat2QobfpfLdUW9hcq7ASXxbC9k5YW5HLVSP6dqyWLEC9EYC
1372	payment	115	115	115	1371	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3buXM9QNSzZ8pfyUZWShiSah6jDLKHTaEDFuTfViigydR7Ay3
1373	payment	115	115	115	1372	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtcr6PYqwi1hU4eCbKmFviHSBYB9iL83St4FS12cxqEeeWi33Gp
1374	payment	115	115	115	1373	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJCMZr2knJ4TWCzLXwWzGBAy1xB27Y8jM8vj6NiAifuA7q4WGZ
1375	payment	115	115	115	1374	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHJ9Wogrr4cvhpH4U9AiYujN8Psj8WoCuE8CGJFFtr6edCQ5oj
1376	payment	115	115	115	1375	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSVR94Kym5PrcH7BK3QdsETpmBgnBvcPcBPAT3QvSe2HB85A59
1377	payment	115	115	115	1376	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurxuR2evs5CoSiHqpry3kV4uq6DrDVr8M2ETAY4uoyoqc4QrTf
1378	payment	115	115	115	1377	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEQH6h1CHeQUEaNbHMAqCDcSV9RBEhfWkas1NhVmnsyE2mpvpQ
1379	payment	115	115	115	1378	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLZiRtd5yoziuPKGcTUciknFhQtMCKqMaNZEsbVzq3Q5456CVj
1380	payment	115	115	115	1379	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPsayT6KNxqAPLudq5kBChc5PqUmrrMyirRSDSC7iELujoEKak
1381	payment	115	115	115	1380	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4VwdNcZTrVkCVejs43UmEidD6LCgGDDX38XGYw2mvPak7ZcMN
1382	payment	115	115	115	1381	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtxVfkaYLqdomwvtbH6Bb57VGBDgmZib74cPFs3GEH4U9jEJd6G
1383	payment	115	115	115	1382	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7eUeAicqopVB6gfvr9vr1heDSwkKmTeU4reoETvsdQfj5gJXC
1384	payment	115	115	115	1383	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7RVBYGoo1SqFQD6UbDzwBmza6qeS8W59zC9WZQBHb3QJimJFj
1385	payment	115	115	115	1384	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8QRFJpW5NVj4zWgy5qjixQ8miQdmKGp4NMM6PxwPYGaErZbqh
1386	payment	115	115	115	1385	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZrEyTPkHZTouvbV77Wmsm9neLQVCW3ZNajGCc36vPyosc93rp
1387	payment	115	115	115	1386	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFHKnDqXRMx1Wgxrk1C5kF9qR4KR3UCjsCHeVpGRNvDV5Cbpn1
1388	payment	115	115	115	1387	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEdvwhxzBMZ8c5JP2aU59KqFAQg4Ccx2tuTF9kZt3Zro1fJ6hL
1389	payment	115	115	115	1388	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7T9DnTSc9iBvRzim47GDKgTL2LgfbCmtvEht2ZVLegzwqPV8t
1390	payment	115	115	115	1389	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDTKDpP8RAVNeAQXtPHsMGitq1CKa3BWasBahrcWTgGU3RcsLt
1391	payment	115	115	115	1390	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2JU635k8jjwb786yqy39ZLULVA6XA5c8wmP46UqNba7weHxEK
1392	payment	115	115	115	1391	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3pKopewpidDtzqpHCpJi2DgiP56iFNDgY4odjjLcWRk4zCoUF
1393	payment	115	115	115	1392	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDCFSNhjMa7R4tdVyVQgCtyF9mKHwYq4SSBxqqUgnVEgEqxwnn
1394	payment	115	115	115	1393	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHPEzpzvt3XyHnroXEraJer7zgfBNUn4hhDegQZv4kSizq2GWa
1395	payment	115	115	115	1394	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEDe2rZyRSRJihYiNYnAGEuBU4ejRAm6pLMmr4nEZjxMn6JaqS
1396	payment	115	115	115	1395	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6kGW2JsiR86Fc6npNinRMLEZLR6wT5YsTBVYzzGTvB7payx2k
1397	payment	115	115	115	1396	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfX9h9JXk6oP6i61KTDcZUzpNKDCqUi4PB1RFiMf615v6YgKoo
1398	payment	115	115	115	1397	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTmeHbA7ydFuG2VjarBCCXUqFB4ietjFiQ6PLPJXw9P1Anga73
1399	payment	115	115	115	1398	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSzW67RxYHpHkRbzLDrVjaveRkZ5b36nJRnhYZq5HDh3SKPFUb
1436	payment	115	115	115	1435	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtfiPgpRimBf7pnh5ayh9Ei33xajfGvEXoE2P9ehcqfqfnx8nsT
1437	payment	115	115	115	1436	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhDQN9yr6FncqpkSgpWADmS8viN1FFcQwya6tuWjUFNwVkBhWc
1438	payment	115	115	115	1437	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsJ3NyahNPyYAVgYgAYfb5pTCXVFYgYiTB2QUpUpe6ongzVgAW
1439	payment	115	115	115	1438	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoNVPwLSYsKQ1bWNGzY62SVQgrkmBF2kbo6ARfxWQDis28bThM
1440	payment	115	115	115	1439	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujTbnTVfX8cUg9oSftyN26h9gfX4az8HJqcyzB2u1j5TS3tnk2
1441	payment	115	115	115	1440	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmqrHbyMuMaH7vqwQcrLhb15D1juaZQP1BXfAN6vVmVTEHmVTW
1442	payment	115	115	115	1441	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvA6R4bk9wfToXW1xcxE8Yncda6vvKgyw3bKGpwwSrxXtxKtgzH
1443	payment	115	115	115	1442	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkJeDoSqKbk171C1xDtTrn7GKu1QdyzpnuUqUedguLDgcJBqcN
1444	payment	115	115	115	1443	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juc6T8uAsjhHFwmsaELj9CsiadrpcGXbMFyK7Cs2gzif8Cydpae
1445	payment	115	115	115	1444	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvX1PBYrBizsaf5SBe32y19AeUA8Y7AvvQpQeecTEWURwi4Lpv
1446	payment	115	115	115	1445	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuafhwRsXUXs9wnDoapHeEt88ukv27F179RwPDqKJkZQ6KQiVLn
1447	payment	115	115	115	1446	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3sD5HbJE2WGLmtwHALbnKAqSa3kRHyefCssKXk9uULpbTQVQV
1448	payment	115	115	115	1447	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtrx4NyDdyU6qLoNmPYJ1F5hRWgBP2fGW2sTeE7YCFxNypDDAGG
1449	payment	115	115	115	1448	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9WENJjz3uHrwY71iH746D9psHTmEFuisLGHbxEbgtsxSRZLoe
1450	payment	115	115	115	1449	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7Jb8PRvG79QUC2aNtVJALTnhW1bnAb8oJcffNMKtMBfj71xRr
1451	payment	115	115	115	1450	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNiPD4piHUszgrv47mpR1UtckTdoffNaLWHyWs6sTemJZV7FKN
1452	payment	115	115	115	1451	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtveSuNMD84DX9d59mNazx4eB6LFykKkmyCthkwsTiho7cFiUqp
1453	payment	115	115	115	1452	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFPk71SpAjExhSwk645KVJu8J6Vhmhtx9B34bKZ9v3qDn5mqTo
1454	payment	115	115	115	1453	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtqtUQwPyMzS9c9Hozrj95cMhEgrPMLs1Bz9Ezua1AiLnFTZK5d
1455	payment	115	115	115	1454	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtn6ZWXNjZiZWxicpqXcVkGcK74smJ3933ocrcR8gDyXruTpKQq
1456	payment	115	115	115	1455	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDH5788d1xr8fiqvjSDDWgSRqDSgJwhvHyUbRUykye4gcvM7YQ
1457	payment	115	115	115	1456	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtajN4x1bNoaE9spix84q6w8XGRyhnTqRCeMxnjRinmcvkC6BVn
1458	payment	115	115	115	1457	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEEhxLu6UKdyvH3BLAYLmUmbqe5H7M7N9obxht5TEzNo4WeG7x
1459	payment	115	115	115	1458	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcSxxV4aVXgkhShgtzUJdcTxPsn9eiLqoLnrGeBAJqnNyW9AsT
1460	payment	115	115	115	1459	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuRwehszbYfeWbC3PrJJXhyDZnrGZiSb5QtZ9XQLiP6WBLD5Boa
1461	payment	115	115	115	1460	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuA9AKL9hxqsPAdptSpXhGn9DfVk3yFAj9gWjb9c8xQCABVECsb
1462	payment	115	115	115	1461	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtX6Nun3benVzcD8C5DxSrSHMk1gqjcSCiGufyZ7wtzHPYdKg2Q
1463	payment	115	115	115	1462	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuK7rRBj9PJfeMDA4UiyMpVifu8Pv9cpnCVa8WJ1KiLL1BSbudj
1464	payment	115	115	115	1463	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jttv3MiaghgRxd3AKZXqcmTdbAni7HghRcQvpUbKy5u1253zPga
1465	payment	115	115	115	1464	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6cn7Sg2BWvryaXFYPaVgHFn818cruQh226yLXL4nED7HbsnY5
1466	payment	115	115	115	1465	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6NfUjsCWh5CKtyTQq3A4sSqMeTR1EnPXYRSQzrSqctKC73LCu
1467	payment	115	115	115	1466	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPm46E5AKwwcQ6jcGjXN8CHFAK3P4WPSnGveiCMA1NYYGoZAMe
1468	payment	115	115	115	1467	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jte4q7MXMWBoyDUHk7CUUSbPXHe4T3r8BsCBaiooB7i9D6aTLN1
1469	payment	115	115	115	1468	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5UEqyZZoMY7z9rqFwy27iJ6kQrW5wvxTN9Uyb89gHwanLNnrR
1470	payment	115	115	115	1469	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5gEF9w4RHrWJgs4R9Dz74hCbevr9QsxWhXzqPrgrZqFtMsGFX
1471	payment	115	115	115	1470	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPFvChiju7gvJdL4ZrkUivi9VrRMNMXWFPt6dhLF68fdPT22cg
1472	payment	115	115	115	1471	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRN5GGQmZ9SiZ8mn6XhQw2mzPM5G4PexqbsNhwgCVPECANhkPt
1473	payment	115	115	115	1472	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtneX8reWotK7RYpAQPdCZcZargj1mEeZ2oHwjoWJeZWgn6Y7hf
1474	payment	115	115	115	1473	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYvqckUnTxn8hUde8mCigpDiWGwrFDhZXZgBeVTju5FfBZfkwm
1475	payment	115	115	115	1474	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucJrPpMGpQgWRwkpYFkFgTguQmJZVgX7a92BJLe2UkWn5h6rnL
1476	payment	115	115	115	1475	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvAwaBgN4cJ1qUnH4S5knGBXLQ2WenorZFyUDs8HB8f3eNFFZMH
1477	payment	115	115	115	1476	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuStu9ND5UPwtX4xHpmgo4FD1z4m9GWHzcaiUPF2rxpsVHquJis
1478	payment	115	115	115	1477	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEbZMzbCFL8NBTVW9GHsLn4dX6oPi16dtYHQJEd7wkcYUqJHLR
1479	payment	115	115	115	1478	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUU3WoXch34Aa8hZw4hH6hmvGkcR8wJyFSLRazt917JqnuSEAg
1480	payment	115	115	115	1479	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttLjNs5Je84aA3KjowUtQmsjCtDhMSL2VvfoipVNoaqZaFt6nb
1481	payment	115	115	115	1480	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXBYnLqPtTHi1NXT5ACUqEo4rpCya3bxRe3t71YjHrDGXMLFae
1482	payment	115	115	115	1481	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubKYvGFZjhiaegNQUuPoQPPWVCm5ek2MAtTkU6BpLvieuf7xPS
1483	payment	115	115	115	1482	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuekGr348S62VUubcPetoXFyXsF6QjvZg3ZsEm1MXSsxzqPhRsy
1484	payment	115	115	115	1483	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuzmdMjY2idyuvu3RnBb3cWbsvzxuMj9GQ8oTF3gM9D1fexudp
1485	payment	115	115	115	1484	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYw3V773e1sMd8orZzmiU1UW8gkKemQd3NmZrzfesPeLnGAHSu
1498	payment	115	115	115	1497	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudBVoqAvtXSsLtWNJ1XMDnXPPkUDvkLgaKv724MtgjWM3prRps
1499	payment	115	115	115	1498	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtpxqyhKzwjAtWAoyKvb3Hmb7RS3MUymQtWc6UFJchErxi3FcFW
1500	payment	115	115	115	1499	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv85kPpzQMosZVxqGag1Sw45TzvB2PzDfG3Zzouc3my2knWVTb3
1501	payment	115	115	115	1500	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVrp3qpT8ZkByjq8mWXvzizvXdkynJxmerfFsdR47HvS1pC95n
1502	payment	115	115	115	1501	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHfeTPi7poyh9YTD8rdenGcAjjgBnQMZAK2knJijakp69dvzwH
1503	payment	115	115	115	1502	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzTWLKnqocWB5QwUhCPT5q9QExbxsa7Jyo2vDqtjKsCFMRzJEJ
1504	payment	115	115	115	1503	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5mtU7wJ87Q1hPxwMe4f2tBz6KLyuyB6SA73bqAY3gMXJUEUnU
1505	payment	115	115	115	1504	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtrrG6y1cbkBnsDrYEJRxCSyD7tC4KB9ZoiZCyjc4DTbM9qhfT1
1506	payment	115	115	115	1505	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupjjBQdd9ynKe8M17G4gFn1e1PeqRqc3kNbk712vFTEjatZ62Q
1507	payment	115	115	115	1506	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jux5BZfsY4GdxmwoLyDc6dVAT6W7y6bWnxKwhq4wvAY5y4wEsET
1508	payment	115	115	115	1507	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRxERBysQ4BHVhbwGbWyrMPnhu9Z8WxS5E19T8faPxM9dRRen3
1509	payment	115	115	115	1508	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuBv28snzeBxae3fynJb2r7wPSZm74kgPF5xiwm2mbkcMKDoY6d
1510	payment	115	115	115	1509	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWsez2F3Z3AADVijs8fbcQmsgL8UVY9tdyijTfLveSGoiq8uUu
1511	payment	115	115	115	1510	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuogAYbpRCu2ryXSUK7tV2SrMxfhhE8BZpfJ46bZAsgkQp2xkmo
1512	payment	115	115	115	1511	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiwovpjrVYa3aamR2nSHdANXcMeVpxBrhDzGTfSXBwFjknifCX
1513	payment	115	115	115	1512	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6BekB5b1MLiSJiidde18eL8WB7vQGPwkeZtPHfiVdT2u9VMYW
1514	payment	115	115	115	1513	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuT2Hu6vaZTe4qwtTznrZNKW6FhJwU3UwYifw1qB628Ebi8zGwH
1515	payment	115	115	115	1514	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLNVeu9Rh7uiti3XXhyyoBrASyW6u1i5Gyg8Y7UE1KBErWnN5u
1516	payment	115	115	115	1515	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkD43pzPgxSQruSk3VLMp8RVqviMs7w9rNwyDdo7kwZLbDx4s3
1517	payment	115	115	115	1516	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttYxBQ4BMAb1j7VDvWCeS3kCQhrjKM7g6woSzQpUQ9RcWJcdM4
1518	payment	115	115	115	1517	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juf4vB9WxvhFLBq68EbMuYvWGywhdMAqoL1y3RpmwrYchEiXTCn
1519	payment	115	115	115	1518	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJzkewhBZj1UjwCpzibaBEQEkELJbFhbHaL3ivJXP69X38e1n2
1520	payment	115	115	115	1519	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1u4zt1SLHWcnYwtLzHhqJCT5rXEzfSBEntiLvP2D7vnwrSA15
1533	payment	115	115	115	1532	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRWq5eox7JGZ1hMzAk23smrLxqgMyAZqfPgK3PNWRzCgnPUEQG
1534	payment	115	115	115	1533	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxGs9jNTyhetXed2tLbCFd2wKNxPJfBDtVjsxoagMWtRBgZZnj
1535	payment	115	115	115	1534	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuES15WGcRwFCVE8ge8d2VcwgQvoLtaTqAoHneNZZBxL32kmCk9
1536	payment	115	115	115	1535	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFH26GuEmuL6NwNFEG6nwtbqsFdPKHzajMTqHbfiv3vAHqLMtW
1537	payment	115	115	115	1536	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJGhbAUCnnBx19NfdFK9a8xKyGHv7Y7oyJ6R7hKDbZU9CpHqmP
1538	payment	115	115	115	1537	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtgh9KZwnr25xXp5J2Pg3L1HjxKokuw4ENHqPFoPoTrHm4XGBmF
1539	payment	115	115	115	1538	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuefisrP2p5jc9TTrbSq8C2a6R98XBqVXEVVMxk7eQMHJxK4Jb2
1540	payment	115	115	115	1539	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRu711R6oYe9LXJvZcLRqSVbHDnWMYp14Em8UkX7WSpz1RcXZM
1541	payment	115	115	115	1540	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jub4vtpF2paAX5DkdXKmxEm1gmVM9wbmHZytDU5kDvC1Mkr5dLx
1486	payment	115	115	115	1485	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMCxNTx9vgv5R3rEHykaMLxrnArtNRpY6NSzuzJxHKdZtiwfT6
1487	payment	115	115	115	1486	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukKp6a3xsD2xafSBJVCm8nFGw7b2xJsCkeoaFTrZ8min3CHqs5
1488	payment	115	115	115	1487	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVfKNGETNvnvpnr2M4EEsb2WWBVjD3GqwBEHCffn5B85HnMywQ
1489	payment	115	115	115	1488	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPZJMddZgj8cuKTJxkBwNpS2LtYLV4dRjrfWEna3AyvGsTCkq2
1490	payment	115	115	115	1489	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwbfptKwNLckVWCVd6ahUvZRRyXy2iDPmiEusWTzTrK95BbGNE
1491	payment	115	115	115	1490	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFQamUEkZ7Q9m3cxWJYuVqBhBcQtfPo9cqyhkTPY9bCCWHk6aA
1492	payment	115	115	115	1491	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3htVpJRoqs15wYCCHc6Bdpgzi4S7fv2wLGv4TpoGHNMdYWnSy
1493	payment	115	115	115	1492	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JufVMLCKwD2gomd1QE4XJBBcnno1gMRWbfrafg3rM7SCdDsWtdR
1494	payment	115	115	115	1493	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv88mnQekwbqnR38Q4xFuj8Eh8NMaKhzidn27mRpa1S1PnJG2cs
1495	payment	115	115	115	1494	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGzgL9V79mxoZ95qsSPmynCjSxHgqXnUajRft42rbXPDhpDSfF
1496	payment	115	115	115	1495	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsYjPiaiCjC4oVCjQqgeZwFxoSJqUYxYu8k48dy5nbxzFSfcxW
1497	payment	115	115	115	1496	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtgE9aWstpCvG69EfoEKLbHXkfLT55w5jRFpsQGu9ppofVkF3zD
1521	payment	115	115	115	1520	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjnP2urprBTMeeU8HM2R9t3h4y6TCz4MDvsQQPpsSuRAUeVhU3
1522	payment	115	115	115	1521	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5yeTcMDf6Bd7RKNnMa7jChrfJZxiqCyM5JuifYSxCdTu5Z2we
1523	payment	115	115	115	1522	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv98pMkTPH4JS6RctyWgxBnPy7YhFt1ENqbxkwyqr9FSp15uLuw
1524	payment	115	115	115	1523	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvG4yTo8MdvEfxRfXVroTdyGBJXHqAcxEpwRM8eraYkyiAhgcSq
1525	payment	115	115	115	1524	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGrtMEooUQ47QiikwJfDfknwi6YCwuW7HvpM2cBrQ4ir7x4RwE
1526	payment	115	115	115	1525	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPyDCgFugxbD741tEWzeUDYpQzss7eNLhpmFDPDe5y2kidLAv9
1527	payment	115	115	115	1526	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMF3K7mS8wGKWuwPnFCebVpbVXAwv2Z6XdkzmXgm8bjCN418x4
1528	payment	115	115	115	1527	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJrpLaSJPX3kqvW9qZDwMbv27SVLdZnpG2MbxGrUiTmU63ChmT
1529	payment	115	115	115	1528	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5xJhpn5s5wmHdtDDUJjcDJeoMWUQQgGpPZ6QYJGQ4vwvcWrar
1530	payment	115	115	115	1529	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8dFUP868y1r7rkC4WhjKy3Eok1Kfmigg9NfBdBvz1KzppweDb
1531	payment	115	115	115	1530	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuH8fadfH8AMKHsjHYCVMRNokB4YrNriiXqhuLGKr6JXcVzeXdb
1532	payment	115	115	115	1531	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYPDtyg1puoz8AtDooLPHobhMCa5fX6DaR1tLD1SxRxME7Xj83
1545	payment	115	115	115	1544	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSdPL1y3vY6o3hYy4cjABbcH7uND5BNt3ecFd148UXqHnGhuhU
1546	payment	115	115	115	1545	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunQbs5Tzu2u1Mrsx5bRJ14qqefnHa3Xbh2xewQ444cXd6DKkiY
1547	payment	115	115	115	1546	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju14qfRNb1zs1LV8CCGP7FKdpFeWaRUCKYnyQJFoouNMoj5Wato
1548	payment	115	115	115	1547	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtbGpsEdkuDe1e97UbrvFpZBfJ1BTNnb68nJTQwW4eCHYoDpev6
1549	payment	115	115	115	1548	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6HDGCZLiaeNQbteGs6fxQBiDNachBv8H6HTALgAAZ345hMM8S
1550	payment	115	115	115	1549	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2xpWAJRSsVaz4RqSNXTaDr1YG7Dd7c13S1GXDtCDuzD7TGumv
1551	payment	115	115	115	1550	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5j8MD41F9uKLX1FxP6gUicUhv9zkqpgX5kXtMNHnyCZ5wZot5
1552	payment	115	115	115	1551	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8hU3NRRAJjH4RK4KPsqH2GKANnQwq9efCmg88HjjRGjx6jorc
1553	payment	115	115	115	1552	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDDpxZ82GPmsNvNDBsM3pS8JyNmkq3thd41Nz6FLZP497nwyw8
1554	payment	115	115	115	1553	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHJT8XeNxpPRfU2rjM4S1aa7EWvrgRGsKPDbiCC5JM2ftFdPYL
1555	payment	115	115	115	1554	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1YJsuQZ8YWa4w6p62f5HcsEw4hZdn8LHS3snpzgSSmFSGpaGf
1556	payment	115	115	115	1555	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVhkxbT9pFqdWGShJM4qD6XffnxjhBfebpUGLYqKFnMSpi6ha8
1557	payment	115	115	115	1556	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHvRZzp3CSMhonHY675gE6EYVFH2joXAvKSpdqEr7AKU4Ki5Y1
1558	payment	115	115	115	1557	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuGNqgCzd5j1ZwbpPwB3MxxneFC3R1MWYYM2wXaabAG3wFBDtg
1559	payment	115	115	115	1558	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9D94LY5vLJPNw4DKCUHao23SLfP1gg3atmkhsB4cdogianAUs
1560	payment	115	115	115	1559	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYdZ9Dq1CXsCK4aYfEY1m1qUzwxkNA52P6XBZnxtHb638adPWf
1561	payment	115	115	115	1560	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGVsjwEsmAspJaA2vyB3UQtN6uSQCsRwfrfhEpkYrriuncChmW
1542	payment	115	115	115	1541	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZt2cvTDwJS36bHZVvvYCPvzhbPUikNdLqL1cVX5RM7u2NMMox
1543	payment	115	115	115	1542	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKshDCr3xUWLbxYLGqauHYnsoarBVgyuephHoWCXwLPZyzapti
1544	payment	115	115	115	1543	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JusE32QrLmbpd4p7CJcPYwZS75iEfozNkyeXLPrxdw5rKzPtddw
1592	payment	115	115	115	1591	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcHavKVCBTqYgypiCW6PZ5Ld1kAxMWZMiKobZhQAurBKTSyec8
1593	payment	115	115	115	1592	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudQZzHTJLJhwmoRawvXhYgwKfJ49abUutbhBUtNCD43oxzXMqP
1594	payment	115	115	115	1593	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtqP1QUakbNqw5Z4CEdrzeFkC5NLGyqSJdEVXR4gu2pdrufhPWd
1595	payment	115	115	115	1594	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsDVJJtKi6G5qSUnhbc724UkfrLFHjJ8E9PziBzb5RUJZXeci3
1596	payment	115	115	115	1595	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtavLHXJdDp7u5pmKz2bAu1HCZ678i3F4SXQUGqfbWDubzo5FTM
1597	payment	115	115	115	1596	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFSH1wkaRVCcGoFxhpKvjrEU9t6fFUy7aubfk1S44od5XzvvhE
1598	payment	115	115	115	1597	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQkYNrEB831q4RGdHmiKGKyMTgrtYkwPgB12tjSWsvNKk8TKdU
1599	payment	115	115	115	1598	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvD7DvZeKCGowFTQ36R3FicfVJvpxYMvzUo1SMb8GHKC5GuF4se
1600	payment	115	115	115	1599	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXhsG6tx4uKKBb69oFehKwtUybnhxAAUtyjsGNgBtbprqAUSei
1601	payment	115	115	115	1600	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5XwyJKFkTodtBJNLTVzGLApB3aDkti14FpDfkXS18NXTs9bBT
1602	payment	115	115	115	1601	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvNNACP6CaysCK5njX2YScr9pxywyrR9kJYmLjGs5FUjgHYQyQe
1603	payment	115	115	115	1602	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juc4ZWU7VY9ypzkr8eiRisGwTxToTANApMwykLR4HsptYYNkVU7
1604	payment	115	115	115	1603	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTH1xWLojotVEJZVL9Q6EPZERqBtgkgaXxqSUrrWrGfrGJEVrX
1605	payment	115	115	115	1604	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMpgmVsnscXYsf3xLyqLfDc6GSPtsmWrDLNuNUjSjUvxd3Wwrf
1606	payment	115	115	115	1605	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuumbNqQhZ1SjVwNjHHUWwbTUamrXfBXooJvSw29CaiFrD3MbHX
1607	payment	115	115	115	1606	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZdWhyAKnNW2uGGVWzEM83CWoogv1SdNwmW3Eu6ELmL5zRBZid
1608	payment	115	115	115	1607	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6KwCA1yYV9oc4duz1XovEbEgQZCreZQFFSV471ZnWUjx4GHY7
1609	payment	115	115	115	1608	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtXudTLfKmoLqu4LZK1U5yHSE8qPn7zhqiTN4ERrCjoKokM9nkV
1610	payment	115	115	115	1609	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juo5Mn8HhUYPq9yqgLXdmeYt35DN69NTfogcWer9oPEc4waAokV
1611	payment	115	115	115	1610	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuHi4WFkHzonqnHTchGmskpXQwg3DNt2rMUEqzwWHtc21gH7Bcn
1612	payment	115	115	115	1611	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXJvKVajTkKBR9tYVsQ8BEhx8hnuQvuJz4FiaKvCLmeRzqKY7D
1613	payment	115	115	115	1612	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jthrri8xxevnLs1gPaQtt5SGMweHazptcLHNiyqRAQsyW26mN4v
1614	payment	115	115	115	1613	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuC3kjewa4vU1B2PssNeRAzdsrm8sptiPSptqnF5jrjjXNaWRL6
1615	payment	115	115	115	1614	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4ALnB1iuKxX64bijjxeDP1k1KVDPF2FPX5smyXzCeqrdMEHzF
1616	payment	115	115	115	1615	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkLG2mqirjxAd26x7QdqdVq37eHXi1iYhtEKL7L1XsYm7c4Yi6
1617	payment	115	115	115	1616	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1uZ8v9FbCi1D9ZiLxVR3hE78WYR1t5VnveomQLRooWbvEgn1L
1618	payment	115	115	115	1617	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucfoPGxYBsdYEoDnABg2bLEiYM4YvJifmUzXyntwQig5zmi6JZ
1619	payment	115	115	115	1618	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juw4NezhtCAoWG4gkACBE4DF8u4YdG4tjFNGvxfnKoozQwxqqBD
1620	payment	115	115	115	1619	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumQ8L8kWNSjK73soXTT7RswUoQTLjEArPiefM9A7qLcJPw2ZxX
1621	payment	115	115	115	1620	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuK1QCqaeDiYsxdReREyvdjFLCCZKU7Fv2X4aK7U4AQWKoKnaQc
1622	payment	115	115	115	1621	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYinE11AGJgfgbpdtTAmfRy54H2YCskDtek4FpjZWs6ANWD1mv
1623	payment	115	115	115	1622	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwE7wKX6fXmJ1xrcsaViwVKU5QdqBeBVqoGoFzbBtece18tKoW
1624	payment	115	115	115	1623	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juk39hrBWNv9YXXJcas8CjHh1f7D78QDUns2JUmQWQ2iNg9J94g
1625	payment	115	115	115	1624	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtconP81kMqbpCULM3MFfc9Cz22g2rK1AQq8XeoRFSXhjvrgA2g
1626	payment	115	115	115	1625	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunZsF28h25N9MZBenVJowSer7Bg792ZCX13XB1P1bU9eDRZ5rv
1562	payment	115	115	115	1561	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubKAuBrqyduRkkXuN8V5k7q4grz2KzNZXuTzxAyo98ivRZdCWJ
1563	payment	115	115	115	1562	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuoPykuvjE5EpbWBaCF9TneXWUVaHQ6jtchejh3TDe81iyzknSV
1564	payment	115	115	115	1563	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuwKSHAYk9W58e8hpvfsZUWHFwTo1nGw3bDhYNjcxDosWoJLdX
1565	payment	115	115	115	1564	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWnZ2FKHDCRUs9FtYqi9kPaZjB4EsdjLXYrcGJQnpoyvuqKBEf
1566	payment	115	115	115	1565	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwL2FYNQnvpuuZ8MKQM6zo4upkRbZxEKVmSFMdjCkpoMahp7Ak
1567	payment	115	115	115	1566	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWEuvapmoFt17QMP8xPLHfMY9RVm2oiSoJMN8ThbofsbAxa8jD
1568	payment	115	115	115	1567	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumGvUYjqg56QytVBy3iDYws7sEpjNii5EV4ty1CGxCaZDXrwuo
1569	payment	115	115	115	1568	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3XruBU8bkjqLyEekfmwRGxxgpwPYPnpjeP8BS2zwdSuVZ9g7T
1570	payment	115	115	115	1569	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2LB18yJipkyHHbEPvop4tQauQ41AgzUjSByW8QMs3u1bn3kgc
1571	payment	115	115	115	1570	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juu4w4P9hJvwaWkAHhrXEmXxnoWzBHsUptXaz4bMh5cWE9CXRhC
1572	payment	115	115	115	1571	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQwBGtQWCsb66Vigkvaudivs9vXzw4bCG6SamJZRkFHZE8bzLG
1573	payment	115	115	115	1572	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuotfyBgSUDUf3s5NakmsMdmPUrPqoRvqgntA625S5A34QYy97
1574	payment	115	115	115	1573	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZx7PjamDD49Wiit63AuTcTxdeouDgXgSFrRYMPqdc4LNCF6nV
1575	payment	115	115	115	1574	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzE7CA6Q2XdRu4cpQKVMzGiff9heNuf5MeDZ4AtgmRRzj1quMM
1576	payment	115	115	115	1575	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiZpFYp9EdNzh8udnimcY3QB9tj3R5xnrbmvXtPpoqUjk1jYoP
1577	payment	115	115	115	1576	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvHUco1bPgz8ZXGDniuStvdLe2Ny2Z3CxeFNGzWooE2HZxEEZm
1578	payment	115	115	115	1577	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juu9L63k2yDBoW7LLNzSSy2uWGGyU3oEAVepMugHkrctxUz5yhK
1579	payment	115	115	115	1578	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqyT2Ng5Wz9h5ShbH2BdJTh2hZ1R7bz6vBojxmahh9pQ5XHjLZ
1580	payment	115	115	115	1579	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuT3o6JGwktaTqxb2xWa4uHGgf7kaLmwp8BJnQtnM73pghz5USe
1581	payment	115	115	115	1580	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2yjUGWZLNYXU2UqX5ags998xBx54kCPdRUUiFc1Ros5PPXsfy
1582	payment	115	115	115	1581	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JupmF8g84tVCEzKJ4xpTx6rgt5Zs32E8MK9dowCEpZ7AXZxYPvF
1583	payment	115	115	115	1582	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBNphh3dmC3Z2PGQTrhaN3YJar4QZFYJj7FBA4McVbfvF143JG
1584	payment	115	115	115	1583	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucUaD8UHYadG5DEodJxMrjQTwqKGcTUjJucZ3htQXaJJ9kCdRV
1585	payment	115	115	115	1584	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNu7RmjvpHXXr9agyw3dCzE3UWEQv82X4U3fWzNHaFRfc71fWx
1586	payment	115	115	115	1585	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6uC2oF2hZ79nftW7mrVn5tpTDiNJBAjEWwGuhcdYrv63qKBg3
1587	payment	115	115	115	1586	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDTBaPXT2rFyDwmDhjn8UzXFDTxrQ3HRSDQHaCzJNRfb2CH3Kp
1588	payment	115	115	115	1587	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8H5Qjye6MJ9uqnBDzGwDA1BwfYpqmRVA1u68yviZKSSSJK9qU
1589	payment	115	115	115	1588	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtk6eir6TQ36oBx7uxkG2d8jW7SfznKbYgH1uSzKry26RFDMD4Z
1590	payment	115	115	115	1589	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWJ9nWZgmxgVu8wufPVs1hmGjGb2n72E9ccwXTghFs3cWTrEPz
1591	payment	115	115	115	1590	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKpw2xpJRaAydtWDJeyMbK6rb9mEaq5mhFHiG29XR1vcwDihqX
1627	payment	115	115	115	1626	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju66gBi3SVwCuyPCcHjiLBzfSyLnUiswRzrqSaa3mktvFvxyPB5
1628	payment	115	115	115	1627	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6cRPJ14w3J5S4w65LGSbubyAq2TXJ6ot9iAmzCqpwsNiz3AY8
1629	payment	115	115	115	1628	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv59KTTyzTNVuvabAjUfMuNA1prCPMhB8fNzvuBmoWf4DiLewav
1630	payment	115	115	115	1629	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuArYmq9A1XKAV4K9jZnzjFszq6vQgcPwgDvyrm7BoQ9H5MTmDN
1631	payment	115	115	115	1630	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLhjvU8SDEtQjt7ZFG8R3wFf4d9dy85xpp3AyusXAoiXBp2J4Y
1632	payment	115	115	115	1631	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwHsogxx2XyEQAreBiBVRqgmmvBoKW5zesBC7zMBtv1XGoKBLr
1633	payment	115	115	115	1632	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYKJtUczQawGx8aTTVEYy6Hh7F7C4o3xF5PPYPkpKvMDNdMykK
1634	payment	115	115	115	1633	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7ahtPNV7vNd4mDi3y1ficsHBqobvQUhKp9qkweAbcgrUy4rFq
1635	payment	115	115	115	1634	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JteZrLcfDZxZd1YKfFWmvR7VTot25JLg4o6ZYby1tFJtf7f1htR
1636	payment	115	115	115	1635	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuziSU1aP7zzLvugd2nCzP8YR9Yr2A17KogbRgP8Hr8hTzxWh5V
1637	payment	115	115	115	1636	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6zbXLE9dKkzwP7HUk7n1D2jRCfxRK1z2mMeypxpMwzWWoLp1q
1638	payment	115	115	115	1637	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9H1nL7RUFrYQQooPwTF6c6FLUt3HBdZQvDW6gGrpghJCZh29G
1639	payment	115	115	115	1638	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZXogiJv72cfcL4i3Ndop7QdDmLBWZVAWpnUJAUuupt8brLbuy
1640	payment	115	115	115	1639	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvL3sCczk9fJkX1gPQds5LdMDGNcjdSQnEHAHGAgkQkfy6o113z
1641	payment	115	115	115	1640	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNNAhBjtVjDxN4sLF33cDAv8Sx2wLo1KWeAJfxqo7qJkH1t1dM
1642	payment	115	115	115	1641	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwfePzTYY2yA2JxhCjtrpbY6iqUzp9FzeB3niowiwMH9FCeQPj
1643	payment	115	115	115	1642	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGG8Di9wYHa6fvcyVm6L9Rna5kDoK66g3ayNaRyLhn8w8qBNxo
1644	payment	115	115	115	1643	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhtdDv5sipe65SfU21sQkxSFyUS8XJwmY27q36WCj7A2K3sZbo
1645	payment	115	115	115	1644	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juc3LjPBCUQU1d6FbkEYxQoG1x57YupyJmjaGZcMLnYFe9oK7ZS
1646	payment	115	115	115	1645	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtmt8jmkvGJBh3sByNRHWJ3RdryWeaL4yWPcUrQcFo1zxWSnTLz
1647	payment	115	115	115	1646	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jud7V8rzqkJwNpxRy2pFYG92zEpo97kDA6Y17H8xcg1SBoVzXRp
1648	payment	115	115	115	1647	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2rXuP9bXgQFFjNfcYT7h3umA3dv81mNFkE11gfzQy6p4yBxkd
1649	payment	115	115	115	1648	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFHJTRrjR2tjZZPoe9i4ZY1w1dFK7zDJpa2bcdejyyPKGtc59c
1650	payment	115	115	115	1649	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLEPa6sSDXdkAscZVtk4nTPmSPw68PuQFsQgc178RuPwpvyS6e
1651	payment	115	115	115	1650	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuABVy8yEwBtgbkgP8Q7pqJMTxJg569uRet7PVXrUhB8B851hka
1652	payment	115	115	115	1651	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtaLQSMEJyVNLxiCzZrzSDaEShuYz9TSHQCw1tFodDrdzncUvHt
1653	payment	115	115	115	1652	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucU1GBr2yj1owbMkC2nHL4vkoxsxvTSPNrMRDL15CT9rkMYsns
1654	payment	115	115	115	1653	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQkx9aMPyruKeLAkfFQS9dSaCLLwazpcK9ZRLhwVBkjwBLtBvM
1655	payment	115	115	115	1654	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtqza9JBhYZXSdf3K3rVkJKMr3PNeTT8mmxCRbJYAkb2QR8kkuT
1656	payment	115	115	115	1655	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMFCpYJXWMNSrDpiVkkBeomGhzPpjm9Cm8B3h6pw12UGwyr1C2
1657	payment	115	115	115	1656	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmcqhJH5Yzm2Ry7sqdzA63SEXwMfTGFmXBDs4vP5TsgZ2kB2rD
1658	payment	115	115	115	1657	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6vksDTp3tuHMAun8evH4EAxTjPGgEP6nxztoQUkBGLQkR9h3n
1659	payment	115	115	115	1658	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUTE4XmFKmFKWxRpmfvGqwYNzvFrbHnanYmYJyDP74YKLBwzPz
1660	payment	115	115	115	1659	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7my9Uh6m3s9wBENukedNFHXvtCEUKZyukmAVPjyCAK232ouJZ
1661	payment	115	115	115	1660	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucN3FHN82rv2UaFY5xYudsi7F3MhLX2C1Hq8r9hpgCVhTwhmm1
1662	payment	115	115	115	1661	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtg34KkbqJawKzVuEK2pdd2DVm8tKYfcyBcUWNaLRLbvRzCzbBy
1663	payment	115	115	115	1662	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwHHPQVky6FrYd6LxDYyafpjMC21xaFredLsm7rnnABensD9fS
1664	payment	115	115	115	1663	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8Lm6adqTgZzVL847CrcdS4xMyTm1AwfuqEqdeJX7oDGY2Ugpy
1665	payment	115	115	115	1664	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvEZ4FfB2LKstwuyfqxwqAWkZTcgpSawQw87UVmAJ13c3wtGri8
1666	payment	115	115	115	1665	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhbZ3tgvbuq6HZAL9ntJKHsSqpZWGb8GSHVXYLumqGoLxoQP3F
1667	payment	115	115	115	1666	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFi3tRig5HgPcYkQJSsDGSo3bNnwBX12Yn4FnwD4uSNFxPTmbw
1668	payment	115	115	115	1667	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jufcb64b7st3PBsrDGVo8YQCvae7LsDTHQuELm79gDfHFzSxpSm
1669	payment	115	115	115	1668	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTFY6Vv7CD4cbZ21joLnxE3LWscLDa5N28KuinGqzUUBZFWGXk
1670	payment	115	115	115	1669	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtp3DyfMQdu1E3rhuDq7RTZ59Nco62R2jSgxjuFeKEGUjwtFk6a
1671	payment	115	115	115	1670	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukadMpYAABmuWVD8SFJM8bdgy5oaQ33XWB1brn19ZnkzuEiQRv
1672	payment	115	115	115	1671	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtY4EpxX3m94h6aMutfBSRqn8DSMthW8e49MmanFvYX4SMdEBpn
1673	payment	115	115	115	1672	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYh76X7A34dGQahkhzyEq9S6vsM322PxdScC1ibYATbnKN2H2j
1674	payment	115	115	115	1673	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkjkJCEF6bWmYQAfWFYbMSc9gNfPcjF8VUN7zcwSUm7kv3MGWt
1675	payment	115	115	115	1674	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juro932AQxBxKo7stiqRxQvEQYUtHeHUPUAPCzLdc7YfxbM7znG
1676	payment	115	115	115	1675	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuaD1XJmjchhqb14BFnrZZ86cjnALnrxvKx7xydn6BtJUJby2Ar
1677	payment	115	115	115	1676	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuE96W6mq3uRoSPGpEM1WoMCPUxF54KSPD88tc7M5NfGhdMGSMV
1678	payment	115	115	115	1677	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuP4LE2TnLXrmvoSbexEJRXrBgBpi4X98HeWXef1GVgiR5vJSws
1679	payment	115	115	115	1678	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZwZo7bdY3ZX5xbQheK4c8m3SjWrQsREMVSjCdfeBySRvLqWyt
1680	payment	115	115	115	1679	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3wdLj95pncanFTpGj1EiKKNvPXEzsNFGwrNF6u4RgLJc4GBYq
1681	payment	115	115	115	1680	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNv3eGt2AywYE7shvrGjeJaeVovoWA1dVmUZHFEKUEVTEEFz1L
1682	payment	115	115	115	1681	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDMGJrenDeYC46aFpmcWEZFVegJYKubJ4eEhBqKgty2Xb45zQY
1683	payment	115	115	115	1682	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVG4YfoFs7Y52UzHdGKsgoEk3JiCTgF1aa3T6ZYRsPhSUoeDg1
1684	payment	115	115	115	1683	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugRHdRsZqeSwUL92e4pqSmnsNZKdKVqN2gwPRZPtH4i4Wqd8So
1685	payment	115	115	115	1684	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju44fQV2297CMCrRHTV9ECTwsfVRFzUz67x5FzfUT5PbQ2TGbqz
1686	payment	115	115	115	1685	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLkuvg33pkfM1s1eB242qGzq3NVpDRugioaRHwvGa6vPwhwJcm
1687	payment	115	115	115	1686	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juqh2NbTSqPbsWcpkTQ1PWYhrabYjKf4sNbqbHKvwbdpdP95XnQ
1688	payment	115	115	115	1687	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYDjSzS5bSj2s6fqe21XTkkF8frVQa7nCEvW6oy1EntP4tEyr5
1689	payment	115	115	115	1688	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTYZr3nvcADjsf8JKr5jWs6PvhrhEtAciWYnPSCw8zBNDfhepr
1690	payment	115	115	115	1689	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jux4tdQFrhHSy1VYgRncUkY6eeHFNhMfdZVx2g7Nr7pJFnAeTG1
1691	payment	115	115	115	1690	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCfPtfJHRrG6Ziove7xbZgDTDXgBQF8rndEaic7VBEzZ2Bfj2r
1692	payment	115	115	115	1691	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVyMWjMeVUr1kUPgyZxcb1m1sn7mB4fumduRTQUF464fvoDTfq
1693	payment	115	115	115	1692	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtqFjqbdARgR9J7QaDkfeYEbawysQLbBS37aroMXw2TfDbjGLvw
1694	payment	115	115	115	1693	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwvmZGkwRpPF6jnnZzzeZbtSmHksPvzpzW1DHGSRormutAbNcx
1695	payment	115	115	115	1694	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtvgdK5NnUFA1ucTmc4RCpN6Mx4i4eKbj7yBbm4gGT6XS4s6zKR
1696	payment	115	115	115	1695	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWsM1rC61oCZwhYFLDcNRXdEFkNhxrv9oUaN5kRyM5ehUCsryU
1697	payment	115	115	115	1696	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuBVRt5PQFTPMbin7XwVvVHyQZdwSUvgifePhbkn31wXf54Qdt
1698	payment	115	115	115	1697	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDwVnKfEUD11QSVAP11Ss4rE79YCiZW9U9XeTHRoUqrcJWUXzW
1699	payment	115	115	115	1698	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFLBdY5T7BybGL1zKoYKFDoiEs7GCrnnjfT2MazmH5t6AvLEmi
1700	payment	115	115	115	1699	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGoaoDZCWNpBkb9zMasvfX5Y1pUGfnnHJHhYHBT9oNywRHm3WT
1701	payment	115	115	115	1700	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdneigGoutdsLiyDKrAERVzQq4qP9jQYS8gURcNexebojah2mB
1702	payment	115	115	115	1701	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6RR8q58YZbHovf2gvaUZ1QqhzrD77djFQQtFUrZ4dhNvxWTvC
1703	payment	115	115	115	1702	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4jyPVJPNFLLsowZvMzBU8du2zEaih6L6aM1wuSHsNmvfW64QM
1704	payment	115	115	115	1703	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYmsqLMtS1xPXgL7Ba4zaHtQQJLUNdszYo7aQejwHr7KDjtBYG
1705	payment	115	115	115	1704	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtrk8ecTkwdsuY4mKwDPFaqedFVNa2D4R97yzBU41HUDDU1Un2r
1706	payment	115	115	115	1705	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuUEGGPKjQ1dqMQEhQWgxTTaTu2DHwK4MeS7KzyH27VtvvS2wH
1707	payment	115	115	115	1706	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuP38eeLde2w6UhBuhh6KwETDoBFC4ozi3m6rmuMdZtAK1cfwim
1708	payment	115	115	115	1707	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEysxRhttsv4fSTbHYnTe3oJJ1YDH3FxFY2xtCfodTuAq6LYz8
1709	payment	115	115	115	1708	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQaz6zbrwmUYrhNmVE59HFShWqY2Zjzkqcij4NCRgqZMe6w1Fg
1710	payment	115	115	115	1709	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGhtWboaHA6Ftf5QoPQZie4DoeWiigHXFXzJ4xb7JZrdfSAWTi
1711	payment	115	115	115	1710	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujpX2Qnc8ytCRt4ddPxWuXKKR2YmgqfknGiF5NNELahSD4LRhb
1712	payment	115	115	115	1711	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtqhk9c2SskpQ5a7tR3x3YK6CUGsxhMoaFSj6zpdBqftmD1yh7h
1713	payment	115	115	115	1712	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLsyYTWu3yATEPadgAbpQpXmZz8iyJpF1PpqVPGHsxoNReL6VF
1714	payment	115	115	115	1713	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7THYxcvDidws2pB6D4hdUPicaUeNGPxsR6FMbtFwcKLkNX8zx
1715	payment	115	115	115	1714	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvPcxcr9LbTJ9oPEfhHR7D273NoEchxwmMf3nVGk5tdx3XxMk4B
1716	payment	115	115	115	1715	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuU6qW1RvGPiwsP98xCv8SFb34EnBwkNMDDyaz2BLH8eZga1eCj
1717	payment	115	115	115	1716	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucAAsF9fyioAfVJSAWnqX6b5gAsSJwNaZgJfgvgsPUsheMtdMp
1718	payment	115	115	115	1717	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqKgM5BwPzMrAnnkx1p5zRxMRxvN4jQH8ENUA2CbPauhGZRDSZ
1719	payment	115	115	115	1718	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuChpzNWtt9EkV7EBqzkwyfkf5Q7KxAjYHF8ZPcFZiMCc6GEwy6
1720	payment	115	115	115	1719	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCWaqMxGKMhhEoW6byqw44o4kEdiw8b4cMDDY58ADSHZ7eu88D
1721	payment	115	115	115	1720	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtdJBfL2K5aQEUdVB3YidjKbsMLMsAwTGBYQsvM29NFNLiszTDC
1722	payment	115	115	115	1721	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JufTzXVw8GUqBFbsWebZVNvjP9pta7YpWTxSvLdX8DJew2VmkrZ
1723	payment	115	115	115	1722	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jug6ACW9vAzTrHzqWmJ7mAuYJHULF9W4r1mBcC921UzkQuqFrV4
1724	payment	115	115	115	1723	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvD7QQtMmHukUAFDZpFDGYu5HLfaQhHoPdDyx5MWjNVb3oJdFcT
1725	payment	115	115	115	1724	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFNuU5TYzfBtYGXC8ZiQrsMXZJL5jCpuYwcpCJYtWBZuPBG6Bx
1726	payment	115	115	115	1725	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtq2B3jSB6fgxGmXNKzw2PRM1jDGSch8tDUwsAaJCygdRVK4xhr
1727	payment	115	115	115	1726	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZWyyHv2BnGksMXfMaNM15TNVd6iJvwrzQuFPggEW3L5mVwmTh
1728	payment	115	115	115	1727	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuB1in9wpTFRUBdhkXuqp8dEd2PBSHYwMZbthme9UqoqxmkaKQ9
1729	payment	115	115	115	1728	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9N6QbbCJjgApThajXBPuqcTtbqyxKdrr2eyhAKtmB6nEp7HHE
1730	payment	115	115	115	1729	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtvua7iCFMdpv57t5SSob8y6fKxi58DTaq2SH2soBsV8yin84pT
1731	payment	115	115	115	1730	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtj9JJbHSxwcaoc2jwbd75jtehLr6QwsaPRqF7erNWCCLmLfMrt
1732	payment	115	115	115	1731	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSyVVDDUWK1wfbPMUgTthac2KH3jwgG947FhvmoXNw3UvEcAbf
1745	payment	115	115	115	1744	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1EwS5S3EUtYb8YERJ1sTCGi3Wy3UCUhbp4PUWYidDb1rJ5fsR
1746	payment	115	115	115	1745	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jui7aRqrFNzw6hgAWnhFTGA3QNyAn2TjHbR6KzzR6mQn5d98pfL
1747	payment	115	115	115	1746	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxF9DFGN3CGmbfNC72ppHDUvMZp42wNQmVpXwfJEkYUNmLSkNk
1748	payment	115	115	115	1747	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtY9622cLfxNiM2EBmkQWC2ZVYZfDfV5F6NQ6oB9YyaMyJPQaN9
1749	payment	115	115	115	1748	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuktAA5nBQYN6ickrbq6VAaomAXevW9TaZgQSaEFAXyb6gajh89
1750	payment	115	115	115	1749	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvAEHHKpGfwST1KnxBDh5RCuAZ57ho147f42N2Be3nq8VyTutmZ
1751	payment	115	115	115	1750	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuALC65RdwW9L7Guccfi99Lt8ZvoT6XyoJkBxqXaxMPkECJ4SqC
1752	payment	115	115	115	1751	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtr7PRHwYbmRpNBpBw5x93tf1aLJDTfeHDEZmzm46eQXHcbBtdq
1753	payment	115	115	115	1752	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuKiKjRjnS4Y5kTiu2mmuudrRp5EFtpLZjoiNGJUibgoMFN7wos
1754	payment	115	115	115	1753	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jthi2a2uKRJvErARY64Zvzh7CDATZeHxbZn7hMcbm6zs4k3S9EA
1755	payment	115	115	115	1754	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukVhkLvR7dtzYxwBV818PkxUJAETvn8nomj9KKpqutU3US9Bm8
1825	payment	115	115	115	1824	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPGaeoqkjXMFYuTGEW1wLWTBHtp5L8w74yjbsUSLxRT2sAeYaH
1826	payment	115	115	115	1825	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKZXiJy4H9b4aquJnR898bWnhDwQuNyyBcDBDotvTjtDP12kJs
1827	payment	115	115	115	1826	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwKLKT2qT62CK5eqUGy46nAi2oxiDNdVegMWdYtq3V4RdXCChW
1828	payment	115	115	115	1827	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujAPA35VMtxtgXKadycaWUbDGVyDaTKXJRyQgrjVRFZHEv9sTc
1829	payment	115	115	115	1828	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunEwbMedgZGxHSXJRbv26s84W6DKcBtXcbue6uiAvVMzHtiWTR
1830	payment	115	115	115	1829	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5FuN6XHuRzFDL9N7SHSvc3MfTWGP2zHR4UNmGrAkULkqubGZy
1831	payment	115	115	115	1830	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9H1wacF56iG1wtkVRa1xFqugkn6KyRJy7wK8wZXKqE93zyf2D
1832	payment	115	115	115	1831	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtx4Kye257MCJjXnJ7L9dezcB2Hx2SWrZ2gKVt7gnYXQWuFMy4T
1833	payment	115	115	115	1832	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtiZqSgPrUNfM8BWQkhHN21p45Zx46Qhc2fVBwT9SSSPhqCZf6D
1834	payment	115	115	115	1833	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFN7XA7fyZxpFSbyyWoSGmXtvNZZWYW9TjYfyML5B2nKDsgbcg
1835	payment	115	115	115	1834	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWicPEgS1EhiDferhmNmNAbzwACXSZnW9AZdALSQ6arKXcBEqj
1848	payment	115	115	115	1847	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtbSiKHGZVxDSxhVoxeot7xsYjq1xCC1Zu4DHVuAwbS9GKgQxga
1849	payment	115	115	115	1848	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JudjsXbJtAGcfdeJGrsabL5RtBwci3ydJ7h8B7aFr96Nac6qktP
1850	payment	115	115	115	1849	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWhMmrAUob3WUBeTdeyQyWzYa9BcVyDkBuvjmTL3bL54PtppVF
1851	payment	115	115	115	1850	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jto3VXfS3eSHJ7ocGZu4PXEh4Npc5aCtt2viTgBD1azxBJcndHh
1852	payment	115	115	115	1851	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7dpV4gHwqmFvbrUSGVnUzb3uehEzMtiaNy87fxuHfzKq2EdzR
1853	payment	115	115	115	1852	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqXS38mkvYTCyTsP1DfDbiGQjANLL43FYXjcDDGRCWgpVWbz2w
1733	payment	115	115	115	1732	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqTDzLMMrAgZVda55mYP3KzAwujTqS8xXuHmcz5EXLN5f7b1G6
1734	payment	115	115	115	1733	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtn7Z8BefibjEsd8gzNMSQd7qC51zG7y3KkqU2LSnPN3opSMxRE
1735	payment	115	115	115	1734	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jun6PuWwLTmjuSQ4Y2uWMzuGgfi2UK5mrVXXJQKC8SVspw7K5jF
1736	payment	115	115	115	1735	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuuFMqg6USgAqsoRaiQFAeMByfHEMqSxfb5wb7Yx6PswreDtZYk
1737	payment	115	115	115	1736	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRF1nyXauafzpP2vrQxw2amprP1dJRBnuA4vkJxnchCyJYmhfD
1738	payment	115	115	115	1737	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHzNNeXpLJqF8WFjiTr5tN3zCULG1PC2TaRLz8qxLNmnrnrmAr
1739	payment	115	115	115	1738	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtnQ6q27LVXDAuXTL4FM6MdnnfHc2A8Jtuwuw9w4QHmupUpi7YZ
1740	payment	115	115	115	1739	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqrsCUaMMwNp7GnyGtoUKrG1STqmUZm8PugJJaLynRSG5yrcx1
1741	payment	115	115	115	1740	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvKGDotDRoTKVCMnkHoYer6qknmjSS1mEAbNJCzWL9cpRRUxeQu
1742	payment	115	115	115	1741	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukPhWMxsDhcHCh4rqSeDYACGhRUjwi8ajGtAGgPEz4cactfFD9
1743	payment	115	115	115	1742	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8yAX4VT16YEa6RF6zA2KSfM22b7H6Kg5n3u8pr63Ar98R2KjD
1744	payment	115	115	115	1743	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4cpsaS347mC6WbdYmFuSafWeVCs6xwVesE1FpAqFj1JQ3GL62
1756	payment	115	115	115	1755	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4zk4JwqLznArYJLpoz9azxP8oP2G1xBg2VYJq3WrdQupwAqZE
1757	payment	115	115	115	1756	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4dBEz7oSWzWf62RKCa819yEc9Jnsw6ys7rvXrRh37QY8xDXu1
1758	payment	115	115	115	1757	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuWUMGZvZag9yU1i74ByZHRTWhxjBvZQaGPdTpgLPLKyNtwDBsC
1759	payment	115	115	115	1758	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2NtAJKUbbotjyc89HUhn29Cuxotdj7hnJjjADC3poU3GWYV46
1760	payment	115	115	115	1759	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtwRcTJsiW4MkhFdU2DEpJ9cPTiFTtp1d323vQfJZe49roRbR6m
1761	payment	115	115	115	1760	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuoyUH1gWL3pJN2NyZToHFKG3EF9EHGgLYmdJFp2CjYcsmBEBxe
1762	payment	115	115	115	1761	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jttyne62Ppia9i8YSZGzDJehsn686AqSxg59D2P6CXyQRYtuc2P
1763	payment	115	115	115	1762	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1VJuo1bJb4V6hGo3ksvAQNwFecFW5Nb5wiv2AoGrU8TBTtZ5N
1764	payment	115	115	115	1763	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jte7LPQXCvSLG9wUySFwBn4rTzqbQGWMTDogrnSp6epuonWqrmW
1765	payment	115	115	115	1764	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7hZNDonKxQjdLcG6SRv3S3bQoHHZ23zRkqRvveSxGKuWq1E2F
1766	payment	115	115	115	1765	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuyZbHumd7rs6X1CboVsNZjeiiwngJDrgnjEgpiXxxfEhGckwwq
1767	payment	115	115	115	1766	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuN5yG7oDZdFCZ8QvWpvZkZfJwZV1KaEo1QRucNgbQjBnY4Rvob
1768	payment	115	115	115	1767	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6WQxhn2J8U4ig9TXxDx951tcvLcAPwpi8UVSTKZT6RkwywaK4
1769	payment	115	115	115	1768	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLV39Pm5EX5RnVAry8KcQx7KqF3pb5yJhGoAnK7SgFJEA1HkPa
1770	payment	115	115	115	1769	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtcs98SKJmHa847BnFZXYXzs1cN9uLjR77S1cSWsDYt2cjMViQr
1771	payment	115	115	115	1770	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju7vys5mumgDF8s4kCiTVXGw1jUKefMwaMi7TKHrjnbSmVPieGb
1772	payment	115	115	115	1771	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCCeNwpQLSvG4QjWAV6rmL1F6ocZDVW6pZKfuxjB4egndJcNab
1773	payment	115	115	115	1772	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvD8Ww6aKFaaZ1JZB975a29hVpBqRhYv91gmdqMQ5X8nBNRCerr
1774	payment	115	115	115	1773	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4tnznm7u72BSrsjyRWVV76Y57K8rekCMQkjHJ3em2diyYpFrW
1775	payment	115	115	115	1774	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6tknmryuzPqDyjNhg4FG3M5mHTGE7mx6vBojFj1nrK3bSiuFB
1776	payment	115	115	115	1775	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqvhMBU8kXMpFhgEq4VxpFTuJK3bZJ5g5VzMiGoSwv6cPkns3i
1777	payment	115	115	115	1776	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVYxDq9N47JQ7MjpctJk4E5q7TKCR6s8w3CRf52hxwe9nW9g7g
1778	payment	115	115	115	1777	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JurUXJ9niHeReN6PpEGXP4cC99wRXcWTipx41BFArX1GbV1FrDS
1779	payment	115	115	115	1778	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juz1HdmuREBZyrzGxyC46mQim6khzptWQSNY7WRWxmU35AbUiCs
1780	payment	115	115	115	1779	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTJR5GehMxLHMie8PrUSWSDra1BamDdj789x6Kx9wgeHKL2bKq
1781	payment	115	115	115	1780	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMkZGLhzTWryPPm4Bp7V6sTDmRc3AXHkvUvDmjsAaDrbSuv2W5
1782	payment	115	115	115	1781	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYRPGQMURJUHEFsXLWosofmXhiE2MvQU56VCoaftsgAcyGyUPv
1783	payment	115	115	115	1782	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuotRJZTYch1ZadgAQnYGJhtSqtFPruqgz67Lhe658qYv8XRm5r
1784	payment	115	115	115	1783	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuAN8x6FypYiikusii7MAshNCbHgF9mgLHh8PWemANCbWjP9G3
1785	payment	115	115	115	1784	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuF8mPa7iTDRrkZBiUisr7QvnHmdvjtkWZVPE9A4ftDayZRZe64
1786	payment	115	115	115	1785	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujLqfGoYKcDChbm4iomE12HZzfhFULsyUaYpKUSAvLuESQNAp2
1787	payment	115	115	115	1786	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxwR4htwetvv33kdosfGu7ET2jfe8TSqfpNoBTP2zqXn7AQxJL
1788	payment	115	115	115	1787	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4JneqiwiTiXWrdqrP7aZmCjrDi6GfGtdEeKwMQrNJFpn8WwvM
1789	payment	115	115	115	1788	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmMFx2XUhAYmQKahfxEF3Tuf36hWFQtNky5rtjX1w1e35oeusi
1790	payment	115	115	115	1789	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDJpXTYn9vgtJzYU2THtFTm5ALv5Zecdc8ERefJkAxXQhWAf1y
1791	payment	115	115	115	1790	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3GpPzansGToYyJZpLGZcevc7xs3utCS8X47J3qEQd45xwChKU
1792	payment	115	115	115	1791	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuH5GpkrLpEKmRw59dqzpsrLdx6LmrvoggbJdEhYiN3WVLChDXp
1793	payment	115	115	115	1792	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNypcCX9HukNpzWVJ6zBy1Xa5BaEaaog7BroNXqzkEW3Ctmvsc
1794	payment	115	115	115	1793	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZVGFaf8zPwuDM3FXTiTWekAqgtR7y8Z6TD7YRCWjRh6SHZMCt
1795	payment	115	115	115	1794	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWW2t5FMnP7r7wKfrixz2Ldh8vsHa8i9gmCNNkUvTiZXMfJE5k
1796	payment	115	115	115	1795	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtwtz2H5ySofnab3QQDQyo9x87cVto9uj74xffEoJCLppNvw655
1797	payment	115	115	115	1796	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoAqi6rJbDVNxmXgkbdRfYfk17gWqjEqMwfm5LhgC65Cs2fxQm
1798	payment	115	115	115	1797	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuRut7Cn63yNLGH2qrN566F5JWwu25YnYJKV9aPrWW1bf2dc8Qu
1799	payment	115	115	115	1798	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2jBuAhX6CxmmAHrHXjeY6KGuVmVB1mEXKWZU1ej58BG2PfygH
1800	payment	115	115	115	1799	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuxjHBMjNbJH7zZFc4EyGBaYax8tnz8vCQDCHt69dvm2qCArbDE
1801	payment	115	115	115	1800	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTtnXwesCw3H3sFpTKHwVTPjVKquKSPYLvSrCMqkobkFH43w7p
1802	payment	115	115	115	1801	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcjkCLtJkmtBj5vj7QSKadrCXdAqdNpzohWvQTDmGKw7kTuw4s
1803	payment	115	115	115	1802	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZ73HnLoNpbgunYmS3XcpVz1rtUkPhnHwukZFu4Ei12NDkipPZ
1804	payment	115	115	115	1803	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtWXVwAUywMm4xNgEWF8k1SAYwbkn2FZssZytSPwpHafRb3ZH6U
1805	payment	115	115	115	1804	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuC9SFJed5GLEmqALThw2g8uKCrZeQbiWYa35W6g8Mpqw8Qx48W
1806	payment	115	115	115	1805	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBRcDAQfX3Grz8QCXQodQhAHCjk32bnuwuRdkQ24c4uFQranAF
1807	payment	115	115	115	1806	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtrffCZg8DkBXC22N53uRHN2hQmeao44A57n6iW6tLqzTAfxrZx
1808	payment	115	115	115	1807	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju69g8iKBm8Xch2XyxrbomVUz1AyxDzUFcJ7o2hS32sug1phKSA
1809	payment	115	115	115	1808	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumEDbv75MB3xdUgUQLcWKDZMrp1jUKrADjRYCcEwHX1pfiwtwQ
1810	payment	115	115	115	1809	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttwZufPTftxJyXqh53BwJPwKYKo299vicNmbt74dG6E44dCC8f
1811	payment	115	115	115	1810	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JunQcg3YrV4L7WQrm8LMQ9WbiigDyn5HdPEVHNwLQcPH9AiSNNB
1812	payment	115	115	115	1811	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtiiVXrGKiP1vjJrTSpWrt9tuwqzTYtY8Y129vK9VceSkh3FAZS
1813	payment	115	115	115	1812	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JufzH5zth7Aisw2G5hmskiawTZ1e9V2UNMemVimxJi48Q6AE1V5
1814	payment	115	115	115	1813	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv8j1jVP5wGzChfk8accowWUCZgwXJvA83oTsyRrjvN3wgn7qW2
1815	payment	115	115	115	1814	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBDZXPgm6RopGZ4AFrHhUadrBsGRGwJWE8pDLdr5ySTfAdCow5
1816	payment	115	115	115	1815	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jud6xBno3w5BxCbRApJupVffzd3xWWonA4tNv6iB9ywugPkrxVg
1817	payment	115	115	115	1816	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9U6SRuHfhU1FpeEoHGjLX9Lvjj4aWtdeMTdxAHpSDoEq6Kbip
1818	payment	115	115	115	1817	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juc6whqqsPRFJZWP4KGBaqVtYbf9f8c154cRajgxC9gsCwKFgHa
1819	payment	115	115	115	1818	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuYUHRnTvDdSXE16erEy9qijAREjZBnLjXrJnaudeCP15gVGSZC
1820	payment	115	115	115	1819	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNSugHzLzoDYGeuFd7zA6DJFDgp6NLVZXm5yRCKZ14CCvNcqUC
1821	payment	115	115	115	1820	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JthU3JgZ7odtKdWxzhw8iPHm38yzEsKXmGSpcTFmzXYouDzN9eF
1822	payment	115	115	115	1821	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukMeURhATikq7rW9FpynJodhFyR6a12Gn2JPEupPbxgQvPGGnp
1823	payment	115	115	115	1822	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtrxExwFzeEEJCbeLnyymmf7VUQz717rBRZjp2LjTMMazSuHnFe
1824	payment	115	115	115	1823	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuM7Nb4A4hYSoUhuwKeCsfvNbBe2mBe1R4dFmMKrr2cLEgGj3wF
1836	payment	115	115	115	1835	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumaaRQsCbmQ42mRxnDCz7wGVGZY3i389PbCSLN4ZyV3BrkVvys
1837	payment	115	115	115	1836	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuS6EH5Q2GrwaZ1Nwhts6XPq5uS9S3drP1J6LmLLgSrsTu5aQmj
1838	payment	115	115	115	1837	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1PftkiQWd8WjtVbHcoQdQQG3rpvqUEJs5PTE9gc4cvTxhs8xd
1839	payment	115	115	115	1838	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuAqBJNbtpydbvg5Hmo91c1Hpj3EafhEHSXyDnK8vjNa7jDJV2P
1840	payment	115	115	115	1839	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1eYMqDge82WNovAF4wX8Saune3UPwtBhrbrohKaZpmkP1q2cU
1841	payment	115	115	115	1840	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuoJ1f8xZ1A7W2td7AYLB5u7XQ9VkSV75w7nX17Vya9mEwGADk
1842	payment	115	115	115	1841	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujCnhtXadnBQKXSCsuB4hxgwhYKgQEHuaFTF47d1AuHfuf9yM9
1843	payment	115	115	115	1842	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQoWnmpW26NojBXd54N8apAmnuBe8yGYFyPu77wfccnTqxHBus
1844	payment	115	115	115	1843	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBMYkLvNbybFRyga5LiGd3KnrB8P6vABXbVDnvjXpXLq8M9tUb
1845	payment	115	115	115	1844	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju6dkuDrfyuWEi8Df2LwxeYbDKXr764mAn6PdieaAXwSKcV4Mt5
1846	payment	115	115	115	1845	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv5tg6vcjdhKytKnyvLqxUVhMbYngXURPyL9BR7EewsmHp5mYA1
1847	payment	115	115	115	1846	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmKSDyJKiTXi49zkBNQqqQGE8abeheeR5zZh3HtmhnXMjXsAFF
1854	payment	115	115	115	1853	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtv3MTktgRxeV4dkrX8FWZmCwFkc5vrQUnhrX9reUySyPfsUAQb
1855	payment	115	115	115	1854	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2yLTk1V2nyBDyoYgZkot1WkHoqmisfTC3dMDSwcTgsSJYdyKo
1856	payment	115	115	115	1855	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuqjkH1J9ywxiwKX2ZxtikmXG17hw3gepxQF6LUoQvp21QbpL13
1857	payment	115	115	115	1856	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtexwdr2Q3u7tC2YqfneDCkFWgkgRQ1NcfukksctuUuPBmvubn2
1858	payment	115	115	115	1857	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4vJBE8jEWgDPevtC8hMjBRTJ4hJ8QowWjCrRra6AMudmEZ3RY
1859	payment	115	115	115	1858	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuY5u4XpPrKxizPceEB4YiavpJUYxsyZCTwZajwvEDjr27MLUdt
1860	payment	115	115	115	1859	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtdi1iQ2njKZr6qWFxRMKh3NZdY2bfPbswkLHMmQR8Rxw2P67Su
1861	payment	115	115	115	1860	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv88LjY9J8P9LJJn5kt272xxg9TdEB4PZ4wLNAmErt3wvrJtT9R
1862	payment	115	115	115	1861	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzLbL9nBrQHU373mrctxM7FHT79YNyFpRYo4NotApJ5pxa3q7y
1863	payment	115	115	115	1862	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jux4vMCmgLHjvpMHBx6hPLkG8BJgN4JRnpEvU8Dt7uTGc4wMZkM
1864	payment	115	115	115	1863	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtkyw7ma7AdYJeMGTUFhAbUYesTFdzetnZCd79SwnrpcTpV715R
1865	payment	115	115	115	1864	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv3Mjj6pwLk1S8Tdd2vzosgZbDiQEnKGRZLQ2prEFhbuYWeG1Ex
1866	payment	115	115	115	1865	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMqVS6ShtogfBcXzHoxFAui9J5atkX5sEG9XMGW7jC7vfUyz5Y
1867	payment	115	115	115	1866	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jud4Jup54QUoLhUweDC3tjGmmnrcGVQc2i3uS1F97A2rve6WaQ1
1868	payment	115	115	115	1867	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTHYMwLcFtUnnVFi2uzUeBfyXTbCAhS4pPrY2cSTAT7u6DTkyc
1869	payment	115	115	115	1868	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtYNYG7rj42tgpwze4988tLMWYFr3NKk6gWj6jWmuyAQX6E25nD
1870	payment	115	115	115	1869	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7kY1WDQ1b71q3njmEka1WGvm4Qojv9VbU2FJaUAXSLnToeq9N
1871	payment	115	115	115	1870	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUnp3rY3SsK9CirANBY55ZKGzTiJATDSK3Pdf5yCBPCEqU6qi3
1872	payment	115	115	115	1871	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSGUR4y6EPeDnXHXKNnWsfehY4dnFjsfJo9hGq6ZuHp1y6fRkU
1873	payment	115	115	115	1872	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JufKiDxXM12iy711UJhgrEhBim8Y9NJdUGWY4nrpkfWzV9MqPkA
1874	payment	115	115	115	1873	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCuaKxAHoBV18m9vDJBydjw3K8niTo3uC3iavGcj5ot3hSe2Kq
1875	payment	115	115	115	1874	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDrrA6xW765Af9oDLS7p3EbnkwHEjjAjtQ7vNiaWFVBZR5Zd1M
1876	payment	115	115	115	1875	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtVybbvUCt6gM1ZY9zJ1fWvTfTRiHmXBrFzPpXZmPjpGgWa1tVe
1877	payment	115	115	115	1876	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuCr2HtekGzMB2rkRnXSo3KKq4WbKNGNo5yk9gEXVog1MYrFAn9
1878	payment	115	115	115	1877	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvG7AMXPoxLh11eCCbJp4ACickX3hGZLddqkKnqjj1qCVfW99F5
1879	payment	115	115	115	1878	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtjibM6DGsKf6M3A74vB9MwizSzsFkWiYAhUZ9R3Ba63sHB7aQT
1880	payment	115	115	115	1879	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4Fy9eVmaiYRWzSFWquQf2rB3QNeyoQYL1T9weSYL5nPdUsvNK
1881	payment	115	115	115	1880	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkmyPpK7aLfpAR5Jwnu6vKwxVH3oSdGDGH51n2VMgLYB2zf5Gc
1882	payment	115	115	115	1881	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQdctMNyY9oxFdskYAfxeYTLdHL1J6QQsUkVwhhTfW8ESRF355
1883	payment	115	115	115	1882	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuyJ6jQJEp6Zxn7kGzELbLmp1pJq1H2TtVKYRDFUtdaysgCiua9
1884	payment	115	115	115	1883	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JubKkmMTUgRpqoPHEBsgs91aPPf6igkGHrFjEZR6Hqxc1BpX3by
1885	payment	115	115	115	1884	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuH4QLAzHYG86BWhtRFXZDQAr2VXhs6kySAR7x42NzLVR1Y2Kum
1886	payment	115	115	115	1885	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juf2LKKkmhko5ynhoqTNTUWSENRJHCSaa1cMfrT9LCk3FVMSeht
1887	payment	115	115	115	1886	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvQSijcZr8Lu2giooFpzmS1XMcBZ2Y6C1BjNKTsfYyWMX2KVqxU
1888	payment	115	115	115	1887	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4hbQ62iZXYLzkd9pgRUyVppRpbhUGTFqGwTXsbEd2z7bSKMFK
1889	payment	115	115	115	1888	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuaQp1WHedAKoM1kmjFW91AoxB69uUitdbwTk5oPy1CeAmoS2u6
1890	payment	115	115	115	1889	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju9vzi6AKefTA9EGkUgXehXa37tecccbXAanHkSZw83wLzJz1dX
1891	payment	115	115	115	1890	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1NBHRGsobv3c7215Z3Usuep8puQnAA6D2pbQ6HDAPoxYTY4Ck
1892	payment	115	115	115	1891	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuQkcWtePB1P745tRzooXxUpvv9bRGUksC45aDRsJpqroM8Hmi7
1893	payment	115	115	115	1892	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugqxvUuuVkh2f2odzxW8z1dSDouDKLG2PRVGz4ZnNKTj9f8CNW
1894	payment	115	115	115	1893	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Judu2RSxHro8efakWMhTKNTJhmWczfrFRM3BAGxywn45TjxNkk7
1895	payment	115	115	115	1894	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtqg6yJsu2mcvB9tQaffBSfFkQq7jHacwhnbiGkk4MbssFBRUvB
1896	payment	115	115	115	1895	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4xpXXw1TDGCejoocU3megtuWajVZq8JSdGC8ZACn9nRrPWRC4
1897	payment	115	115	115	1896	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6kWMfPhWCjadwhtuiu8Kczcju33qdFgTuPzyJP6Gjy6FegKMN
1898	payment	115	115	115	1897	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXy8ZehQhTCzMn4cgPFq22zPccdAAYJZZaqeiETafo2f3fXvHv
1899	payment	115	115	115	1898	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuSjNDNQF5WygiPNFFm5WNxYChGbTrGBJTDPJpQehXTiWbYxcpy
1900	payment	115	115	115	1899	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1UGaYDfmzt8PkxPxzi1eRMNgeewLrvrXWBpXVkTThpALTcdnh
1901	payment	115	115	115	1900	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1RpDL5Ze4B9xzUB7sGP5C66oFWwnQonEaeVGu3XqJJktFiNwa
1902	payment	115	115	115	1901	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvBnDSfGpLbzcUCA1Vk3UqXGLBCrT2gUHnycNgXZi5hWYbDdNuE
1903	payment	115	115	115	1902	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtqiSh8CLsfuiq1ts1B441wH5fGfyE94KYtYnpVQVgjurNUvgEZ
1904	payment	115	115	115	1903	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzyN943WyQcRpvM1bWsYHuKNha9huPoNz21TS1TnWi7ZiJ5rss
1905	payment	115	115	115	1904	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsVSexPhoHotRpnXqH9wRRFPRqKhbbKkGnrVXBDtLBrWGu34f7
1906	payment	115	115	115	1905	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEWBjUHKy4q3qw49BCCVfrNN7VRVHXKSYMiTzWNkq7mXs9wNr3
1919	payment	115	115	115	1918	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju8uMrotwiPUo8WXRhA46zfwimXrPpDXtCBfCrpMJxpfbcNa5WA
1920	payment	115	115	115	1919	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujbRYc4L63rBvR74TKhEN6YmcAa4xWPa9Ma2s2Z7Faa92nEL3T
1921	payment	115	115	115	1920	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJWvnMv5kRVGUwMUA1wCcFLDPpUsoUFf7C1Wxwv9yUjMkiaNbR
1922	payment	115	115	115	1921	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVe9VabqTqCommLtvAs5SF6DJ7WG3sooKkpm76cYNHywCp7AsT
1923	payment	115	115	115	1922	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju4hcjkyLaYTmxS9wy6ctdyreXXEZewEJ52Jxao7FivrqHJD9dr
1924	payment	115	115	115	1923	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXrWDVvby9JeVvpDNDDAysxYHxBs9X2sRMUcetrB8qsBVCAWYt
1925	payment	115	115	115	1924	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju5f8puLZN7XSmeUWti6xzZnaF4J7Siq8Lhr8e3KfY82nQPwh5R
1926	payment	115	115	115	1925	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvMLQpvxbKVfyEzsJrg86M7gR4NaiaNuwnRVK7dz6XRFbkKih3g
1927	payment	115	115	115	1926	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv2zCuUgvNMDXnYVqJp2vg5puo6jwqQ2ZiVnGMD9hb6SbCG1jkg
1928	payment	115	115	115	1927	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMegrvo8fGiFq1PkoaoSM8vhbyvuwwSAaJw6bnmvFyfG2LzuLW
1929	payment	115	115	115	1928	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhzwRJMX2nLrHwjNaT6ZCntWDf69Txdy1N3oPYGDjHek2y5eGn
1942	payment	115	115	115	1941	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtcEmSC9tJW7tKArvqb5P6rsG2erRaD1jorkcDVRSCfjFZWo1dy
1943	payment	115	115	115	1942	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLGbD3g7jkVasFRTACuVzwRYH5p1FtYc53TwYFn1o11d1YhUoE
1944	payment	115	115	115	1943	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuGXvXDzdanLzBy9XEw56p5eL8JNaJMffrsj1Bf3jxvDmmojokL
1945	payment	115	115	115	1944	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JujvCsBWApUR7WrujRHbrN4VA4FcBWiUA8h2LQo9KyBk5bXFBzW
1946	payment	115	115	115	1945	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNGCV4aF8PWNWboJf1s7VKma6EzYvuwQVNEEEmhDuChULrzwP1
1947	payment	115	115	115	1946	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucaYRkxg241NSGMihvSCD6e6D1rNqSSL4fuQnFB79Nr45tpmrm
1948	payment	115	115	115	1947	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttctHLXytSwpndw9ixSDoTFv5n9yQZR3WZFgM3j1FXFDSLgrPT
1949	payment	115	115	115	1948	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZ1Zt7LfaD6b8nRShUaY2SASxpd1AuHtBTU82h3WbBbenStFzH
1950	payment	115	115	115	1949	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv6ZZqCfb7umiKXMq1GZTYKw2EXdipAaF7obgQnfvB45w4dwj1Y
1951	payment	115	115	115	1950	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMbGpSGmpBsoG5s1GX3SNzoo78KYHyeyj3ozpg3KbEazr8fGn4
1952	payment	115	115	115	1951	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFFnBrBdCkfP81cLDHM81ZzcqM9niiSzTHWsgCGGRakbP4cHne
1969	payment	115	115	115	1968	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtaC93qrA3AKJafyBfUW5tsYhLnzftmSBv7NAMRhfNUkZvkuGWr
1970	payment	115	115	115	1969	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvFuyZVcLmWocnZ9bw3Uq7f8wxGhPmvnKdsJqf3H7HZFSPgbm3u
1971	payment	115	115	115	1970	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JukSsHhwvsWZ1m1r3ENimdoRrZWMZhkJtbjjLu8PJNCST3R5uFM
1972	payment	115	115	115	1971	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtkRqfTYQRyDkBDN6QPVfKoaSC3YXXeKKS9f8pZCQrNdsDv2XUs
1973	payment	115	115	115	1972	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JutQFoygEfdACJ9b4atSfPfnbt3S3ovPQqMD52BzXjGaTdnT6Fv
1974	payment	115	115	115	1973	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv1z8a38E1G1VA6aworiLsFiBios12zWMZJCDLTNoGRUrs1wwhk
1980	payment	115	115	115	1979	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuRmTwZ1PciJgbyorEKNzNC347knMxcY16VTCMcAsCYDJsLzXrC
1907	payment	115	115	115	1906	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuDzGefMycCGvvPBeCLvgWnyuw7bPDpPwaqT6fGNekCC2qp4Qsv
1908	payment	115	115	115	1907	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuJsfaM3JsUysXCdMMWRwZGq4jEKNTsudUMHFXU6r3ucEzhbXVH
1909	payment	115	115	115	1908	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuiRyi7stH3m6XhRqAWx6wM5sjZ8sZKupTx1VJmmtKxktyQgWbP
1910	payment	115	115	115	1909	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuZNf3gkjuYWA2KpW2ZW2ReiQ9X16tFB9LsFinVvUZfSbkzy8sG
1911	payment	115	115	115	1910	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4DCXcoTDszUJFSUmpG2FCHiH9cwKmdWi9XYp37gocaW4svHkW
1912	payment	115	115	115	1911	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv4bveW1dNpcYY4ruJRgLM7se5gXLKxyW9NEUQ8hbDQZy8TEwHH
1913	payment	115	115	115	1912	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDEnRUP2CZtAy195mSYNSDgCS2LQzbjz265z61bhq3oNFqESn9
1914	payment	115	115	115	1913	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtoXBSv2T59sGnmyVwU8cvEURRzdSWNW4oqcJ982G92quH2eagv
1915	payment	115	115	115	1914	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuaE71ACxe8xFPAoeLN49KgPppU4KrvXgg26xaMg4zbSb6m95zb
1916	payment	115	115	115	1915	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuTK18RTSzvRrYr2ZqEXWkqbXWtgxscdSgwsWK5k8fVg7WqXd3M
1917	payment	115	115	115	1916	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juet7YKVYevJKdqnoNFSUyN9yb9ZwPoKS31WUXsUCUpuQjmV5wY
1918	payment	115	115	115	1917	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuXpo1WQ8sXiibDAw8qdEoaJZgFde6QJAwnfWX9UL5YGPU2Qnaw
1930	payment	115	115	115	1929	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvGhBUQgQrqHbCfBHvbQ5LoEtqkJ746XUKvVXa43morgCaVSuq2
1931	payment	115	115	115	1930	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtqqVrzSvLEFmn2odJqamBsLLBetfUTRkk5v5MGMUhyfwEJN7FK
1932	payment	115	115	115	1931	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtbnyxr1JvTCV6TtrYcp1p54fZ81Zqz2WLChKUydRo54YQMNixy
1933	payment	115	115	115	1932	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvAh51JjctL7igagjQmtUnSUwo3u5N2u1mx2n9kUAxXE7NYpFe6
1934	payment	115	115	115	1933	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1aYiCVU9B5kN7P9f1JitvRf3jbMnjbc4vcVcoa4bN1i9f2ho6
1935	payment	115	115	115	1934	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2eSjsrT4KMvJsh6m9TZq7exzri6E4m98WcEwkUz4Mc51FP473
1936	payment	115	115	115	1935	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2QRHuNUtxPtdxWSnZgR6SXmiGtsJTgQGU855prxe95UJNhFDX
1937	payment	115	115	115	1936	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JttBjaouLHuj7eeduMqaRbNMGiG13zrVYde4k6KMxb6egcUPxct
1938	payment	115	115	115	1937	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JumAoHx5sA75rtwgrndVmRm26MZxAq9GNP8jygecVkRXxABxJEQ
1939	payment	115	115	115	1938	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jtcz9SEvMVCh1frRDGDw9tn9xxDoNFWmyKZAAm9as97ovrfAsVD
1940	payment	115	115	115	1939	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JucuLf6WTcPAwG1UuCtrdY5d4NQpFwHZ3gJDJkrTe6Qv3V4QBWB
1941	payment	115	115	115	1940	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvHFr8cCUeVabqekZz9rv4FzN2dc1fAq5JtZoMfNMjwuN4vdDNa
1953	payment	115	115	115	1952	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju1HkEjm1Z9bEFrDgyRpprdLzQz9gMXC9pqM2wx3Bz6RX1PNTVt
1954	payment	115	115	115	1953	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Juex73DMDvdutehF97KPqqAjAq7A3un1eUBFfexD1kx78pSzQHp
1955	payment	115	115	115	1954	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuhUcLD2jf8JJ4EsnCD8Jyg1jUP3GnE52xZwczHHfiXEsKnRekx
1956	payment	115	115	115	1955	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuN2fNMa7hJ6481uEG4YvxrgPrYdTeTWNrCeNPtA55HbQwcLWHN
1957	payment	115	115	115	1956	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuPPGAhwge9T8zvHNgw5GbgVPMbm8HTVsTNtw1vFFaZMjZoqK6P
1958	payment	115	115	115	1957	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmvnCFxBpTLEBhAU2GRfnaKYdU2W4XycBNkBKmEUttnZY5wiKZ
1959	payment	115	115	115	1958	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvLTjG9JizygFiZ7sxNkhYXSnRckgze7qPMdo21zh9aoPpFsXof
1960	payment	115	115	115	1959	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuwcE91dNub5vPh5xnL6gdtyCdZiMzPG6jbyW1E4DCoZrxmroet
1961	payment	115	115	115	1960	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvM6vYFnJXFcDaFJ2QXJF2vAP8ixmtf38tzohKmmUiYhxq2npwc
1962	payment	115	115	115	1961	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNW4twm1dLnMhq3a666FJG9qGf7vGrrtvwPC45ZpdmwFmaCzCf
1963	payment	115	115	115	1962	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuVfXo8d54sG6gCtAAgxBX3y1qbanjM5cMXRvbaQPcP8AofsGNL
1964	payment	115	115	115	1963	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuNd8g3NsMTYktgG8gC3CWKXq51ghTKQUA9JCcnSSsC3jZNJZ29
1965	payment	115	115	115	1964	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtZHG9xWXVgMCGaN16BCirzWbr7yaWcwCAuD5mfw6FyPpGfdtnS
1966	payment	115	115	115	1965	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuFhSR9JrFq5oEF3JBe2bAudeJzTTV9wByqY5ZVo97ViufdR5TZ
1967	payment	115	115	115	1966	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jti3xgGJr3bssWhdemiYGq3VaoHCG3hYU7JFYCHqWjQzTWtN4pK
1968	payment	115	115	115	1967	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvRpNGQkwshZxQmpujAoiMsSdForPG2tHoFhBrzK171tBwtonM1
1975	payment	115	115	115	1974	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuV6jzc8ZFfnrfU4VhRASLgbhay15gpDdjQBshaNo6Dv5pifkdz
1976	payment	115	115	115	1975	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv9yxGFiZR76d26WCS2NdieivaQJCFpmxH6Pq5gkv53DG6ygVHH
1977	payment	115	115	115	1976	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMirsdxV8FavKpWVfkqBZkGv5BwKUqQJnH8jKXTbX6tw7oeLqS
1978	payment	115	115	115	1977	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuykBS6GrfiZLCTweWnT2SjCCyokS2qnaFQE65hjy6bK9ibVo7q
1979	payment	115	115	115	1978	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtuAgNb7BXY9aBkSKwj3uxT9oz6nCieMKyoechQ41beLygyL6nq
1984	payment	115	115	115	1983	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuzCjCwvwPoByVHbLgyLSBrtCruch2ZJZe9sGok8T2ybuswQYCN
1985	payment	115	115	115	1984	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuUNp2M3rrJGLhqC7FCBdp3wTVZPm5P1UnPkWvA1LyfUE9zXmWC
1986	payment	115	115	115	1985	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuMum8VPDYSDH6DMiz5xSpqHcpcY6XH7YaAYh1XqXFyuWq9wXkG
1993	payment	115	115	115	1992	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JthHffATJSqqqAmrCWbwrPYvXArTuaDgwBSEQxkGvSni1uocTtC
1981	payment	115	115	115	1980	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtsHwaxa3qQRfBtyK2Eex2p3Yj9nDq2GUUU7VgkPpDxcGi76zPC
1982	payment	115	115	115	1981	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvDqcrRVthr9NGhmk4sRvzfdFC7PJkrhk1EVebUEG5aB4aK448m
1983	payment	115	115	115	1982	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju2megLqNsRvKsSkrZXHkPnoHJWGR5DKCfMvUVsxYDuqwP3ZbRS
1987	payment	115	115	115	1986	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JvCfSe6snhGQgyYsGGnyYGYvmm74FEvy2ScbjSJ4eURTJG4Y15i
1988	payment	115	115	115	1987	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtmQAR4epgr1t1LuX8Z3wXSEKUgVeA4BTYQJKvL2P4SFGkoYeuA
1989	payment	115	115	115	1988	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JugEW5voBdru7r3rbjuu693yPJ7TXA7QfVkaDPN2dTHQrjpe1yU
1990	payment	115	115	115	1989	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Ju3t4pLPwXdXnWuB1fuhxyN4HRrXJ2n6DAGFiepudBkrBgZFnYH
1991	payment	115	115	115	1990	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtyPhsNkhc2R5DfCxcZ9cijwhddYvgqBUdxREYM6F5VMLcBM32h
1992	payment	115	115	115	1991	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JtzSawFGH3QFsdhg1cRybSNJb9uGiBGd2aNFG56jMRX8dZFg5Mf
1994	payment	115	115	115	1993	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuLHYhqHyR9UpA9iyUiSWbTRNQeEcx8x5QX4U9cp8tnEpu7UWNy
1995	payment	115	115	115	1994	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5JuEDibawiRZwhurrcg7xhUWfBy7zF29CMgyUaFXYEjbTnrvawgy
1996	payment	115	115	115	1995	1000000000	250000000	\N	E4YM2vTHhWEg66xpj52JErHUBU4pZ1yageL4TVDDpTTSsv8mK6YaH	5Jv7XEcsVcBRL5SnNMwanGmb9xHxpBDKYos3dV9DGqzMjuYSea1D
\.


--
-- Data for Name: voting_for; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.voting_for (id, value) FROM stdin;
1	3NK2tkzqqK5spR2sZ7tujjqPksL45M3UUrcA4WhCkeiPtnugyE2x
\.


--
-- Data for Name: zkapp_account_permissions_precondition; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_account_permissions_precondition (id, edit_state, send, receive, access, set_delegate, set_permissions, set_verification_key, set_zkapp_uri, edit_action_state, set_token_symbol, increment_nonce, set_voting_for, set_timing) FROM stdin;
\.


--
-- Data for Name: zkapp_account_precondition; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_account_precondition (id, balance_id, nonce_id, receipt_chain_hash, delegate_id, state_id, action_state_id, proved_state, is_new, permissions_id) FROM stdin;
\.


--
-- Data for Name: zkapp_account_update; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_account_update (id, body_id) FROM stdin;
\.


--
-- Data for Name: zkapp_account_update_body; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_account_update_body (id, account_identifier_id, update_id, balance_change, increment_nonce, events_id, actions_id, call_data_id, call_depth, zkapp_network_precondition_id, zkapp_account_precondition_id, zkapp_valid_while_precondition_id, use_full_commitment, implicit_account_creation_fee, may_use_token, authorization_kind, verification_key_hash_id) FROM stdin;
\.


--
-- Data for Name: zkapp_account_update_failures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_account_update_failures (id, index, failures) FROM stdin;
\.


--
-- Data for Name: zkapp_accounts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_accounts (id, app_state_id, verification_key_id, zkapp_version, action_state_id, last_action_slot, proved_state, zkapp_uri_id) FROM stdin;
\.


--
-- Data for Name: zkapp_action_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_action_states (id, element0, element1, element2, element3, element4) FROM stdin;
\.


--
-- Data for Name: zkapp_amount_bounds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_amount_bounds (id, amount_lower_bound, amount_upper_bound) FROM stdin;
\.


--
-- Data for Name: zkapp_balance_bounds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_balance_bounds (id, balance_lower_bound, balance_upper_bound) FROM stdin;
\.


--
-- Data for Name: zkapp_commands; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_commands (id, zkapp_fee_payer_body_id, zkapp_account_updates_ids, memo, hash) FROM stdin;
\.


--
-- Data for Name: zkapp_epoch_data; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_epoch_data (id, epoch_ledger_id, epoch_seed, start_checkpoint, lock_checkpoint, epoch_length_id) FROM stdin;
\.


--
-- Data for Name: zkapp_epoch_ledger; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_epoch_ledger (id, hash_id, total_currency_id) FROM stdin;
\.


--
-- Data for Name: zkapp_events; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_events (id, element_ids) FROM stdin;
\.


--
-- Data for Name: zkapp_fee_payer_body; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_fee_payer_body (id, public_key_id, fee, valid_until, nonce) FROM stdin;
\.


--
-- Data for Name: zkapp_field; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_field (id, field) FROM stdin;
\.


--
-- Data for Name: zkapp_field_array; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_field_array (id, element_ids) FROM stdin;
\.


--
-- Data for Name: zkapp_global_slot_bounds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_global_slot_bounds (id, global_slot_lower_bound, global_slot_upper_bound) FROM stdin;
\.


--
-- Data for Name: zkapp_length_bounds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_length_bounds (id, length_lower_bound, length_upper_bound) FROM stdin;
\.


--
-- Data for Name: zkapp_network_precondition; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_network_precondition (id, snarked_ledger_hash_id, blockchain_length_id, min_window_density_id, total_currency_id, global_slot_since_genesis, staking_epoch_data_id, next_epoch_data_id) FROM stdin;
\.


--
-- Data for Name: zkapp_nonce_bounds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_nonce_bounds (id, nonce_lower_bound, nonce_upper_bound) FROM stdin;
\.


--
-- Data for Name: zkapp_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_permissions (id, edit_state, send, receive, access, set_delegate, set_permissions, set_verification_key_auth, set_verification_key_txn_version, set_zkapp_uri, edit_action_state, set_token_symbol, increment_nonce, set_voting_for, set_timing) FROM stdin;
1	signature	signature	none	none	signature	signature	signature	3	signature	signature	signature	signature	signature	signature
\.


--
-- Data for Name: zkapp_states; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_states (id, element0, element1, element2, element3, element4, element5, element6, element7) FROM stdin;
\.


--
-- Data for Name: zkapp_states_nullable; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_states_nullable (id, element0, element1, element2, element3, element4, element5, element6, element7) FROM stdin;
\.


--
-- Data for Name: zkapp_timing_info; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_timing_info (id, initial_minimum_balance, cliff_time, cliff_amount, vesting_period, vesting_increment) FROM stdin;
\.


--
-- Data for Name: zkapp_token_id_bounds; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_token_id_bounds (id, token_id_lower_bound, token_id_upper_bound) FROM stdin;
\.


--
-- Data for Name: zkapp_updates; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_updates (id, app_state_id, delegate_id, verification_key_id, permissions_id, zkapp_uri_id, token_symbol_id, timing_id, voting_for_id) FROM stdin;
\.


--
-- Data for Name: zkapp_uris; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_uris (id, value) FROM stdin;
\.


--
-- Data for Name: zkapp_verification_key_hashes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_verification_key_hashes (id, value) FROM stdin;
\.


--
-- Data for Name: zkapp_verification_keys; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.zkapp_verification_keys (id, verification_key, hash_id) FROM stdin;
\.


--
-- Name: account_identifiers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.account_identifiers_id_seq', 243, true);


--
-- Name: blocks_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.blocks_id_seq', 447, true);


--
-- Name: epoch_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.epoch_data_id_seq', 449, true);


--
-- Name: internal_commands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.internal_commands_id_seq', 82, true);


--
-- Name: protocol_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.protocol_versions_id_seq', 1, true);


--
-- Name: public_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.public_keys_id_seq', 244, true);


--
-- Name: snarked_ledger_hashes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.snarked_ledger_hashes_id_seq', 2, true);


--
-- Name: timing_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.timing_info_id_seq', 243, true);


--
-- Name: token_symbols_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.token_symbols_id_seq', 1, true);


--
-- Name: tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.tokens_id_seq', 1, true);


--
-- Name: user_commands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_commands_id_seq', 1996, true);


--
-- Name: voting_for_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.voting_for_id_seq', 1, true);


--
-- Name: zkapp_account_permissions_precondition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_account_permissions_precondition_id_seq', 1, false);


--
-- Name: zkapp_account_precondition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_account_precondition_id_seq', 1, false);


--
-- Name: zkapp_account_update_body_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_account_update_body_id_seq', 1, false);


--
-- Name: zkapp_account_update_failures_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_account_update_failures_id_seq', 1, false);


--
-- Name: zkapp_account_update_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_account_update_id_seq', 1, false);


--
-- Name: zkapp_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_accounts_id_seq', 1, false);


--
-- Name: zkapp_action_states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_action_states_id_seq', 1, false);


--
-- Name: zkapp_amount_bounds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_amount_bounds_id_seq', 1, false);


--
-- Name: zkapp_balance_bounds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_balance_bounds_id_seq', 1, false);


--
-- Name: zkapp_commands_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_commands_id_seq', 1, false);


--
-- Name: zkapp_epoch_data_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_epoch_data_id_seq', 1, false);


--
-- Name: zkapp_epoch_ledger_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_epoch_ledger_id_seq', 1, false);


--
-- Name: zkapp_events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_events_id_seq', 1, false);


--
-- Name: zkapp_fee_payer_body_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_fee_payer_body_id_seq', 1, false);


--
-- Name: zkapp_field_array_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_field_array_id_seq', 1, false);


--
-- Name: zkapp_field_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_field_id_seq', 1, false);


--
-- Name: zkapp_global_slot_bounds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_global_slot_bounds_id_seq', 1, false);


--
-- Name: zkapp_length_bounds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_length_bounds_id_seq', 1, false);


--
-- Name: zkapp_network_precondition_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_network_precondition_id_seq', 1, false);


--
-- Name: zkapp_nonce_bounds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_nonce_bounds_id_seq', 1, false);


--
-- Name: zkapp_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_permissions_id_seq', 1, true);


--
-- Name: zkapp_states_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_states_id_seq', 1, false);


--
-- Name: zkapp_states_nullable_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_states_nullable_id_seq', 1, false);


--
-- Name: zkapp_timing_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_timing_info_id_seq', 1, false);


--
-- Name: zkapp_token_id_bounds_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_token_id_bounds_id_seq', 1, false);


--
-- Name: zkapp_updates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_updates_id_seq', 1, false);


--
-- Name: zkapp_uris_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_uris_id_seq', 1, false);


--
-- Name: zkapp_verification_key_hashes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_verification_key_hashes_id_seq', 1, false);


--
-- Name: zkapp_verification_keys_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.zkapp_verification_keys_id_seq', 1, false);


--
-- Name: account_identifiers account_identifiers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_identifiers
    ADD CONSTRAINT account_identifiers_pkey PRIMARY KEY (id);


--
-- Name: account_identifiers account_identifiers_public_key_id_token_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_identifiers
    ADD CONSTRAINT account_identifiers_public_key_id_token_id_key UNIQUE (public_key_id, token_id);


--
-- Name: accounts_accessed accounts_accessed_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_accessed
    ADD CONSTRAINT accounts_accessed_pkey PRIMARY KEY (block_id, account_identifier_id);


--
-- Name: accounts_created accounts_created_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_created
    ADD CONSTRAINT accounts_created_pkey PRIMARY KEY (block_id, account_identifier_id);


--
-- Name: blocks_internal_commands blocks_internal_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks_internal_commands
    ADD CONSTRAINT blocks_internal_commands_pkey PRIMARY KEY (block_id, internal_command_id, sequence_no, secondary_sequence_no);


--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (id);


--
-- Name: blocks blocks_state_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_state_hash_key UNIQUE (state_hash);


--
-- Name: blocks_user_commands blocks_user_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks_user_commands
    ADD CONSTRAINT blocks_user_commands_pkey PRIMARY KEY (block_id, user_command_id, sequence_no);


--
-- Name: blocks_zkapp_commands blocks_zkapp_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks_zkapp_commands
    ADD CONSTRAINT blocks_zkapp_commands_pkey PRIMARY KEY (block_id, zkapp_command_id, sequence_no);


--
-- Name: epoch_data epoch_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_data
    ADD CONSTRAINT epoch_data_pkey PRIMARY KEY (id);


--
-- Name: epoch_data epoch_data_seed_ledger_hash_id_total_currency_start_checkpo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_data
    ADD CONSTRAINT epoch_data_seed_ledger_hash_id_total_currency_start_checkpo_key UNIQUE (seed, ledger_hash_id, total_currency, start_checkpoint, lock_checkpoint, epoch_length);


--
-- Name: internal_commands internal_commands_hash_command_type_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internal_commands
    ADD CONSTRAINT internal_commands_hash_command_type_key UNIQUE (hash, command_type);


--
-- Name: internal_commands internal_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internal_commands
    ADD CONSTRAINT internal_commands_pkey PRIMARY KEY (id);


--
-- Name: protocol_versions protocol_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocol_versions
    ADD CONSTRAINT protocol_versions_pkey PRIMARY KEY (id);


--
-- Name: protocol_versions protocol_versions_transaction_network_patch_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.protocol_versions
    ADD CONSTRAINT protocol_versions_transaction_network_patch_key UNIQUE (transaction, network, patch);


--
-- Name: public_keys public_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.public_keys
    ADD CONSTRAINT public_keys_pkey PRIMARY KEY (id);


--
-- Name: public_keys public_keys_value_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.public_keys
    ADD CONSTRAINT public_keys_value_key UNIQUE (value);


--
-- Name: snarked_ledger_hashes snarked_ledger_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.snarked_ledger_hashes
    ADD CONSTRAINT snarked_ledger_hashes_pkey PRIMARY KEY (id);


--
-- Name: snarked_ledger_hashes snarked_ledger_hashes_value_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.snarked_ledger_hashes
    ADD CONSTRAINT snarked_ledger_hashes_value_key UNIQUE (value);


--
-- Name: timing_info timing_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timing_info
    ADD CONSTRAINT timing_info_pkey PRIMARY KEY (id);


--
-- Name: token_symbols token_symbols_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.token_symbols
    ADD CONSTRAINT token_symbols_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_pkey PRIMARY KEY (id);


--
-- Name: tokens tokens_value_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_value_key UNIQUE (value);


--
-- Name: user_commands user_commands_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_hash_key UNIQUE (hash);


--
-- Name: user_commands user_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_pkey PRIMARY KEY (id);


--
-- Name: voting_for voting_for_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.voting_for
    ADD CONSTRAINT voting_for_pkey PRIMARY KEY (id);


--
-- Name: zkapp_account_permissions_precondition zkapp_account_permissions_precondition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_permissions_precondition
    ADD CONSTRAINT zkapp_account_permissions_precondition_pkey PRIMARY KEY (id);


--
-- Name: zkapp_account_precondition zkapp_account_precondition_balance_id_receipt_chain_hash_de_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_precondition
    ADD CONSTRAINT zkapp_account_precondition_balance_id_receipt_chain_hash_de_key UNIQUE (balance_id, receipt_chain_hash, delegate_id, state_id, action_state_id, proved_state, is_new, nonce_id);


--
-- Name: zkapp_account_precondition zkapp_account_precondition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_precondition
    ADD CONSTRAINT zkapp_account_precondition_pkey PRIMARY KEY (id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_pkey PRIMARY KEY (id);


--
-- Name: zkapp_account_update_failures zkapp_account_update_failures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_failures
    ADD CONSTRAINT zkapp_account_update_failures_pkey PRIMARY KEY (id);


--
-- Name: zkapp_account_update zkapp_account_update_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update
    ADD CONSTRAINT zkapp_account_update_pkey PRIMARY KEY (id);


--
-- Name: zkapp_accounts zkapp_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_accounts
    ADD CONSTRAINT zkapp_accounts_pkey PRIMARY KEY (id);


--
-- Name: zkapp_action_states zkapp_action_states_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_action_states
    ADD CONSTRAINT zkapp_action_states_pkey PRIMARY KEY (id);


--
-- Name: zkapp_amount_bounds zkapp_amount_bounds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_amount_bounds
    ADD CONSTRAINT zkapp_amount_bounds_pkey PRIMARY KEY (id);


--
-- Name: zkapp_balance_bounds zkapp_balance_bounds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_balance_bounds
    ADD CONSTRAINT zkapp_balance_bounds_pkey PRIMARY KEY (id);


--
-- Name: zkapp_commands zkapp_commands_hash_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_commands
    ADD CONSTRAINT zkapp_commands_hash_key UNIQUE (hash);


--
-- Name: zkapp_commands zkapp_commands_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_commands
    ADD CONSTRAINT zkapp_commands_pkey PRIMARY KEY (id);


--
-- Name: zkapp_epoch_data zkapp_epoch_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_epoch_data
    ADD CONSTRAINT zkapp_epoch_data_pkey PRIMARY KEY (id);


--
-- Name: zkapp_epoch_ledger zkapp_epoch_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_epoch_ledger
    ADD CONSTRAINT zkapp_epoch_ledger_pkey PRIMARY KEY (id);


--
-- Name: zkapp_events zkapp_events_element_ids_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_events
    ADD CONSTRAINT zkapp_events_element_ids_key UNIQUE (element_ids);


--
-- Name: zkapp_events zkapp_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_events
    ADD CONSTRAINT zkapp_events_pkey PRIMARY KEY (id);


--
-- Name: zkapp_fee_payer_body zkapp_fee_payer_body_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_fee_payer_body
    ADD CONSTRAINT zkapp_fee_payer_body_pkey PRIMARY KEY (id);


--
-- Name: zkapp_field_array zkapp_field_array_element_ids_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_field_array
    ADD CONSTRAINT zkapp_field_array_element_ids_key UNIQUE (element_ids);


--
-- Name: zkapp_field_array zkapp_field_array_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_field_array
    ADD CONSTRAINT zkapp_field_array_pkey PRIMARY KEY (id);


--
-- Name: zkapp_field zkapp_field_field_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_field
    ADD CONSTRAINT zkapp_field_field_key UNIQUE (field);


--
-- Name: zkapp_field zkapp_field_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_field
    ADD CONSTRAINT zkapp_field_pkey PRIMARY KEY (id);


--
-- Name: zkapp_global_slot_bounds zkapp_global_slot_bounds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_global_slot_bounds
    ADD CONSTRAINT zkapp_global_slot_bounds_pkey PRIMARY KEY (id);


--
-- Name: zkapp_length_bounds zkapp_length_bounds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_length_bounds
    ADD CONSTRAINT zkapp_length_bounds_pkey PRIMARY KEY (id);


--
-- Name: zkapp_network_precondition zkapp_network_precondition_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_network_precondition
    ADD CONSTRAINT zkapp_network_precondition_pkey PRIMARY KEY (id);


--
-- Name: zkapp_nonce_bounds zkapp_nonce_bounds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_nonce_bounds
    ADD CONSTRAINT zkapp_nonce_bounds_pkey PRIMARY KEY (id);


--
-- Name: zkapp_permissions zkapp_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_permissions
    ADD CONSTRAINT zkapp_permissions_pkey PRIMARY KEY (id);


--
-- Name: zkapp_states_nullable zkapp_states_nullable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable
    ADD CONSTRAINT zkapp_states_nullable_pkey PRIMARY KEY (id);


--
-- Name: zkapp_states zkapp_states_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states
    ADD CONSTRAINT zkapp_states_pkey PRIMARY KEY (id);


--
-- Name: zkapp_timing_info zkapp_timing_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_timing_info
    ADD CONSTRAINT zkapp_timing_info_pkey PRIMARY KEY (id);


--
-- Name: zkapp_token_id_bounds zkapp_token_id_bounds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_token_id_bounds
    ADD CONSTRAINT zkapp_token_id_bounds_pkey PRIMARY KEY (id);


--
-- Name: zkapp_updates zkapp_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates
    ADD CONSTRAINT zkapp_updates_pkey PRIMARY KEY (id);


--
-- Name: zkapp_uris zkapp_uris_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_uris
    ADD CONSTRAINT zkapp_uris_pkey PRIMARY KEY (id);


--
-- Name: zkapp_uris zkapp_uris_value_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_uris
    ADD CONSTRAINT zkapp_uris_value_key UNIQUE (value);


--
-- Name: zkapp_verification_key_hashes zkapp_verification_key_hashes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_verification_key_hashes
    ADD CONSTRAINT zkapp_verification_key_hashes_pkey PRIMARY KEY (id);


--
-- Name: zkapp_verification_key_hashes zkapp_verification_key_hashes_value_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_verification_key_hashes
    ADD CONSTRAINT zkapp_verification_key_hashes_value_key UNIQUE (value);


--
-- Name: zkapp_verification_keys zkapp_verification_keys_hash_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_verification_keys
    ADD CONSTRAINT zkapp_verification_keys_hash_id_key UNIQUE (hash_id);


--
-- Name: zkapp_verification_keys zkapp_verification_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_verification_keys
    ADD CONSTRAINT zkapp_verification_keys_pkey PRIMARY KEY (id);


--
-- Name: zkapp_verification_keys zkapp_verification_keys_verification_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_verification_keys
    ADD CONSTRAINT zkapp_verification_keys_verification_key_key UNIQUE (verification_key);


--
-- Name: idx_accounts_accessed_block_account_identifier_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_accounts_accessed_block_account_identifier_id ON public.accounts_accessed USING btree (account_identifier_id);


--
-- Name: idx_accounts_accessed_block_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_accounts_accessed_block_id ON public.accounts_accessed USING btree (block_id);


--
-- Name: idx_accounts_created_block_account_identifier_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_accounts_created_block_account_identifier_id ON public.accounts_created USING btree (account_identifier_id);


--
-- Name: idx_accounts_created_block_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_accounts_created_block_id ON public.accounts_created USING btree (block_id);


--
-- Name: idx_blocks_creator_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_creator_id ON public.blocks USING btree (creator_id);


--
-- Name: idx_blocks_height; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_height ON public.blocks USING btree (height);


--
-- Name: idx_blocks_internal_commands_block_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_internal_commands_block_id ON public.blocks_internal_commands USING btree (block_id);


--
-- Name: idx_blocks_internal_commands_internal_command_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_internal_commands_internal_command_id ON public.blocks_internal_commands USING btree (internal_command_id);


--
-- Name: idx_blocks_internal_commands_secondary_sequence_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_internal_commands_secondary_sequence_no ON public.blocks_internal_commands USING btree (secondary_sequence_no);


--
-- Name: idx_blocks_internal_commands_sequence_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_internal_commands_sequence_no ON public.blocks_internal_commands USING btree (sequence_no);


--
-- Name: idx_blocks_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_parent_id ON public.blocks USING btree (parent_id);


--
-- Name: idx_blocks_user_commands_block_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_user_commands_block_id ON public.blocks_user_commands USING btree (block_id);


--
-- Name: idx_blocks_user_commands_sequence_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_user_commands_sequence_no ON public.blocks_user_commands USING btree (sequence_no);


--
-- Name: idx_blocks_user_commands_user_command_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_user_commands_user_command_id ON public.blocks_user_commands USING btree (user_command_id);


--
-- Name: idx_blocks_zkapp_commands_block_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_zkapp_commands_block_id ON public.blocks_zkapp_commands USING btree (block_id);


--
-- Name: idx_blocks_zkapp_commands_sequence_no; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_zkapp_commands_sequence_no ON public.blocks_zkapp_commands USING btree (sequence_no);


--
-- Name: idx_blocks_zkapp_commands_zkapp_command_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_blocks_zkapp_commands_zkapp_command_id ON public.blocks_zkapp_commands USING btree (zkapp_command_id);


--
-- Name: idx_chain_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_chain_status ON public.blocks USING btree (chain_status);


--
-- Name: idx_token_symbols_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_token_symbols_value ON public.token_symbols USING btree (value);


--
-- Name: idx_voting_for_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_voting_for_value ON public.voting_for USING btree (value);


--
-- Name: idx_zkapp_events_element_ids; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_zkapp_events_element_ids ON public.zkapp_events USING btree (element_ids);


--
-- Name: idx_zkapp_field_array_element_ids; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_zkapp_field_array_element_ids ON public.zkapp_field_array USING btree (element_ids);


--
-- Name: account_identifiers account_identifiers_public_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_identifiers
    ADD CONSTRAINT account_identifiers_public_key_id_fkey FOREIGN KEY (public_key_id) REFERENCES public.public_keys(id) ON DELETE CASCADE;


--
-- Name: account_identifiers account_identifiers_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_identifiers
    ADD CONSTRAINT account_identifiers_token_id_fkey FOREIGN KEY (token_id) REFERENCES public.tokens(id) ON DELETE CASCADE;


--
-- Name: accounts_accessed accounts_accessed_account_identifier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_accessed
    ADD CONSTRAINT accounts_accessed_account_identifier_id_fkey FOREIGN KEY (account_identifier_id) REFERENCES public.account_identifiers(id);


--
-- Name: accounts_accessed accounts_accessed_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_accessed
    ADD CONSTRAINT accounts_accessed_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id);


--
-- Name: accounts_accessed accounts_accessed_delegate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_accessed
    ADD CONSTRAINT accounts_accessed_delegate_id_fkey FOREIGN KEY (delegate_id) REFERENCES public.public_keys(id);


--
-- Name: accounts_accessed accounts_accessed_permissions_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_accessed
    ADD CONSTRAINT accounts_accessed_permissions_id_fkey FOREIGN KEY (permissions_id) REFERENCES public.zkapp_permissions(id);


--
-- Name: accounts_accessed accounts_accessed_timing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_accessed
    ADD CONSTRAINT accounts_accessed_timing_id_fkey FOREIGN KEY (timing_id) REFERENCES public.timing_info(id);


--
-- Name: accounts_accessed accounts_accessed_token_symbol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_accessed
    ADD CONSTRAINT accounts_accessed_token_symbol_id_fkey FOREIGN KEY (token_symbol_id) REFERENCES public.token_symbols(id);


--
-- Name: accounts_accessed accounts_accessed_voting_for_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_accessed
    ADD CONSTRAINT accounts_accessed_voting_for_id_fkey FOREIGN KEY (voting_for_id) REFERENCES public.voting_for(id);


--
-- Name: accounts_accessed accounts_accessed_zkapp_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_accessed
    ADD CONSTRAINT accounts_accessed_zkapp_id_fkey FOREIGN KEY (zkapp_id) REFERENCES public.zkapp_accounts(id);


--
-- Name: accounts_created accounts_created_account_identifier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_created
    ADD CONSTRAINT accounts_created_account_identifier_id_fkey FOREIGN KEY (account_identifier_id) REFERENCES public.account_identifiers(id);


--
-- Name: accounts_created accounts_created_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.accounts_created
    ADD CONSTRAINT accounts_created_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id);


--
-- Name: blocks blocks_block_winner_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_block_winner_id_fkey FOREIGN KEY (block_winner_id) REFERENCES public.public_keys(id);


--
-- Name: blocks blocks_creator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_creator_id_fkey FOREIGN KEY (creator_id) REFERENCES public.public_keys(id);


--
-- Name: blocks_internal_commands blocks_internal_commands_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks_internal_commands
    ADD CONSTRAINT blocks_internal_commands_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id) ON DELETE CASCADE;


--
-- Name: blocks_internal_commands blocks_internal_commands_internal_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks_internal_commands
    ADD CONSTRAINT blocks_internal_commands_internal_command_id_fkey FOREIGN KEY (internal_command_id) REFERENCES public.internal_commands(id) ON DELETE CASCADE;


--
-- Name: blocks blocks_next_epoch_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_next_epoch_data_id_fkey FOREIGN KEY (next_epoch_data_id) REFERENCES public.epoch_data(id);


--
-- Name: blocks blocks_parent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.blocks(id);


--
-- Name: blocks blocks_proposed_protocol_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_proposed_protocol_version_id_fkey FOREIGN KEY (proposed_protocol_version_id) REFERENCES public.protocol_versions(id);


--
-- Name: blocks blocks_protocol_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_protocol_version_id_fkey FOREIGN KEY (protocol_version_id) REFERENCES public.protocol_versions(id);


--
-- Name: blocks blocks_snarked_ledger_hash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_snarked_ledger_hash_id_fkey FOREIGN KEY (snarked_ledger_hash_id) REFERENCES public.snarked_ledger_hashes(id);


--
-- Name: blocks blocks_staking_epoch_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks
    ADD CONSTRAINT blocks_staking_epoch_data_id_fkey FOREIGN KEY (staking_epoch_data_id) REFERENCES public.epoch_data(id);


--
-- Name: blocks_user_commands blocks_user_commands_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks_user_commands
    ADD CONSTRAINT blocks_user_commands_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id) ON DELETE CASCADE;


--
-- Name: blocks_user_commands blocks_user_commands_user_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks_user_commands
    ADD CONSTRAINT blocks_user_commands_user_command_id_fkey FOREIGN KEY (user_command_id) REFERENCES public.user_commands(id) ON DELETE CASCADE;


--
-- Name: blocks_zkapp_commands blocks_zkapp_commands_block_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks_zkapp_commands
    ADD CONSTRAINT blocks_zkapp_commands_block_id_fkey FOREIGN KEY (block_id) REFERENCES public.blocks(id) ON DELETE CASCADE;


--
-- Name: blocks_zkapp_commands blocks_zkapp_commands_zkapp_command_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.blocks_zkapp_commands
    ADD CONSTRAINT blocks_zkapp_commands_zkapp_command_id_fkey FOREIGN KEY (zkapp_command_id) REFERENCES public.zkapp_commands(id) ON DELETE CASCADE;


--
-- Name: epoch_data epoch_data_ledger_hash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.epoch_data
    ADD CONSTRAINT epoch_data_ledger_hash_id_fkey FOREIGN KEY (ledger_hash_id) REFERENCES public.snarked_ledger_hashes(id);


--
-- Name: internal_commands internal_commands_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.internal_commands
    ADD CONSTRAINT internal_commands_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.public_keys(id);


--
-- Name: timing_info timing_info_account_identifier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.timing_info
    ADD CONSTRAINT timing_info_account_identifier_id_fkey FOREIGN KEY (account_identifier_id) REFERENCES public.account_identifiers(id);


--
-- Name: tokens tokens_owner_public_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_owner_public_key_id_fkey FOREIGN KEY (owner_public_key_id) REFERENCES public.public_keys(id) ON DELETE CASCADE;


--
-- Name: tokens tokens_owner_token_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tokens
    ADD CONSTRAINT tokens_owner_token_id_fkey FOREIGN KEY (owner_token_id) REFERENCES public.tokens(id);


--
-- Name: user_commands user_commands_fee_payer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_fee_payer_id_fkey FOREIGN KEY (fee_payer_id) REFERENCES public.public_keys(id);


--
-- Name: user_commands user_commands_receiver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_receiver_id_fkey FOREIGN KEY (receiver_id) REFERENCES public.public_keys(id);


--
-- Name: user_commands user_commands_source_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_commands
    ADD CONSTRAINT user_commands_source_id_fkey FOREIGN KEY (source_id) REFERENCES public.public_keys(id);


--
-- Name: zkapp_account_precondition zkapp_account_precondition_action_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_precondition
    ADD CONSTRAINT zkapp_account_precondition_action_state_id_fkey FOREIGN KEY (action_state_id) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_account_precondition zkapp_account_precondition_balance_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_precondition
    ADD CONSTRAINT zkapp_account_precondition_balance_id_fkey FOREIGN KEY (balance_id) REFERENCES public.zkapp_balance_bounds(id);


--
-- Name: zkapp_account_precondition zkapp_account_precondition_delegate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_precondition
    ADD CONSTRAINT zkapp_account_precondition_delegate_id_fkey FOREIGN KEY (delegate_id) REFERENCES public.public_keys(id);


--
-- Name: zkapp_account_precondition zkapp_account_precondition_nonce_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_precondition
    ADD CONSTRAINT zkapp_account_precondition_nonce_id_fkey FOREIGN KEY (nonce_id) REFERENCES public.zkapp_nonce_bounds(id);


--
-- Name: zkapp_account_precondition zkapp_account_precondition_permissions_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_precondition
    ADD CONSTRAINT zkapp_account_precondition_permissions_id_fkey FOREIGN KEY (permissions_id) REFERENCES public.zkapp_account_permissions_precondition(id);


--
-- Name: zkapp_account_precondition zkapp_account_precondition_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_precondition
    ADD CONSTRAINT zkapp_account_precondition_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.zkapp_states_nullable(id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_account_identifier_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_account_identifier_id_fkey FOREIGN KEY (account_identifier_id) REFERENCES public.account_identifiers(id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_actions_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_actions_id_fkey FOREIGN KEY (actions_id) REFERENCES public.zkapp_events(id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_call_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_call_data_id_fkey FOREIGN KEY (call_data_id) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_events_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_events_id_fkey FOREIGN KEY (events_id) REFERENCES public.zkapp_events(id);


--
-- Name: zkapp_account_update zkapp_account_update_body_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update
    ADD CONSTRAINT zkapp_account_update_body_id_fkey FOREIGN KEY (body_id) REFERENCES public.zkapp_account_update_body(id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_update_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_update_id_fkey FOREIGN KEY (update_id) REFERENCES public.zkapp_updates(id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_verification_key_hash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_verification_key_hash_id_fkey FOREIGN KEY (verification_key_hash_id) REFERENCES public.zkapp_verification_key_hashes(id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_zkapp_account_precondition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_zkapp_account_precondition_id_fkey FOREIGN KEY (zkapp_account_precondition_id) REFERENCES public.zkapp_account_precondition(id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_zkapp_network_precondition_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_zkapp_network_precondition_id_fkey FOREIGN KEY (zkapp_network_precondition_id) REFERENCES public.zkapp_network_precondition(id);


--
-- Name: zkapp_account_update_body zkapp_account_update_body_zkapp_valid_while_precondition_i_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_account_update_body
    ADD CONSTRAINT zkapp_account_update_body_zkapp_valid_while_precondition_i_fkey FOREIGN KEY (zkapp_valid_while_precondition_id) REFERENCES public.zkapp_global_slot_bounds(id);


--
-- Name: zkapp_accounts zkapp_accounts_action_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_accounts
    ADD CONSTRAINT zkapp_accounts_action_state_id_fkey FOREIGN KEY (action_state_id) REFERENCES public.zkapp_action_states(id);


--
-- Name: zkapp_accounts zkapp_accounts_app_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_accounts
    ADD CONSTRAINT zkapp_accounts_app_state_id_fkey FOREIGN KEY (app_state_id) REFERENCES public.zkapp_states(id);


--
-- Name: zkapp_accounts zkapp_accounts_verification_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_accounts
    ADD CONSTRAINT zkapp_accounts_verification_key_id_fkey FOREIGN KEY (verification_key_id) REFERENCES public.zkapp_verification_keys(id);


--
-- Name: zkapp_accounts zkapp_accounts_zkapp_uri_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_accounts
    ADD CONSTRAINT zkapp_accounts_zkapp_uri_id_fkey FOREIGN KEY (zkapp_uri_id) REFERENCES public.zkapp_uris(id);


--
-- Name: zkapp_action_states zkapp_action_states_element0_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_action_states
    ADD CONSTRAINT zkapp_action_states_element0_fkey FOREIGN KEY (element0) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_action_states zkapp_action_states_element1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_action_states
    ADD CONSTRAINT zkapp_action_states_element1_fkey FOREIGN KEY (element1) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_action_states zkapp_action_states_element2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_action_states
    ADD CONSTRAINT zkapp_action_states_element2_fkey FOREIGN KEY (element2) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_action_states zkapp_action_states_element3_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_action_states
    ADD CONSTRAINT zkapp_action_states_element3_fkey FOREIGN KEY (element3) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_action_states zkapp_action_states_element4_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_action_states
    ADD CONSTRAINT zkapp_action_states_element4_fkey FOREIGN KEY (element4) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_commands zkapp_commands_zkapp_fee_payer_body_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_commands
    ADD CONSTRAINT zkapp_commands_zkapp_fee_payer_body_id_fkey FOREIGN KEY (zkapp_fee_payer_body_id) REFERENCES public.zkapp_fee_payer_body(id);


--
-- Name: zkapp_epoch_data zkapp_epoch_data_epoch_ledger_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_epoch_data
    ADD CONSTRAINT zkapp_epoch_data_epoch_ledger_id_fkey FOREIGN KEY (epoch_ledger_id) REFERENCES public.zkapp_epoch_ledger(id);


--
-- Name: zkapp_epoch_data zkapp_epoch_data_epoch_length_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_epoch_data
    ADD CONSTRAINT zkapp_epoch_data_epoch_length_id_fkey FOREIGN KEY (epoch_length_id) REFERENCES public.zkapp_length_bounds(id);


--
-- Name: zkapp_epoch_ledger zkapp_epoch_ledger_hash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_epoch_ledger
    ADD CONSTRAINT zkapp_epoch_ledger_hash_id_fkey FOREIGN KEY (hash_id) REFERENCES public.snarked_ledger_hashes(id);


--
-- Name: zkapp_epoch_ledger zkapp_epoch_ledger_total_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_epoch_ledger
    ADD CONSTRAINT zkapp_epoch_ledger_total_currency_id_fkey FOREIGN KEY (total_currency_id) REFERENCES public.zkapp_amount_bounds(id);


--
-- Name: zkapp_fee_payer_body zkapp_fee_payer_body_public_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_fee_payer_body
    ADD CONSTRAINT zkapp_fee_payer_body_public_key_id_fkey FOREIGN KEY (public_key_id) REFERENCES public.public_keys(id);


--
-- Name: zkapp_network_precondition zkapp_network_precondition_blockchain_length_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_network_precondition
    ADD CONSTRAINT zkapp_network_precondition_blockchain_length_id_fkey FOREIGN KEY (blockchain_length_id) REFERENCES public.zkapp_length_bounds(id);


--
-- Name: zkapp_network_precondition zkapp_network_precondition_global_slot_since_genesis_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_network_precondition
    ADD CONSTRAINT zkapp_network_precondition_global_slot_since_genesis_fkey FOREIGN KEY (global_slot_since_genesis) REFERENCES public.zkapp_global_slot_bounds(id);


--
-- Name: zkapp_network_precondition zkapp_network_precondition_min_window_density_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_network_precondition
    ADD CONSTRAINT zkapp_network_precondition_min_window_density_id_fkey FOREIGN KEY (min_window_density_id) REFERENCES public.zkapp_length_bounds(id);


--
-- Name: zkapp_network_precondition zkapp_network_precondition_next_epoch_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_network_precondition
    ADD CONSTRAINT zkapp_network_precondition_next_epoch_data_id_fkey FOREIGN KEY (next_epoch_data_id) REFERENCES public.zkapp_epoch_data(id);


--
-- Name: zkapp_network_precondition zkapp_network_precondition_snarked_ledger_hash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_network_precondition
    ADD CONSTRAINT zkapp_network_precondition_snarked_ledger_hash_id_fkey FOREIGN KEY (snarked_ledger_hash_id) REFERENCES public.snarked_ledger_hashes(id);


--
-- Name: zkapp_network_precondition zkapp_network_precondition_staking_epoch_data_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_network_precondition
    ADD CONSTRAINT zkapp_network_precondition_staking_epoch_data_id_fkey FOREIGN KEY (staking_epoch_data_id) REFERENCES public.zkapp_epoch_data(id);


--
-- Name: zkapp_network_precondition zkapp_network_precondition_total_currency_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_network_precondition
    ADD CONSTRAINT zkapp_network_precondition_total_currency_id_fkey FOREIGN KEY (total_currency_id) REFERENCES public.zkapp_amount_bounds(id);


--
-- Name: zkapp_states zkapp_states_element0_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states
    ADD CONSTRAINT zkapp_states_element0_fkey FOREIGN KEY (element0) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states zkapp_states_element1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states
    ADD CONSTRAINT zkapp_states_element1_fkey FOREIGN KEY (element1) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states zkapp_states_element2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states
    ADD CONSTRAINT zkapp_states_element2_fkey FOREIGN KEY (element2) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states zkapp_states_element3_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states
    ADD CONSTRAINT zkapp_states_element3_fkey FOREIGN KEY (element3) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states zkapp_states_element4_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states
    ADD CONSTRAINT zkapp_states_element4_fkey FOREIGN KEY (element4) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states zkapp_states_element5_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states
    ADD CONSTRAINT zkapp_states_element5_fkey FOREIGN KEY (element5) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states zkapp_states_element6_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states
    ADD CONSTRAINT zkapp_states_element6_fkey FOREIGN KEY (element6) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states zkapp_states_element7_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states
    ADD CONSTRAINT zkapp_states_element7_fkey FOREIGN KEY (element7) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states_nullable zkapp_states_nullable_element0_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable
    ADD CONSTRAINT zkapp_states_nullable_element0_fkey FOREIGN KEY (element0) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states_nullable zkapp_states_nullable_element1_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable
    ADD CONSTRAINT zkapp_states_nullable_element1_fkey FOREIGN KEY (element1) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states_nullable zkapp_states_nullable_element2_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable
    ADD CONSTRAINT zkapp_states_nullable_element2_fkey FOREIGN KEY (element2) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states_nullable zkapp_states_nullable_element3_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable
    ADD CONSTRAINT zkapp_states_nullable_element3_fkey FOREIGN KEY (element3) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states_nullable zkapp_states_nullable_element4_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable
    ADD CONSTRAINT zkapp_states_nullable_element4_fkey FOREIGN KEY (element4) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states_nullable zkapp_states_nullable_element5_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable
    ADD CONSTRAINT zkapp_states_nullable_element5_fkey FOREIGN KEY (element5) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states_nullable zkapp_states_nullable_element6_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable
    ADD CONSTRAINT zkapp_states_nullable_element6_fkey FOREIGN KEY (element6) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_states_nullable zkapp_states_nullable_element7_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_states_nullable
    ADD CONSTRAINT zkapp_states_nullable_element7_fkey FOREIGN KEY (element7) REFERENCES public.zkapp_field(id);


--
-- Name: zkapp_updates zkapp_updates_app_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates
    ADD CONSTRAINT zkapp_updates_app_state_id_fkey FOREIGN KEY (app_state_id) REFERENCES public.zkapp_states_nullable(id);


--
-- Name: zkapp_updates zkapp_updates_delegate_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates
    ADD CONSTRAINT zkapp_updates_delegate_id_fkey FOREIGN KEY (delegate_id) REFERENCES public.public_keys(id);


--
-- Name: zkapp_updates zkapp_updates_permissions_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates
    ADD CONSTRAINT zkapp_updates_permissions_id_fkey FOREIGN KEY (permissions_id) REFERENCES public.zkapp_permissions(id);


--
-- Name: zkapp_updates zkapp_updates_timing_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates
    ADD CONSTRAINT zkapp_updates_timing_id_fkey FOREIGN KEY (timing_id) REFERENCES public.zkapp_timing_info(id);


--
-- Name: zkapp_updates zkapp_updates_token_symbol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates
    ADD CONSTRAINT zkapp_updates_token_symbol_id_fkey FOREIGN KEY (token_symbol_id) REFERENCES public.token_symbols(id);


--
-- Name: zkapp_updates zkapp_updates_verification_key_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates
    ADD CONSTRAINT zkapp_updates_verification_key_id_fkey FOREIGN KEY (verification_key_id) REFERENCES public.zkapp_verification_keys(id);


--
-- Name: zkapp_updates zkapp_updates_voting_for_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates
    ADD CONSTRAINT zkapp_updates_voting_for_id_fkey FOREIGN KEY (voting_for_id) REFERENCES public.voting_for(id);


--
-- Name: zkapp_updates zkapp_updates_zkapp_uri_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_updates
    ADD CONSTRAINT zkapp_updates_zkapp_uri_id_fkey FOREIGN KEY (zkapp_uri_id) REFERENCES public.zkapp_uris(id);


--
-- Name: zkapp_verification_keys zkapp_verification_keys_hash_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.zkapp_verification_keys
    ADD CONSTRAINT zkapp_verification_keys_hash_id_fkey FOREIGN KEY (hash_id) REFERENCES public.zkapp_verification_key_hashes(id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

