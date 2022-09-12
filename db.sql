create extension if not exists "uuid-ossp";


create table users(
id uuid primary key,
name varchar(250) not null,
email varchar(250) not null,
verified boolean default false,
verified_on timestamp,
active boolean default true,
created_on timestamp default now(),
created_by uuid references users(id),
deleted boolean default false,
deleted_on timestamp,
deleted_by uuid references users(id)
);

ALTER TABLE users ALTER COLUMN id SET DATA TYPE uuid USING (uuid_generate_v4()),
ALTER COLUMN id SET DEFAULT uuid_generate_v4();

select * from users;

create type role as enum ('admin','guest','customer');

create table roles(
id uuid  primary key,
name role,
active boolean,
deleted boolean,
created_on timestamp 
);

ALTER TABLE roles ALTER COLUMN id SET DATA TYPE uuid USING (uuid_generate_v4()),
ALTER COLUMN id SET DEFAULT uuid_generate_v4();
alter table roles add primary key(id);


select * from roles;

create table user_roles(
id uuid primary key,
user_id uuid references users(id),
role_id uuid references roles(id),
deleted boolean default false
);

create table backup ( 
id uuid primary key, 
name varchar(250) 
);


create function aftr_delete()
returns trigger as $body$
begin 
insert into backup values(old.id, old.name);
delete from user_roles 
where user_roles.user_id=old.id;
return NULL;
end; 

$body$
language plpgsql; 
create trigger user_delete before delete on users
for each row
execute function aftr_delete();

insert into roles (id,name) values (uuid_generate_v4(),'admin'), (uuid_generate_v4(),'guest'), (uuid_generate_v4(),'customer');

insert into users (id,name,email) values 
(uuid_generate_v4(),'john', 'jo@gmail.com'),
(uuid_generate_v4(),'raj', 'ra@gmail.com'),
(uuid_generate_v4(),'ankita', 'an@gmail.com'),
(uuid_generate_v4(),'samuel', 'sa@gmail.com'),
(uuid_generate_v4(),'ishita', 'i@gmail.com'),
(uuid_generate_v4(),'rohan','ro@gmail.com'),
(uuid_generate_v4(),'mike', 'mi@gmail.com'),
(uuid_generate_v4(),'adre', 'ad@gmail.com'),
(uuid_generate_v4(),'vishal','vi@gmail.com'),
(uuid_generate_v4(),'niki', 'ni@gmail.com'); 

select * from users;

delete from users where id= '5166a415-9cce-4138-9b84-69d79d409a4c';

delete from users where id ='b939ed85-39a1-4932-a750-5c84e88e2a9f';

insert into user_roles (id,user_id,role_id) 
values 
(uuid_generate_v4(),'b939ed85-39a1-4932-a750-5c84e88e2a9f','7aa4249c-6417-40bc-91a8-41718a1ebc03'),
(uuid_generate_v4(),'993b47b3-da26-4ac7-aed6-a9e78ccbedcc','7aa4249c-6417-40bc-91a8-41718a1ebc03'),
(uuid_generate_v4(),'22524f40-214b-4938-93e9-8df7e4951049','7aa4249c-6417-40bc-91a8-41718a1ebc03'),
(uuid_generate_v4(),'953dbbae-e2dd-4814-9f2b-bd4ec780de95','7aa4249c-6417-40bc-91a8-41718a1ebc03'),
(uuid_generate_v4(),'41b6b4dc-67c8-4e31-944f-52e479fc3616','b1363f7c-54b5-4c53-9638-8dd47e90dcd0'),
(uuid_generate_v4(),'80e4c951-211e-4c3c-a62a-06699cb66671','b1363f7c-54b5-4c53-9638-8dd47e90dcd0'),
(uuid_generate_v4(),'a2517fbf-08aa-4365-944e-81e9d5cd98f9','b1363f7c-54b5-4c53-9638-8dd47e90dcd0'),
(uuid_generate_v4(),'b31aa6f4-1706-4fd4-aecf-a865b0c9bb98','201c274e-c6bb-4733-acf8-c89fe17d72c1'),
(uuid_generate_v4(),'470437ff-5b52-4beb-856c-c05e6a88e5ef','201c274e-c6bb-4733-acf8-c89fe17d72c1');

select * from user_roles;
select * from backup;

create table user_backup as table users;
select * from user_backup;

create view show_user
as select ur.id,ur.name,ur.email,ur.created_on, rol.name as role,ur.deleted,ur.active,ur.verified 
from 
users as ur left join user_roles as usrol 
on usrol.user_id = ur.id
left join roles as rol on rol.id =usrol.role_id
where ur.created_on > now() - interval '5' day and
ur.verified=true;


create function created()
returns trigger as $cration$
BEGIN
set new.verified= true,
new.created_on := now();
new.verified_on:= now();
return new;
end; 

$body$
language plpgsql; 
create trigger user_createon()    
before insert on users
for each row
execute function created();



select * from show_user;


























