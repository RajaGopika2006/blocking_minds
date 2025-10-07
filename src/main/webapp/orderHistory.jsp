<%@ page import="java.sql.*, java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String DB_URL = "jdbc:mysql://localhost:3306/blockingminds";
    String DB_USER = "root";
    String DB_PASS = "sk2023@gopi";

    // Try to get userId from session, else resolve by session "user" name
    Integer userId = (Integer) session.getAttribute("userId");
    if(userId == null){
        String sessionName = (String) session.getAttribute("user");
        if(sessionName != null){
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                try(Connection con=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);
                    PreparedStatement ps=con.prepareStatement("SELECT id FROM users WHERE name=? LIMIT 1")){
                    ps.setString(1, sessionName);
                    try(ResultSet rs=ps.executeQuery()){
                        if(rs.next()) userId = rs.getInt(1);
                    }
                }
            }catch(Exception ignore){}
        }
    }
%>
<html>
<head>
    <title>Your Orders | Blocking Minds</title>
    <style>
        body{font-family:"Nunito",sans-serif;margin:0;background:#f4f6f9;}
        header{background:#2c3e50;color:#fff;padding:16px 24px;display:flex;justify-content:space-between;align-items:center}
        nav a{color:#fff;text-decoration:none;margin-left:18px;font-weight:700}
        nav a:hover{opacity:.9}
        .wrap{max-width:1100px;margin:28px auto;padding:0 20px}
        .card{background:#fff;border-radius:14px;box-shadow:0 8px 22px rgba(0,0,0,.06);padding:22px;margin-bottom:16px}
        .h{margin:0 0 10px;color:#2c3e50}
        .muted{color:#667}
        table{width:100%;border-collapse:collapse;margin-top:10px}
        th,td{padding:12px;border-bottom:1px solid #eef2f6;text-align:left}
        th{background:#f7f9fb;color:#2c3e50}
        .pill{padding:6px 10px;border-radius:999px;background:#eef2f6;font-weight:800;font-size:12px}
        footer{margin-top:40px;background:#2c3e50;color:#fff;text-align:center;padding:18px}
    </style>
</head>
<body>
<header>
    <div class="brand">Your Orders</div>
    <nav>
        <a href="home.jsp">Blogs</a>
        <a href="shop.jsp">Shop</a>
        <a href="cart.jsp">Cart</a>
    </nav>
</header>

<div class="wrap">
<%
    if(userId == null){
%>
    <div class="card">
        <h3 class="h">Please log in</h3>
        <p class="muted">We couldn’t identify your account. Log in so we can show your order history.</p>
        <a class="pill" href="login.jsp">Go to Login</a>
    </div>
<%
    } else {
        Class.forName("com.mysql.cj.jdbc.Driver");
        try(Connection con=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
%>
    <div class="card">
        <h3 class="h">Orders</h3>
        <table>
            <tr><th>#</th><th>Date</th><th>Status</th><th>Total (₹)</th></tr>
            <%
                try(PreparedStatement ps=con.prepareStatement(
                    "SELECT id, order_date, status, total FROM orders WHERE user_id=? ORDER BY id DESC")){
                    ps.setInt(1, userId);
                    try(ResultSet rs=ps.executeQuery()){
                        boolean any=false;
                        while(rs.next()){
                            any=true;
            %>
                <tr>
                    <td><%= rs.getInt("id") %></td>
                    <td><%= rs.getTimestamp("order_date") %></td>
                    <td><span class="pill"><%= rs.getString("status") %></span></td>
                    <td><%= String.format("%.2f", rs.getBigDecimal("total")) %></td>
                </tr>
            <%
                        }
                        if(!any){
            %>
                <tr><td colspan="4" class="muted">No orders yet.</td></tr>
            <%
                        }
                    }
                }
            %>
        </table>
    </div>

    <div class="card">
        <h3 class="h">Recent Items</h3>
        <table>
            <tr><th>Order #</th><th>Product</th><th>Qty</th><th>Price (₹)</th></tr>
            <%
                try(PreparedStatement ps=con.prepareStatement(
                    "SELECT oi.order_id, p.name, oi.quantity, oi.price " +
                    "FROM order_items oi JOIN orders o ON oi.order_id=o.id " +
                    "JOIN products p ON p.id=oi.product_id WHERE o.user_id=? ORDER BY oi.order_id DESC, oi.id DESC LIMIT 50")){
                    ps.setInt(1, userId);
                    try(ResultSet rs=ps.executeQuery()){
                        boolean any=false;
                        while(rs.next()){
                            any=true;
            %>
                <tr>
                    <td><%= rs.getInt(1) %></td>
                    <td><%= rs.getString(2) %></td>
                    <td><%= rs.getInt(3) %></td>
                    <td><%= String.format("%.2f", rs.getBigDecimal(4)) %></td>
                </tr>
            <%
                        }
                        if(!any){
            %>
                <tr><td colspan="4" class="muted">No items to show.</td></tr>
            <%
                        }
                    }
                }
            %>
        </table>
    </div>
<%
        }
    }
%>
</div>

<footer>© 2025 Blocking Minds Store</footer>
</body>
</html>
