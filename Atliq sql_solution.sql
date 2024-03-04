use retail_events_db;

select * FROM dim_campaigns;
select * from dim_products;
select * from dim_stores;
select * from fact_events;

/*List of products with base price greater than 500 and featured in promo type of BOGOF*/
select distinct product_name, base_price, promo_type
from dim_products inner join fact_events using(product_code)
where base_price > 500 and promo_type = "BOGOF";

/*City with their store count sorted in descending order*/
select city, count(store_id) as no_of_stores
from dim_stores
group by 1
order by 2 desc;

/*List of campaign with their revenues before and after the promo*/
select campaign_name, concat(sum(base_price*`quantity_sold(before_promo)`)/1000000, " M") as revenue_before_promo,
					concat(sum(base_price*`quantity_sold(after_promo)`)/1000000," M") as revenue_after_promo
from dim_campaigns
                inner join fact_events using(campaign_id)
group by 1;

/*Calculate the ISU % for each category sold in Diwali campaign and provide rankings based the ISU%*/
with diwali as(select category,
		              ((sum(`quantity_sold(after_promo)`)/sum(`quantity_sold(before_promo)`)-1)*100) as `ISU_%`
               from fact_events 
				       inner join dim_campaigns using(campaign_id) 
                       inner join dim_products using(product_code)
			   where campaign_name= "Diwali"
			   group by 1)
select category, concat(`ISU_%`, " %") as `ISU%`, dense_rank() over(order by `ISU_%` desc) as `rank`
from diwali;

/*Top 5 product by incremental revenue percent*/
select category, product_name,
       ((sum(`quantity_sold(after_promo)`)/sum(`quantity_sold(before_promo)`))-1)*100 as `IR_%`
from fact_events
            inner join dim_products using(product_code)
group by 1,2
order by 3 desc
limit 5;