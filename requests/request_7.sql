-- 7. Вывести для каждого издательства количество изданных книг.

SELECT publishing_house, COUNT(book_id)
	FROM publications
	GROUP BY publishing_house