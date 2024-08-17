create table banks (
  bank_id  int generated always as identity,
  bank_name varchar2(100 char) not null,
  constraint banks_pk primary key (bank_id),
  constraint banks_uq1 unique (bank_name)
);

create table customers (
  customer_id   int generated always as identity,
  customer_name varchar2(100 char) not null,
  constraint customers_pk primary key (customer_id),
  constraint customers_uq1 unique (customer_name)
);



create table accounts (
  account_id  int generated always as identity,
  bank_id      int not null,
  customer_id  int not null,
  constraint accounts_pk primary key (account_id),
  constraint accounts_fk1 foreign key (bank_id) references banks(bank_id),
  constraint accounts_fk2 foreign key (customer_id) references customers(customer_id)
);

create table transactions (
  transaction_id  int generated always as identity,
  from_account_id int not null,
  to_account_id   int not null,
  constraint transactions_pk primary key (transaction_id),
  constraint transactions_fk1 foreign key (from_account_id) references accounts(account_id),
  constraint transactions_fk2 foreign key (to_account_id) references accounts(account_id)
);

drop materialized view log on accounts;
create materialized view log on accounts with rowid,sequence (bank_id, customer_id), primary key including new values;


create materialized view bank_customers
  refresh fast on commit
as
select bank_id, customer_id, count(*) N
from accounts
group by bank_id, customer_id;

alter table bank_customers
  add constraint bank_cust_pk primary key (bank_id,customer_id);

insert into banks (bank_name) values ( 'first citizen' );
insert into banks (bank_name) values ( 'second citizen' );
insert into customers (customer_name) values ('smavris');
insert into customers (customer_name) values ('daustin');
commit;

insert into accounts (bank_id, customer_id) values (1,1);
insert into accounts (bank_id, customer_id) values (2,2);
commit;

grant insert,update,select,delete on banks to bank_db;
grant insert,update,select,delete on customers to bank_db;
grant insert,update,select,delete on accounts to bank_db;
grant insert,update,select,delete on bank_customers to bank_db;
