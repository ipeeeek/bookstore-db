USE bookstore_dev;
GO

CREATE FUNCTION format_full_address (@shipping_address_id INT)
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
