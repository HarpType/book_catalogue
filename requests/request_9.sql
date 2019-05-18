SELECT name, COUNT(book_name)
	FROM categories_with_books
	GROUP BY name