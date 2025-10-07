<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Shop</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
      body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    margin: 0;
    padding: 0;
    background: #f9fafb;
    color: #333;
}

header {
    background: #374151;   /* dark grey */
    color: #fff;
    padding: 20px;
    text-align: center;
    font-size: 28px;
    font-weight: bold;
    letter-spacing: 1px;
}

#products {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
    gap: 20px;
    padding: 20px;
    max-width: 1200px;
    margin: auto;
}

.product {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 4px 10px rgba(0,0,0,0.08);
    padding: 20px;
    text-align: center;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.product:hover {
    transform: translateY(-5px);
    box-shadow: 0 8px 16px rgba(0,0,0,0.15);
}

.product img {
    max-width: 100%;
    height: 180px;
    object-fit: cover;
    border-radius: 10px;
    margin-bottom: 15px;
}

.product h3 {
    font-size: 20px;
    margin: 10px 0;
    color: #111827;
}

.product p {
    font-size: 16px;
    margin: 5px 0 15px;
    color: #4b5563;
}

.product button {
    background: #4b5563;   /* grey button */
    color: #fff;
    border: none;
    padding: 10px 18px;
    font-size: 15px;
    border-radius: 8px;
    cursor: pointer;
    transition: background 0.2s ease;
}

.product button:hover {
    background: #374151;   /* darker grey */
}

#cartInfo {
    position: sticky;
    bottom: 0;
    background: #1f2937;   /* dark grey for cart bar */
    color: #fff;
    padding: 15px 20px;
    text-align: right;
    font-size: 18px;
    border-top-left-radius: 12px;
    border-top-right-radius: 12px;
    box-shadow: 0 -2px 10px rgba(0,0,0,0.2);
}

#cartInfo a {
    color: #d1d5db;   /* light grey link */
    text-decoration: none;
    margin-left: 20px;
    font-weight: bold;
}

#cartInfo a:hover {
    color: #f9fafb;
    text-decoration: underline;
}
      
    </style>
    <script>
        function addToCart(pid) {
            $.ajax({
                url: "CartServlet",
                type: "POST",
                data: { action: "add", id: pid },
                dataType: "json",
                success: function (data) {
                    $("#cartCount").text("(" + data.count + ")");
                    $("#subtotal").text(data.subtotal.toFixed(2));
                },
                error: function (xhr, status, err) {
                    console.error("AJAX Error:", status, err);
                    alert("Error: " + xhr.responseText);
                }
            });
        }
    </script>
</head>
<body>
    <header>🛒 Online Shop</header>

    <div id="products">
        <%
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection con = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/blockingminds", "root", "sk2023@gopi");
                Statement st = con.createStatement();
                ResultSet rs = st.executeQuery("SELECT id, name, price, image_url FROM products");

                while (rs.next()) {
        %>
            <div class="product">
                <img src="<%= rs.getString("image_url") %>" alt="<%= rs.getString("name") %>">
                <h3><%= rs.getString("name") %></h3>
                <p>Price: ₹<%= rs.getDouble("price") %></p>
                <button onclick="addToCart(<%= rs.getInt("id") %>)" id="vbutn-<%= rs.getInt("id") %>">
    Add to Cart
</button>
                
            </div>
        <%
                }
                con.close();
            } catch (Exception e) {
                out.println("<p style='color:red;text-align:center;'>Error loading products.</p>");
            }
        %>
    </div>

    <div id="cartInfo">
        Cart Items  | Subtotal: ₹<span id="subtotal">0.00</span>
        <a href="cart.jsp">Go to Cart →</a>
    </div>
</body>
</html>
