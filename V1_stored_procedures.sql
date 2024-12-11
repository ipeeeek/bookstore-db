USE bookstore_dev;
GO

CREATE PROCEDURE usp_process_order
	@customer_id INT,
	@shipping_address_id INT,
	@order_status_id INT,
	@payment_id INT,
	@total_amount DECIMAL(18,2)
AS
BEGIN
	INSERT INTO customer_order (
		customer_id,
		shipping_address_id,
		order_status_id,
		payment_id,
		total_amount
	)
	VALUES (
		@customer_id,
		@shipping_address_id,
		@order_status_id,
		@payment_id,
		@total_amount
	);
END;
GO

CREATE PROCEDURE usp_add_shipping_address
	@street_id INT,
	@neighborhood_id INT,
	@district_id INT,
	@province_id INT,
	@country_id INT,
	@postal_code_id INT,
	@shipping_address_id INT OUTPUT
AS
BEGIN
	INSERT INTO shipping_address (
	street_id,
	neighborhood_id,
	district_id,
	province_id,
	country_id,
	postal_code_id
	)
	VALUES (
	@street_id,
	@neighborhood_id,
	@district_id,
	@province_id,
	@country_id,
	@postal_code_id
	)

	SET @shipping_address_id = SCOPE_IDENTITY();
END;