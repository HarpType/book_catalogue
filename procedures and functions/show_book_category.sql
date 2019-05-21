-- Написать функцию, возвращающую таблицу со всеми категориями, к которым принадлежит книга. 
-- Входные данные: ISBN публикации. На выходе надо получить таблицу категорий, к которым 
-- принадлежит книга, включая все родительские категории тех категорий, с которыми книга 
-- связана непосредственно.

CREATE OR REPLACE FUNCTION book_category(pub_isbn char(50))
RETURNS TABLE (category_name character(50)) AS $$
DECLARE
    _orig_book_id bigint;
    book_category_id bigint;
    parent_book_category_id bigint;
    cur_parent_book_category_id bigint;
BEGIN
    SELECT orig_books.id INTO _orig_book_id 
        FROM (SELECT * FROM publications WHERE publications.isbn = pub_isbn) AS public
        JOIN books ON (public.book_id = books.id)
        JOIN orig_books ON (books.orig_book_id = orig_books.id);

    IF _orig_book_id is NULL
    THEN
        RETURN;
    END IF;

    -- пройдёмся по всем категориям книги
    FOR book_category_id IN (SELECT category_id 
            FROM categories_books WHERE categories_books.book_id = _orig_book_id)
    LOOP
        -- для каждой категории найдём все родительские категории
        SELECT parent_id INTO parent_book_category_id 
            FROM parent_categories WHERE parent_categories.category_id = book_category_id;

        WHILE parent_book_category_id IS NOT NULL
        LOOP
            SELECT name INTO category_name
                FROM categories WHERE categories.id = parent_book_category_id;

            RETURN NEXT;

            cur_parent_book_category_id := parent_book_category_id;
            SELECT parent_id INTO parent_book_category_id 
            FROM parent_categories WHERE parent_categories.category_id = cur_parent_book_category_id;
        END LOOP;

        -- выберем начальное значение категории
        SELECT name INTO category_name 
            FROM categories WHERE categories.id = book_category_id;    

        RETURN NEXT;
    END LOOP;
END; $$
LANGUAGE plpgsql 