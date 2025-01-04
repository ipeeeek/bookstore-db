USE bookstore_dev;
GO

CREATE FUNCTION fn_format_full_address (
	@shipping_address_id INT
)
RETURNS VARCHAR(1000)
AS
BEGIN
    DECLARE @full_address VARCHAR(1000);

    SELECT @full_address = 
        s.street_name + ',' + 
        n.neighborhood_name + ',' + 
        d.district_name + ',' + 
        p.province_name + ',' + 
        c.country_name + ',' + 
        pc.postal_code

    FROM shipping_address sa
    JOIN street s ON sa.street_id = s.street_id
    JOIN neighborhood n ON sa.neighborhood_id = n.neighborhood_id
    JOIN district d ON sa.district_id = d.district_id
    JOIN province p ON sa.province_id = p.province_id
    JOIN country c ON sa.country_id = c.country_id
    JOIN postal_code pc ON sa.postal_code_id = pc.postal_code_id
    WHERE sa.shipping_address_id = @shipping_address_id;

    RETURN @full_address;
END;
GO

--CALCULATE BOOK RATING AVERAGE
CREATE FUNCTION fn_calculate_average_rating (
	@book_id INT
)
RETURNS DECIMAL(1,1)
AS
BEGIN
	DECLARE @book_rating DECIMAL(3,1)
		SELECT @book_rating = AVG(rating_value)
		FROM rating
		WHERE book_id = @book_id;
	RETURN @book_rating;
END;
GO

--CALCULATE TOTAL COST OF THE CART
CREATE FUNCTION fn_calculate_cart_total (
	@cart_id INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @cart_total DECIMAL(18,2)

		SELECT @cart_total = SUM(b.price * cb.quantity)
		FROM cart_book cb
		JOIN book b ON cb.book_id = b.book_id
		WHERE cb.cart_id = @cart_id;

	RETURN @cart_total;
END;
GO

--CALCULATE SALES TAX
CREATE FUNCTION fn_calculate_sales_tax (
	@book_id INT
)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @book_price DECIMAL(18,2);
	DECLARE @sales_tax_applied DECIMAL(18,2);
	DECLARE @sales_tax_percentage DECIMAL(18,2) = 0.008;

	SELECT @book_price = price
	FROM book
	WHERE book_id = @book_id;

	SET @sales_tax_applied = @book_price * @sales_tax_percentage;

	RETURN @sales_tax_applied;
END;
GO

--CALCULATE REVENUE
CREATE FUNCTION fn_calculate_revenue (
	@start_date DATE = NULL,
	@end_date DATE = NULL
)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @total_revenue DECIMAL(18,2)
	SELECT @total_revenue = SUM(total_amount)
	FROM customer_order
	WHERE (@start_date IS NULL OR created_at >= @start_date)
	AND (@end_date IS NULL OR created_at <= @end_date);
	RETURN @total_revenue
END;
GO

--CALCULATE DISCOUNTED PRICE
CREATE FUNCTION fn_calculate_discount (
	@book_id INT, 
	@discount_percentage DECIMAL(3,2)
)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @original_price DECIMAL(18, 2);
    DECLARE @discounted_price DECIMAL(18, 2);

	SELECT @original_price = price
	FROM book
	WHERE book_id = @book_id;

	SET @discounted_price = @original_price - (@original_price * @discount_percentage / 100);

	RETURN @discounted_price;
END;
