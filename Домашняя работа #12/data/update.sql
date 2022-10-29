CREATE OR REPLACE FUNCTION action_on_update()
RETURNS trigger
AS $$
DECLARE
	p_old_sales_id 		integer;
	p_old_good_id 		integer;
	p_old_sales_qty 	integer;
	
	p_new_sales_id 		integer;
	p_new_good_id 		integer;
	p_new_sales_qty 	integer;
	
	v_good_name 	varchar(63);
	v_good_price 	numeric(12, 2);
	v_sum 			numeric(12, 2);
BEGIN
	p_old_sales_id 		= 	OLD.sales_id;
	p_old_good_id 		= 	OLD.good_id;
	p_old_sales_qty 	= 	OLD.sales_qty;	
	
	p_new_sales_id 		= 	NEW.sales_id;
	p_new_good_id 		= 	NEW.good_id;
	p_new_sales_qty 	= 	NEW.sales_qty;
	
	select good_name, good_price into v_good_name, v_good_price 
		from goods
	where goods_id = p_old_good_id;
	
	v_sum = v_good_price * p_old_sales_qty;
	
	if v_sum < (
		select sum_sale 
			from good_sum_mart
		where good_name = v_good_name)
	then 
		update good_sum_mart 
			set sum_sale = sum_sale - v_sum
		where good_name = v_good_name;
	else 
		delete from good_sum_mart
			where good_name = v_good_name;
	end if;
	
	select good_name, good_price into v_good_name, v_good_price 
		from goods
	where goods_id = p_new_good_id;
	 
	v_sum = v_good_price * p_new_sales_qty;
	
	if exists (
		select 1 
			from good_sum_mart
		where good_name = v_good_name)
	then 
		update good_sum_mart 
			set sum_sale = sum_sale + v_sum
		where good_name = v_good_name;
	else 
		insert into good_sum_mart(good_name, sum_sale)
			values (v_good_name, v_sum);
	end if;

	RETURN NEW;
END;
$$
  LANGUAGE plpgsql
  VOLATILE
  SET search_path = pract_functions, public
  COST 100;
  
  
CREATE TRIGGER trigger_update_sales
AFTER UPDATE
ON sales
FOR EACH ROW
EXECUTE PROCEDURE action_on_update();