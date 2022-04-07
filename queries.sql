-- генерация случайной даты в диапазоне
ALTER SESSION SET NLS_DATE_FORMAT = 'DD.MM.YYYY';

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

--добавить курс валюты в таблицу
CREATE OR REPLACE PROCEDURE insert_new_exchange_rate (
    p_exchange_rate_id         IN "Exchange_rates"."exchange_rate_id"%TYPE,
    p_currency_id              IN "Exchange_rates"."currency_id"%TYPE,
    p_start_date_exchange_rate IN "Exchange_rates"."start_date_exchange_rate"%TYPE := to_date(current_date, 'DD.MM.YYYY'),
    p_exchange_rate            IN "Exchange_rates"."exchange_rate"%TYPE,
    p_exchange_rate_scale      IN "Exchange_rates"."exchange_rate_scale"%TYPE
) IS
BEGIN
    INSERT INTO "Exchange_rates" (
        "exchange_rate_id",
        "currency_id",
        "start_date_exchange_rate",
        "exchange_rate",
        "exchange_rate_scale"
    ) VALUES (
        p_exchange_rate_id,
        p_currency_id,
        p_start_date_exchange_rate,
        p_exchange_rate,
        p_exchange_rate_scale
    );

END insert_new_exchange_rate;


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


-- 4.3 заполнение таблицы документов
CREATE OR REPLACE PROCEDURE fill_documents IS
    CURSOR c_document IS
    SELECT
        "Currencies"."currency_id"                          AS currency_id,
        "Clients"."client_id"                               AS client_id,
        "Currencies"."currency_id" || "Clients"."client_id" AS document_id,
        "Currencies"."currency_id" * "Clients"."client_id"  AS amount
    FROM
        "Currencies"
        LEFT JOIN "Clients" ON ( "Currencies"."currency_id" - 100 <= "Clients"."client_id"
                                 AND "Currencies"."currency_id" + 100 >= "Clients"."client_id" );

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
    COUNT(*)
FROM
    "Documents"
    LEFT JOIN "Clients" ON "Clients"."client_id" = "Documents"."client_id"
GROUP BY
    "Clients"."client_name"

-- 5.3.1 Выбор списка 5.3 для клиентов у которых есть документы в 3х или 4х различных валютах
SELECT
    "Clients"."client_name",
    COUNT(distinct "Documents"."currency_id")
FROM
    "Documents"
    LEFT JOIN "Clients" ON "Clients"."client_id" = "Documents"."client_id"
GROUP BY
    "Clients"."client_name"
HAVING COUNT(distinct "Documents"."currency_id") = 3
       OR COUNT(distinct "Documents"."currency_id") = 4

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

-- 7.2 поиск курса валют по ближайшей дате
CREATE OR REPLACE FUNCTION search_exchange_rate (
    p_currency_id IN INTEGER,
    p_date        IN CHAR
) RETURN NUMBER IS

    course FLOAT;
    CURSOR c1 IS
    SELECT
        "exchange_rate"
    FROM
        (
            SELECT
                "exchange_rate"
            FROM
                "Exchange_rates"
            WHERE
                "currency_id" = p_currency_id
            ORDER BY
                abs(to_date(p_date, 'DD.MM.YYYY') - to_date("Exchange_rates"."start_date_exchange_rate", 'DD.MM.YYYY'))
        )
    WHERE
        ROWNUM = 1;

BEGIN
    OPEN c1;
    FETCH c1 INTO course;
    IF c1%notfound THEN
        RETURN NULL;
    END IF;
    CLOSE c1;
    RETURN course;
END;

SELECT
    search_exchange_rate(840, '10.10.2030')
FROM
    dual;


