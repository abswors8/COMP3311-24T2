create or replace function sqr(n numeric) returns integer as $$
begin
    return n*n;
end;
$$ language plpgsql;

--q2
create or replace function spread(n text) returns text as $$
declare
    RESULT TEXT := '';
    i integer;
begin
    i := 1;
    for i in 1..length($1) loop
        result := result || substr(n,i,1) || ' ';
    end loop;
    return result;
end;
$$ language plpgsql;
--q3
create or replace function seq(lo int, hi int, inc int) returns setof integer
as $$
declare 
    i integer;
begin
    i := lo;
    if (inc > 0) then
        while (i <= hi)
        loop
            return next i;
            i := i + inc;
        end loop;
    elsif (inc < 0) then
        while (i >= hi)
        loop
            return next i;
            i := i + inc;
        end loop;
    end if;
    return;
end;
$$ language plpgsql;

--q6
create or replace function fac(n int) returns integer as $$
select count(*) from beers;
--select product(seq) from seq(1,n,1);
$$ language sql;

-- q7
create or replace function hotelsIn(_addr text) returns text
as $$
declare
    r record;
    result text := '';
begin
    for r in select * from bars where addr = _addr
    loop
        result := result || r.name || e'\n';
    end loop;
    return result;
end
$$ language plpgsql;

--q10
create or replace function hotelsIn2(text) returns setof Bars
as $$
    select * from Bars where addr = $1;
$$ language sql;

-- -- q11
create or replace function hotelsIn3(_addr text) returns setof Bars
as $$
declare
    r record;
begin
    for r in select * from Bars where addr = _addr
    loop
        return next r;
    end loop;
    return;
end;
$$ language plpgsql;
--q9
create or replace function happyHourPrice(_hotel text, _beer text, _discount numeric) returns text
as $$
declare
    hcount integer;
    bcount integer;
    old_price real;
    new_price real;
begin
    select count(*) into hcount from Bars where name = _hotel;
    if (hcount = 0) then
        return 'There is no hotel called ' || _hotel || e'\n';
    end if;
    select count(*) into bcount from Beers where name = _beer;
    if (bcount = 0) then
        return 'There is no beer called ' || _beer || e'\n';
    end if;
    select price into old_price from Sells s where s.beer = _beer and s.bar = _hotel;
    if (not found) then
        return 'The ' || _hotel || ' does not serve ' || _beer;
    end if;
    new_price := old_price - _discount;
    if (new_price < 0) then
        return 'Price reduction is too large ' || _beer || ' only costs ' || to_char(old_price, '$99.99');
    else 
        return 'Happy hour price for ' || _beer || ' at ' || _hotel || ' is ' || to_char(new_price, '$99.99');
    end if;
end;
$$ language plpgsql;
