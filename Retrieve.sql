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
SELECT
 
  CASE
    WHEN bks.memid = 0 THEN 'GUEST GUEST'
    ELSE mems.firstname || ' ' || mems.surname
  END AS member,
  fct.name AS facility,
  CASE
    WHEN bks.memid = 0 THEN bks.slots * fct.guestcost
    ELSE bks.slots * fct.membercost
  END AS cost
FROM cd.bookings bks
JOIN cd.facilities fct ON bks.facid = fct.facid
-- Use LEFT JOIN to ensure bookings with memid=0 are included
LEFT JOIN cd.members mems ON bks.memid = mems.memid
WHERE
  bks.starttime >= '2012-09-14' AND bks.starttime < '2012-09-15'
  AND (
    (bks.memid = 0 AND bks.slots * fct.guestcost > 30) OR
    (bks.memid != 0 AND bks.slots * fct.membercost > 30)
  )
ORDER BY cost DESC;
--7)How can you output a list of all members, including the individual who recommended them (if any), without using any joins? Ensure that there are no duplicates in the list, and that each firstname + surname pairing is formatted as a column and ordered.
SELECT DISTINCT mems.firstname || ' ' ||  mems.surname as member,
	
	(
	SELECT recs.firstname || ' ' || recs.surname as recommender 
		
	 FROM cd.members recs 
		WHERE recs.memid = mems.recommendedby
	)
	FROM 
		cd.members mems

ORDER BY member; 
--8)The Produce a list of costly bookings exercise contained some messy logic: we had to calculate the booking cost in both the WHERE clause and the CASE statement.
--Try to simplify this calculation using subqueries. For reference, the question was:
--How can you produce a list of bookings on the day of 2012-09-14 which will cost the member (or guest) more than $30? 
--Remember that guests have different costs to members (the listed costs are per half-hour 'slot'), and the guest user is always ID 0.
--Include in your output the name of the facility, the name of the member formatted as a single column, and the cost. Order by descending cost.
SELECT member, facility, cost FROM (
	SELECT 
		mems.firstname || ' ' || mems.surname AS member,
		facs.name AS facility,
		CASE
			WHEN mems.memid = 0 then
				bks.slots*facs.guestcost
			ELSE
				bks.slots*facs.membercost
		END AS cost
		FROM
			cd.members mems
			INNER JOIN cd.bookings bks
				ON mems.memid = bks.memid
			INNER JOIN cd.facilities facs
				ON bks.facid = facs.facid
		WHERE
			bks.starttime >= '2012-09-14'AND bks.starttime < '2012-09-15'
	) AS bookings
	WHERE cost > 30
ORDER BY cost desc; 
--Chapter 3: Modifying data
--1)The club is adding a new facility - a spa. We need to add it into the facilities table. Use the following values:
--facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
INSERT INTO cd.facilities
(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
VALUES
(9, 'Spa', 20, 30, 100000, 800);
--OR
INSERT INTO cd.facilities VALUES (9, 'Spa', 20, 30, 100000, 800);
--2)In the previous exercise, you learned how to add a facility.
--Now you're going to add multiple facilities in one command. Use the following values:
--facid: 9, Name: 'Spa', membercost: 20, guestcost: 30, initialoutlay: 100000, monthlymaintenance: 800.
--facid: 10, Name: 'Squash Court 2', membercost: 3.5, guestcost: 17.5, initialoutlay: 5000, monthlymaintenance: 80.
INSERT INTO cd.facilities
VALUES
(9, 'Spa', 20, 30, 100000, 800),
(10, 'Squash Court 2', 3.5, 17.5, 5000, 80);
--3)Let's try adding the spa to the facilities table again.
--This time, though, we want to automatically generate the value for the next facid, rather than specifying it as a constant.
--Use the following values for everything else: 
INSERT INTO cd.facilities
(facid, name, membercost, guestcost, initialoutlay, monthlymaintenance)
SELECT 
    MAX(facid) + 1, 'Spa', 20, 30, 100000, 800
FROM 
    cd.facilities;
