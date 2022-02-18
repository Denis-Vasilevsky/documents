-- генерация случайной даты в диапазоне
CREATE OR REPLACE FUNCTION gen_date
( 
    start_date_in IN CHAR, 
    end_date_in IN CHAR
) 
    RETURN date
IS
    random_date DATE;
BEGIN
    random_date := TO_DATE(TO_DATE(end_date_in, 'DD.MM.YYYY') - FLOOR(dbms_random.value * (TO_NUMBER(TO_DATE(end_date_in, 'DD.MM.YYYY') - TO_DATE(start_date_in, 'DD.MM.YYYY') + 1))), 'DD.MM.YY');
    RETURN random_date;
END;


-- добавить клиента в таблицу
CREATE OR REPLACE PROCEDURE add_client
(
    client_id_in IN INTEGER,
    client_name_in IN VARCHAR2
) IS
BEGIN
    INSERT INTO "Clients"
    ( "client_id", "client_name") 
    VALUES (client_id_in, client_name_in);
END add_client;


-- добавить валюту в таблицу
CREATE OR REPLACE PROCEDURE add_currency
(
    currency_id_in IN INTEGER,
    currency_ISO_name_in IN CHAR,
    currency_name_in IN VARCHAR2
) IS
BEGIN
    INSERT INTO "Currencies"
    ( "currency_id", "currency_ISO_name", "currency_name") 
    VALUES (currency_id_in, currency_ISO_name_in, currency_name_in);
END add_currency;


-- добавить документа в таблицу
CREATE OR REPLACE PROCEDURE add_document
(
    document_id_in IN INTEGER,
    currency_id_in IN INTEGER,
    client_id_in IN INTEGER,
    document_Date_in in DATE,
    amount_in IN FLOAT
) IS
BEGIN
    INSERT INTO "Documents"
        ( "document_id", "currency_id", "client_id", "document_Date", "amount") 
        VALUES (document_id_in, currency_id_in, client_id_in, document_Date_in, amount_in);
END add_document;


-- 4.1 заполнение таблицы клиентов
CREATE OR REPLACE PROCEDURE fill_Clients
(
    range_in IN INTEGER
) 
IS
BEGIN
    FOR i IN 1 .. range_in
    LOOP
    IF MOD(i,2)=0
        THEN
            add_client(i, 'Client'|| i);
    END IF;
    END LOOP;
END fill_Clients;


-- 4.2 заполнение таблицы валют
DECLARE
   TYPE array_t IS VARRAY(7) OF CHAR(3);
   array array_t := array_t('BYB', 'BYR', 'BYN', 'USD', 'EUR', 'RUB', 'RUR');
BEGIN
   FOR i IN 1 .. array.count 
   LOOP
       add_currency(i, array(i), 'currency - '|| array(i));
   END LOOP;
END;


-- 4.3 заполнение таблицы документов
DECLARE
    CURSOR c1
    IS
    SELECT  "Currencies"."currency_id" AS currency_id, "Clients"."client_id" AS client_id, "Currencies"."currency_id" || "Clients"."client_id" AS document_id, "Currencies"."currency_id" * "Clients"."client_id" AS amount 
    FROM "Currencies" 
    LEFT JOIN "Clients" ON ("Currencies"."currency_id" - 100 <= "Clients"."client_id" AND "Currencies"."currency_id" + 100 >="Clients"."client_id");
BEGIN
    FOR item IN c1
    LOOP
        add_document(item.document_id, item.currency_id, item.client_id, gen_date('01.01.1999','31.12.2021'), item.amount);
    END LOOP;
END;

-- 5.1 Выбор списка всех клиентов без повторений
SELECT "client_name" FROM "Clients" GROUP BY "client_name";


-- 5.2 Выбор списка: клиент, кол-во документов
SELECT "Clients"."client_name", COUNT(*) 
FROM "Documents" 
LEFT JOIN "Clients" ON "Clients"."client_id"="Documents"."client_id" 
GROUP BY"Clients"."client_name";


-- 5.3 Выбор списка: клиент, кол-во валют документов
SELECT "Clients"."client_name","Currencies"."currency_ISO_name", COUNT(*)
FROM "Clients"
INNER JOIN "Documents" ON "Documents"."client_id" = "Clients"."client_id"
INNER JOIN "Currencies" ON "Documents"."currency_id"="Currencies"."currency_id"
GROUP BY "Clients"."client_name", "Currencies"."currency_ISO_name"

-- 5.4 Выбор списка: клиент, валюта, общая сумма в валюте
SELECT "Clients"."client_name","Currencies"."currency_ISO_name", SUM("Documents"."amount")
FROM "Clients"
INNER JOIN "Documents" ON "Documents"."client_id" = "Clients"."client_id"
INNER JOIN "Currencies" ON "Documents"."currency_id"="Currencies"."currency_id"
GROUP BY "Clients"."client_name", "Currencies"."currency_ISO_name"
