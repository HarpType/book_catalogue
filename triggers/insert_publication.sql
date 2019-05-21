-- Написать триггер на добавление публикации. При добавлении публикации, 
-- если значение для года (Year) не определено, вставлять текущий год. Если не определено значение для описания (Annotation),
-- вставлять информацию об оригинале книги (название книги и имя автора на языке оригинала).

CREATE OR REPLACE FUNCTION handler_insert_publication()
RETURNS TRIGGER
AS $$
DECLARE 
    _year int;
    _annotation char(1000);
    _cur_orig_author_name char(30);
BEGIN
    _year := NEW.year;
    _annotation := NEW.annotation;

    IF _year is NULL 
    THEN
        _year := date_part('year', CURRENT_DATE);
    END IF;

    IF _annotation is NULL
    THEN
        SELECT orig_books.name INTO _annotation
            FROM publications
            JOIN books ON (publications.book_id = books.id)
            JOIN orig_books ON (books.orig_book_id = orig_books.id);

        FOR _cur_orig_author_name IN (SELECT orig_authors.name 
                                        FROM publications
                                        JOIN books ON (publications.book_id = books.id)
                                        JOIN orig_books ON (books.orig_book_id = orig_books.id)
                                        JOIN orig_authors_orig_books ON (orig_books.id = orig_authors_orig_books.book_id)
                                        JOIN orig_authors ON (orig_authors_orig_books.author_id = orig_authors.id))
        LOOP
            _annotation := CONCAT(_annotation, _cur_orig_author_name);
        END LOOP;
    END IF;

    INSERT INTO publications (isbn, year, publishing_house, annotation, book_id, edition)
        VALUES(NEW.isbn, _year, NEW.publishing_house, _annotation, NEW.book_id, NEW.edition);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER insert_publication
	BEFORE INSERT ON publications
	FOR EACH ROW EXECUTE PROCEDURE handler_insert_publication();