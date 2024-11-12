<%@ page import="java.sql.*" %>
<%@ page import="java.io.*" %>
<!DOCTYPE html>
<html>
<head>
    <title>Database Query Tool</title>
    <style>
        body {
            font-family: sans-serif;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }

        .container {
            border: 1px solid #ccc;
            padding: 20px;
            border-radius: 5px;
        }

        textarea {
            width: 100%;
            height: 100px;
            margin-bottom: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Database Query Tool</h1>
        <form method="post">
            <textarea name="query" placeholder="Enter your SQL query here..."></textarea><br>
            <input type="submit" value="Execute Query">
        </form>

        <%
            if (request.getMethod().equalsIgnoreCase("post")) {
                String query = request.getParameter("query");
                if (query != null && !query.trim().isEmpty()) {
                    try (Connection conn = DatabaseUtil.getConnection();
                         Statement stmt = conn.createStatement()) {

                        boolean hasResultSet = stmt.execute(query);

                        if (hasResultSet) {
                            // Query returned a result set (SELECT, SHOW, etc.)
                            try (ResultSet rs = stmt.getResultSet()) {
                                ResultSetMetaData metaData = rs.getMetaData();
                                int columnCount = metaData.getColumnCount();
        %>
                                <table>
                                    <thead>
                                        <tr>
                                            <% for (int i = 1; i <= columnCount; i++) { %>
                                                <th><%= metaData.getColumnLabel(i) %></th>
                                            <% } %>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <% while (rs.next()) { %>
                                            <tr>
                                                <% for (int i = 1; i <= columnCount; i++) { %>
                                                    <td><%= rs.getString(i) %></td>
                                                <% } %>
                                            </tr>
                                        <% } %>
                                    </tbody>
                                </table>
        <%
                            }
                        } else {
                            // Query was a DML statement (UPDATE, DELETE, INSERT)
                            int rowsAffected = stmt.getUpdateCount();
                            out.println("<p>" + rowsAffected + " rows affected.</p>");
                        }

                    } catch (SQLException e) {
                        out.println("<p style='color: red;'>Error executing query: " + e.getMessage() + "</p>");
                    }
                } else {
                    out.println("<p>Please enter a query.</p>");
                }
            }
        %>
    </div>
</body>
</html>
