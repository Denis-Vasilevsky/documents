-- генерация случайной даты в диапазоне
CREATE OR REPLACE FUNCTION gen_random_date (
    p_start_date IN CHAR,
    p_end_date   IN CHAR
) RETURN DATE IS
    random_date DATE;
BEGIN
    random_date := to_date(to_date(p_end_date, 'DD.MM.YYYY') - floor(dbms_random.value *(to_number(to_date(p_end_date, 'DD.MM.YYYY') -
    to_date(p_start_date, 'DD.MM.YYYY') + 1))), 'DD.MM.YYYY');

    RETURN random_date;
END;


-- добавить клиента в таблицу
CREATE OR REPLACE PROCEDURE insert_new_client (
    p_client_id   IN "Clients"."client_id"%TYPE,
    p_client_name IN "Clients"."client_name"%TYPE
) IS
BEGIN
    INSERT INTO "Clients" (
        "client_id",
        "client_name"
    ) VALUES (
        p_client_id,
        p_client_name
    );

END insert_new_client;



-- добавить валюту в таблицу
CREATE OR REPLACE PROCEDURE insert_new_currency (
    p_currency_id            IN "Currencies"."currency_id"%TYPE,
    p_currency_iso_name      IN "Currencies"."currency_ISO_name"%TYPE,
    p_currency_name          IN "Currencies"."currency_name"%TYPE,
    p_precision              IN "Currencies"."precision"%TYPE := 5,
    p_sign_national_currency IN "Currencies"."sign_national_currency"%TYPE := 0,
    p_start_date             IN "Currencies"."start_date"%TYPE := '01.01.1990',
    p_end_date               IN "Currencies"."end_date"%TYPE := '31.12.2999',
    p_old_currency_id        IN "Currencies"."old_currency_id"%TYPE := NULL,
    p_scale_denomination     IN "Currencies"."scale_denomination"%TYPE := NULL
) IS
BEGIN
    INSERT INTO "Currencies" (
        "currency_id",
        "currency_ISO_name",
        "currency_name",
        "precision",
        "sign_national_currency",
        "start_date",
        "end_date",
        "old_currency_id",
        "scale_denomination"
    ) VALUES (
        p_currency_id,
        p_currency_iso_name,
        p_currency_name,
        p_precision,
        p_sign_national_currency,
        p_start_date,
        p_end_date,
        p_old_currency_id,
        p_scale_denomination
    );

END insert_new_currency;


-- добавить документа в таблицу
CREATE OR REPLACE PROCEDURE insert_new_document (
    p_document_id   IN "Documents"."document_id"%TYPE,
    p_currency_id   IN "Documents"."currency_id"%TYPE,
    p_client_id     IN "Documents"."client_id"%TYPE,
    p_document_date IN "Documents"."document_Date"%TYPE,
    p_amount        IN "Documents"."amount"%TYPE
) IS
BEGIN
    INSERT INTO "Documents" (
        "document_id",
        "currency_id",
        "client_id",
        "document_Date",
        "amount"
    ) VALUES (
        p_document_id,
        p_currency_id,
        p_client_id,
        p_document_date,
        p_amount
    );

END insert_new_document;


-- 4.1 заполнение таблицы клиентов
CREATE OR REPLACE PROCEDURE fill_clients (
    range_in IN INTEGER
) IS
BEGIN
    FOR i IN 1..range_in LOOP
        IF MOD(i, 2) = 0 THEN
            insert_new_client(p_client_id => i, p_client_name => 'Client - ' || i);
        END IF;
    END LOOP;
END fill_clients;

-- представление для заполнения таблицы документов
CREATE VIEW v_documents AS
    SELECT
        "Currencies"."currency_id"                          AS currency_id,
        "Clients"."client_id"                               AS client_id,
        "Currencies"."currency_id" || "Clients"."client_id" AS document_id,
        "Currencies"."currency_id" * "Clients"."client_id"  AS amount
    FROM
        "Currencies"
        LEFT JOIN "Clients" ON ( "Currencies"."currency_id" - 100 <= "Clients"."client_id"
                                 AND "Currencies"."currency_id" + 100 >= "Clients"."client_id" );

-- 4.3 заполнение таблицы документов
CREATE OR REPLACE PROCEDURE fill_documents IS
    CURSOR c_document IS
    SELECT
        *
    FROM
        v_documents;

BEGIN
    FOR item IN c_document LOOP
        insert_new_document(p_document_id => item.document_id, p_currency_id => item.currency_id, p_client_id => item.client_id, p_document_date =>
        gen_random_date(p_start_date => '01.01.1999', p_end_date => '31.12.2021'), p_amount => item.amount);
    END LOOP;
END fill_documents;

-- 5.1 Выбор списка всех клиентов без повторений
SELECT
    "client_name"
FROM
    "Clients"
GROUP BY
    "client_name";


-- 5.2 Выбор списка: клиент, кол-во документов
SELECT
    "Clients"."client_name",
    COUNT(*)
FROM
    "Documents"
    LEFT JOIN "Clients" ON "Clients"."client_id" = "Documents"."client_id"
GROUP BY
    "Clients"."client_name";


-- 5.3 Выбор списка: клиент, кол-во валют документов
SELECT
    "Clients"."client_name",
    "Currencies"."currency_ISO_name",
    COUNT(*)
FROM
         "Clients"
    INNER JOIN "Documents" ON "Documents"."client_id" = "Clients"."client_id"
    INNER JOIN "Currencies" ON "Documents"."currency_id" = "Currencies"."currency_id"
GROUP BY
    "Clients"."client_name",
    "Currencies"."currency_ISO_name";

-- 5.4 Выбор списка: клиент, валюта, общая сумма в валюте
SELECT
    "Clients"."client_name",
    "Currencies"."currency_ISO_name",
    SUM("Documents"."amount")
FROM
         "Clients"
    INNER JOIN "Documents" ON "Documents"."client_id" = "Clients"."client_id"
    INNER JOIN "Currencies" ON "Documents"."currency_id" = "Currencies"."currency_id"
GROUP BY
    "Clients"."client_name",
    "Currencies"."currency_ISO_name";
