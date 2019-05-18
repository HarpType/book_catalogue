-- Написать функцию, добавляющую публикацию книги. Функция должна возвращать идентификатор созданной
-- записи о публикациях. Входные данные:  название книги и фамилия автора в оригинале 
-- (на родном языке автора), код родного языка автора, данные о публикации 
-- (ISBN, Name, Volume, Edition, Year, Annotation), код языка книги (Language.Code), сведения об 
-- авторе на языке книги (Surname, FirstName, MiddleName). Перед добавлением записи о публикации
--  выбрать из базы значения вторичных ключей для добавляемой записи исходя из входных параметров 
-- процедуры. Для автора,  книги (в оригинале) и имени автора на языке публикации в случае
-- отсутствия в базе записей, соответствующих входным параметрам, добавить их.

CREATE OR REPLACE FUNCTION add_publication (orig_book_name char(50), orig_author_surname char(30),
                                                orig_lang char(10),  isbn char(13), book_name char(50),
                                                volume smallint DEFAULT null, publishin_house char(30), edition integer DEFAULT null, 
                                                year smallint, annotation char(1000), lang char(7), 
                                                surname char(20), firstname char(20), middlename char(20) DEFAULT null)
RETURNS integer AS $book_id$
DECLARE 
    orig_book_id integer;
    orig_author_id integer;
    book_id integer;
BEGIN
    -- Сначала проверить наличие оригинального автора и книги, добавлять в случае необходимости
    -- Проверить публкацию
END;
book_id LANGUAGE plpgsql