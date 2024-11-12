package com.example;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;

@WebServlet("/SqlQueryServlet")
public class SqlQueryServlet extends HttpServlet {
    private static final String JDBC_URL = "jdbc:mariadb://localhost:3306/imart";
    private static final String JDBC_USER = "imart_user";
    private static final String JDBC_PASSWORD = "securepassword";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {

        String query = request.getParameter("query");
        StringBuilder result = new StringBuilder();

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             Statement stmt = conn.createStatement()) {

            if (query.trim().toLowerCase().startsWith("select")) {
                ResultSet rs = stmt.executeQuery(query);
                result.append(formatResultSet(rs));
            } else {
                int rowsAffected = stmt.executeUpdate(query);
                result.append("<p>Query executed successfully, ")
                      .append(rowsAffected)
                      .append(" rows affected.</p>");
            }
        } catch (SQLException e) {
            result.append("<p>Error executing query: ")
                  .append(e.getMessage())
                  .append("</p>");
        }

        request.setAttribute("queryResult", result.toString());
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }

    private String formatResultSet(ResultSet rs) throws SQLException {
        StringBuilder table = new StringBuilder("<table class='query-table'>");
        ResultSetMetaData metaData = rs.getMetaData();
        int columnCount = metaData.getColumnCount();

        // Table header
        table.append("<tr>");
        for (int i = 1; i <= columnCount; i++) {
            table.append("<th>").append(metaData.getColumnName(i)).append("</th>");
        }
        table.append("</tr>");

        // Table rows
        while (rs.next()) {
            table.append("<tr>");
            for (int i = 1; i <= columnCount; i++) {
                table.append("<td>").append(rs.getString(i)).append("</td>");
            }
            table.append("</tr>");
        }
        table.append("</table>");
        return table.toString();
    }
}
