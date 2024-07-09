create assertion manager_works_in_department
check ( not exists ( select * from Employees e
            join Departments d on (d.manager=e.id) where e.works_in <> d.id))

CREATE FUNCTION function() RETURNS trigger
as $$
    DECLARE
    ...
    BEGIN
    ...what happens
    END;
$$ LANGUAGE plpgsql;

create trigger trigger
BEFORE/AFTER whatever
ON tablename
EXECUTE PROCEDURE function()

DROP TRIGGER trigger ON tablename;

create function R_pk() returns trigger
as $$
BEGIN
    if (new.a is null or new.b is null) then
        raise exception 'Bad pk'
    end if;
    if (TG_OP = 'UPDATE' and old.a=new.a and old.b=new.b) then
        return;
    end if;
    --must be INSERT
    select * from R where a=new.a and b=new.b;
    if (found) then 
        raise exception 'duplicate pk';
    end if;
end;
$$ language plpgsql;

create trigger R_pk() before insert or update on R
for each row execute procedure R_pk();


insert into R (1,2,hello);

--q9
emp (
    empname
    salary
    last_date
    last_user
)

create or replace function emp_stamp() returns trigger
as $$
BEGIN
    if new.empname is null or new.salary is null then
        raise exception 'Cant have null entries';
    end if;
    -- stamp
    new.last_date:=now();
    new.last_user:=user();
    return new;
end;
$$ language plpgsql;

create trigger emp_stamp before insert or update on emp
    for each row execute procedure emp_stamp();

insert into emp values ('John', $999999);

select * from emp;

empname  | salary | last_date | last_user
____________________________________________

John     | 9999999| 09-07-2024---| Abbie


-- q10

create or replace function insert_student() returns trigger as $$
BEGIN
    update course set numStudes=numStudes+1 where code=new.course;
    retuwn new;
end;
$$ language plpgsql;

create or replace function delete_student() returns trigger as $$
BEGIN
    update course set numStudes=numStudes-1 where code=old.course;
    retuwn old;
end;
$$ language plpgsql;

create or replace function update_student() returns trigger as $$
DECLARE
    quota_f boolean;
BEGIN
    select into quota_f (numStudes >= quota)
    from course where code = new.course;
    if (quoata_f) then
        raise exception 'Class if full';
    end if;
    return new;
end;
$$ language plpgsql;

create trigger insert_student after insert on enrolment
    for each row execute insert_student();


create trigger delete_student after delete on enrolment
    for each row execute delete_student();


create trigger update_student after update on enrolment
    for each row execute update_student();


-- q11

create function new_shipment() returns trigger as $$
declare 
    custid integer;
    isbnb text;
    shipm,ent_id integer;
    time_now timestamp;
BEGIN
    select into custid from ustomers where id = new.customer;
    if not found then
        raise exception 'not a customer';
    end if;

    select into isbnb from editions where isbn=new.isbn;
    if not found then
        rais exception 'not a book';
    end if;

    if TG_OP = 'insert' then
        update Stock set numInStock = numInStock-1 where isbn=new.isbn;
    else if new.isbn <> old.isbn then
        update Stock set numInStock = numInStock-1 where isbn=new.isbn;
        update Stock set numInStock = numInStock+1 where isbn=old.isbn;
    end if;

    time_now := now()
    select into shipment_id max(id) from shipments order by id desc;
    shipment_id := shipment_id +_ 1;

    new.id := shipment_id;
    new.ship_date:=time_now;
    return new;
end;
$$ language plpgsql;

create trigger check_shipment before insert or update on SHipments for each row execute procedure new_shipment();


insert into table Shipments values (...,
....,
...)
--q12
create table Shipmants (
    id serial pimary key,
    -- default nextval('Shipments_id_seq') primary key
    customer references customers(id)
    isbn text references Editions(id),
    ship_date timestamp default now()
)


-- q13

create aggregate aggregate(basetype) (
    stype =
    nitcond =
    sfunc =
    finalfunc =
)
--q14

create aggregate mean(numeric) (
    stype = StateType,
    nitcond = '(0,0)'
    sfunc = include
    finalfunc = compute
)

create type StateType as (sum numeric, count numeric);

create fucntion include (s StateType, v nmeric) returns StateType
as $$
BEGIN
    if v is not null then
    s.sum := s.sum + v;
    s.count := s.count + 1;
    end if;
    return s;
end;
$$ language plpgsql;

create or repllace function compute (s StateType) returns numeric
as $$
BEGIN
    if s.copunt = 0 then
        return null;
    else 
        return s.sum/s.count;
    end if;
end;
$$language plpgsql;

-- q15

select sum(a)::numeric/count(a) from table;



