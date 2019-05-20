-- Написать процедуру, определяющую есть ли циклические зависимости среди категорий, и если 
-- есть – удаляющую такие зависимости. При этом удаляться должна ссылка старшей категории 
-- (с большим номером id)  на младшую (с меньшим номером id).

CREATE OR REPLACE FUNCTION remove_categ_cycle()
RETURNS integer AS $remove_status$
DECLARE 
    parent_categ_cursor CURSOR FOR 
        SELECT category_id, parent_id FROM parent_categories;
    cur_category_id bigint;
    cur_parent_id bigint;
    result integer;
BEGIN
    result := 0;

    OPEN parent_categ_cursor;

    LOOP

        FETCH  parent_categ_cursor INTO cur_category_id, cur_parent_id;

        IF NOT FOUND THEN RETURN result;END IF;
        -- находится ли циклическая зависимость в таблице?
        IF EXISTS (SELECT 1 FROM parent_categories 
                    WHERE category_id = cur_parent_id AND parent_id = cur_category_id)
        THEN
            IF cur_parent_id > cur_category_id 
            THEN
                DELETE FROM parent_categories
                    WHERE category_id = cur_parent_id AND parent_id = cur_category_id;
            ELSE
                DELETE FROM parent_categories 
                    WHERE category_id = cur_category_id AND parent_id = cur_parent_id;
            END IF;

            result := 1;
        END IF;

        FETCH NEXT FROM parent_categ_cursor INTO cur_category_id, cur_parent_id;

    END LOOP;

    CLOSE parent_categ_cursor;
    DEALLOCATE parent_categ_cursor;

    RETURN result;
END;
$remove_status$ LANGUAGE plpgsql 