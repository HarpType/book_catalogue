-- 5. В какие категории попала книга "Programming .NET Web Services".

SELECT categories.name
	FROM categories
	JOIN categories_books ON (categories.id = categories_books.category_id)
	JOIN orig_books ON (categories_books.book_id = orig_books.id)
	WHERE orig_books.name = 'Programming .NET Web Services'