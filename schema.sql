create schema PartyRoleModel;
use PartyRoleModel;
-- 1. partyType Table
-- stores the types of parties (eg., Person, Organization)
create table PartyType( 
	PartyTypeID INT auto_increment primary key,
    TypeName varchar(50) not null unique,
    Description Text
);
Insert into PartyType (TypeName, Description) values ('Person','An individual person'),('Organization','A company or organization');
select * from PartyType;

-- 2. Party Table
-- represents the core entity (Person or Organization).
create table party(
	PartyID int auto_increment primary key,
    Name varchar(100) not null,
    PartyTypeID int not null,
    createdDate DateTime Default current_timestamp,
    foreign key (PartyTypeID) references PartyType(PartyTypeID)
);
-- insert Parties
insert into party (Name, PartyTypeID) values ('John Smit',1), ('Google',2),('Jane Smit',1);

select party.PartyID,party.Name, party.createdDate, PartyType.TypeName, PartyType.Description from party join PartyType on party.PartyTypeID = PartyType.PartyTypeID;

-- 3. RoleType Table
-- Defines valid roles that parties can play (e.g., Employee, Customer). 
Create table RoleType (
	RoleTypeID int auto_increment primary key,
    RoleName varchar(50) not null unique,
    Description text
);
-- insert into roles types 
insert into RoleType (RoleName, Description) values ('Employee','A person Employed by an organization'),
	('Employer', 'An organization that emplys people'), ('Husband', 'A male spouse'), ('Wife','A female spouse'); 
select * from roletype;

-- 4. PartyRole Table
-- Associates a party with a specific role, including temporal attributes to track when the role is active. 
create table PartyRole(
	PartyRoleID int auto_increment primary key,
    PartyID int not null,
    RoleTypeId int not null,
    StartDate datetime not null default current_timestamp,
    EndDate datetime,
    foreign key (PartyID) references party(PartyID),
    foreign key (RoleTypeID) references RoleType (RoleTypeID),
    CHECK (EndDate is null or EndDate > StartDate)
);
-- insert into party roles
insert into PartyRole (PartyID, RoleTypeID, StartDate) values (1, 1, '2023-01-01'),(1, 3, '2020-06-15'),(2, 2, '2023-01-01'),(3, 4, '2020-06-15');
select * from partyrole;   

-- 5. PartyRelationshipType Table
-- Defines valid relationship types and the roles parties can play in them (e.g., Employer-Employee). 
create table PartyrelationshipType (
	RelationshipTypeID int auto_increment primary key,
    RelationshipName varchar(50) not null unique,
    FromRoleTypeID int not null,
    ToRoleTypeID int not null,
    Description text,
    foreign key (FromRoleTypeID) references RoleType(RoleTypeID),
    foreign key (ToRoleTypeID) references RoleType(RoleTypeID)
);
-- Insert Party Relationship Types 
INSERT INTO PartyRelationshipType (RelationshipName, FromRoleTypeID, ToRoleTypeID, Description) VALUES
('Employment', 2, 1, 'Employer-Employee relationship'),
('Marriage', 4, 3, 'Wife-Husband relationship'); 
select * from partyrelationshiptype;
-- 6. PartyRelationship Table
-- Captures relationships between two parties, specifying their roles and the relationship type. 
Create table PartyRelationship(
	RelationshipID int auto_increment primary key,
    RelationshipTypeID int not null,
	FromPartyID int not null,
    ToPartyID int not null,
    StartDate datetime not null default current_timestamp,
    EndDate datetime,
    foreign key (RelationshipTypeID) references PartyrelationshipType(RelationshipTypeID),
    foreign key (FromPartyID) references Party(PartyID),
    foreign key (ToPartyID) references Party(PartyID),
    check (FromPartyID != ToPartyID),
    check (EndDate is null or EndDate > StartDate)
);
-- Insert Party Relationships
INSERT INTO PartyRelationship (RelationshipTypeID, FromPartyID, ToPartyID, StartDate) VALUES
(1, 2, 1, '2023-01-01'), 
(2, 3, 1, '2020-06-15');
select * from partyrelationship;

-- Queries
-- list all relationships for a party
SELECT prt.RelationshipName, p1.Name AS FromParty, p2.Name AS ToParty, rt1.RoleName AS FromRole, rt2.RoleName AS ToRole
FROM PartyRelationship pr
JOIN PartyRelationshipType prt ON pr.RelationshipTypeID = prt.RelationshipTypeID
JOIN Party p1 ON pr.FromPartyID = p1.PartyID
JOIN Party p2 ON pr.ToPartyID = p2.PartyID
JOIN RoleType rt1 ON prt.FromRoleTypeID = rt1.RoleTypeID
JOIN RoleType rt2 ON prt.ToRoleTypeID = rt2.RoleTypeID
WHERE p1.Name = 'Google' OR p2.Name = 'Google';

-- active relationships
SELECT prt.RelationshipName, p1.Name AS FromParty, p2.Name AS ToParty
FROM PartyRelationship pr
JOIN PartyRelationshipType prt ON pr.RelationshipTypeID = prt.RelationshipTypeID
JOIN Party p1 ON pr.FromPartyID = p1.PartyID
JOIN Party p2 ON pr.ToPartyID = p2.PartyID
WHERE pr.EndDate IS NULL OR pr.EndDate > CURRENT_TIMESTAMP;



















