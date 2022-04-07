/*==============================================================*/
/* DBMS name:      PostgreSQL 8                                 */
/* Created on:     06.04.2022 13:10:40                          */
/*==============================================================*/


drop table Clients;

drop table Currencies;

drop index Relationship_3_FK;

drop index Relationship_2_FK;

drop table Documents;

drop index Relationship_4_FK;

drop table Exchange_rates;

/*==============================================================*/
/* Table: Clients                                               */
/*==============================================================*/
create table Clients (
   client_id            INT4                 not null,
   client_name          VARCHAR(20)          not null,
   constraint PK_CLIENTS primary key (client_id)
);

/*==============================================================*/
/* Table: Currencies                                            */
/*==============================================================*/
create table Currencies (
   currency_id          INT4                 not null,
   currency_ISO_name    CHAR(3)              not null,
   currency_name        VARCHAR(20)          not null,
   precision            INT4                 not null default 5,
   sign_national_currency NUMERIC(1)           not null default 0,
   start_date           DATE                 not null default '01.01.1990',
   end_date             DATE                 not null default '31.12.2999',
   old_currency_id      INT4                 null,
   scale_denomination   FLOAT8               null,
   constraint PK_CURRENCIES primary key (currency_id)
);

/*==============================================================*/
/* Table: Documents                                             */
/*==============================================================*/
create table Documents (
   document_id          VARCHAR(20)          not null,
   currency_id          INT4                 null,
   client_id            INT4                 null,
   document_Date        DATE                 not null,
   amount               FLOAT8               not null,
   constraint PK_DOCUMENTS primary key (document_id)
);

/*==============================================================*/
/* Index: Relationship_2_FK                                     */
/*==============================================================*/
create  index Relationship_2_FK on Documents (
currency_id
);

/*==============================================================*/
/* Index: Relationship_3_FK                                     */
/*==============================================================*/
create  index Relationship_3_FK on Documents (
client_id
);

/*==============================================================*/
/* Table: Exchange_rates                                        */
/*==============================================================*/
create table Exchange_rates (
   exchange_rate_id     INT4                 not null,
   currency_id          INT4                 null,
   start_date_exchange_rate DATE                 not null,
   exchange_rate        FLOAT8               not null,
   exchange_rate_scale  FLOAT8               not null,
   constraint PK_EXCHANGE_RATES primary key (exchange_rate_id)
);

/*==============================================================*/
/* Index: Relationship_4_FK                                     */
/*==============================================================*/
create  index Relationship_4_FK on Exchange_rates (
currency_id
);

alter table Documents
   add constraint FK_DOCUMENT_RELATIONS_CURRENCI foreign key (currency_id)
      references Currencies (currency_id)
      on delete restrict on update restrict;

alter table Documents
   add constraint FK_DOCUMENT_RELATIONS_CLIENTS foreign key (client_id)
      references Clients (client_id)
      on delete restrict on update restrict;

alter table Exchange_rates
   add constraint FK_EXCHANGE_RELATIONS_CURRENCI foreign key (currency_id)
      references Currencies (currency_id)
      on delete restrict on update restrict;
