SELECT categories_with_books.name, COUNT(books.name)
	FROM categories_with_books
	JOIN books ON (categories_with_books.book_id = books.orig_book_id)
	GROUP BY categories_with_books.name