--4)We made a mistake when entering the data for the second tennis court. The initial outlay was 10000 rather than 8000:
--you need to alter the data to fix the error.
UPDATE cd.facilities
SET initialoutlay = 10000
WHERE facid = 1;
--5)We want to increase the price of the tennis courts for both members and guests. Update the costs to be 6 for members, and 30 for guests.
--The Tennis Courts 1 AND 2 correspond to facid 0 and facid 1 (0,1) IS OUR RANGE. 
UPDATE cd.facilities
    SET
	   membercost = 6,
	   guestcost = 30
	WHERE facid IN (0,1);   
--6)We want to alter the price of the second tennis court so that it costs 10% more than the first one.
--Try to do this without using constant values for the prices, so that we can reuse the statement if we want to.
UPDATE cd.facilities
 SET 
     membercost = (SELECT membercost * 1.1 FROM cd.facilities WHERE facid = 0),
     guestcost = (SELECT guestcost * 1.1 FROM cd.facilities WHERE facid = 0)
WHERE facid = 1;
--7)As part of a clearout of our database, we want to delete all bookings from the cd.bookings table. 
TUNCATE cd.bookings
--OR
DELETE FROM cd.bookings;
--8)We want to remove member 37, who has never made a booking, from our database. 
DELETE FROM cd.members WHERE memid = 37;
--9)In our previous exercises, we deleted a specific member who had never made a booking. now delete all members who have never made a booking.
DELETE FROM cd.members
--10)In our previous exercises, we deleted a specific member who had never made a booking.
How can we make that more general, to delete all members who have never made a booking?
DELETE FROM cd.members 
WHERE memid NOT IN (SELECT memid FROM cd.bookings);
--CHAPTER 4: Aggregation 
--1)For our first foray into aggregates, we're going to stick to something simple.
--how many facilities exist - produce a total count.
SELECT COUNT(*) FROM cd.facilities;
--2)Produce a count of the number of facilities that have a cost to guests of 10 or more.
SELECT COUNT(*) FROM cd.facilities
WHERE guestcost >= 10;
--3)Produce a count of the number of recommendations each member has made. Order by member ID.
SELECT recommendedby, COUNT(*) FROM cd.members
WHERE recommendedby IS NOT NULL
GROUP BY recommendedby
ORDER BY recommendedby;
--4)Produce a list of the total number of slots booked per facility. 
--produce an output table consisting of facility id and slots, sorted by facility id.
SELECT facid, SUM(slots) AS "Total slots" FROM cd.bookings
GROUP BY facid
ORDER BY facid;
--5)Produce a list of the total number of slots booked per facility in the month of September 2012. 
--Produce an output table consisting of facility id and slots, sorted by the number of slots.
SELECT facid, SUM(slots) AS "Total Slots" FROM cd.bookings
WHERE starttime >= '2012-09-01' AND  starttime < '2012-10-1'
GROUP BY facid
ORDER BY SUM(slots);
--6)Produce a list of the total number of slots booked per facility per month in the year of 2012. 
--Produce an output table consisting of facility id and slots, sorted by the id and month.
--Using  EXTRACT allows you to get individual components of a timestamp, like day, month, year, etc.group by the output of this function	
SELECT facid, EXTRACT (month from starttime) AS month, SUM(slots) AS "Total Slots" FROM cd.bookings
WHERE EXTRACT (year from starttime) = 2012
GROUP BY facid, month
ORDER BY facid, month;
--7)Find the total number of members (including guests) who have made at least one booking.
SELECT COUNT(DISTINCT memid) FROM cd.bookings
WHERE slots >= 1;
--8)Produce a list of facilities > 1000 slots booked. Output table consisting of facility id and slots, sorted by facility id.
SELECT facid, SUM(slots) AS "Total Slots" FROM cd.bookings
GROUP BY facid
HAVING SUM(slots) > 1000
ORDER BY facid;
--SUM(SLOTS)you'll get one big number—the total revenue for all products combined.
--GROUP BY facid YOU TELL THE SQL TO GROUP  product A into one group, all for Product B into another group, and so onare in A otherwise just SUM(SLOTS) GIVES THE BIG NUMBER  
--Then the HAVING clause runs after the SUM(slots) AND keeping only those that exceed 1000

