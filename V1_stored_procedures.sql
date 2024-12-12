USE bookstore_dev;
GO

-- PROCESS ORDER
CREATE PROCEDURE usp_process_order
    @customer_id INT,
    @shipping_address_id INT,
    @order_status_id INT,
    @payment_id INT,
    @total_amount DECIMAL(18,2),
    @order_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

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

    SET @order_id = SCOPE_IDENTITY();
END;
GO

-- ADD SHIPPING ADDRESS
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
    SET NOCOUNT ON;

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
    );

    SET @shipping_address_id = SCOPE_IDENTITY();
END;
GO

-- REGISTER CUSTOMER
CREATE PROCEDURE usp_register_customer
    @first_name NVARCHAR(50),
    @last_name NVARCHAR(50),
    @phone_number VARCHAR(15),
    @email NVARCHAR(255),
    @password_hash VARBINARY(64),
    @new_customer_id INT OUTPUT,
	@new_cart_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO customer (
        first_name,
        last_name,
        phone_number,
        email,
        password_hash
    )
    VALUES (
        @first_name,
        @last_name,
        @phone_number,
        @email,
        @password_hash
    );

    SET @new_customer_id = SCOPE_IDENTITY();

	--Creates a cart for the registered customer.
	INSERT INTO cart (
		customer_id
	)
	VALUES (
		@new_customer_id
	)

	SET @new_cart_id = SCOPE_IDENTITY();
END;
GO

-- ADD BOOK TO CART
CREATE PROCEDURE usp_add_book_to_cart
	@cart_id INT,
	@book_id INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION;

	--Check if the book already exists in the cart.
	BEGIN TRY
		IF EXISTS (
			SELECT 1
			FROM cart_book
			WHERE cart_id = @cart_id AND book_id = @book_id
		)
		BEGIN
			UPDATE cart_book
			SET quantity = quantity + 1
			WHERE cart_id = @cart_id AND book_id = @book_id
		END

		ELSE
		BEGIN
			INSERT INTO cart_book (
				cart_id,
				book_id
			)
			VALUES (
				@cart_id,
				@book_id
			);
		END

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH;

END;
GO

--ADD BOOK TO FAVORITE
CREATE PROCEDURE usp_add_book_to_favorite
	@favorite_id INT,
	@book_id INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION;

	--Check if the book already exists in favorites.
	BEGIN TRY
		IF NOT EXISTS (
			SELECT 1
			FROM favorite_book
			WHERE favorite_id = @favorite_id AND book_id = @book_id
		)
		BEGIN
			INSERT INTO favorite_book (
				favorite_id,
				book_id
			)
			VALUES (
				@favorite_id,
				@book_id
			);
		END

		COMMIT TRANSACTION;
	END TRY

	BEGIN CATCH
		ROLLBACK TRANSACTION;
		THROW;
	END CATCH;

END;
GO

CREATE PROCEDURE usp_remove_book_from_cart
	@cart_id INT,
	@book_id INT

AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRANSACTION;

	BEGIN TRY
		IF EXISTS (
			SELECT 1
			FROM cart_book
			WHERE cart_id = @cart_id AND book_id = @book_id AND quantity > 1
		)
		BEGIN
			UPDATE cart_book
			SET quantity = quantity - 1
			WHERE cart_id = @cart_id AND book_id = @book_id
		END
		ELSE 