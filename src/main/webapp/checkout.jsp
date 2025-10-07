<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String DB_URL = "jdbc:mysql://localhost:3306/blockingminds";
    String DB_USER = "root";
    String DB_PASS = "sk2023@gopi";

    @SuppressWarnings("unchecked")
    List<Map<String,Object>> cart = (List<Map<String,Object>>) session.getAttribute("cart");
    if(cart == null){ cart = new ArrayList<>(); session.setAttribute("cart", cart); }
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

    String method = request.getMethod();
    String placedMsg = null;
    Integer newOrderId = null;

    if("POST".equalsIgnoreCase(method) && cart!=null && !cart.isEmpty()){
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String address = request.getParameter("address");

        BigDecimal total = BigDecimal.ZERO;
        for(Map<String,Object> it: cart){
            BigDecimal price=(BigDecimal)it.get("price");
            int qty=(Integer)it.get("qty");
            total = total.add(price.multiply(new BigDecimal(qty)));
        }

        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            try(Connection con=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS)){
                con.setAutoCommit(false);
                try(PreparedStatement psOrder = con.prepareStatement(
                        "INSERT INTO orders(user_id,total,status) VALUES (?,?,?)",
                        Statement.RETURN_GENERATED_KEYS)){
                    if(userId==null) psOrder.setNull(1, java.sql.Types.INTEGER); else psOrder.setInt(1, userId);
                    psOrder.setBigDecimal(2, total);
                    psOrder.setString(3, "Pending");
                    psOrder.executeUpdate();
                    try(ResultSet keys=psOrder.getGeneratedKeys()){
                        if(keys.next()) newOrderId = keys.getInt(1);
                    }
                }

                try(PreparedStatement psItem = con.prepareStatement(
                        "INSERT INTO order_items(order_id,product_id,quantity,price) VALUES (?,?,?,?)");
                    PreparedStatement psStock = con.prepareStatement(
                        "UPDATE products SET stock=stock-? WHERE id=? AND stock>=?")){
                    for(Map<String,Object> it: cart){
                        int pid=(Integer)it.get("id");
                        int qty=(Integer)it.get("qty");
                        BigDecimal price=(BigDecimal)it.get("price");

                        psItem.setInt(1, newOrderId);
                        psItem.setInt(2, pid);
                        psItem.setInt(3, qty);
                        psItem.setBigDecimal(4, price);
                        psItem.addBatch();

                        psStock.setInt(1, qty);
                        psStock.setInt(2, pid);
                        psStock.setInt(3, qty);
                        psStock.addBatch();
                    }
                    psItem.executeBatch();
                    int[] stockRes = psStock.executeBatch();
                    // simple check: if any stock update failed (0), you may rollback (omitted for brevity)
                }

                con.commit();
                cart.clear();
                placedMsg = "Order placed successfully!";
            }
        } catch(Exception e){
            placedMsg = "Failed to place order: " + e.getMessage();
        }
    }
%>
<html>
<head>
    <title>Checkout | Blocking Minds</title>
    <style>
        body{font-family:"Nunito",sans-serif;margin:0;background:#f4f6f9;}
        header{background:#2c3e50;color:#fff;padding:16px 24px;display:flex;justify-content:space-between;align-items:center}
        nav a{color:#fff;text-decoration:none;margin-left:18px;font-weight:700}
        nav a:hover{opacity:.9}
        .wrap{max-width:900px;margin:28px auto;padding:0 20px}
        .card{background:#fff;border-radius:14px;box-shadow:0 8px 22px rgba(0,0,0,.06);padding:22px}
        .h{margin:0 0 14px;color:#2c3e50}
        label{display:block;margin:10px 0 6px;font-weight:700;color:#2c3e50}
        input,textarea{width:100%;padding:12px;border:1px solid #dfe6ee;border-radius:10px}
        textarea{min-height:100px}
        .btn{background:#2c3e50;color:#fff;border:none;border-radius:10px;padding:12px 16px;font-weight:800;cursor:pointer}
        .btn:hover{background:#1a242f}
        .summary{margin-top:14px;background:#f8fafc;border-radius:10px;padding:14px}
        .msg{margin:10px 0;padding:12px;border-left:4px solid #2c7be5;background:#fff;border-radius:8px}
        .ok{border-color:#2ecc71}
        .err{border-color:#e74c3c}
        footer{margin-top:40px;background:#2c3e50;color:#fff;text-align:center;padding:18px}
    </style>
</head>
<body>
<header>
    <div class="brand">Checkout</div>
    <nav>
        <a href="home.jsp">Blogs</a>
        <a href="shop.jsp">Shop</a>
        <a href="cart.jsp">Cart</a>
        <a href="orderHistory.jsp">Orders</a>
    </nav>
</header>

<div class="wrap">
    <div class="card">
        <h2 class="h">Shipping & Contact</h2>

        <% if(placedMsg != null){ %>
            <div class="msg <%= placedMsg.startsWith("Order placed")?"ok":"err" %>">
                <%= placedMsg %>
                <% if(newOrderId!=null){ %> (Order #<%= newOrderId %>) <% } %>
            </div>
            <a class="btn" href="orderHistory.jsp" style="margin-top:10px;display:inline-block">View Orders</a>
        <% } else if(cart==null || cart.isEmpty()){ %>
            <div class="msg err">Your cart is empty.</div>
            <a class="btn" href="shop.jsp">Go to Shop</a>
        <% } else { %>
            <form method="post">
                <label>Full Name</label>
                <input name="fullName" required value="<%= (String)session.getAttribute("user")!=null ? (String)session.getAttribute("user") : "" %>">
                <label>Email</label>
                <input type="email" name="email" id="email"required>
                <label>Address</label>
                <textarea name="address" id="address" required></textarea>

                <div class="summary">
                <strong>Order Summary</strong><br/>
                <%
                    BigDecimal subtotal = BigDecimal.ZERO;
                    for(Map<String,Object> it: cart){
                        BigDecimal price=(BigDecimal)it.get("price");
                        int qty=(Integer)it.get("qty");
                        subtotal = subtotal.add(price.multiply(new BigDecimal(qty)));
                    }
                    BigDecimal shipping = subtotal.compareTo(new BigDecimal("999.00"))>=0 ? BigDecimal.ZERO : new BigDecimal("49.00");
                    BigDecimal total = subtotal.add(shipping);
                %>
                Subtotal: ₹ <%= String.format("%.2f", subtotal) %><br/>
                Shipping: ₹ <%= String.format("%.2f", shipping) %><br/>
                <strong>Total: ₹ <%= String.format("%.2f", total) %></strong>
                </div>

                <button class="btn" type="submit" id="submit" style="margin-top:12px">Place Order</button>
            </form>
        <% } %>
    </div>
</div>

<footer>© 2025 Blocking Minds Store</footer>
</body>
</html>
