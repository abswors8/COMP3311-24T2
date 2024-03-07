-- q2
update Employees
set salary = salary * 0.8
where age < 25;
-- q3
update Employees E
set E.salary = E.salary * 1.10
where eid in (select d.eid from Departments d, WorksIn w
                where d.dname = 'Sales' and d.did = w.did)

-- q4
create table Departments (
      did     integer,
      dname   text,
      budget  real,
      manager integer not null references Employees(eid),
      primary key (did)
);

-- q5
create table Employees (
      eid     integer,
      ename   text,
      age     integer,
      salary  real check (salary >= 15000),
      primary key (eid)
);

--q6
create table WorksIn (
      eid     integer references Employees(eid),
      did     integer references Departments(did),
      percent real,
      primary key (eid,did)
      constraint FullTimeCheck
        check (1 >= (select sum(w.percent) from WorksInw where w.eid = eid))
);

--q7
create table Departments (
      did     integer,
      dname   text,
      budget  real,
      manager integer not null references Employees(eid),
      primary key (did)
      constraint FullTimeManager
        check (1.0 = (select sum(w.percent) from WorksIn w where w.eid = manager))
);

--q8
create table WorksIn (
      eid     integer references Employees(eid) on delete cascade,
      did     integer references Departments(did),
      percent real,
      primary key (eid,did)
);

-- q9 
create table Departments (
      did     integer,
      dname   text,
      budget  real,
      manager integer references Employees(eid),
      primary key (did)
);

-- q10
create table WorksIn (
      eid     integer references Employees(eid) on delete cascade,
      did     integer references Departments(did) on delete set default,
      percent real,
      primary key (eid,did)
);

--q12
select sname from Suppliers 
natural join Catalog 
natural join Parts
where colour = 'red';

select s.sname from suppliers s, parts p, catalog c
where p.colour = 'red' and c.pid = p.pid and c.sid = s.sid;

--q13
select c.sid from parts p join catalog c on c.pid=p.pid where p.colour='red' or p.colour='green';

--q14
select s.sid from suppliers s where s.address = '221 Packer St' or
s.sid in (select s.sid from Suppliers 
natural join Catalog 
natural join Parts
where colour = 'red')

-- q15
(select sname from Suppliers 
natural join Catalog 
natural join Parts
where colour = 'red')
intersect
(select sname from Suppliers 
natural join Catalog 
natural join Parts
where colour = 'green');

--q16
select s.sid from suppliers s where 
not exists ((select p.pid from parts p)
except
(select c.pid from catalog c where c.sid = s.sid))

--q17
select s.sid from suppliers s where 
not exists ((select p.pid from parts p where p.colour ='red')
except
(select c.pid from catalog c join parts p where c.sid = s.sid and p.colour = 'red')

select c.sid from catalog c 
where not exists (select p.pid from parts p where p.colour='red' and
not exists (select c1.sid from catalog c1 where c1.sid=c.sid and c1.pid=p.pid));

--q21
select c.pid from catalog c 
    where exists (select c1.sid 
    from catalog c1 where c1.pid=c.pid 
    and c1.sid != c.sid)

select count(c.sid) from catalog c group by c.pid

--q22
select c.pid from catalog c, suppliers s
where s.sname = 'Yosemite Sham' and c.sid=s.sid and
c.cost >= all(select c1.cost from catalog c1, suppliers s1 where s1.name = 'Yosemite Sham' and c1.sid=s1.sid);
c.cost = max(select ....)

--q23
select c.pid from catalog c
where c.price < 200
group by c.pid
having count(*) = (select count(*) from Suppliers);
