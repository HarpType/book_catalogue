-- 6. На скольких языках издана каждая книга?

SELECT orig_books.name, COUNT(books.lang)
	FROM books
	JOIN orig_books ON (books.orig_book_id = orig_books.id)
	GROUP BY orig_books.name