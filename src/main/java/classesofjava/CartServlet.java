package classesofjava;


import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

@WebServlet("/CartServlet")
public class CartServlet extends HttpServlet {

    private static final String DB_URL = "jdbc:mysql://localhost:3306/blockingminds";
    private static final String DB_USER = "root";
    private static final String DB_PASS = "sk2023@gopi";

    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        List<Map<String,Object>> cart = (List<Map<String,Object>>) session.getAttribute("cart");
        if (cart == null) {
            cart = new ArrayList<>();
            session.setAttribute("cart", cart);
        }

        String action = request.getParameter("action");
        String idStr = request.getParameter("id");
        int pid = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : -1;

        if ("add".equalsIgnoreCase(action) && pid > 0) {
            boolean found = false;
            for (Map<String,Object> item : cart) {
                if (((Integer) item.get("id")) == pid) {
                    int q = (Integer) item.get("qty");
                    item.put("qty", q + 1);
                    found = true;
                    break;
                }
            }
            if (!found) {
                try (Connection con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
                     PreparedStatement ps = con.prepareStatement("SELECT id, name, price, image_url FROM products WHERE id=?")) {
                    ps.setInt(1, pid);
                    ResultSet rs = ps.executeQuery();
                    if (rs.next()) {
                        Map<String,Object> newItem = new HashMap<>();
                        newItem.put("id", rs.getInt("id"));
                        newItem.put("name", rs.getString("name"));
                        newItem.put("price", rs.getBigDecimal("price"));
                        newItem.put("image", rs.getString("image_url"));
                        newItem.put("qty", 1);
                        cart.add(newItem);
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        else if ("remove".equalsIgnoreCase(action) && pid > 0) {
            cart.removeIf(m -> ((Integer) m.get("id")) == pid);
        }
        else if ("update".equalsIgnoreCase(action) && pid > 0) {
            String qtyStr = request.getParameter("qty");
            if (qtyStr != null) {
                int qty = Math.max(1, Integer.parseInt(qtyStr));
                for (Map<String,Object> item : cart) {
                    if (((Integer) item.get("id")) == pid) {
                        item.put("qty", qty);
                        break;
                    }
                }
            }
        }

        // Recalculate subtotal
        BigDecimal subtotal = BigDecimal.ZERO;
        int totalQty = 0;
        for (Map<String,Object> item : cart) {
            BigDecimal price = (BigDecimal) item.get("price");
            int qty = (Integer) item.get("qty");
            subtotal = subtotal.add(price.multiply(new BigDecimal(qty)));
            totalQty += qty;
        }

        // Respond with JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String json = String.format(
            "{\"cartCount\":%d, \"subtotal\":%.2f}",
            totalQty, subtotal
        );
        response.getWriter().write(json);
    }
}
