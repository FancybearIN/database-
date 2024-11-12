<!DOCTYPE html>
<html>
<head>
    <title>SQL Query Interface</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .query-form { margin: 20px; }
        .query-table { margin: 20px; border-collapse: collapse; width: 100%; }
        .query-table th, .query-table td { padding: 10px; border: 1px solid #ddd; text-align: left; }
        .query-table th { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2>SQL Query Interface</h2>
    <form action="SqlQueryServlet" method="POST" class="query-form">
        <label for="query">Enter SQL Query:</label><br>
        <input type="text" id="query" name="query" style="width: 100%; padding: 8px;" required>
        <button type="submit" style="margin-top: 10px; padding: 8px 16px;">Execute</button>
    </form>
    <hr>

    <!-- Display results from the query here -->
    <div>
        <%
            String table = (String) request.getAttribute("queryResult");
            if (table != null) {
                out.print(table);
            }
        %>
    </div>
</body>
</html>
