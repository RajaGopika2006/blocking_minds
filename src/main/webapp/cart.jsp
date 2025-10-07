<%@ page import="java.sql.*, java.util.*, java.math.BigDecimal" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String DB_URL = "jdbc:mysql://localhost:3306/blockingminds";
    String DB_USER = "root";
    String DB_PASS = "sk2023@gopi";
    @SuppressWarnings("unchecked")
    List<Map<String,Object>> cart = (List<Map<String,Object>>) session.getAttribute("cart");
    if(cart == null){ cart = new ArrayList<>(); session.setAttribute("cart", cart); }

    String action = request.getParameter("action");
    BigDecimal subtotal = BigDecimal.ZERO;
    int totalItems = 0;
    for(Map<String,Object> item: cart){
        BigDecimal price = (BigDecimal)item.get("price");
        int qty = (Integer)item.get("qty");
        subtotal = subtotal.add(price.multiply(new BigDecimal(qty)));
        totalItems += qty;
    }
    boolean isAjax = "XMLHttpRequest".equals(request.getHeader("X-Requested-With"));

    if("add".equalsIgnoreCase(action)){
        int pid = Integer.parseInt(request.getParameter("id"));
        Class.forName("com.mysql.cj.jdbc.Driver");
        try(Connection con=DriverManager.getConnection(DB_URL,DB_USER,DB_PASS);
            PreparedStatement ps=con.prepareStatement("SELECT id,name,price,image_url FROM products WHERE id=?")){
            ps.setInt(1, pid);
            try(ResultSet rs=ps.executeQuery()){
                if(rs.next()){
                    boolean found=false;
                    for(Map<String,Object> item: cart){
                        if(((Integer)item.get("id"))==pid){
                            int q=(Integer)item.get("qty");
                            item.put("qty", q+1);
                            found=true; break;
                        }
                    }
                    if(!found){
                        Map<String,Object> it=new HashMap<>();
                        it.put("id", rs.getInt("id"));
                        it.put("name", rs.getString("name"));
                        it.put("price", rs.getBigDecimal("price"));
                        it.put("image", rs.getString("image_url"));
                        it.put("qty", 1);
                        cart.add(it);
                    }
                }
            }
        }
    } else if("remove".equalsIgnoreCase(action)){
        int pid = Integer.parseInt(request.getParameter("id"));
        cart.removeIf(m -> ((Integer)m.get("id"))==pid);
    } else if("update".equalsIgnoreCase(action)){
        for(Map<String,Object> item: cart){
            int pid=(Integer)item.get("id");
            String qStr = request.getParameter("qty_"+pid);
            if(qStr!=null){
                int q = Math.max(1, Integer.parseInt(qStr));
                item.put("qty", q);
            }
        }
    }
    subtotal = BigDecimal.ZERO;
    totalItems = 0;
    for(Map<String,Object> item: cart){
        BigDecimal price = (BigDecimal)item.get("price");
        int qty = (Integer)item.get("qty");
        subtotal = subtotal.add(price.multiply(new BigDecimal(qty)));
        totalItems += qty;
    }

    if(isAjax){
        response.setContentType("application/json");
        out.print("{\"count\":"+totalItems+",\"subtotal\":\""+subtotal.toString()+"\"}");
        return;
    }
