-- генерация случайной даты в диапазоне
create or replace function gen_random_date(
    p_start_date date,
    p_end_date date
)
    returns date as
$$
begin
    return floor(random() * (p_end_date::date - p_start_date::date + 1))::integer + p_start_date::date;
end;
$$ language plpgsql;


-- добавить клиента в таблицу
create or replace procedure insert_new_client(
    p_client_id int4,
    p_client_name varchar(20)
) as
$$
BEGIN
    insert into clients (client_id, client_name) values (p_client_id, p_client_name);
end;
$$ language plpgsql;


-- добавить валюту в таблицу
create or replace procedure insert_new_currency(
    p_currency_id int4,
    p_currency_iso_name CHAR(3),
    p_currency_name VARCHAR(20),
    p_precision INT4 default 5,
    p_sign_national_currency NUMERIC(1) default 0,
    p_start_date DATE default '01.01.1990',
    p_end_date DATE default '31.12.2999',
    p_old_currency_id INT4 default null,
    p_scale_denomination FLOAT8 default null
) as
$$
BEGIN
    insert into currencies (currency_id, currency_iso_name, currency_name, precision, sign_national_currency,
                            start_date, end_date, old_currency_id, scale_denomination)
    values (p_currency_id, p_currency_iso_name, p_currency_name, p_precision, p_sign_national_currency, p_start_date,
            p_end_date, p_old_currency_id, p_scale_denomination);
end;
$$ language plpgsql;


-- добавить документ в таблицу
create or replace procedure insert_new_document(
    p_document_id VARCHAR(20),
    p_currency_id INT4,
    p_client_id INT4,
    p_document_date DATE,
    p_amount FLOAT8
) as
$$
BEGIN
    insert into documents (document_id, currency_id, client_id, document_date, amount)
    values (p_document_id, p_currency_id, p_client_id, p_document_date, p_amount);
end;
$$ language plpgsql;


-- добавить курс в таблицу
create or replace procedure insert_new_exchange_rate(
    p_exchange_rate_id INT4,
    p_currency_id INT4,
    p_start_date_exchange_rate DATE,
    p_exchange_rate FLOAT8,
    p_exchange_rate_scale FLOAT8
) as
$$
BEGIN
    insert into exchange_rates (exchange_rate_id, currency_id, start_date_exchange_rate, exchange_rate,
                                exchange_rate_scale)
    VALUES (p_exchange_rate_id, p_currency_id, p_start_date_exchange_rate, p_exchange_rate, p_exchange_rate_scale);
end;
$$ language plpgsql;


-- 4.1 заполнение таблицы клиентов
CREATE OR REPLACE PROCEDURE fill_clients(
    range_in integer
) as
$$
BEGIN
    FOR i IN 1..range_in
        LOOP
            IF MOD(i, 2) = 0 THEN
                call insert_new_client(i, 'Client - ' || i);
            END IF;
        END LOOP;
END;
$$ language plpgsql;

call fill_clients(1000);


-- 4.2 заполнение таблицы валют
call insert_new_currency
    (p_currency_id => 112, p_currency_iso_name => 'BYB', p_currency_name => 'Belarussian Ruble',
     p_start_date => '25.05.1992',
     p_end_date => '01.01.2000');

call insert_new_currency
    (p_currency_id => 974, p_currency_iso_name => 'BYR', p_currency_name => 'Belarussian Ruble',
     p_start_date => '01.01.2000',
     p_end_date => '01.07.2016',
     p_old_currency_id => 112, p_scale_denomination => 1000);

call insert_new_currency
    (p_currency_id => 933, p_currency_iso_name => 'BYN', p_currency_name => 'Belarusian Ruble',
     p_start_date => '01.07.2016',
     p_old_currency_id => 974,
     p_sign_national_currency => 1, p_scale_denomination => 10000);

call insert_new_currency
    (p_currency_id => 810, p_currency_iso_name => 'RUR', p_currency_name => 'Russian Ruble',
     p_start_date => '01.01.1992',
     p_end_date => '01.01.1998');

call insert_new_currency
    (p_currency_id => 643, p_currency_iso_name => 'RUB', p_currency_name => 'Russian Ruble',
     p_start_date => '01.01.1998',
     p_old_currency_id => 810,
     p_scale_denomination => 1000);

call insert_new_currency
    (p_currency_id => 840, p_currency_iso_name => 'USD', p_currency_name => 'US Dollar');
call insert_new_currency
    (p_currency_id => 978, p_currency_iso_name => 'EUR', p_currency_name => 'Euro');
call insert_new_currency
    (p_currency_id => 826, p_currency_iso_name => 'GBP', p_currency_name => 'Pound Sterling');
call insert_new_currency
    (p_currency_id => 756, p_currency_iso_name => 'CHF', p_currency_name => 'Swiss Franc');
