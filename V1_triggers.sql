USE bookstore_dev;
GO

CREATE TRIGGER trg_rating_after_insert_calculate_average
ON rating
AFTER INSERT
AS
BEGIN
	DECLARE @book_id INT;
	DECLARE @new_average_rating DECIMAL(1,1);

	SELECT @book_id = book_id FROM inserted;
	SET @new_average_rating = dbo.fn_calculate_average_rating(@book_id)

	UPDATE book
	SET average_rating = @new_average_rating
	WHERE @book_id = @book_id;

END;
GO

CREATE TRIGGER trg_book_after_in_stock_notify_customer
ON book
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
	
	INSERT INTO in_stock_notification_queue (in_stock_notification_subscription_id, notification_status)
	SELECT 
		isns.in_stock_notification_subscription_id,
		'Pending'

	FROM in_stock_notification_subscription isns
	INNER JOIN inserted i ON isns.book_id = i.book_id
	WHERE i.stock_quantity > 0
END;
GO

CREATE TRIGGER trg_customer_order_book_after_sale_update_stock_quantity
ON customer_order_book
AFTER INSERT
AS
BEGIN
	DECLARE @book_id INT;
	DECLARE @stock_quantity INT;
	DECLARE @new_stock_quantity INT;
	DECLARE @quantity_sold INT

	SELECT 
		@book_id = book_id,
		@quantity_sold = quantity
	FROM inserted;

	SELECT
		@stock_quantity = stock_quantity
	FROM book
	WHERE book_id = @book_id;

	SET @new_stock_quantity = @stock_quantity - @quantity_sold;

	UPDATE book
	SET stock_quantity = @new_stock_quantity
	WHERE book_id = @book_id;

END;
GO