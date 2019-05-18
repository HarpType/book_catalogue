-- 3. Найти ISBN-ы всех изданий всех книг Хэмингуэя.
SELECT isbn 
	FROM books_info
	WHERE author_surname = 'Hemingway'