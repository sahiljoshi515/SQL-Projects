/*
CS197Q Project assignment
Use the Chinook database for this assignment. 

Be sure to read the README file and refer to the Chinook ERD diagram for this project assignment.

Write the following SQL statements. Each question requires a single SQL statement.
Note that unless the question states otherwise, you may use unique IDs for records. For example,
if you are given a customer's name, you may execute a query to look up the unique identifier for 
that customer (CustomerId) and use that number in your final query. Some questions may specifically
state that you must use subqueries instead of numbers, so you would use the subquewry instead of the number in that case.

Remember to delete all SQL code that is not your final answer to the questions below.
*/
/* 1. Write a query that lists all customers supported by employee Jane Peacock (SuportRepId).
      The query returns only the customer's first and last names, email, and country, in aplphabetical
	  order by last name.
*/

SELECT FIRSTNAME, LASTNAME, EMAIL, COUNTRY 
FROM CUSTOMER WHERE SUPPORTREPID = 3
ORDER BY LASTNAME;




/* 2. Write a query that reports only the track names for all tracks that feature the artist Miles Davis,
     sorted in alphabetical order. Note that a composer is NOT the same as an artist (see the Chinook ERD).
	 You should have 37 rows in your result set. 
*/

SELECT NAME FROM TRACK NATURAL JOIN ALBUM WHERE ARTISTID = 68
ORDER BY NAME;




/* 3. Write a query that displays the customer id, first and last names, and the count of the number
      of invoices generated by each customer. Use the alias 'NumInvoices' for the count. Order the 
	  results with the smallest number of invoices first to largest last.
	  You should have 59 rows in your result set.
*/

SELECT CustomerId, FirstName, LastName, COUNT (InvoiceId) AS NumInvoices 
FROM CUSTOMER NATURAL JOIN Invoice 
GROUP BY CustomerId
ORDER BY NUMINVOICES;





/* 4. Write a query that displays the first and last name, email, and name of the track for all tracks 
      that have been ordered by the customer Isabelle Mercier. Note that a customer has ordered one or more tracks when 
	  they have generated an invoice. The results are sorted by the track name in alphabetical order.
	  You should have 38 rows in your result set.
*/

SELECT FirstName, LastName, Email, Name FROM CUSTOMER 
NATURAL JOIN INVOICE NATURAL JOIN InvoiceLine NATURAL JOIN TRACK
WHERE CustomerId = 43
ORDER BY NAME;





/* 5. Write a query that lists the distinct genres for all of the tracks ordered by Isabelle Mercier.
      The result set contains only the genre name, in alphabetical order.
	  You should have 9 rows in your result set.
*/


SELECT DISTINCT GENRE.NAME FROM GENRE join track using (GenreId)
natural join invoiceline natural join invoice where CustomerId = 43
ORDER BY genre.NAME;




/* 6. Write a query that lists all of the playlists that contain tracks that Isabelle Mercier has ordered. 
      The result set includes only the playlist id and playlist name, and no playlist is repeated (all distinct by ID).
	  You should have 8 rows in your result set.
*/

SELECT DISTINCT Playlist.PlaylistID, Playlist.NAME FROM Playlist
NATURAL JOIN PlaylistTrack JOIN InvoiceLine USING (TRACKID)  JOIN Invoice USING (INVOICEID)
WHERE CustomerId = 43
GROUP BY PlaylistId;



/* 7. Write a query that returns the invoices that contain tracks ordered by Isabelle Mercier that appear on 
      the "90's Music" playlist. The result set shows only the columns InvoiceId, InvoiceDate, and Total, ordered 
	  by the most recent date to the oldest date (for example, 2010-01-22 would come before 2009-01-22).
	  You should have 3 rows in your result set. The Total of the first row would be 16.86.
*/

SELECT INVOICE.InvoiceId, INVOICE.InvoiceDate, INVOICE.TOTAL FROM Invoice
JOIN InvoiceLine USING (InvoiceId) JOIN PlaylistTrack USING (TRACKID) JOIN Playlist USING (PlaylistId)
WHERE Invoice.CUSTOMERID =43 AND PLAYLIST.PlaylistId = 5
GROUP BY InvoiceId
ORDER BY InvoiceDate DESC;




/* 8. Write a statement that creates a new invoice for Isabelle Mercier. Use the current date/time (use the date function)
      and an initial total of 0.00. (You may look up a previous insert statement for this customer in the 
	  sql file that populated the Chinook database originally if you want to copy the rest of the data such as address, etc.)
      Since there is no autoincrement on the primary key, use 1 + the current max value for that column in the table
	  (execute a query to find this value).
	  Remember to delete all SQL code that is not your final answer to the questions below.
*/

INSERT INTO Invoice
VALUES (413, 43, date('now'), (SELECT Address FROM CUSTOMER WHERE FirstName = 'Isabelle' and LastName = 'Mercier'),
 (SELECT City FROM CUSTOMER WHERE FirstName = 'Isabelle' and LastName = 'Mercier'), NULL, (SELECT Country FROM CUSTOMER WHERE FirstName = 'Isabelle' and LastName = 'Mercier'),
 (SELECT PostalCode FROM CUSTOMER WHERE FirstName = 'Isabelle' and LastName = 'Mercier'), 0.00);



/* 9. Write a statement that adds the track Plaster Caster by Gene Simmons to Isabelle Mercier's new invoice. 
      Make sure you use the track from the "Greatest Kiss" album. Quantity is 2 (she loves Gene). You will need 
	  to do some querying to find the correct values to enter. Since there is no autoincrement on the primary key, 
	  use 1 + the current max value for the invoice line id in the table.
	  Remember to delete all SQL code that is not your final answer to the questions below.
*/

INSERT INTO InvoiceLine 
VALUES (2241, 413, (SELECT TrackId FROM Track where Name = 'Plaster Caster' And AlbumId = 37), (SELECT UnitPrice FROM Track where Name = 'Plaster Caster' And AlbumId = 37), 2)



/* 10. Write a statement that updates the total for Isabelle Mercier's new invoice created in question 8. The new total is the 
       current invoice total plus the line total of the line you added in the statement in question 9. You must use a subquery 
	   to get the current invoice total from the invoice and a subquery to get the line total from the line you added above.
	   The line total is UnitPrice * Quantity from the invoice line. 
	   So, updated invoice total = (subquery to get current invoice total) + (subquery to get invoice line total)
	   Do not not type in any numbers numbers in your statement except for the InvoiceId and InvoiceLineId. 
*/

UPDATE INVOICE 
SET TOTAL = (SELECT TOTAL FROM INVOICE WHERE InvoiceId = 413) + (SELECT (UnitPrice * Quantity) FROM InvoiceLine WHERE InvoiceLineId = 2241)
WHERE INVOICEID = 413;

