<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>iMart SQL Query Interface</title>
    <style>
        .query-table {
            border-collapse: collapse;
            width: 100%;
        }
        .query-table th, .query-table td {
            border: 1px solid #ddd;
            padding: 8px;
        }
    </style>
</head>
<body>
    <h1>iMart SQL Query Interface</h1>
    <form method="post" action="SqlQueryServlet">
        <label for="query">Enter SQL Query:</label><br>
        <textarea id="query" name="query" rows="10" cols="80"></textarea><br>
        <input type="submit" value="Execute Query">
    </form>

    <h2>Query Results:</h2>
    <div>
        ${queryResult} 
    </div>
</body>
</html>
