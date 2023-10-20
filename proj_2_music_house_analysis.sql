-- Basic Requirements
--------------------------------------------------------------------------------------------------------
-- Which tracks appeared in the most playlists? how many playlist did they appear in?
SELECT * FROM playlist_track;
SELECT * FROM tracks;

SELECT playlist_track.TrackId AS 'Track ID', tracks.Name AS 'Track Name', count(playlist_track.PlaylistId) AS 'Count of Playlist'
FROM playlist_track
INNER JOIN tracks
	ON playlist_track.TrackId = tracks.TrackId
GROUP BY playlist_track.TrackId
ORDER BY 3 DESC;

-- Which track generated the most revenue? which album? which genre?
SELECT * FROM invoice_items;

/* Revenue per Track */
SELECT invoice_items.TrackId AS 'Track ID', tracks.Name AS 'Track Name', tracks.UnitPrice AS 'Unit Price', count(invoice_items.UnitPrice) AS 'Count of Sales per Track'
	, sum(invoice_items.UnitPrice) AS 'Revenue per Track'
FROM invoice_items
INNER JOIN tracks
	ON invoice_items.TrackId = tracks.TrackId
GROUP BY invoice_items.TrackId, tracks.Name
ORDER BY 5 DESC, 1;

/* Revenue per Album */
SELECT tracks.AlbumId AS 'Album ID', albums.Title AS "Album Title", tracks.UnitPrice AS 'Track Unit Price', count(invoice_items.UnitPrice) AS 'Number of Tracks sold per Album'
	, sum(invoice_items.UnitPrice) AS 'Revenue per Album'
FROM invoice_items
INNER JOIN tracks
	ON invoice_items.TrackId = tracks.TrackId
INNER JOIN albums
	ON tracks.AlbumId = albums.AlbumId
GROUP BY albums.Title
ORDER BY 4 DESC, 1;

/* Revenue per Album - SPOT VALIDATION of total sales of tracks sold for the album */
SELECT tracks.AlbumId AS 'Album ID', albums.Title AS "Album Title", tracks.Name, tracks.UnitPrice AS 'Track Unit Price', count(invoice_items.UnitPrice) AS 'Count of Sales per Track'
	, sum(invoice_items.UnitPrice) AS 'Revenue per Track'
FROM invoice_items
INNER JOIN tracks
	ON invoice_items.TrackId = tracks.TrackId
INNER JOIN albums
	ON tracks.AlbumId = albums.AlbumId
WHERE albums.Title = 'Minha Historia'	
GROUP BY tracks.Name
ORDER BY 5 DESC;

/* Revenue per Album - SPOT VALIDATION of total number of tracks sold for the album*/
SELECT tracks.AlbumId AS 'Album ID', albums.Title AS "Album Title", tracks.Name AS "Track Name", count(invoice_items.TrackId) AS 'Number of Tracks Sold'
FROM tracks
INNER JOIN albums
	ON albums.AlbumId = tracks.AlbumId
LEFT JOIN invoice_items
	ON albums.AlbumId = tracks.AlbumId AND invoice_items.TrackId = tracks.TrackId
WHERE albums.Title = 'Minha Historia'	
GROUP BY tracks.TrackId
ORDER BY 4 DESC;

/* Revenue per Genre */
SELECT genres.GenreId AS 'Genre ID', genres.Name AS "Genre Name", tracks.UnitPrice AS 'Track Unit Price', count(invoice_items.UnitPrice) AS 'Number of Tracks sold per Genre'
	, round(sum(invoice_items.UnitPrice), 2) AS 'Revenue per Genre'
FROM invoice_items
INNER JOIN tracks
	ON invoice_items.TrackId = tracks.TrackId
INNER JOIN genres
	ON tracks.GenreId = genres.GenreId
GROUP BY genres.Name, tracks.UnitPrice
ORDER BY 4 DESC, 1;

/* Revenue per Genre  - SPOT VALIDAATION of total sales of tracks sold for the genre */
SELECT genres.GenreId AS 'Genre ID', genres.Name AS "Genre", tracks.Name AS 'Track Name', tracks.UnitPrice AS 'Track Unit Price'
	,count(invoice_items.UnitPrice) AS 'Count of Sales per Genre', sum(invoice_items.UnitPrice) AS 'Revenue per Track'
FROM invoice_items
INNER JOIN tracks
	ON invoice_items.TrackId = tracks.TrackId
INNER JOIN genres
	ON tracks.GenreId = genres.GenreId
WHERE genres.Name = 'Rock'	
GROUP BY tracks.Name
ORDER BY 5 DESC;

/* Revenue per Genre - SPOT VALIDATION of total number of tracks sold for the genre*/
SELECT genres.GenreId AS 'Genre ID', genres.Name AS "Genre", tracks.Name AS "Track Name", count(invoice_items.TrackId) AS 'Number of Tracks Sold'
FROM tracks
INNER JOIN genres
	ON tracks.GenreId = genres.GenreId
LEFT JOIN invoice_items
	ON tracks.GenreId = genres.GenreId AND invoice_items.TrackId = tracks.TrackId
WHERE genres.Name = 'Rock'	
GROUP BY tracks.Name
ORDER BY 4 DESC;

-- Which countries have the highest sales revenue? What percent of total revenue does each country make up?
---- Which countries have the highest sales revenue?
SELECT BillingCountry, sum(Total) AS 'Total Revenue per Country'
FROM invoices
GROUP BY BillingCountry
ORDER BY 2 DESC;

---- What percent of total revenue does each country make up?
WITH TOTAL_REVENUE AS (
		SELECT sum(Total) AS all_total_revenue
		FROM invoices
	),
	COUNTRY_REVENUE AS (
		SELECT BillingCountry, sum(Total) AS country_revenue
		FROM invoices
		GROUP BY BillingCountry
	)

SELECT invoices.BillingCountry, COUNTRY_REVENUE.country_revenue AS 'Total Revenue per Country', TOTAL_REVENUE.all_total_revenue AS 'Overall Total Revenue',
		round((COUNTRY_REVENUE.country_revenue  / TOTAL_REVENUE.all_total_revenue) * 100, 2) AS 'Percent of Total Revenue'
FROM invoices
INNER JOIN COUNTRY_REVENUE ON invoices.BillingCountry = COUNTRY_REVENUE.BillingCountry
CROSS JOIN TOTAL_REVENUE
GROUP BY invoices.BillingCountry
ORDER BY 2 DESC;

-- How many customers did each employee support, what is the average revenue for each sale, and what is their total sale?
SELECT employees.EmployeeId, employees.FirstName || " " || employees.LastName AS 'Employee Name', count(DISTINCT customers.CustomerId) AS 'Count of Customers per Employee',
	round(avg(invoices.Total), 2) AS 'Average Revenue per Sale', round(sum(invoices.Total), 2) AS 'Total Sale per Employee'
FROM employees
LEFT JOIN customers ON employees.EmployeeId = customers.SupportRepId
LEFT JOIN invoices ON customers.CustomerId = invoices.CustomerId
GROUP BY 1, 2
ORDER BY EmployeeId;