/*==============================================================*/
/* DBMS name:      ORACLE Version 11g                           */
/* Created on:     16.02.2022 19:59:53                          */
/*==============================================================*/


alter table "Documents"
   drop constraint FK_DOCUMENT_RELATIONS_CURRENCI;

alter table "Documents"
   drop constraint FK_DOCUMENT_RELATIONS_CLIENTS;

drop table "Clients" cascade constraints;

drop table "Currencies" cascade constraints;

drop index "Relationship_3_FK";

drop index "Relationship_2_FK";

drop table "Documents" cascade constraints;

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
   constraint PK_CURRENCIES primary key ("currency_id")
);

/*==============================================================*/
/* Table: "Documents"                                           */
/*==============================================================*/
create table "Documents" 
(
   "document_id"        INTEGER              not null,
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

alter table "Documents"
   add constraint FK_DOCUMENT_RELATIONS_CURRENCI foreign key ("currency_id")
      references "Currencies" ("currency_id");

alter table "Documents"
   add constraint FK_DOCUMENT_RELATIONS_CLIENTS foreign key ("client_id")
      references "Clients" ("client_id");

