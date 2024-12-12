USE bookstore_dev;
GO

CREATE INDEX IX_rating_book_id ON rating(book_id);
CREATE INDEX IX_province_country_id ON province(country_id);
CREATE INDEX IX_district_province_id ON district(province_id);
CREATE INDEX IX_neighborhood_district_id ON neighborhood(district_id);
CREATE INDEX IX_postal_code_district_id ON postal_code(district_id);
CREATE INDEX IX_street_neighborhood_id ON street(neighborhood_id);
CREATE INDEX IX_payment_customer_id ON payment(customer_id);
CREATE INDEX IX_book_category_category_id ON book_category(category_id);
CREATE INDEX IX_book_author_author_id ON book_author(author_id);
CREATE INDEX IX_cart_book_book_id ON cart_book(book_id);
CREATE INDEX IX_favorite_book_book_id ON favorite_book(book_id);
CREATE INDEX IX_book_genre_genre_id ON book_genre(genre_id);
CREATE INDEX IX_customer_order_book_book_id ON customer_order_book(book_id);
CREATE INDEX IX_category_category_name ON category(category_name);
CREATE INDEX IX_author_last_name ON author(last_name);
CREATE INDEX IX_cart_customer_id ON cart(customer_id);
CREATE INDEX IX_favorite_customer_id ON favorite(customer_id);
CREATE INDEX IX_genre_genre_name ON genre(genre_name);
CREATE INDEX IX_customer_order_customer_id ON customer_order(customer_id);
CREATE INDEX IX_book_title ON book(title);
CREATE INDEX IX_book_isbn ON book(isbn);
CREATE INDEX IX_book_price ON book(price);
CREATE INDEX IX_book_publisher_id ON book(publisher_id);