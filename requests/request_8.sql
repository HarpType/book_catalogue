SELECT isbn, name 
	FROM books_info
	WHERE lang = orig_lang
	GROUP BY isbn, name