CREATE VIEW books_info
	AS SELECT publications.*, books.name, books.volume, books.lang,
				orig_books.name orig_name, orig_authors.surname author_surname, orig_authors.lang orig_lang
	FROM publications
	JOIN books ON (publications.book_id = books.id)
	JOIN orig_books ON (books.orig_book_id = orig_books.id)
	JOIN orig_authors_orig_books ab ON (orig_books.id = ab.book_id)
	JOIN orig_authors ON (ab.author_id = orig_authors.id)
