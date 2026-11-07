create schema plutos

create table man (keyid bigint primary key
				 ,name  text not null
				 ,email text not null unique
				 ,status smallint default 1
				 ,create_date timestamp default now())