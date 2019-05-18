-- 4. Выбрать все издания Стейнбека на русском языке.
SELECT name
	FROM books_info
	WHERE author_surname = 'Steinbeck' AND lang = 'ru'