-- заполнение таблицы валют
BEGIN
    insert_new_currency(p_currency_id => 112, p_currency_iso_name => 'BYB', p_currency_name => 'Belarussian Ruble',
                        p_start_date => '25.05.1992',
                        p_end_date => '01.01.2000');

    insert_new_currency(p_currency_id => 974, p_currency_iso_name => 'BYR', p_currency_name => 'Belarussian Ruble',
                        p_start_date => '01.01.2000',
                        p_end_date => '01.07.2016',
                        p_old_currency_id => 112, p_scale_denomination => 1000);

    insert_new_currency(p_currency_id => 933, p_currency_iso_name => 'BYN', p_currency_name => 'Belarusian Ruble',
                        p_start_date => '01.07.2016',
                        p_old_currency_id => 974,
                        p_sign_national_currency => 1, p_scale_denomination => 10000);

    insert_new_currency(p_currency_id => 810, p_currency_iso_name => 'RUR', p_currency_name => 'Russian Ruble',
                        p_start_date => '01.01.1992',
                        p_end_date => '01.01.1998');

    insert_new_currency(p_currency_id => 643, p_currency_iso_name => 'RUB', p_currency_name => 'Russian Ruble',
                        p_start_date => '01.01.1998',
                        p_old_currency_id => 810,
                        p_scale_denomination => 1000);

    insert_new_currency(p_currency_id => 840, p_currency_iso_name => 'USD', p_currency_name => 'US Dollar');
    insert_new_currency(p_currency_id => 978, p_currency_iso_name => 'EUR', p_currency_name => 'Euro');
    insert_new_currency(p_currency_id => 826, p_currency_iso_name => 'GBP', p_currency_name => 'Pound Sterling');
    insert_new_currency(p_currency_id => 756, p_currency_iso_name => 'CHF', p_currency_name => 'Swiss Franc');
    insert_new_currency(p_currency_id => 156, p_currency_iso_name => 'CNY', p_currency_name => 'Yuan Renminbi');
END;


-- заполнение таблицы курсов валют
BEGIN
    insert_new_exchange_rate(p_exchange_rate_id => 1, p_currency_id => 840, p_exchange_rate => 2.5759,
                             p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                 '01.01.2021');

    insert_new_exchange_rate(p_exchange_rate_id => 2, p_currency_id => 978, p_exchange_rate => 3.168,
                             p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                 '01.01.2021');

    insert_new_exchange_rate(p_exchange_rate_id => 3, p_currency_id => 643, p_exchange_rate => 3.4871,
                             p_exchange_rate_scale => 100, p_start_date_exchange_rate =>
                                 '01.01.2021');

    insert_new_exchange_rate(p_exchange_rate_id => 4, p_currency_id => 826, p_exchange_rate => 3.5016,
                             p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                 '01.01.2021');

    insert_new_exchange_rate(p_exchange_rate_id => 5, p_currency_id => 156, p_exchange_rate => 3.9515,
                             p_exchange_rate_scale => 10, p_start_date_exchange_rate =>
                                 '01.01.2021');

    insert_new_exchange_rate(p_exchange_rate_id => 6, p_currency_id => 756, p_exchange_rate => 2.9147,
                             p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                 '01.01.2021');

    insert_new_exchange_rate(p_exchange_rate_id => 7, p_currency_id => 840, p_exchange_rate => 2.5481,
                             p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                 '01.01.2022');

    insert_new_exchange_rate(p_exchange_rate_id => 8, p_currency_id => 978, p_exchange_rate => 2.8826,
                             p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                 '01.01.2022');

    insert_new_exchange_rate(p_exchange_rate_id => 9, p_currency_id => 643, p_exchange_rate => 3.4322,
                             p_exchange_rate_scale => 100, p_start_date_exchange_rate =>
                                 '01.01.2022');

    insert_new_exchange_rate(p_exchange_rate_id => 10, p_currency_id => 826, p_exchange_rate => 3.4295,
                             p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                 '01.01.2022');

    insert_new_exchange_rate(p_exchange_rate_id => 11, p_currency_id => 156, p_exchange_rate => 3.9978,
                             p_exchange_rate_scale => 10, p_start_date_exchange_rate =>
                                 '01.01.2022');

    insert_new_exchange_rate(p_exchange_rate_id => 12, p_currency_id => 756, p_exchange_rate => 2.7759,
                             p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                 '01.01.2022');

