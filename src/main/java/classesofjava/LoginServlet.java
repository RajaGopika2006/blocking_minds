package classesofjava;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private static final String JDBC_URL = "jdbc:mysql://localhost:3306/blockingminds";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "sk2023@gopi";

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username"); 
        String password = request.getParameter("password");

        boolean isValid = false;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DriverManager.getConnection(JDBC_URL, DB_USER, DB_PASSWORD)) {
                String sql = "SELECT * FROM users WHERE (email=? OR name=?) AND password=?";
                PreparedStatement stmt = conn.prepareStatement(sql);
                stmt.setString(1, username);
                stmt.setString(2, username);
                stmt.setString(3, password); 

                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    isValid = true;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        if (isValid) {
            request.getSession().setAttribute("user", username);
            response.sendRedirect("home.jsp");
        } else {
            response.sendRedirect("login.jsp?error=1");
        }
    }
}