--9)Produce a list of facilities along with their total revenue.
--The output table should consist of facility name and revenue, sorted by revenue.There's a different cost for guests and members!
SELECT fct.name, SUM(slots * CASE
		   WHEN memid = 0 THEN fct.guestcost
		   ELSE fct.membercost
	       END) AS revenue
       FROM cd.bookings bks
       INNER JOIN cd.facilities fct ON
	   bks.facid = fct.facid

GROUP BY fct.name
ORDER BY revenue;
--10)Produce a list of facilities with a total revenue < than 1000. Output table  = facility name and revenue, sorted by revenue.
--There's a different cost for guests and members.
--filtering the calculated revenue by using HAVING Clause
SELECT fct.name, SUM(slots * CASE
		   WHEN memid = 0 THEN fct.guestcost
		   ELSE fct.membercost
	       END) AS revenue
		   
		   FROM cd.bookings bks
		   INNER JOIN cd.facilities fct ON
		   bks.facid = fct.facid
		   GROUP BY fct.name
		   HAVING SUM(slots * CASE
		   WHEN memid = 0 THEN fct.guestcost
		   ELSE fct.membercost
		   END) < 1000
		   ORDER BY revenue;
--11)Output the facility id that has the highest number of slots booked. 
--For bonus points, try a version without a LIMIT clause. This version will probably look messy!
SELECT facid, SUM(slots) AS "Total Slots" FROM cd.bookings
GROUP BY facid
ORDER BY SUM(slots) DESC LIMIT 1;
--12)List of the total number of slots booked per facility per month in the year of 2012. 
--Include output rows containing totals for all months per facility, and a total for all months for all facilities.
--The output table should shows facility id, month and slots, sorted by the id and month. 
--When calculating  return null values in the month and facid columns.
SELECT facid, EXTRACT(month from starttime) AS month, SUM(slots) AS slots FROM cd.bookings
WHERE (starttime >= '2012-01-01' AND starttime < '2013-01-01')
GROUP BY ROLLUP(facid,month)
ORDER BY facid, month; 
--ROLLUP generates aggregate rows by following a strict hierarchy, from the most detailed grouping down to the overall total.
--14) total number of hours booked per facility, remembering that a slot lasts half an hour.
--The output table should consist of the facility id, name, and hours booked, sorted by facility id. Try formatting the hours to two decimal places.
SELECT bks.facid, fct.name, ROUND(SUM(bks.slots)/2.0, 2) AS "Total Hours" FROM cd.bookings bks
INNER JOIN cd.facilities fct ON
bks.facid = fct.facid
GROUP BY bks.facid, fct.name
ORDER BY bks.facid;
--15)Produce a list of each member name, id, and their first booking after September 1st 2012. Order by member ID.
SELECT mem.surname, mem.firstname, mem.memid, MIN(starttime) FROM cd.members mem
INNER JOIN cd.bookings bks ON
mem.memid = bks.memid
WHERE starttime > '2012-09-01'
GROUP BY mem.surname, mem.firstname, mem.memid
ORDER BY mem.memid;
--16)Produce a list of member names, with each row containing the total member count. Order by join date, and include guest members.
SELECT (SELECT COUNT(*) FROM cd.members), firstname, surname FROM cd.members mems
GROUP BY mems.firstname, mems.surname, mems.joindate
ORDER BY joindate;
--17)Produce a monotonically increasing numbered list of members (including guests)
-- ordered by their date of joining. Remember that member IDs are not guaranteed to be sequential.
--OVER()display individual records (like a member's name) AND a total statistic for the whole group
--If you want both the detail and the big picture calculation in the same row, use OVER()!
SELECT row_number() OVER (ORDER BY joindate), firstname, surname
FROM cd.members ORDER BY joindate;
--OR
SELECT COUNT(*) OVER (ORDER BY joindate) AS row_number, firstname, surname FROM cd.members;
--17.Output the facility id that has the highest number of slots booked.
--Ensure that in the event of a tie, all tieing results get output.
