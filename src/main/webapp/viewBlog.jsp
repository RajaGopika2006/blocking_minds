<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Blog Details</title>
    <style>
        body {
            font-family: "Nunito", sans-serif;
            margin: 0;
            padding: 0;
            background: #f4f6f9;
        }
        header {
            background: #2c3e50;
            padding: 15px;
            text-align: center;
            color: white;
            font-size: 28px;
            font-weight: bold;
        }
        .blog-container {
            max-width: 900px;
            margin: 40px auto;
            background: white;
            padding: 30px;
            border-radius: 15px;
            box-shadow: 0 8px 20px rgba(0,0,0,0.1);
        }
        .blog-container img {
            width: 100%;
            border-radius: 12px;
            margin-bottom: 20px;
        }
        .blog-container h1 {
            font-size: 28px;
            margin-bottom: 15px;
            color: #2c3e50;
        }
        .blog-container p {
            font-size: 17px;
            color: #444;
            line-height: 1.8;
            text-align: justify;
        }
        .back-btn {
            display: inline-block;
            margin-top: 20px;
            padding: 10px 18px;
            background: #2c3e50;
            color: white;
            border-radius: 8px;
            text-decoration: none;
        }
        .back-btn:hover {
            background: #1a242f;
        }
    </style>
</head>
<body>
    <header>Blog Details</header>
    <div class="blog-container">
        <%
            String id = request.getParameter("id");
            if(id != null) {
                Connection con = null;
                PreparedStatement ps = null;
                ResultSet rs = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    con = DriverManager.getConnection("jdbc:mysql://localhost:3306/blockingminds","root","sk2023@gopi");
                    ps = con.prepareStatement("SELECT title, content, image_url FROM archae_blogs WHERE id=?");
                    ps.setInt(1, Integer.parseInt(id));
                    rs = ps.executeQuery();
                    if(rs.next()) {
        %>
                        <img src="<%= rs.getString("image_url") %>" alt="Blog Image">
                        <h1><%= rs.getString("title") %></h1>
                        <p><%= rs.getString("content") %></p>
                        <a class="back-btn" href="home.jsp">← Back to Blogs</a>
        <%
                    } else {
                        out.println("<p style='color:red;'>Blog not found!</p>");
                    }
                } catch(Exception e) {
                    out.println("<p style='color:red;'>Error: "+e.getMessage()+"</p>");
                } finally {
                    if(rs!=null) rs.close();
                    if(ps!=null) ps.close();
                    if(con!=null) con.close();
                }
            } else {
                out.println("<p style='color:red;'>Invalid request!</p>");
            }
        %>
    </div>
</body>
</html>
