-- Написать функцию, добавляющую публикацию книги. Функция должна возвращать идентификатор созданной
-- записи о публикациях. Входные данные:  название книги и фамилия автора в оригинале 
-- (на родном языке автора), код родного языка автора, данные о публикации 
-- (ISBN, Name, Volume, Edition, Year, Annotation), код языка книги (Language.Code), сведения об 
-- авторе на языке книги (Surname, FirstName, MiddleName). Перед добавлением записи о публикации
-- выбрать из базы значения вторичных ключей для добавляемой записи исходя из входных параметров 
-- процедуры. Для автора,  книги (в оригинале) и имени автора на языке публикации в случае
-- отсутствия в базе записей, соответствующих входным параметрам, добавить их.

CREATE OR REPLACE FUNCTION add_publication (orig_book_name char(50), orig_author_surname char(30),
                                                orig_lang char(10),  pub_isbn char(13), book_name char(50),
                                                pub_year smallint, pub_annotation char(1000), book_lang char(7), 
                                                author_surname char(20), author_firstname char(20), 
                                                pub_publishing_house char(30), book_volume smallint DEFAULT null, 
                                                pub_edition integer DEFAULT null, author_middlename char(20) DEFAULT null)
RETURNS integer AS $book_id$
DECLARE 
    _orig_book_id bigint;
    _orig_author_id bigint;
    book_id bigint;
    author_id bigint;
BEGIN
    -- сначала проверим, есть ли оригинальное имя автора
    SELECT id INTO _orig_author_id FROM orig_authors 
        WHERE surname = orig_author_surname AND lang = orig_lang;

    IF _orig_author_id is NULL 
    THEN 
        -- добавим нового автора (оригинал)
        INSERT INTO orig_authors(surname, lang) VALUES(orig_author_surname, orig_lang)
            RETURNING id INTO _orig_author_id;
    END IF;

    
    -- проверим книгу на оригинале
    SELECT id INTO _orig_book_id FROM orig_books WHERE name = orig_book_name;

    IF _orig_book_id is NULL 
    THEN
        -- добавим новую оригинальную книгу
        INSERT INTO orig_books(name) VALUES(orig_book_name)
            RETURNING id INTO _orig_book_id;

        -- добавим связь между автором и книгой (оригиналы)
        INSERT INTO orig_authors_orig_books(author_id, book_id) VALUES(_orig_author_id, _orig_book_id);
    END IF;


    -- проверим автора (на языке книги)
    SELECT id INTO author_id FROM authors 
        WHERE surname = author_surname AND firstname = author_firstname AND middlename = author_middlename
            AND authors.orig_author_id = _orig_author_id;

    IF author_id is NULL 
    THEN
        -- добавим нового автора (на языке книги)
        INSERT INTO authors(surname, firstname, middlename, orig_author_id) 
            VALUES(author_surname, author_firstname, author_middlename, _orig_author_id)
            RETURNING id INTO author_id;
    END IF;

    -- проверим наличие книги (на языке книги)
    SELECT id INTO book_id FROM books
        WHERE name = book_name AND volume = book_volume AND lang = book_lang 
        AND books.orig_book_id = _orig_book_id;

    IF book_id is NULL 
    THEN
        -- добавим новую книгу (на языке книги)
        INSERT INTO books(name, volume, lang, orig_book_id) 
            VALUES (book_name, book_volume, book_lang, _orig_book_id)
            RETURNING id INTO book_id;

        -- добавим связь между автором и книгой (на языке книги)
        INSERT INTO authors_books(author_id, book_id) VALUES(author_id, book_id);
    END IF;

    --добавим публикацию книги
    INSERT INTO publications(isbn, year, publishing_house, annotation, book_id, edition)
        VALUES(pub_isbn, pub_year, pub_publishing_house, pub_annotation, book_id, pub_edition);

    RETURN book_id;
    
END;
$book_id$ LANGUAGE plpgsql