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
