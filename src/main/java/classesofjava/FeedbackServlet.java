	package classesofjava;
	
	import java.io.*;
	import javax.servlet.*;
	import javax.servlet.annotation.WebServlet;
	import javax.servlet.http.*;
	import org.w3c.dom.*;
	import javax.xml.parsers.*;
	import javax.xml.transform.*;
	import javax.xml.transform.dom.DOMSource;
	import javax.xml.transform.stream.StreamResult;
	
	@WebServlet("/FeedbackServlet")
	public class FeedbackServlet extends HttpServlet {
	    private static final long serialVersionUID = 1L;
	    private String filePath;
	
	    public void init() throws ServletException {
	        filePath = getServletContext().getRealPath("/") + "feedback.xml";
	    }
	
	    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
	            throws ServletException, IOException {
	
	       
	        String name = request.getParameter("name");
	        String email = request.getParameter("email");
	        String phone = request.getParameter("phone");
	        String feedbackText = request.getParameter("feedback");
	        String rating = request.getParameter("rating");
	
	        try {
	            File xmlFile = new File(filePath);
	            DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
	            DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
	            Document doc;
	
	            
	            if (!xmlFile.exists()) {
	                doc = dBuilder.newDocument();
	                Element rootElement = doc.createElement("feedbacks");
	                doc.appendChild(rootElement);
	            } else {
	                doc = dBuilder.parse(xmlFile);
	                doc.getDocumentElement().normalize();
	            }
	
	           
	            Element root = doc.getDocumentElement();
	
	          
	            Element feedback = doc.createElement("feedback");
	            feedback.setAttribute("c_id", "C" + System.currentTimeMillis());
	
	        
	            Element nameEl = doc.createElement("name");
	            nameEl.appendChild(doc.createTextNode(name));
	            feedback.appendChild(nameEl);
	
	            Element emailEl = doc.createElement("email");
	            emailEl.appendChild(doc.createTextNode(email));
	            feedback.appendChild(emailEl);
	
	            Element phoneEl = doc.createElement("phone");
	            phoneEl.appendChild(doc.createTextNode(phone));
	            feedback.appendChild(phoneEl);
	
	            Element msgEl = doc.createElement("message"); 
	            msgEl.appendChild(doc.createTextNode(feedbackText));
	            feedback.appendChild(msgEl);
	
	            Element ratingEl = doc.createElement("rating");
	            ratingEl.appendChild(doc.createTextNode(rating));
	            feedback.appendChild(ratingEl);
	
	            root.appendChild(feedback);
	
	            
	            TransformerFactory transformerFactory = TransformerFactory.newInstance();
	            Transformer transformer = transformerFactory.newTransformer();
	            transformer.setOutputProperty(OutputKeys.INDENT, "yes");
	            DOMSource source = new DOMSource(doc);
	            StreamResult result = new StreamResult(xmlFile);
	            transformer.transform(source, result);
	
	           
	            response.sendRedirect("feedback.jsp");
	
	        } catch (Exception e) {
	            e.printStackTrace();
	            response.setContentType("text/html");
	            response.getWriter().println("<h2>Error saving feedback!</h2>");
	            response.getWriter().println("<a href='feedback.jsp'>Go Back</a>");
	        }
	    }
	}
