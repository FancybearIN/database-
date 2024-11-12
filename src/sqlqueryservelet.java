import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/SqlQueryServlet")
public class SqlQueryServlet extends HttpServlet {
    private static final String JDBC_URL = "jdbc:mariadb://localhost:3306/imart";
    private static final String JDBC_USER = "imart_user";
    private static final String JDBC_PASSWORD = "securepassword";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String query = request.getParameter("query");
        StringBuilder table = new StringBuilder();

        try (Connection conn = DriverManager.getConnection(JDBC_URL, JDBC_USER, JDBC_PASSWORD);
             Statement stmt = conn.createStatement()) {

            if (query.trim().toLowerCase().startsWith("select")) {
                ResultSet rs = stmt.executeQuery(query);
                int columnCount = rs.getMetaData().getColumnCount();

                // Start table
                table.append("<table class='query-table'><tr>");
                
                // Table header
                for (int i = 1; i <= columnCount; i++) {
                    table.append("<th>").append(rs.getMetaData().getColumnName(i)).append("</th>");
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
            } else {
                int rowsAffected = stmt.executeUpdate(query);
                table.append("<p>Query executed successfully, ").append(rowsAffected).append(" rows affected.</p>");
            }
        } catch (Exception e) {
            table.append("<p>Error executing query: ").append(e.getMessage()).append("</p>");
        }

        request.setAttribute("queryResult", table.toString());
        request.getRequestDispatcher("index.jsp").forward(request, response);
    }
}
