<%@ page import="java.sql.*" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Blocking Minds - Archaeology Blogs</title>
    <style>
        body {
            font-family: "Nunito", sans-serif;
            margin: 0;
            padding: 0;
            background: #f4f6f9;
            scroll-behavior: smooth;
        }
        header {
            background: #2c3e50;
            padding: 15px;
            text-align: center;
            color: white;
            font-size: 28px;
            font-weight: bold;
            letter-spacing: 1px;
        }
        nav {
            background: #1a242f;
            display: flex;
            justify-content: center;
            gap: 25px;
            padding: 12px 0;
        }
        nav a {
            color: white;
            text-decoration: none;
            font-weight: bold;
            transition: color 0.3s;
        }
        nav a:hover {
            color: #f39c12;
        }
        .container {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
            gap: 20px;
            padding: 40px;
            max-width: 1200px;
            margin: auto;
        }
        .card {
            background: white;
            border-radius: 15px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.1);
            overflow: hidden;
            transition: transform 0.2s;
        }
        .card:hover {
            transform: translateY(-8px);
        }
        .card img {
            width: 100%;
            height: 200px;
            object-fit: cover;
        }
        .card-body {
            padding: 20px;
        }
        .card h2 {
            font-size: 20px;
            margin: 0 0 10px;
            color: #2c3e50;
        }
        .card p {
            color: #555;
            font-size: 15px;
            line-height: 1.5;
        }
        .btn {
            display: inline-block;
            margin-top: 10px;
            padding: 10px 18px;
            background: #2c3e50;
            color: white;
            border-radius: 8px;
            text-decoration: none;
            transition: background 0.3s;
        }
        .btn:hover {
            background: #1a242f;
        }

        /* About Us */
        .about-section {
            display: flex;
            flex-wrap: wrap;
            align-items: center;
            gap: 30px;
            padding: 60px 40px;
            background: #fff;
        }
        .about-section img {
            width: 400px;
            border-radius: 12px;
            box-shadow: 0 6px 15px rgba(0,0,0,0.1);
        }
        .about-text {
            flex: 1;
        }
        .about-text h2 {
            font-size: 28px;
            margin-bottom: 15px;
            color: #2c3e50;
        }
        .about-text p {
            font-size: 17px;
            color: #555;
            line-height: 1.8;
        }

        /* Contact Us */
        .contact-section {
            background: #ecf0f1;
            padding: 60px 40px;
            text-align: center;
        }
        .contact-section h2 {
            font-size: 28px;
            margin-bottom: 20px;
            color: #2c3e50;
        }
        .contact-form {
            max-width: 600px;
            margin: auto;
            background: white;
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 6px 18px rgba(0,0,0,0.1);
        }
        .contact-form input, .contact-form textarea {
            width: 100%;
            padding: 12px;
            margin: 10px 0;
            border: 1px solid #ccc;
            border-radius: 8px;
            font-size: 15px;
        }
        .contact-form button {
            padding: 12px 20px;
            background: #2c3e50;
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            cursor: pointer;
        }
        .contact-form button:hover {
            background: #1a242f;
        }

        footer {
            background: #2c3e50;
            color: white;
            padding: 20px;
            text-align: center;
            font-size: 14px;
        }
    </style>
</head>
<body>
    <header>Blocking Minds - Tamil Nadu Archaeology</header>
    <nav>
        <a href="#blogs">Blogs</a>
        <a href="shop.jsp" id="shop">Shop</a>   <!-- ✅ New Shop link -->
        <a href="#about">About Us</a>
        <a href="#contact">Contact</a>
         <a href="feedback.jsp">Feedback</a>
    </nav>

    <!-- Blogs Section -->
    <div id="blogs" class="container">
        <%
            Connection con = null;
            Statement st = null;
            ResultSet rs = null;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                con = DriverManager.getConnection("jdbc:mysql://localhost:3306/blockingminds","root","sk2023@gopi");
                st = con.createStatement();
                rs = st.executeQuery("SELECT id, title, short_desc, image_url FROM archae_blogs");

                while(rs.next()) {
        %>
            <div class="card">
                <img src="<%= rs.getString("image_url") %>" alt="Blog Image">
                <div class="card-body">
                    <h2><%= rs.getString("title") %></h2>
                    <p><%= rs.getString("short_desc") %></p>
                    <a class="btn" href="viewBlog.jsp?id=<%= rs.getInt("id") %>">Read More</a>
                </div>
            </div>
        <% } 
            } catch(Exception e) {
                out.println("<p style='color:red;'>Error: "+e.getMessage()+"</p>");
            } finally {
                if(rs!=null) rs.close();
                if(st!=null) st.close();
                if(con!=null) con.close();
            }
        %>
    </div>

    <!-- About Us -->
    <section id="about" class="about-section">
        <img src="images/archaeology_about.jpg" alt="About Blocking Minds">
        <div class="about-text">
            <h2>About Blocking Minds</h2>
            <p>
                Blocking Minds is a digital space dedicated to exploring the rich archaeological heritage 
                of Tamil Nadu. From the grandeur of Chola temples to the hidden treasures of Keeladi, 
                we aim to bring history closer to the modern world. 
                Our mission is to preserve knowledge and spark curiosity about ancient Tamil culture.
            </p>
        </div>
    </section>

    <!-- Contact Us -->
    <section id="contact" class="contact-section">
        <h2>Contact Us</h2>
        <form class="contact-form" method="post" action="sendMessage.jsp">
            <input type="text" name="name" placeholder="Your Name" required>
            <input type="email" name="email" placeholder="Your Email" required>
            <textarea name="message" rows="5" placeholder="Your Message" required></textarea>
            <button type="submit">Send Message</button>
        </form>
    </section>

    <footer>
        © 2025 Blocking Minds | Tamil Nadu Archaeology Blogs
    </footer>
</body>
</html>
