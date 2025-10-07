<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, javax.xml.parsers.*, org.w3c.dom.*" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Feedback Form</title>
    <style>
        body { font-family: Arial, sans-serif; background: #f4f4f9; margin: 0; padding: 0; display: flex; flex-direction: column; align-items: center; }
        .form-container { background: #fff; padding: 30px; border-radius: 12px; box-shadow: 0px 4px 12px rgba(0,0,0,0.1); width: 400px; margin-top: 30px; }
        input, textarea, select, button { display: block; width: 100%; margin-bottom: 12px; padding: 10px; border-radius: 8px; border: 1px solid #ccc; }
        button { background: #4CAF50; color: white; border: none; cursor: pointer; font-size: 16px; }
        .feedback-box { background:#fff; padding:15px; border-radius:8px; margin-bottom:10px; box-shadow:0px 2px 6px rgba(0,0,0,0.1); width: 500px; }
    </style>
</head>
<body>

    <div class="form-container">
        <h2 style="text-align:center;">Feedback Form</h2>
        <form id="feedbackForm">
            <input type="text" name="name" placeholder="Your Name" required>
            <input type="email" name="email" placeholder="Your Email" required>
            <input type="text" name="phone" placeholder="Your Phone Number" required>
            <textarea name="feedback" placeholder="Enter your feedback..." rows="4" required></textarea>
            <select name="rating" required>
                <option value="">Select Rating</option>
                <option value="1">⭐</option>
                <option value="2">⭐⭐</option>
                <option value="3">⭐⭐⭐</option>
                <option value="4">⭐⭐⭐⭐</option>
                <option value="5">⭐⭐⭐⭐⭐</option>
            </select>
            <button type="submit">Submit Feedback</button>
        </form>
    </div>

    <div style="margin-top:40px; width: 550px;">
        <h2>What Others Say</h2>
        <div id="feedbackList">
            <%
                try {
                    String xmlPath = application.getRealPath("/") + "feedback.xml";
                    File xmlFile = new File(xmlPath);
                    if(xmlFile.exists()) {
                        DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
                        DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
                        Document doc = dBuilder.parse(xmlFile);
                        doc.getDocumentElement().normalize();

                        NodeList nList = doc.getElementsByTagName("feedback");

                        if(nList.getLength() == 0) {
                            out.println("<p>No feedback yet.</p>");
                        }

                        for(int i = 0; i < nList.getLength(); i++) {
                            Node nNode = nList.item(i);
                            if(nNode.getNodeType() == Node.ELEMENT_NODE) {
                                Element eElement = (Element) nNode;
                                String name = eElement.getElementsByTagName("name").item(0).getTextContent();
                                String message = eElement.getElementsByTagName("message").item(0).getTextContent();
                                String rating = eElement.getElementsByTagName("rating").item(0).getTextContent();
            %>
                                <div class="feedback-box">
                                    <strong><%= name %></strong> (Rating: <%= rating %>/5)<br>
                                    <%= message %>
                                </div>
            <%
                            }
                        }
                    } else {
                        out.println("<p>No feedback yet.</p>");
                    }
                } catch(Exception e) {
                    out.println("<p>Error loading feedback!</p>");
                }
            %>
        </div>
    </div>

    <script>
        document.getElementById("feedbackForm").addEventListener("submit", function(e) {
            e.preventDefault(); 
            let formData = new FormData(this);

            fetch("FeedbackServlet", {
                method: "POST",
                body: formData
            })
            .then(response => response.text())  
            .then(data => {
                document.getElementById("feedbackList").innerHTML = data; 
                document.getElementById("feedbackForm").reset(); 
                alert("Feedback submitted successfully!");
            })
            .catch(err => {
                console.error("Error:", err);
                alert("Something went wrong!");
            });
        });
    </script>

</body>
</html>