END;

-- триггер контроля принадлежности к национальной валюте
CREATE OR REPLACE TRIGGER check_nation_currency
    FOR UPDATE OR INSERT ON "Currencies"
    COMPOUND TRIGGER

    sign_national_currency_count NUMBER;

    PROCEDURE set_0 IS
    BEGIN
        IF sign_national_currency_count != 0 AND :new."sign_national_currency" = 1
        THEN
            raise_application_error(-20000, 'national currency sign 1 is already exists');
        END IF;
    END;

    BEFORE STATEMENT IS
    BEGIN
        SELECT COUNT(*)
        INTO sign_national_currency_count
        FROM "Currencies"
        WHERE "sign_national_currency" = 1;
    END BEFORE STATEMENT;

    BEFORE EACH ROW IS
    BEGIN
        set_0;
    END BEFORE EACH ROW;

END check_nation_currency;


-- вывод документов и стоимости в USD и BYN
SELECT
    d."document_id",
    c."currency_ISO_name"                                                  AS document_currency,
    d."amount",
    d."client_id",
    d."document_Date",
    recalculate_currencies(d."currency_id", 840, d."amount", '01.01.2021') AS "amount in USD",
    recalculate_currencies(d."currency_id", 933, d."amount", '01.01.2021') "amount in BYN"
FROM
    "Documents" d
    LEFT JOIN "Currencies" c ON d."currency_id" = c."currency_id";

-- 8 перевод валюты
-- получить самую новую валюту
CREATE OR REPLACE FUNCTION search_currency(
    p_currency_id IN INTEGER
) RETURN INTEGER IS
    id_1         INTEGER;
    id_2         INTEGER;
    result       INTEGER;
BEGIN
    id_1 := get_currency_by_old_id(p_currency_id);
    IF id_1 = -1 THEN
        result := p_currency_id;
    ELSE
        LOOP
            id_2 := id_1;
            result := get_currency_by_old_id(id_1);
            IF result = -1 THEN
                result := id_2;
                EXIT;
            END IF;
            id_1 := result;
        END LOOP;
    END IF;

    RETURN result;
END;

-- найти деноминацию
CREATE OR REPLACE FUNCTION get_denomination(
    p_currency_id IN INTEGER
) RETURN INTEGER IS
    id_1         INTEGER;
    id_2         INTEGER;
    result       INTEGER;
    denomination FLOAT := 1;
    d            FLOAT;
BEGIN
    id_1 := get_currency_by_old_id(p_currency_id);
    IF id_1 = -1 THEN
        result := p_currency_id;
    ELSE
        LOOP
            id_2 := id_1;
            SELECT "scale_denomination"
            INTO d
            FROM "Currencies"
            WHERE "currency_id" = id_2;

            denomination := denomination * d;
            result := get_currency_by_old_id(id_1);
            IF result = -1 THEN
                result := id_2;
                EXIT;
            END IF;
            id_1 := result;
        END LOOP;
    END IF;

    RETURN denomination;
END;

-- найти валюту по коду старой валюты
CREATE OR REPLACE FUNCTION get_currency_by_old_id(
    p_old_id IN INTEGER
) RETURN INTEGER IS
    id INTEGER;
BEGIN
    SELECT "currency_id"
    INTO id
    FROM "Currencies"
    WHERE "old_currency_id" = p_old_id;

    RETURN id;
EXCEPTION
    WHEN no_data_found THEN
        RETURN -1;
END;

