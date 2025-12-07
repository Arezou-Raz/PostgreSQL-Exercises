--Chapter 1: -- Chapter 1: Simple SQL Queries
--1) How can you retrieve all the information from the cd.facilities table?
SELECT * FROM cd.facilities;
--2)You want to print out a list of all of the facilities and their cost to members. How would you retrieve a list of only facility names and costs?
SELECT name, membercost from cd.facilities;
--3)How can you produce a list of facilities that charge a fee to members?
select * from cd.facilities where membercost > 0;
--4)How can you produce a list of facilities that charge a fee to members, and that fee is less than 1/50th of the monthly maintenance cost? Return the facid, facility name, member cost, and monthly maintenance of the facilities in question.
select facid, name, membercost, monthlymaintenance from cd.facilities where membercost > 0 AND membercost < monthlymaintenance / 50;
--5)How can you produce a list of all facilities with the word 'Tennis' in their name?
select * from cd.facilities where name like '%Tennis%';
--6)How can you retrieve the details of facilities with ID 1 and 5? Try to do it without using the OR operator.
select * from cd.facilities where facid = 1 or facid = 5; 
--7)How can you produce a list of facilities, with each labelled as 'cheap' or 'expensive' depending on if their monthly maintenance cost is more than $100? Return the name and monthly maintenance of the facilities in question.
select name, 
	case when (monthlymaintenance > 100) then
		'expensive'
	else
		'cheap'
	end as cost
	from cd.facilities;  
--8)How can you produce a list of members who joined after the start of September 2012? Return the memid, surname, firstname, and joindate of the members in questio
select memid, surname, firstname, joindate 
        from cd.members
        where joindate >= '2012-09-01';
--9)How can you produce an ordered list of the first 10 surnames in the members table? The list must not contain duplicates.
select distinct surname
        from cd.members
order by surname limit 10;
--10)You, for some reason, want a combined list of all surnames and all facility names. Yes, this is a contrived example :-). Produce that list!
select surname 
from cd.members
union 
select name
from cd.facilities
order by surname; 
--11)You'd like to get the signup date of your last member. How can you retrieve this information?
select max(joindate)
from cd.members;
--12)You'd like to get the first and last name of the last member(s) who signed up - not just the date. How can you do that?
select firstname, surname, joindate 
        from cd.members
		order by joindate desc limit 1;
--Chapeter 2: Joins and Subqueries
--1)How can you produce a list of the start times for bookings by members named 'David Farrell'?
select 
  T2.starttime 
from cd.members AS T1
INNER JOIN cd.bookings AS T2
  ON T1.memid = T2.memid
WHERE 
  T1.firstname = 'David' AND T1.surname = 'Farrell';
--2)How can you produce a list of the start times for bookings for tennis courts, for the date '2012-09-21'? Return a list of start time and facility name pairings, ordered by the time.
select T2.starttime, 
       T3.name 
  
FROM cd.bookings AS T2
INNER JOIN cd.facilities AS T3
    ON T2.facid = T3.facid
	WHERE
	    T3.name LIKE'Tennis Court%' AND CAST (T2.starttime AS date) = '2012-09-21'
	ORDER BY
	    T2.starttime;
--3)How can you output a list of all members who have recommended another member? Ensure that there are no duplicates in the list, and that results are ordered by (surname, firstname).
SELECT DISTINCT T1.firstname, T1.surname 
FROM cd.members AS T1
INNER JOIN cd.members AS T2 
ON T1.memid = T2.recommendedby
ORDER BY T1.surname, T1.firstname;
--4)How can you output a list of all members, including the individual who recommended them (if any)? Ensure that results are ordered by (surname, firstname).
SELECT 
    T1.firstname AS memfname,
    T1.surname AS memsname,
	T2.firstname AS recfname,
	T2.surname AS recsname 
From cd.members AS T1 
--5)How can you produce a list of all members who have used a tennis court? Include in your output the name of the court, and the name of the member formatted as a single column. Ensure no duplicate data, and order by the member name followed by the facility name.
SELECT DISTINCT mems.firstname || ' ' || mems.surname AS member, fct.name AS facility 
FROM cd.members mems 
INNER JOIN cd.bookings bks ON 
mems.memid = bks.memid 
INNER JOIN cd.facilities fct ON 
bks.facid = fct.facid
WHERE fct.name IN ('Tennis Court 1','Tennis Court 2')
ORDER BY member, facility;
--6)How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0. Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost, and do not use any subqueries.

    
