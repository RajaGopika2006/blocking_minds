package classesofjava;

import org.openqa.selenium.By;
import org.openqa.selenium.Keys;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.support.ui.ExpectedConditions;
import org.openqa.selenium.support.ui.WebDriverWait;

import java.time.Duration;
import java.util.List;

public class Demo {
    public static void main(String[] args) {
   
        System.setProperty("webdriver.chrome.driver", "C:\\Users\\rajag\\Downloads\\chromedriver-win64\\chromedriver-win64\\chromedriver.exe");
        WebDriver driver = new ChromeDriver();
        WebDriverWait wait = new WebDriverWait(driver, Duration.ofSeconds(10));

        try {
            driver.get("http://localhost:8080/BlockingMindsWebProject/login.jsp");
            System.out.println("Step 1: Opened Login page.");
            System.out.println("Page Title: " + driver.getTitle());
            WebElement usernameField = driver.findElement(By.id("username"));
            usernameField.sendKeys("Gopika");
            WebElement passwordField = driver.findElement(By.id("password"));
            passwordField.sendKeys("sk2023@gopi" + Keys.ENTER);
            System.out.println("Step 2 & 3: Typed username and password and logged in.");
            
            String pageTitle = driver.getTitle();
            String expectedTitle = "Blocking Minds - Archaeology Blogs";
            if (pageTitle.equals(expectedTitle)) {
                System.out.println("Step 4:  Verify title passed. Page title is correct.");
            } else {
                System.out.println("Step 4:  Verify title failed. Expected: '" + expectedTitle + "', Found: '" + pageTitle + "'.");
            }
            WebElement shopLink = driver.findElement(By.linkText("Shop"));
            shopLink.click();
            System.out.println("Step 5: Clicked 'Shop' link.");
            wait.until(ExpectedConditions.presenceOfElementLocated(By.id("products")));
            WebElement productsElement = driver.findElement(By.id("products"));
            if (productsElement.isDisplayed()) {
                System.out.println("Step 6:  Assert element present passed. 'products' element is visible.");
            } else {
                System.out.println("Step 6:  Assert element present failed. 'products' element is not visible.");
            }
            WebElement addButton = driver.findElement(By.cssSelector("button[id^='vbutn-']"));
            addButton.click();
            System.out.println("Step 7: Clicked product with ID 'vbutn'.");
            WebElement cartLink = driver.findElement(By.cssSelector("a[href*='cart.jsp']"));
            cartLink.click();
            List<WebElement> checkoutLinks = driver.findElements(By.cssSelector("a[href*='checkout.jsp']"));
            if (!checkoutLinks.isEmpty()) {
                checkoutLinks.get(0).click();
                System.out.println("Step 9: Clicked checkout link.");
            } else {
                System.out.println("Step 9: Checkout link not found (cart might still be empty).");
            }

            System.out.println("Step 9: Clicked checkout link.");
            WebElement emailField = driver.findElement(By.id("email"));
            emailField.sendKeys("rajagopikarajagopal2006@gmail.com");
            System.out.println("Step 10: Typed email address.");
            String storedEmail = emailField.getAttribute("value");
            System.out.println("Step 11: Stored email value: " + storedEmail);
            WebElement submitButton = driver.findElement(By.id("submit"));
            String submitButtonText = submitButton.getAttribute("value");
            String expectedButtonText = "Place Order";
            if (submitButtonText.equals(expectedButtonText)) {
                System.out.println("Step 12:  Verify text passed. Submit button text is correct.");
            } else {
                System.out.println("Step 12:  Verify text failed. Expected: '" + expectedButtonText + "', Found: '" + submitButtonText + "'.");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (driver != null) {
                driver.quit();
                System.out.println("Browser closed.");
            }
        }
    }
}