-- пересчёт суммы к указанной валюте на дату
CREATE OR REPLACE FUNCTION recalculate_currencies(
    p_transferred_currency_id INTEGER,
    p_received_currency_id INTEGER,
    p_transfer_amount FLOAT,
    p_course_date DATE
) RETURN FLOAT IS
    transferred_currency_id   INTEGER := p_transferred_currency_id;
    received_currency_id      INTEGER := p_received_currency_id;
    transfer_amount           FLOAT   := p_transfer_amount;
    course_date               DATE    := p_course_date;
    transferred_course        FLOAT;
    transferred_scale         FLOAT;
    transferred_sign_national INTEGER;
    transferred_precision     INTEGER;
    received_course           FLOAT;
    received_scale            FLOAT;
    received_sign_national    INTEGER;
    received_precision        INTEGER;
    id_1                      INTEGER;
    id_2                      INTEGER;
    d_1                       float;
    d_2                       float;
    result                    FLOAT;
BEGIN
    if transferred_currency_id = received_currency_id then
        result := transfer_amount;
    end if;

    id_1 := search_currency(transferred_currency_id);
    id_2 := search_currency(received_currency_id);
    d_1 := get_denomination(transferred_currency_id);
    d_2 := get_denomination(received_currency_id);

    if id_1 = id_2 then
        result := transfer_amount / d_1 * d_2;
    end if;

    select "sign_national_currency", "precision"
    into transferred_sign_national, transferred_precision
    from "Currencies"
    where "currency_id" = id_1;
    select "sign_national_currency", "precision"
    into received_sign_national, received_precision
    from "Currencies"
    where "currency_id" = id_2;

    IF transferred_sign_national = 1 and received_sign_national = 0 then
        select "exchange_rate", "exchange_rate_scale"
        into received_course, received_scale
        from "Exchange_rates"
        where "start_date_exchange_rate" = course_date
          and "currency_id" = id_2;
        result := ROUND(transfer_amount / d_1 / ROUND(received_course, received_precision) * received_scale * d_2,
                        transferred_precision);


    elsIF transferred_sign_national = 0 and received_sign_national = 1 then
        select "exchange_rate", "exchange_rate_scale"
        into transferred_course, transferred_scale
        from "Exchange_rates"
        where "start_date_exchange_rate" = course_date
          and "currency_id" = id_1;
        result := ROUND(ROUND(transferred_course, transferred_precision) * transfer_amount / transferred_scale / d_1 *
                        d_2, transferred_precision);

    elsIF transferred_sign_national = 0 and received_sign_national = 0 then
        select "exchange_rate", "exchange_rate_scale"
        into transferred_course, transferred_scale
        from "Exchange_rates"
        where "start_date_exchange_rate" = course_date
          and "currency_id" = id_1;
        select "exchange_rate", "exchange_rate_scale"
        into received_course, received_scale
        from "Exchange_rates"
        where "start_date_exchange_rate" = course_date
          and "currency_id" = id_2;
        result := ROUND(ROUND(transferred_course, transferred_precision) * transfer_amount / transferred_scale *
                        received_scale / received_course / d_1 * d_2, received_precision);
    end if;

    return result;

end;

select recalculate_currencies(978, 974, 1, '01.01.2022')
from dual

-- примеры
-- 1 000 BYR -> BYN 01.01.2022
select recalculate_currencies(974, 933, 1000, '01.01.2022') from dual;
-- 1 BYN -> BYR 01.01.2022
select recalculate_currencies(933, 974, 1, '01.01.2022') from dual;
-- 1 000 000 BYB -> BYN 01.01.2022
select recalculate_currencies(112, 933, 1000000, '01.01.2022') from dual;

-- 1 000  EUR -> USD 01.01.2022
select recalculate_currencies(978, 840, 1000, '01.01.2022') from dual;
-- 100 USD -> BYN 01.01.2022
select recalculate_currencies(840, 933, 100, '01.01.2022') from dual;

-- 10 заполнение таблицы курсов валют
CREATE OR REPLACE PROCEDURE fill_exchange_rates(p_start_date IN DATE, p_end_date IN DATE) is
    i INTEGER := 0;
