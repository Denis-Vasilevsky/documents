/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     03.03.2022 20:22:23                          */
/*==============================================================*/


alter table "Documents"
   drop constraint FK_DOCUMENT_RELATIONS_CURRENCY;

alter table "Documents"
   drop constraint FK_DOCUMENT_RELATIONS_CLIENTS;

alter table "Exchange_rates"
   drop constraint FK_EXCHANGE_RELATIONS_CURRENCY;

drop table "Clients" cascade constraints;

drop table "Currencies" cascade constraints;

drop index "Relationship_3_FK";

drop index "Relationship_2_FK";

drop table "Documents" cascade constraints;

drop index "Relationship_4_FK";

drop table "Exchange_rates" cascade constraints;

/*==============================================================*/
/* Table: "Clients"                                             */
/*==============================================================*/
create table "Clients" 
(
   "client_id"          INTEGER              not null,
   "client_name"        VARCHAR2(20)         not null,
   constraint PK_CLIENTS primary key ("client_id")
);

/*==============================================================*/
/* Table: "Currencies"                                          */
/*==============================================================*/
create table "Currencies" 
(
   "currency_id"        INTEGER              not null,
   "currency_ISO_name"  CHAR(3)              not null,
   "currency_name"      VARCHAR2(20)         not null,
   "precision"          INTEGER              default 5 not null,
   "sign_national_currency" NUMBER(1)            default 0 not null,
   "start_date"         DATE                 default '01.01.1990' not null,
   "end_date"           DATE                 default '31.12.2999' not null,
   "old_currency_id"    INTEGER,
   "scale_denomination" FLOAT,
   constraint PK_CURRENCIES primary key ("currency_id")
);

/*==============================================================*/
/* Table: "Documents"                                           */
/*==============================================================*/
create table "Documents" 
(
   "document_id"        VARCHAR2(20)         not null,
   "currency_id"        INTEGER,
   "client_id"          INTEGER,
   "document_Date"      DATE                 not null,
   "amount"             FLOAT                not null,
   constraint PK_DOCUMENTS primary key ("document_id")
);

/*==============================================================*/
/* Index: "Relationship_2_FK"                                   */
/*==============================================================*/
create index "Relationship_2_FK" on "Documents" (
   "currency_id" ASC
);

/*==============================================================*/
/* Index: "Relationship_3_FK"                                   */
/*==============================================================*/
create index "Relationship_3_FK" on "Documents" (
   "client_id" ASC
);

/*==============================================================*/
/* Table: "Exchange_rates"                                      */
/*==============================================================*/
create table "Exchange_rates" 
(
   "exchange_rate_id"   INTEGER              not null,
   "currency_id"        INTEGER,
   "start_date_exchange_rate" DATE                 not null,
   "exchange_rate"      FLOAT                not null,
   "exchange_rate_scale" FLOAT                not null,
   constraint PK_EXCHANGE_RATES primary key ("exchange_rate_id")
);

/*==============================================================*/
/* Index: "Relationship_4_FK"                                   */
/*==============================================================*/
create index "Relationship_4_FK" on "Exchange_rates" (
   "currency_id" ASC
);

alter table "Documents"
   add constraint FK_DOCUMENT_RELATIONS_CURRENCY foreign key ("currency_id")
      references "Currencies" ("currency_id");

alter table "Documents"
   add constraint FK_DOCUMENT_RELATIONS_CLIENTS foreign key ("client_id")
      references "Clients" ("client_id");

alter table "Exchange_rates"
   add constraint FK_EXCHANGE_RELATIONS_CURRENCY foreign key ("currency_id")
      references "Currencies" ("currency_id");
