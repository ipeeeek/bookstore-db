USE bookstore_dev;
GO

CREATE VIEW vw_out_of_stock_books
AS
SELECT
	b.book_id,
	b.title,
	b.stock_quantity
FROM book b
WHERE b.stock_quantity = 0;
GO;

CREATE VIEW vw_sold_books
AS
SELECT
	b.book_id,
	b.title,
	SUM(cob.quantity) AS total_quantity_sold

FROM customer_order_book cob
INNER JOIN book b ON cob.book_id = b.book_id
GROUP BY b.book_id, b.title