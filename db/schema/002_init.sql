ALTER TABLE man ALTER COLUMN keyid ADD GENERATED ALWAYS AS IDENTITY;

create table wallet_type (keyid        bigint GENERATED ALWAYS AS IDENTITY PRIMARY key
						  ,code        text not null unique
						  ,text        text not null
						  ,create_date timestamp default now());

create table wallet (keyid      		bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY
					,man_id      		bigint not null references man(keyid) on delete cascade
					,balance     		numeric(15,2) default 0 not null
					,code       		text not null unique
					,note        		text
					,wallet_type_id     bigint not null references wallet_type(keyid)
					,create_date 		timestamp default now()
					,update_date 		timestamp);

create table transactions (keyid          bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY
						  ,wallet_from_id bigint not null references wallet(keyid)
						  ,wallet_to_id   bigint not null references wallet(keyid) check(wallet_from_id != wallet_to_id)
						  ,value          numeric(15,2) not null check(value > 0)
						  ,create_date    timestamptz default now()
						  ,note           text);

create table man_type(keyid bigint generated always as identity primary key
					 ,code text not null unique
					 ,text text not null
					 ,status boolean not null)

alter table man
add column man_type_id bigint references man_type(keyid)

create or replace
function ftrg_set_update_date()
  returns trigger as $$
begin

  new.update_date := now();

end;
$$ language plpgsql

create trigger trg_set_wallet_update_date
before update on wallet
for each row
execute function ftrg_set_update_date();