CREATE TABLE Players (
    name varchar(40) primary key,
    playsFor varchar(40) references Teams(name)
);

CREATE TABLE Teams (
    name varchar(40) primary key,
    captain varchar(40) references Players(name)
);

CREATE TABLE Fans (
    name varchar(40) primary key
);

CREATE TABLE FavPlayers (
    fan varchar(40) references Fans(name),
    player varchar(40) references Players(name),
    primary key(fan,player)
);

CREATE TABLE FavTeams (
    fan varchar(40) references Fans(name),
    team varchar(40) references Teams(name),
    primary key(fan,team)
);

CREATE TABLE FavColours (
    fan varchar(40) references Fans(name),
    colour varchar(40),
    primary key(fan,colour)
);

CREATE TABLE TeamColours (
    team varchar(40) references Teams(name),
    colour varchar(40),
    primary key(team,colour)
);

-- q20

CREATE DOMAIN validTFN as char(11) 
        check (value ~ "^[0-9](3)-[0-9](3)-[0-9](3)$")


create domain ValidABN as integer check (value > 100000);

CREATE DOMAIN validISBN as char(20) 
		check (value ~ '^[A-Z][0-9]{3}-[0-9]{4}-[0-9]{5}$');


CREATE TABLE Person (
    name varchar(40),
    tfn validTFN primary key,
    address text
)

CREATE TABLE Authors (
    penname text,
    person validTFN references Person(tfn),
    primary key(person)
)

CREATE TABLE Editors (
    ...
    Publisher
    person
)

CREATE TABLE Publishers (
    ...
    abn validABN primarykey
    name
    address
)

CREATE TABLE Books (
    ...
    name
    isbn
    edition
    publisher
)

CREATE TABLE Writes (
    ...
    Book
    Author 
)

-- q20 single table example

create table Person (
	tfn         validTFN,
	name        varchar(50),
	address     varchar(100),
	kind        varchar(10) check (kind in ('author','editor')),
	-- attributes for Authors
	penname     varchar(50),
	-- attributes for Editors
	publisher   ValidABN not null,
	primary key (tfn),
	foreign key (publisher) references Publisher(abn),
	constraint  NoPenNameIfEditor check
			((kind = 'author' and publisher is null) or
			 (kind = 'editor' and penname is null))
);
