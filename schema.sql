-- Branch: CORENROLL-15

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
insert into party (Name, PartyTypeID) values ('Umesh',1), ('cts Insurance', 2); 
update party set Name='ABC Insurance' where PartyTypeID=2;
select * from party;
select party.PartyID,party.Name, party.createdDate, PartyType.TypeName, PartyType.Description from party join PartyType on party.PartyTypeID = PartyType.PartyTypeID;

-- 3. RoleType Table
-- Defines valid roles that parties can play (e.g., Employee, Customer). 
Create table RoleType (
	RoleTypeID int auto_increment primary key,
    RoleName varchar(50) not null unique,
    Description text
);
-- insert into roles types 
INSERT INTO RoleType (RoleName, Description)
VALUES ('Policyholder', 'Owner of the policy'), ('Insured', 'Person covered by the policy'), ('Beneficiary', 'Receives benefits in case of claim'), ('Agent', 'Sells or manages policy');
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
INSERT INTO PartyRole (PartyID, RoleTypeID) VALUES (1, 1);
INSERT INTO PartyRole (PartyID, RoleTypeID) VALUES (2, 4);
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
truncate Partyrelationshiptype;
INSERT INTO PartyRelationshipType (RelationshipName, FromRoleTypeID, ToRoleTypeID, Description)
VALUES ('Agent-Manages-Policyholder', 4, 1, 'Agent manages a Policyholder');
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
INSERT INTO PartyRelationship (RelationshipTypeID, FromPartyID, ToPartyID)
VALUES (1, 2, 1);

select * from partyrelationship;

CREATE TABLE Policy (
    PolicyID INT AUTO_INCREMENT PRIMARY KEY,
    PolicyNumber VARCHAR(50) UNIQUE NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME,
    Status VARCHAR(30) DEFAULT 'Active',
    CreatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO Policy (PolicyNumber, StartDate, EndDate, Status)
VALUES ('POL123456', '2025-01-01', '2026-01-01', 'Active');
CREATE TABLE Plan (
    PlanID INT AUTO_INCREMENT PRIMARY KEY,
    PlanName VARCHAR(100) NOT NULL,
    Description TEXT,
    BaseCoverageAmount DECIMAL(12,2),
    BasePremiumAmount DECIMAL(12,2)
);
INSERT INTO Plan (PlanName, Description, BaseCoverageAmount, BasePremiumAmount)
VALUES ('Health Basic', 'Basic health coverage plan', 500000.00, 5000.00);

CREATE TABLE PolicyPlan (
    PolicyPlanID INT AUTO_INCREMENT PRIMARY KEY,
    PolicyID INT NOT NULL,
    PlanID INT NOT NULL,
    CoverageAmount DECIMAL(12,2), -- optional override
    PremiumAmount DECIMAL(12,2),  -- optional override
    FOREIGN KEY (PolicyID) REFERENCES Policy(PolicyID),
    FOREIGN KEY (PlanID) REFERENCES Plan(PlanID),
    UNIQUE (PolicyID, PlanID) -- prevent duplicates
);
INSERT INTO PolicyPlan (PolicyID, PlanID, CoverageAmount, PremiumAmount)
VALUES (1, 1, 600000.00, 5500.00);
SET FOREIGN_KEY_CHECKS = 1;

create table PolicyPartyRole (
    PolicyPartyRoleID int auto_increment primary key,
    PolicyID int not null,
    PartyRoleID int not null,
    RoleTypeID int not null, 
    StartDate datetime not null default current_timestamp,
    EndDate datetime,
    foreign key (PolicyID) references Policy(PolicyID),
    foreign key (PartyRoleID) references PartyRole(PartyRoleID),
    foreign key (RoleTypeID) references RoleType(RoleTypeID),
    unique (PolicyID, PartyRoleID, RoleTypeID),
    check (EndDate is null or EndDate > StartDate)
);
INSERT INTO PolicyPartyRole (PolicyID, PartyRoleID, RoleTypeID)
VALUES (1, 1, 1);
INSERT INTO PolicyPartyRole (PolicyID, PartyRoleID, RoleTypeID)
VALUES (1, 2, 4);
create table Person (
    PartyID int primary key,
    DateOfBirth date,
    Gender varchar(10),
    Phone varchar(20),
    Email varchar(100),
    foreign key (PartyID) references Party(PartyID)
);
INSERT INTO Person (PartyID, DateOfBirth, Gender, Phone, Email)
VALUES (1, '1985-03-20', 'Male', '9800000000', 'john@example.com');
create table Organization (
    PartyID int primary key,
    RegistrationNumber varchar(50),
    Address text,
    foreign key (PartyID) references Party(PartyID)
);
INSERT INTO Organization (PartyID, RegistrationNumber, Address)
VALUES (2, 'REG-12345', 'Kathmandu, Nepal');

