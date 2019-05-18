-- 5. В какие категории попала книга "Programming .NET Web Services".

SELECT name
	FROM categories_with_books
	WHERE categories_with_books.book_name = 'Programming .NET Web Services'