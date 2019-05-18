-- 2. Выбрать все книги, изданные на русском языке
SELECT name
	FROM books 
	WHERE books.lang = 'ru'