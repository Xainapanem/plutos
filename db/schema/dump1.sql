--
-- PostgreSQL database dump
--

\restrict Hx4izyqBdCXCkkvza1y2Me2ectSoi4bnJ2GIoBtEoQbPTj3LJZhIKtq5JeNK2SB

-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

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
-- Name: plutos; Type: SCHEMA; Schema: -; Owner: plutos
--

CREATE SCHEMA plutos;


ALTER SCHEMA plutos OWNER TO plutos;

--
-- Name: ftrg_execute_transaction(); Type: FUNCTION; Schema: plutos; Owner: plutos
--

CREATE FUNCTION plutos.ftrg_execute_transaction() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare

  l_cur_balance numeric(15,2);

begin

  select balance into l_cur_balance
  from wallet
  where keyid = new.wallet_from_id
  for update;

  if l_cur_balance >= new.value then

	 update wallet
	 set balance =  w.balance + new.value
	 where keyid = new.wallet_to_id;

	 update wallet w
	 set balance =  balance - new.value
	 where keyid = new.wallet_from_id;

	 new.status = 1;

     return new;

  else

     new.status = 2;

     insert into transactions_errlog
       (transactions_id
       ,err_text
       ,err_type)
       values
       (new.keyid
       ,'Operation error: Tried to make balance negative.'
       ,1);

       return new;

  end if;

  exception when others then

    new.status := 2;

    insert into transations_errlog
       (transactions_id
       ,err_text
       ,err_type)
       values
       (new.keyid
       ,'Exec err: ' || sqlerrm
       ,2);

     return new;


end;
$$;


ALTER FUNCTION plutos.ftrg_execute_transaction() OWNER TO plutos;

--
-- Name: ftrg_set_update_date(); Type: FUNCTION; Schema: plutos; Owner: plutos
--

CREATE FUNCTION plutos.ftrg_set_update_date() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin

  new.update_date := now();

end;
$$;


ALTER FUNCTION plutos.ftrg_set_update_date() OWNER TO plutos;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: man; Type: TABLE; Schema: plutos; Owner: plutos
--

CREATE TABLE plutos.man (
    keyid bigint NOT NULL,
    name text NOT NULL,
    email text NOT NULL,
    status smallint DEFAULT 1,
    create_date timestamp without time zone DEFAULT now(),
    man_type_id bigint
);


ALTER TABLE plutos.man OWNER TO plutos;

--
-- Name: man_keyid_seq; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

CREATE SEQUENCE plutos.man_keyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE plutos.man_keyid_seq OWNER TO plutos;

--
-- Name: man_keyid_seq1; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

ALTER TABLE plutos.man ALTER COLUMN keyid ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME plutos.man_keyid_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: man_type; Type: TABLE; Schema: plutos; Owner: plutos
--

CREATE TABLE plutos.man_type (
    keyid bigint NOT NULL,
    code text NOT NULL,
    text text NOT NULL,
    status boolean NOT NULL
);


ALTER TABLE plutos.man_type OWNER TO plutos;

--
-- Name: man_type_keyid_seq; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

CREATE SEQUENCE plutos.man_type_keyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE plutos.man_type_keyid_seq OWNER TO plutos;

--
-- Name: man_type_keyid_seq1; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

ALTER TABLE plutos.man_type ALTER COLUMN keyid ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME plutos.man_type_keyid_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transactions; Type: TABLE; Schema: plutos; Owner: plutos
--

CREATE TABLE plutos.transactions (
    keyid bigint NOT NULL,
    wallet_from_id bigint NOT NULL,
    wallet_to_id bigint NOT NULL,
    value numeric(15,2) NOT NULL,
    create_date timestamp with time zone DEFAULT now(),
    note text,
    status smallint NOT NULL,
    CONSTRAINT transactions_check CHECK ((wallet_from_id <> wallet_to_id)),
    CONSTRAINT transactions_status_check CHECK ((status = ANY (ARRAY[0, 1, 2]))),
    CONSTRAINT transactions_value_check CHECK ((value > (0)::numeric))
);


ALTER TABLE plutos.transactions OWNER TO plutos;

--
-- Name: transactions_keyid_seq; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

CREATE SEQUENCE plutos.transactions_keyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE plutos.transactions_keyid_seq OWNER TO plutos;

--
-- Name: transactions_keyid_seq1; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

ALTER TABLE plutos.transactions ALTER COLUMN keyid ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME plutos.transactions_keyid_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: transations_errlog; Type: TABLE; Schema: plutos; Owner: plutos
--

CREATE TABLE plutos.transations_errlog (
    keyid bigint NOT NULL,
    transactions_id bigint,
    err_text text,
    err_type smallint,
    create_date timestamp without time zone DEFAULT now()
);


ALTER TABLE plutos.transations_errlog OWNER TO plutos;

--
-- Name: transations_errlog_keyid_seq; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

CREATE SEQUENCE plutos.transations_errlog_keyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE plutos.transations_errlog_keyid_seq OWNER TO plutos;

--
-- Name: transations_errlog_keyid_seq1; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

ALTER TABLE plutos.transations_errlog ALTER COLUMN keyid ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME plutos.transations_errlog_keyid_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: wallet; Type: TABLE; Schema: plutos; Owner: plutos
--

