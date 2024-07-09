-- week 7 triggers & aggregates

-- quick recap of assertions/constraints :)

create assertion manager_works_in_department
check  ( not exists ( select * from employees e join departments d on (d.manager=e.id) where e.works_in <> d.id))

create assertion employee_manager_salary
check (not exists (select * from employees e join departments d on (d.id=e.works_in)
        join employees m on (d.manager = m.id)
        where e.salary > m.salary))

-- triggers 

--1st part
CREATE FUNCTION triggerfunction() returns trigger as $$
DECLARE
    ...
BEGIN
 stuff happens
END;
LANGUAGE plpgsql;

--2nd
create trigger triggername 
BEFORE/AFTER operation (INSERT/UPDATE/DELETE) or op2
ON tablename 
FOR EACH (ROW/STATEMENT) execute procedure triggerfunction();

DROP TRIGGER triggername on tablename;

--q6
-- if something is a primaery key
-- primary cant be duplicate
--pk cant be null

-- what we are inserting is 'new' for insert e.g. new.id
-- what we are updating or deleting is 'old' e.d. old.id

-- insert ..... new....

-- update new & old 

-- delete old

-- To reference the operation that triggers the trigger you use the variable TG_OP  ('UPDATE'|'DELETE'|'INSERT')

create function pkcheck() returns trigger
as $$
begin
    if (new.a is null or new.b is null) then
        raise exception 'Bad key'
    end if;
    if (TG_OP = 'UPDATE' and a.old=a.new and b.old=b.new) then
        return;
    end if;
    select * from R where a=new.a and b=new.b;
    if (found) then
        raise exception 'DUplicat pk'
    end if;
end;
$$ language plpgsql;

create trigger R-pk_check before insert or update on R
for each row execute procedure pkcheck();

insert into R values (1,2,hello),(1,2,goodbye);

--q9
create or replace function emp_stamp() as $$
begin
    --error checking first
    if new.empname is null or new.salary is null then
        raise exceptrion 'stop that';
    end if;
    -- salary cant be < 0 duh
    if new.salary < 0 then 
        raise exception 'poor'
    end if;

    new.last_date := now();
    new.last_user := user();
    return new;
end;
$$language plpgsql;

create trigger empstamp before insert or update on emp for each row execute procedure emp_stamp();

insert into employees valuse ('John', 999999);

select * from Employees;

    empname | salary | last_date | last_user
    ----------------------------------------
    'John'    | 99999| 08-07-24-1106-AM | Abbie


-- q10

-- number students ++ on an insert/update into enrolments

-- number students -- on a delete/update into enrolments

-- checking the quota on an insert

create or replace function insert() returns trigger as $$
begin
    update course set numStudes=numStudes+1 where code = new.course;
    return new;
end;
$$ language plpgsql;

create or replace function delete() returns trigger as $$
begin
    update course set numStudes=numStudes-1 where code = old.course;
    return new;
end;
$$ language plpgsql;

create or replace function update() returns trigger as $$
begin
    update course set numStudes=numStudes+1 where code = new.course;
    update course set numStudes=numStudes-1 where code = old.course;
    return new;
end;
$$ language plpgsql;

create or replace function quoatachk() returns trigger as $$
declare
    full boolean;
begin
    select into full (numStudes >= quota) from Courses c where code = new.course;
    if (full) then
        raise exception'get on the waitlist';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger insert_st after insert on enrolment for each row execute procedure insert();

-- same for delet
-- same for update

create trigger check_qouta before insert or update on enrolment for each row execute procedure quoatachk();


-- q11
create function new_shipment() as $$
DECLARE
    cust_id integer;
    isbn_num integer;
    shipment_id integer;
    time_now timestamp;
begin
    select into cust_id from customers where id = new.customer;
    if not found then
        raise exception 'not a customer'
    end if;
    select into isbn_num from editions where isbn=new.isbn;
    if not found then
        reaise exception 'not a book'
    end if;

    if TG_OP = 'INSERT' then
        update Stock set numInStock=numInStock-1 where isbn = new.isbn;
    else if new.isbn <> old.isbn then 
        update Stock set numInStock=numInStock-1 where isbn = new.isbn;
        update Stock set numInStock=numInStock+1 where isbn = old.isbn;
    end if;

    time_now := now();

    select intio shipment_id max(id) from shipments;
    shipment_id := shipment_id +1;
    new.id = shipment_id;
    new.ship_date := time_now;
    return new;
end; $$ language plpgsql;

create trigger check_shipment before insert or update on Shipments for each row execute procedure new_shipment();

-- q12 
create table Shipments (
    id serial  primary key,
    customer integer references Customers(id),
    isbn text references Editions(isbn),
    ship_date timestamp default now()
);

-- q13

CREATE AGGREGATE AggName(BaseType) (
    stype     = ..., -- what state were maintaining throughout ... what variables do i need to keep track of if i was doing fac ! I wouyld want to keep track of an intewger = n!
    initcond  = ..., -- 1
    sfunc     = ..., -- variable * stype 
    finalfunc = ..., -- factorial it would be nothing but in something like avg it would be divide sum/count
);


create type StateType as (sum numeric, count numeric);

init cond = (0,0)

create fucntion sfunc(s StateType, v numeric) returns StateType
as $$
begin
    if (v is not null) then
        s.sum := s.sum + v;
        s.count := s.count + 1;
    end if;
    end;
$$ language plpgsql;

create function finalfunc(s StateType) returns numeric
as $$
begin
    return s.sum / s.count;
end;
$$ language plpgsql;

create aggregate mean(numeric) (
    stype = StateType,
    initcond = (0,0),
    sfunc = sfunc,
    finalfunc = finalfunc
)

insert into table R valuse (1,2,4,3);

update table <2 becomes 3;

trigger <2 becomes 0;

-- 1st case (0,0,4,3)
--2nd case (3,3,4,3)

update table set salary = salary * 2;

salary 5000 <- old
salary 10000 <- new