call insert_new_currency
    (p_currency_id => 156, p_currency_iso_name => 'CNY', p_currency_name => 'Yuan Renminbi');
call insert_new_currency
    (p_currency_id => 51, p_currency_iso_name => 'AMD', p_currency_name => 'Armenian Dram');
call insert_new_currency
    (p_currency_id => 68, p_currency_iso_name => 'BOB', p_currency_name => 'Boliviano');
call insert_new_currency
    (p_currency_id => 124, p_currency_iso_name => 'CAD', p_currency_name => 'Canadian Dollar');
call insert_new_currency
    (p_currency_id => 392, p_currency_iso_name => 'JPY', p_currency_name => 'Yen');
call insert_new_currency
    (p_currency_id => 973, p_currency_iso_name => 'AOA', p_currency_name => 'Kwanza');


-- 4.3 заполнение таблицы документов
CREATE OR REPLACE PROCEDURE fill_documents() as
$$
declare
    c_document cursor for
        select currencies.currency_id                             as currency_id,
               clients.client_id                                  as client_id,
               currencies.currency_id || '_' || clients.client_id as document_id,
               currencies.currency_id * clients.client_id         as amount
        from currencies
                 left join clients on (clients.client_id between currencies.currency_id - 100 and currencies.currency_id + 100);
BEGIN
    for item in c_document
        loop
            call insert_new_document(item.document_id, item.currency_id,
                                     item.client_id, gen_random_date('01.01.1999', '31.12.2021'),
                                     item.amount);
        end loop;
END;
$$ language plpgsql;

call fill_documents();

-- 10 заполнение таблицы курсов
CREATE OR REPLACE PROCEDURE fill_exchange_rates(p_start_date  DATE, p_end_date IN DATE) as
$$
declare
    i integer := 0;
BEGIN
    loop
        if EXTRACT(dow FROM p_start_date + i) != 6 and
            EXTRACT(dow FROM p_start_date + i) != 0 then
            call insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 0, p_currency_id => 840,
                                     p_exchange_rate => random(),
                                     p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                         p_start_date + i);

            call insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 1, p_currency_id => 978,
                                     p_exchange_rate => random(),
                                     p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                         p_start_date + i);

            call insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 2, p_currency_id => 643,
                                     p_exchange_rate => random(),
                                     p_exchange_rate_scale => 100, p_start_date_exchange_rate =>
                                         p_start_date + i);

            call insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 3, p_currency_id => 826,
                                     p_exchange_rate => random(),
                                     p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                         p_start_date + i);

            call insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 4, p_currency_id => 156,
                                     p_exchange_rate => random(),
                                     p_exchange_rate_scale => 10, p_start_date_exchange_rate =>
                                         p_start_date + i);

            call insert_new_exchange_rate(p_exchange_rate_id => i * 6 + 5, p_currency_id => 756,
                                     p_exchange_rate => random(),
                                     p_exchange_rate_scale => 1, p_start_date_exchange_rate =>
                                         p_start_date + i);
        end if;

        i := i + 1;
        if i = p_end_date - p_start_date then
            exit;
        end if;

    end loop;
end;
$$ language plpgsql;

call fill_exchange_rates('01.01.1990', '31.12.2021');


-- 7.2 поиск курса валют по ближайшей дате
CREATE OR REPLACE FUNCTION search_exchange_rate(
    p_currency_id INTEGER,
    p_date date
) RETURNS float8 as
$$
declare
    course float8;
BEGIN
    select exchange_rate
    into course
    FROM exchange_rates
    WHERE currency_id = p_currency_id
    ORDER BY abs(p_date - start_date_exchange_rate)
    LIMIT 1;
    return course;
end;
$$ language plpgsql;

SELECT document_id,
       amount,
       currency_id,
       document_Date,
       search_exchange_rate(currency_id, document_Date)
FROM documents


-- поиск курса валют по ближайшей дате с кешем
create temp table temp_courses
(
    currency_id              int4,
    start_date_exchange_rate date,
    exchange_rate            float8
);

CREATE OR REPLACE FUNCTION search_exchange_rate_with_cache(
    p_currency_id INTEGER,
    p_date date
) RETURNS float8 as
$$
declare
    course float8;
BEGIN
    select exchange_rate
    into course
    from temp_courses
    where start_date_exchange_rate = p_date
      and currency_id = p_currency_id;
    if course is null then
        select exchange_rate
        into course
        FROM exchange_rates
        WHERE currency_id = p_currency_id
        ORDER BY abs(p_date - start_date_exchange_rate)
        LIMIT 1;
        if course is not null then
            insert into temp_courses (currency_id, start_date_exchange_rate, exchange_rate)
            VALUES (p_currency_id, p_date, course);
        end if;

    end if;
    return course;
end;
$$ language plpgsql;

SELECT document_id,
       amount,
       currency_id,
       document_Date,
       search_exchange_rate_with_cache(currency_id, document_Date)
FROM documents;