begin
    loop
        if (to_number(to_char((to_date(p_start_date) + i), 'D')) != 6 and to_number(to_char((to_date(p_start_date) + i), 'D')) != 7) then
            insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 0, p_currency_id => 840,
                                     p_exchange_rate => dbms_random.value,
                                     p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                         to_date(p_start_date + i));

            insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 1, p_currency_id => 978,
                                     p_exchange_rate => dbms_random.value,
                                     p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                         to_date(p_start_date + i));

            insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 2, p_currency_id => 643,
                                     p_exchange_rate => dbms_random.value,
                                     p_exchange_rate_scale => 100, p_start_date_exchange_rate =>
                                         to_date(p_start_date + i));

            insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 3, p_currency_id => 826,
                                     p_exchange_rate => dbms_random.value,
                                     p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                         to_date(p_start_date + i));

            insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 4, p_currency_id => 156,
                                     p_exchange_rate => dbms_random.value,
                                     p_exchange_rate_scale => 10, p_start_date_exchange_rate =>
                                         to_date(p_start_date + i));

            insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 5, p_currency_id => 756,
                                     p_exchange_rate => dbms_random.value,
                                     p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                         to_date(p_start_date + i));
        end if;

        i := i + 1;
        if i = to_date(p_end_date) - to_date(p_start_date) then
            exit;
        end if;

    end loop;

end fill_exchange_rates;

-- заполнение от 01.01.1990 до 31.12.2021
begin
    fill_exchange_rates('01.01.1990', '31.12.2021');
end;

-- 12
create or replace package pk as
    type r_course is record
                     (
                         "currency_id"              INTEGER,
                         "start_date_exchange_rate" DATE,
                         "exchange_rate"            FLOAT
                     );
    type t_course is table of r_course index by pls_integer;

    -- поиск курса
    FUNCTION search_course(
        p_currency_id IN INTEGER,
        p_date IN CHAR
    ) RETURN NUMBER;

    -- вывод количества записей в кеше
    procedure console;

    -- очистка кеша
    procedure clear;
end pk;

create or replace package body pk as
    t t_course;

    FUNCTION search_course(
        p_currency_id IN INTEGER,
        p_date IN CHAR
    ) RETURN NUMBER is
        currency number;
        date_    Date;
        course   number := -1;
        i        number;

    begin
        for i in 1 .. t.COUNT
            loop
                if  p_currency_id = t(1)."currency_id" or p_date = t(i)."start_date_exchange_rate"  then
                    course := t(i)."exchange_rate";
                    exit;
                end if;
            end loop;
        if course = -1 then
            select "currency_id", "start_date_exchange_rate", "exchange_rate"
            into currency, date_, course
            from (
                     SELECT "currency_id", "start_date_exchange_rate", "exchange_rate"
                     FROM "Exchange_rates"
                     WHERE "currency_id" = p_currency_id
                     ORDER BY abs(to_date(p_date, 'DD.MM.YYYY') -
                                  to_date("Exchange_rates"."start_date_exchange_rate", 'DD.MM.YYYY')))
            WHERE ROWNUM = 1;
            i := t.COUNT + 1;
            t(i)."currency_id" := p_currency_id;
            t(i)."start_date_exchange_rate" := p_date;
            t(i)."exchange_rate" := course;
        end if;
        return course;
    EXCEPTION
        WHEN no_data_found THEN
            RETURN -1;
    end;

    procedure console is
    begin
        DBMS_OUTPUT.PUT_LINE(t.COUNT);
    end;

    procedure clear is
    begin
        t.DELETE();
    end;


end pk;

-- вывод обычной функцией
SELECT d."document_id",
       d."amount",
       d."currency_id",
       d."document_Date",
       search_exchange_rate(d."currency_id", d."document_Date")
FROM "Documents" d

-- вывод функцией с кешем
SELECT d."document_id",
       d."amount",
       d."currency_id",
       d."document_Date",
       pk.search_course(d."currency_id", d."document_Date")
FROM "Documents" d


-- вывод количества записей
begin
    pk.console();
end;

-- очистка кеша
begin
    pk.clear();
end;
