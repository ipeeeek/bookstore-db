USE bookstore_dev;
GO

-- PROCESS ORDER
CREATE PROCEDURE usp_process_order
    @customer_id INT,
    @shipping_address_id INT,
    @payment_id INT,
    @total_amount DECIMAL(18,2),
    @order_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        INSERT INTO customer_order (
            customer_id,
            shipping_address_id,
            payment_id,
            total_amount
        )
        VALUES (
            @customer_id,
            @shipping_address_id,
            @payment_id,
            @total_amount
        );

        SET @order_id = SCOPE_IDENTITY();

        INSERT INTO customer_order_book (
            customer_order_id,
            book_id,
            quantity
        )
        SELECT
            @order_id,
            cb.book_id,
            cb.quantity
        FROM
            cart c
        INNER JOIN cart_book cb ON c.cart_id = cb.cart_id
        WHERE
            c.customer_id = @customer_id;

        DELETE cb
        FROM cart_book cb
        INNER JOIN cart c ON cb.cart_id = c.cart_id
        WHERE c.customer_id = @customer_id;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO



-- ADD SHIPPING ADDRESS
CREATE PROCEDURE usp_add_shipping_address
    @customer_id INT,
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
        customer_id,
        street_id,
        neighborhood_id,
        district_id,
        province_id,
        country_id,
        postal_code_id
    )
    VALUES (
        @customer_id,
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

    -- Creates a cart for the registered customer.
    INSERT INTO cart (
        customer_id
    )
    VALUES (
        @new_customer_id
    )

    SET @new_cart_id = SCOPE_IDENTITY();
END;
GO

-- UPDATE CUSTOMER INFORMATION
CREATE PROCEDURE usp_update_customer
    @customer_id INT,
    @new_phone_number VARCHAR(15),
    @new_email NVARCHAR(255)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE customer
        SET
            phone_number = @new_phone_number,
            email = @new_email
        WHERE customer_id = @customer_id;
        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
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

    -- Check if the book already exists in the cart.
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

-- ADD BOOK TO FAVORITE
CREATE PROCEDURE usp_add_book_to_favorite
    @favorite_id INT,
    @book_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    -- Check if the book already exists in favorites.
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

-- REMOVE BOOK FROM CART
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
        BEGIN
            DELETE FROM cart_book
            WHERE cart_id = @cart_id AND book_id = @book_id
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- REMOVE BOOK FROM FAVORITES
CREATE PROCEDURE usp_remove_book_from_favorite
    @favorite_id INT,
    @book_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    -- Check if the book already exists in favorites.
    BEGIN TRY
        DELETE FROM favorite_book
        WHERE favorite_id = @favorite_id AND book_id = @book_id

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

END;
GO

-- UPDATE CUSTOMER PASSWORD
CREATE PROCEDURE usp_update_customer_password
    @customer_id INT,
    @new_password VARBINARY(64)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    
    BEGIN TRY
        UPDATE customer
        SET password_hash = @new_password
        WHERE customer_id = @customer_id
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- UPDATE ADMIN PASSWORD
CREATE PROCEDURE usp_update_admin_password
    @admin_user_id INT,
    @new_password VARBINARY(64)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    
    BEGIN TRY
        UPDATE admin_user
        SET password_hash = @new_password
        WHERE admin_user_id = @admin_user_id
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ADD BOOK TO STORE INVENTORY
CREATE PROCEDURE usp_add_book
    @title NVARCHAR(255),
    @isbn NVARCHAR(13),
    @publication_date DATE,
    @cover_image_path NVARCHAR(255),
    @synopsis NVARCHAR(MAX),
    @price DECIMAL(18,2),
    @stock_quantity INT,
    @page_count INT,
    @new_book_id INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        IF NOT EXISTS (
            SELECT 1
            FROM book
            WHERE isbn = @isbn
        )
        BEGIN
            INSERT INTO book (
                title,
                isbn,
                publication_date,
                cover_image_path,
                synopsis,
                price,
                stock_quantity,
                page_count
            )
            VALUES (
                @title,
                @isbn,
                @publication_date,
                @cover_image_path,
                @synopsis,
                @price,
                @stock_quantity,
                @page_count
            );

            SET @new_book_id = SCOPE_IDENTITY();
        END

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH

END;
GO





-- REMOVE BOOK FROM STORE INVENTORY
CREATE PROCEDURE usp_remove_book
    @book_id INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        DELETE FROM book
        WHERE book_id = @book_id
        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH

END;
GO

-- UPDATE BOOK DETAILS
CREATE PROCEDURE usp_update_book
    @book_id INT,
    @title NVARCHAR(255),
    @isbn NVARCHAR(13),
    @publication_date DATE,
    @cover_image_path NVARCHAR(255),
    @synopsis NVARCHAR(MAX),
    @price DECIMAL(18,2),
    @stock_quantity INT,
    @page_count INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE book
        SET
            title = @title,
            isbn = @isbn,
            publication_date = @publication_date,
            cover_image_path = @cover_image_path,
            synopsis = @synopsis,
            price = @price,
            stock_quantity = @stock_quantity,
            page_count = @page_count
        WHERE book_id = @book_id;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