%>
<html>
<head>
    <title>Your Cart | Blocking Minds</title>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: "Nunito", sans-serif;
            margin: 0;
            background: #f4f6f9;
            color: #2c3e50;
            line-height: 1.5;
        }
        header {
            background: linear-gradient(135deg, #2c3e50, #34495e);
            color: #fff;
            padding: 16px 24px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(0,0,0,0.15);
        }
        header .brand {
            font-size: 22px;
            font-weight: 800;
            letter-spacing: 0.5px;
        }
        nav a {
            color: #fff;
            text-decoration: none;
            margin-left: 18px;
            font-weight: 600;
            transition: 0.3s ease;
        }
        nav a:hover {
            opacity: .85;
            border-bottom: 2px solid #fff;
            padding-bottom: 3px;
        }
        .wrap {
            max-width: 1100px;
            margin: 32px auto;
            padding: 0 20px;
        }
        .table {
            width: 100%;
            background: #fff;
            border-radius: 14px;
            box-shadow: 0 8px 22px rgba(0,0,0,.06);
            overflow: hidden;
            border-collapse: collapse;
        }
        .table th, .table td {
            padding: 14px;
        }
        .table th {
            background: #eef2f6;
            text-align: left;
            font-size: 14px;
            font-weight: 700;
            letter-spacing: 0.4px;
        }
        .table tr:hover {
            background: #fafbfd;
        }
        .table td {
            vertical-align: middle;
            font-size: 15px;
            color: #333;
        }
        tr+tr td {
            border-top: 1px solid #f0f2f5;
        }
        .thumb {
            width: 72px;
            height: 72px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #ddd;
            transition: transform 0.2s;
        }
        .thumb:hover {
            transform: scale(1.05);
        }
        .qty {
            width: 70px;
            padding: 8px;
            border: 1px solid #dfe6ee;
            border-radius: 8px;
            text-align: center;
            font-weight: 600;
        }

        .btn {
            background: #2c3e50;
            color: #fff;
            border: none;
            border-radius: 10px;
            padding: 10px 16px;
            font-weight: 700;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            transition: background 0.3s, transform 0.2s;
        }
        .btn:hover {
            background: #1a252f;
            transform: translateY(-1px);
        }
        .btn.alt {
            background: #27ae60;
        }
        .btn.alt:hover {
            background: #1e874b;
        }

        .row-right {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 14px;
            flex-wrap: wrap;
        }
        .total {
            font-size: 20px;
            font-weight: 800;
            color: #2c3e50;
        }
        .empty {
            background: #fff;
            padding: 40px;
            border-radius: 14px;
            text-align: center;
            box-shadow: 0 8px 22px rgba(0,0,0,.06);
        }
        .empty p {
            font-size: 18px;
            margin-bottom: 16px;
        }
        footer {
            margin-top: 40px;
            background: #2c3e50;
            color: #fff;
            text-align: center;
            padding: 18px;
            font-size: 14px;
            letter-spacing: 0.5px;
        }
        @media (max-width: 768px) {
            .table th, .table td {
                padding: 10px;
                font-size: 13px;
            }
            .thumb {
                width: 60px;
                height: 60px;
            }
            .qty {
                width: 55px;
                padding: 6px;
            }
            header {
                flex-direction: column;
                align-items: flex-start;
            }
            nav {
                margin-top: 10px;
            }
        }
    </style>
    <script>
        function updateQty(pid){
            var qty = $("#qty-"+pid).val();
            $.ajax({
                url: "cart.jsp",
                type: "POST",
                data: { action: "update", ["qty_"+pid]: qty },
                dataType: "json",
                success: function(data){
                    $("#cartCount").text("(" + data.count + ")");
                    $("#subtotal").text(data.subtotal);
                    location.reload(); 
                }
            });
        }
        function removeFromCart(pid){
            $.ajax({
                url: "cart.jsp",
                type: "POST",
                data: { action: "remove", id: pid },
                dataType: "json",
                success: function(data){
                    $("#cartCount").text("(" + data.count + ")");
                    $("#subtotal").text(data.subtotal);
                    location.reload();
                }
            });
        }
    </script>
</head>
<body>
<header>
    <div class="brand">Your Cart</div>
    <nav>
        <a href="home.jsp">Blogs</a>
        <a href="shop.jsp">Shop</a>
        <a href="orderHistory.jsp">Orders</a>
    </nav>
</header>

<div class="wrap">
<%
    if(cart.isEmpty()){
%>
    <div class="empty">
        <p>Your cart is empty.</p>
        <a class="btn" href="shop.jsp">Go to Shop</a>
    </div>
<%
    } else {
%>
    <table class="table">
        <tr>
            <th>Product</th><th>Name</th><th>Price</th><th>Qty</th><th>Line Total</th><th></th>
        </tr>
        <%
            for(Map<String,Object> item: cart){
                int pid=(Integer)item.get("id");
                String name=(String)item.get("name");
                BigDecimal price=(BigDecimal)item.get("price");
                int qty=(Integer)item.get("qty");
                String image=(String)item.get("image");
                BigDecimal line = price.multiply(new BigDecimal(qty));
        %>
        <tr>
            <td><img class="thumb" src="<%= image %>" alt="<%= name %>"></td>
            <td><strong><%= name %></strong></td>
            <td>₹ <%= String.format("%.2f", price) %></td>
            <td>
                <input id="qty-<%= pid %>" class="qty" type="number" min="1" value="<%= qty %>" onchange="updateQty(<%= pid %>)">
            </td>
            <td>₹ <%= String.format("%.2f", line) %></td>
            <td><button class="btn" onclick="removeFromCart(<%= pid %>)">Remove</button></td>
        </tr>
        <% } %>
    </table>
    <div class="row-right" style="margin-top:8px">
        <span class="total">Subtotal: ₹ <span id="subtotal"><%= String.format("%.2f", subtotal) %></span></span> &nbsp; 
        Cart Items <span id="cartCount">(<%= totalItems %>)</span>
    </div>
    <div class="row-right">
        <a class="btn alt" href="checkout.jsp">Proceed to Checkout</a>
    </div>
<% } %>
</div>

<footer>© 2025 Blocking Minds Store</footer>
</body>
</html>
