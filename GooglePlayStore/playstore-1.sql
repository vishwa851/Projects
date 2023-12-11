create DATABASE playstore;

use playstore;

set sql_safe_updates = 0;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
SET GLOBAL opt_local_infile = true;

drop TABLe stats;
create table stats (
      app nvarchar(230),
      category nvarchar(230),
      rating double,
      reviews bigint,
      size nvarchar(230),
      installs nvarchar(230),
      type char(40),
      price bigint,
      content_rating nvarchar(230),
      genres nvarchar(230),
      last_update date,
      current_ver nvarchar(230),
      android_ver nvarchar(230)
      );
      
LOAD DATA local INFILE 'C:\\googleplaystore.csv' INTO TABLE stats
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

create table reviews (
          app nvarchar(230),
          review nvarchar(1000),
          sentiment nvarchar(100),
          polarity double,
          subjectivity double
          );
          
LOAD DATA local INFILE 'C:\\googleplaystore_user_reviews.csv' INTO TABLE reviews
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

select * from stats where app = 'null'
or category = 'null'
or rating = 'null'
or reviews = 'null'
or size = 'null'
or installs = 'null'
or type = 'null'
or price = 'null'
or content_rating = 'null'
or genres = 'null'
or current_ver = 'null'
or android_ver = 'null';

DELETE from stats where type = '0' or type ='null';

with temp(Sno) as (
select row_number() over(partition by app) from stats
)
delete from temp where Sno >1;

-- total unique apps and categories 

select count(distinct app) as 'Toatal Apps', count(distinct category) Categories from stats;

-- Number of apps in each category

select distinct category, count(distinct app) total_apps from stats 
group by category
order by 2 desc;

-- Top 5 and its percentage share in market

call temp();

-- CREATE DEFINER=`root`@`localhost` PROCEDURE `temp`()
-- BEGIN
-- declare total bigint;
-- declare apps bigint;

-- select count(distinct app) into total from stats;

-- select distinct category, count(distinct app), (count(distinct app)/total)*100 as percentage_share from stats group by category order by 3 desc limit 5;
-- END 


-- number of free apps vs paid apps

select type, count(distinct app) from stats group by type;

-- Top rated free apps (rating>=4.5)

select row_number() over () as Sno, app, category, rating, reviews from stats 
where rating >=4.5 and type = 'free' 
order by 4 desc;

-- most reviewd app

select distinct app, category, rating, sum(reviews) as reviews from stats 
group by app,category,rating 
order by 4 desc
limit 10;

-- apps with more than 10M downloads

select distinct app, category,installs from stats 
where cast(replace(substring(installs,1,locate('+',installs)-1),',','') as unsigned) >= 100000000 
order by 1 asc;

--  Average rating per category

select category, round(Avg(rating),1) as avg_rating from stats 
group by category 
order by 2 desc;

-- Top categories based on downloads

select category, sum(cast(replace(substring(installs,1,locate('+',installs)-1),',','')as unsigned)) as Total_downloads
from stats 
group by category 
order by 2 desc 
limit 10;

-- avg sentiment polarity per category

select category, round(avg(polarity),5) as avg_polarity from stats s 
join reviews r 
on s.app=r.app 
group by 1 
order by 2 desc; 

-- sentiment reviews by category

select  category, sentiment, count(*) as total_count from stats s 
join reviews r
on s.app=r.app
where sentiment <> 'nan'
group by category,sentiment 
order by 1,2,3;