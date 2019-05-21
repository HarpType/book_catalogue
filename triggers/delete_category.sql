-- Создать триггер на удаление категории книг. Категория может быть удалена только в случае если либо ни одна книга не ссылается на
-- категорию, либо категория не является корневой. При удалении некорневой категории, все книги в этой категории включить 
-- в родительскую категорию. В случае удаления корневой категории, сделать все ее подкатегории корневыми.

CREATE OR REPLACE FUNCTION handler_delete_category()
RETURNS TRIGGER
AS $$
DECLARE
    _category_id bigint;
    _parent_id bigint;
    root_category boolean;
    empty_category boolean;
BEGIN
    root_category := TRUE;
    empty_category := TRUE;

    _category_id := OLD.id;

    -- для начала определим, какая категория перед нами
    -- существуют ли категории, которые указывают на нашу? 
    IF EXISTS (SELECT 1 FROM parent_categories WHERE parent_categories.category_id = _category_id)
    THEN
        root_category := FALSE;
    END IF;

    -- существуют ли книги, на которые указывает наша категория?
    IF EXISTS (SELECT 1 FROM categories_books WHERE categories_books.category_id = _category_id)
    THEN
        empty_category := FALSE;
    END IF;

    IF root_category
    THEN
        -- если категория корневая и пуста
        IF empty_category 
        THEN
            DELETE FROM parent_categories WHERE parent_categories.parent_id = _category_id;

            RETURN NEW;
        END IF;

        RETURN NULL;
    ELSE 
        -- заменяем свой идентификатор в таблице категория-родительская_категория на идентификатор родителя
        UPDATE parent_categories
                SET parent_id = _parent_id
                WHERE parent_id = _category_id;

        -- если категория не корневая и непустая
        IF NOT empty_category
        THEN
            UPDATE categories_books
                SET category_id = _parent_id
                WHERE category_id = _category_id;
        END IF;

        RETURN NEW;
    END IF;
END;
$$ LANGUAGE plpgsql;;

--триггер, исполняющий функцию для обработки процесса удаления категории
CREATE TRIGGER delete_category
	BEFORE DELETE ON categories
	FOR EACH ROW EXECUTE PROCEDURE handler_delete_category();