CREATE TABLE plutos.wallet (
    keyid bigint NOT NULL,
    man_id bigint NOT NULL,
    balance numeric(15,2) DEFAULT 0 NOT NULL,
    code text NOT NULL,
    note text,
    wallet_type_id bigint NOT NULL,
    create_date timestamp without time zone DEFAULT now(),
    update_date timestamp without time zone
);


ALTER TABLE plutos.wallet OWNER TO plutos;

--
-- Name: wallet_keyid_seq; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

CREATE SEQUENCE plutos.wallet_keyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE plutos.wallet_keyid_seq OWNER TO plutos;

--
-- Name: wallet_keyid_seq1; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

ALTER TABLE plutos.wallet ALTER COLUMN keyid ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME plutos.wallet_keyid_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: wallet_type; Type: TABLE; Schema: plutos; Owner: plutos
--

CREATE TABLE plutos.wallet_type (
    keyid bigint NOT NULL,
    code text NOT NULL,
    text text NOT NULL,
    create_date timestamp without time zone DEFAULT now()
);


ALTER TABLE plutos.wallet_type OWNER TO plutos;

--
-- Name: wallet_type_keyid_seq; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

CREATE SEQUENCE plutos.wallet_type_keyid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE plutos.wallet_type_keyid_seq OWNER TO plutos;

--
-- Name: wallet_type_keyid_seq1; Type: SEQUENCE; Schema: plutos; Owner: plutos
--

ALTER TABLE plutos.wallet_type ALTER COLUMN keyid ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME plutos.wallet_type_keyid_seq1
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: man man_email_key; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.man
    ADD CONSTRAINT man_email_key UNIQUE (email);


--
-- Name: man man_pkey; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.man
    ADD CONSTRAINT man_pkey PRIMARY KEY (keyid);


--
-- Name: man_type man_type_code_key; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.man_type
    ADD CONSTRAINT man_type_code_key UNIQUE (code);


--
-- Name: man_type man_type_pkey; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.man_type
    ADD CONSTRAINT man_type_pkey PRIMARY KEY (keyid);


--
-- Name: transactions transactions_pkey; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (keyid);


--
-- Name: transations_errlog transations_errlog_pkey; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.transations_errlog
    ADD CONSTRAINT transations_errlog_pkey PRIMARY KEY (keyid);


--
-- Name: wallet wallet_code_key; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.wallet
    ADD CONSTRAINT wallet_code_key UNIQUE (code);


--
-- Name: wallet wallet_pkey; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.wallet
    ADD CONSTRAINT wallet_pkey PRIMARY KEY (keyid);


--
-- Name: wallet_type wallet_type_code_key; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.wallet_type
    ADD CONSTRAINT wallet_type_code_key UNIQUE (code);


--
-- Name: wallet_type wallet_type_pkey; Type: CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.wallet_type
    ADD CONSTRAINT wallet_type_pkey PRIMARY KEY (keyid);


--
-- Name: transactions trg_execute_transaction; Type: TRIGGER; Schema: plutos; Owner: plutos
--

CREATE TRIGGER trg_execute_transaction AFTER INSERT ON plutos.transactions FOR EACH ROW EXECUTE FUNCTION plutos.ftrg_execute_transaction();


--
-- Name: wallet trg_set_wallet_update_date; Type: TRIGGER; Schema: plutos; Owner: plutos
--

CREATE TRIGGER trg_set_wallet_update_date BEFORE UPDATE ON plutos.wallet FOR EACH ROW EXECUTE FUNCTION plutos.ftrg_set_update_date();


--
-- Name: man man_man_type_id_fkey; Type: FK CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.man
    ADD CONSTRAINT man_man_type_id_fkey FOREIGN KEY (man_type_id) REFERENCES plutos.man_type(keyid);


--
-- Name: transactions transactions_wallet_from_id_fkey; Type: FK CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.transactions
    ADD CONSTRAINT transactions_wallet_from_id_fkey FOREIGN KEY (wallet_from_id) REFERENCES plutos.wallet(keyid);


--
-- Name: transactions transactions_wallet_to_id_fkey; Type: FK CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.transactions
    ADD CONSTRAINT transactions_wallet_to_id_fkey FOREIGN KEY (wallet_to_id) REFERENCES plutos.wallet(keyid);


--
-- Name: transations_errlog transations_errlog_transactions_id_fkey; Type: FK CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.transations_errlog
    ADD CONSTRAINT transations_errlog_transactions_id_fkey FOREIGN KEY (transactions_id) REFERENCES plutos.transactions(keyid);


--
-- Name: wallet wallet_man_id_fkey; Type: FK CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.wallet
    ADD CONSTRAINT wallet_man_id_fkey FOREIGN KEY (man_id) REFERENCES plutos.man(keyid) ON DELETE CASCADE;


--
-- Name: wallet wallet_wallet_type_id_fkey; Type: FK CONSTRAINT; Schema: plutos; Owner: plutos
--

ALTER TABLE ONLY plutos.wallet
    ADD CONSTRAINT wallet_wallet_type_id_fkey FOREIGN KEY (wallet_type_id) REFERENCES plutos.wallet_type(keyid);


--
-- PostgreSQL database dump complete
--

\unrestrict Hx4izyqBdCXCkkvza1y2Me2ectSoi4bnJ2GIoBtEoQbPTj3LJZhIKtq5JeNK2SB

