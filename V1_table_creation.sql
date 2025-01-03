USE bookstore_dev;
GO

--Tables related to users and order details.

CREATE TABLE admin_user (
	admin_user_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	first_name NVARCHAR(50) NOT NULL,
	last_name NVARCHAR(50) NOT NULL,
	email NVARCHAR(255) NOT NULL UNIQUE,
	password_hash VARBINARY(64) NOT NULL,
	last_login DATETIME NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE customer (
	customer_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	first_name NVARCHAR(50) NOT NULL,
	last_name NVARCHAR(50) NOT NULL,
	phone_number VARCHAR(15) NOT NULL,
	email NVARCHAR(255) NOT NULL UNIQUE,
	password_hash VARBINARY(64) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE country (
	country_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	country_name NVARCHAR(100) NOT NULL UNIQUE,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE province (
	province_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	country_id INT NOT NULL,
	province_name NVARCHAR(100) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_province_country
		FOREIGN KEY (country_id) 
		REFERENCES country(country_id)
);

CREATE TABLE district (
	district_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	province_id INT NOT NULL,
	district_name NVARCHAR(100) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_district_province
		FOREIGN KEY (province_id) 
		REFERENCES province(province_id)
);

CREATE TABLE neighborhood (
	neighborhood_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	district_id INT NOT NULL,
	neighborhood_name NVARCHAR(100) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_neighborhood_district
		FOREIGN KEY (district_id)
		REFERENCES district(district_id)
);

CREATE TABLE postal_code (
	postal_code_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	district_id INT NOT NULL,
	postal_code NVARCHAR(10) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_postal_code_district
		FOREIGN KEY (district_id)
		REFERENCES district(district_id)
);

CREATE TABLE street (
	street_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	neighborhood_id INT NOT NULL,
	street_name NVARCHAR(100) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_street_neighborhood
		FOREIGN KEY (neighborhood_id)
		REFERENCES neighborhood(neighborhood_id)
);

CREATE TABLE shipping_address (
	shipping_address_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	customer_id INT NOT NULL,
	country_id INT NOT NULL,
	province_id INT NOT NULL,
	district_id INT NOT NULL,
	neighborhood_id INT NOT NULL,
	street_id INT NOT NULL,
	postal_code_id INT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_shipping_address_customer
		FOREIGN KEY (customer_id)
		REFERENCES customer(customer_id),

	CONSTRAINT FK_shipping_address_country
		FOREIGN KEY (country_id) 
		REFERENCES country(country_id),

	CONSTRAINT FK_shipping_address_province
		FOREIGN KEY (province_id) 
		REFERENCES province(province_id),

	CONSTRAINT FK_shipping_address_district
		FOREIGN KEY (district_id) 
		REFERENCES district(district_id),

	CONSTRAINT FK_shipping_address_neighborhood
		FOREIGN KEY (neighborhood_id) 
		REFERENCES neighborhood(neighborhood_id),

	CONSTRAINT FK_shipping_address_street
		FOREIGN KEY (street_id) 
		REFERENCES street(street_id),

	CONSTRAINT FK_shipping_address_postal_code
		FOREIGN KEY (postal_code_id) 
		REFERENCES postal_code(postal_code_id)
);

CREATE TABLE payment_method (
	payment_method_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	payment_method_name NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE payment_status (
	payment_status_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	payment_status_name NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE payment (
	payment_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	customer_id INT NOT NULL,
	payment_method_id INT NOT NULL,
	payment_status_id INT NOT NULL DEFAULT 1, 
	total_amount DECIMAL(18,2) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_payment_customer_id
		FOREIGN KEY (customer_id) 
		REFERENCES customer(customer_id),

	CONSTRAINT FK_payment_payment_method
		FOREIGN KEY (payment_method_id) 
		REFERENCES payment_method(payment_method_id),

	CONSTRAINT FK_payment_payment_status
		FOREIGN KEY (payment_status_id)
		REFERENCES payment_status(payment_status_id)
);

--Tables related to books, favorites and cart.

CREATE TABLE category (
	category_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	category_name NVARCHAR(100) NOT NULL UNIQUE,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE author (
	author_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	first_name NVARCHAR(50) NOT NULL,
	last_name NVARCHAR(50) NOT NULL,
	bio NVARCHAR(MAX) NULL,
	path_to_image NVARCHAR(255) NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE cart (
	cart_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	customer_id INT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_cart_customer
		FOREIGN KEY (customer_id)
		REFERENCES customer(customer_id)
);

CREATE TABLE favorite (
	favorite_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	customer_id INT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_favorite_customer
		FOREIGN KEY (customer_id)
		REFERENCES customer(customer_id)
);

CREATE TABLE genre (
	genre_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	genre_name NVARCHAR(50) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE order_status (
	order_status_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	order_status_name NVARCHAR(50) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE customer_order (
	customer_order_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	customer_id INT NOT NULL,
	shipping_address_id INT NOT NULL,
	order_status_id INT NOT NULL,
	payment_id INT NOT NULL,
	total_amount DECIMAL(18,2) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_customer_order_customer
		FOREIGN KEY (customer_id)
		REFERENCES customer(customer_id),

	CONSTRAINT FK_customer_order_order_status
		FOREIGN KEY (order_status_id)
		REFERENCES order_status(order_status_id),

	CONSTRAINT FK_customer_order_shipping_address
		FOREIGN KEY (shipping_address_id)
		REFERENCES shipping_address(shipping_address_id),

	CONSTRAINT FK_customer_order_payment
		FOREIGN KEY (payment_id)
		REFERENCES payment(payment_id)
);

CREATE TABLE dimension (
	dimension_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	height DECIMAL(4,2) NOT NULL,
	width DECIMAL(4,2) NOT NULL,
	depth DECIMAL(4,2) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE book_format (
	book_format_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	book_format_name NVARCHAR(50) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE book_language (
	book_language_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	book_language_name NVARCHAR(50) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE publisher (
	publisher_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	publisher_name NVARCHAR(50) NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
);

CREATE TABLE book (
	book_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	title NVARCHAR(255) NOT NULL,
	isbn NVARCHAR(13) NOT NULL UNIQUE,
	publication_date DATE NOT NULL,
	cover_image_path NVARCHAR(255) NULL,
	synopsis NVARCHAR(MAX) NULL,
	price DECIMAL(18,2) NOT NULL,
	stock_quantity INT NOT NULL,
	page_count INT NOT NULL,
	average_rating DECIMAL(1,1) NULL,
	dimension_id INT NOT NULL,
	book_format_id INT NOT NULL,
	book_language_id INT NOT NULL,
	publisher_id INT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_book_dimension
		FOREIGN KEY (dimension_id)
		REFERENCES dimension(dimension_id),

	CONSTRAINT FK_book_book_format
		FOREIGN KEY (book_format_id)
		REFERENCES book_format(book_format_id),

	CONSTRAINT FK_book_book_language
		FOREIGN KEY (book_language_id)
		REFERENCES book_language(book_language_id),

	CONSTRAINT FK_book_publisher
		FOREIGN KEY (publisher_id)
		REFERENCES publisher(publisher_id)
);

CREATE TABLE rating (
	rating_id INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
	customer_id INT NOT NULL,
	book_id INT NOT NULL,
	rating_value INT NOT NULL CHECK (rating_value BETWEEN 1 AND 5),
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_rating_customer
		FOREIGN KEY (customer_id)
		REFERENCES customer(customer_id),

	CONSTRAINT FK_rating_book
		FOREIGN KEY (book_id)
		REFERENCES book(book_id),

	CONSTRAINT unique_customer_book
		UNIQUE (customer_id, book_id)
);

--JOIN TABLES

CREATE TABLE book_category (
	book_id  INT NOT NULL,
	category_id INT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()

	 CONSTRAINT PK_book_category 
		PRIMARY KEY (book_id, category_id),

	CONSTRAINT FK_book_category_book
		FOREIGN KEY (book_id)
		REFERENCES book(book_id),

	CONSTRAINT FK_book_category_category
		FOREIGN KEY (category_id)
		REFERENCES category(category_id)
);

CREATE TABLE book_author (
	book_id  INT NOT NULL,
	author_id INT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()

	 CONSTRAINT PK_book_author
		PRIMARY KEY (book_id, author_id),

	CONSTRAINT FK_book_author_book
		FOREIGN KEY (book_id)
		REFERENCES book(book_id),

	CONSTRAINT FK_book_author_author
		FOREIGN KEY (author_id)
		REFERENCES author(author_id)
);

CREATE TABLE book_genre (
	book_id  INT NOT NULL,
	genre_id INT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()

	 CONSTRAINT PK_book_genre 
		PRIMARY KEY (book_id, genre_id),

	CONSTRAINT FK_book_genre_book
		FOREIGN KEY (book_id)
		REFERENCES book(book_id),

	CONSTRAINT FK_book_genre_genre
		FOREIGN KEY (genre_id)
		REFERENCES genre(genre_id)
);

CREATE TABLE cart_book (
	cart_id  INT NOT NULL,
	book_id INT NOT NULL,
	quantity INT NOT NULL DEFAULT 1,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()
	
	CONSTRAINT PK_cart_book 
		PRIMARY KEY (cart_id, book_id),

	CONSTRAINT FK_cart_book_cart
		FOREIGN KEY (cart_id)
		REFERENCES cart(cart_id),

	CONSTRAINT FK_cart_book_book
		FOREIGN KEY (book_id)
		REFERENCES book(book_id)
);

CREATE TABLE favorite_book(
	favorite_id  INT NOT NULL,
	book_id INT NOT NULL,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()

	 CONSTRAINT PK_favorite_book 
		PRIMARY KEY (favorite_id, book_id),

	CONSTRAINT FK_favorite_book_favorite
		FOREIGN KEY (favorite_id)
		REFERENCES favorite(favorite_id),

	CONSTRAINT FK_favorite_book_book
		FOREIGN KEY (book_id)
		REFERENCES book(book_id)
);

CREATE TABLE customer_order_book (
	customer_order_id  INT NOT NULL,
	book_id INT NOT NULL,
	quantity INT NOT NULL DEFAULT 1,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()

	 CONSTRAINT PK_customer_order_book 
		PRIMARY KEY (customer_order_id, book_id),

	CONSTRAINT FK_customer_order_book_customer_order
		FOREIGN KEY (customer_order_id)
		REFERENCES customer_order(customer_order_id),

	CONSTRAINT FK_customer_order_book_book
		FOREIGN KEY (book_id)
		REFERENCES book(book_id)
);

CREATE TABLE in_stock_notification_subscription (
	in_stock_notification_subscription_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	customer_id INT NOT NULL,
	book_id INT NOT NULL,
	notification_enabled BIT DEFAULT 1,
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_in_stock_notification_subscription_customer
		FOREIGN KEY (customer_id)
		REFERENCES customer(customer_id),

	CONSTRAINT FK_in_stock_notification_subscription_book
		FOREIGN KEY (book_id)
		REFERENCES book(book_id)
);

CREATE TABLE in_stock_notification_queue (
	in_stock_notification_queue_id INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	in_stock_notification_subscription_id INT NOT NULL,
	notification_status NVARCHAR(20) NOT NULL DEFAULT 'Pending',
	created_at DATETIME NOT NULL DEFAULT GETDATE(),
	updated_at DATETIME NOT NULL DEFAULT GETDATE()

	CONSTRAINT FK_in_stock_notification_queue_in_stock_notification_subscription
		FOREIGN KEY (in_stock_notification_subscription_id)
		REFERENCES in_stock_notification_subscription(in_stock_notification_subscription_id)
);