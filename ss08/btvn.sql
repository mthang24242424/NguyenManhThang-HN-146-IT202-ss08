drop database if exists btvnminiproject2;
create database btvnminiproject2;
use btvnminiproject2;

create table customers(
	customer_id int auto_increment primary key,
    customer_name varchar(100) not null,
    email varchar(100) not null unique,
    phone varchar(10) not null unique
    
)ENGINE=InnoDB;

create table categories(
	category_id int primary key auto_increment,
    category_name varchar(255) not null unique
    
)ENGINE=InnoDB;

create table products(
	product_id int auto_increment,
    product_name varchar(255) not null unique,
    price decimal(10,2) not null check(price>0),
    category_id int not null,
    primary key(product_id, category_id),
    foreign key (category_id) references categories(category_id)
    on update cascade
    on delete cascade
    
)ENGINE=InnoDB;

create table orders(
	order_id int auto_increment,
    customer_id int not null,
    order_date datetime, 
    status enum('pending', 'completed', 'cancel') default('pending'),
    primary key(order_id, customer_id),
    foreign key(customer_id) references customers(customer_id)
    on update cascade
    on delete cascade
    
)ENGINE=InnoDB;

create table order_items(
	order_item_id int auto_increment,
    order_id int not null,
    product_id int not null,
    quantity int not null check(quantity>0),
    primary key(order_item_id, order_id, product_id),
    foreign key(order_id) references orders(order_id)
    on update cascade 
    on delete cascade,
    foreign key(product_id) references products(product_id)
    on update cascade
    on delete cascade

)ENGINE=InnoDB;

insert into customers (customer_name, email, phone) values
('nguyen van an', 'an@gmail.com', '0901111111'),
('tran thi binh', 'binh@gmail.com', '0902222222'),
('le van cuong', 'cuong@gmail.com', '0903333333'),
('pham thi dung', 'dung@gmail.com', '0904444444'),
('hoang van em', 'em@gmail.com', '0905555555');

insert into categories (category_name) values
('dien thoai'),
('laptop'),
('phu kien'),
('man hinh'),
('am thanh');

insert into products (product_name, price, category_id) values
('iphone 15', 25000000.00, 1),
('laptop dell inspiron', 18000000.00, 2),
('chuot logitech', 450000.00, 3),
('man hinh 27 inch', 4200000.00, 4),
('tai nghe bluetooth', 1200000.00, 5);

insert into orders (customer_id, order_date, status) values
(1, '2026-01-01 10:00:00', 'completed'),
(2, '2026-01-02 14:20:00', 'pending'),
(3, '2026-01-03 09:15:00', 'completed'),
(1, '2026-01-04 20:10:00', 'cancel'),
(4, '2026-01-05 08:30:00', 'completed');

insert into order_items (order_id, product_id, quantity) values
(1, 1, 1),
(1, 3, 2),
(2, 5, 1),
(3, 2, 1),
(5, 4, 2);

-- Phan A
select category_id, category_name from categories;

select order_id, customer_id, order_date, status from orders where status = 'completed';

select product_id, product_name, price, category_id from products order by price desc;

select product_id, product_name, price from products order by price desc limit 5 offset 2;

-- Phan B
select p.product_id, p.product_name, p.price, c.category_name
from products p
join categories c on p.category_id = c.category_id;

select o.order_id, o.order_date, c.customer_name, o.status
from orders o
join customers c on o.customer_id = c.customer_id;

select o.order_id, sum(oi.quantity) as total_quantity
from orders o
left join order_items oi on o.order_id = oi.order_id
group by o.order_id;

select c.customer_id, c.customer_name, count(o.order_id) as total_orders
from customers c
left join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name;

select c.customer_id, c.customer_name, count(o.order_id) as total_orders
from customers c
join orders o on c.customer_id = o.customer_id
group by c.customer_id, c.customer_name
having count(o.order_id) >= 2;

select c.category_id, c.category_name, avg(p.price) as avg_price, min(p.price) as min_price, max(p.price) as max_price
from categories c
join products p on c.category_id = p.category_id
group by c.category_id, c.category_name;

-- Phan C
select product_id, product_name, price from products where price > (select avg(price) from products);

select c.customer_id, c.customer_name, c.email, c.phone
from customers c
where exists (select 1 from orders o where o.customer_id = c.customer_id);

select t.order_id, t.total_quantity
from (
  select oi.order_id, sum(oi.quantity) as total_quantity
  from order_items oi
  group by oi.order_id
) as t
where t.total_quantity = (
  select max(t2.total_quantity)
  from (select sum(quantity) as total_quantity
    from order_items
    group by order_id
  ) as t2
);

select distinct c.customer_name
from customers c
join orders o on o.customer_id = c.customer_id
join order_items oi on oi.order_id = o.order_id
join products p on p.product_id = oi.product_id
where p.category_id = (
  select t.category_id
  from (
    select category_id, avg(price) as avg_price
    from products
    group by category_id
    order by avg_price desc
    limit 1
  ) as t
);

select t.customer_id, t.customer_name, sum(t.quantity) as total_quantity_bought
from (
  select
    c.customer_id,
    c.customer_name,
    oi.quantity
  from customers c
  join orders o on o.customer_id = c.customer_id
  join order_items oi on oi.order_id = o.order_id
) as t
group by t.customer_id, t.customer_name;

select product_id, product_name, price
from products
where price = (select max(price) from products);