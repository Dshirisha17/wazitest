package dev.galasa.nextgenbank.uitesting1.e2etesting;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;

import dev.galasa.AfterClass;
import dev.galasa.BeforeClass;
import dev.galasa.Test;
import dev.galasa.selenium.IChromeOptions;
import dev.galasa.selenium.IWebDriver;
import dev.galasa.selenium.IWebPage;
import dev.galasa.selenium.SeleniumManagerException;
import dev.galasa.selenium.WebDriver;

@Test
public class TestE2etesting {

    @WebDriver
    public IWebDriver webDriver;

    private IWebPage webPage;
    private final long timeoutMillis = 120000; // 120 seconds timeout
    private List<String> failureMessages; // List to collect failure messages

    @BeforeClass
    public void setUp() throws SeleniumManagerException {
        // Configure ChromeOptions
        IChromeOptions chromeOptions = webDriver.getChromeOptions();
        chromeOptions.addArgument("--headless");                      // Headless mode
        chromeOptions.addArgument("--disable-gpu");                   // Disable GPU usage
        chromeOptions.addArgument("--no-sandbox");                    // Disable sandbox
        chromeOptions.addArgument("--disable-dev-shm-usage");         // Prevent shared memory issues in Docker
        chromeOptions.addArgument("--remote-debugging-port=9222");    // Remote debugging on port 9222
        chromeOptions.addArgument("--disable-software-rasterizer");   // Disable software rasterizer
        chromeOptions.addArgument("--disable-notifications");         // Disable notifications
        chromeOptions.addArgument("--start-maximized");               // Start browser maximized

        // Allocate the web page and open the target URL
        webPage = webDriver.allocateWebPage("http://10.10.1.135:200");
        failureMessages = new ArrayList<>(); // Initialize the failure messages list

        // Log the browser capabilities if needed
        System.out.println("Browser capabilities: " + webDriver.getCapabilities());
    }

    @AfterClass
    public void tearDown() {
        try {
            if (webDriver != null) {
                webDriver.closeAllWindows(); // Close all browser windows
            }
        } catch (Exception e) {
            System.err.println("Failed to close the WebDriver: " + e.getMessage());
        }

        // Log any failure messages that were collected during the tests
        if (!failureMessages.isEmpty()) {
            System.err.println("Test failures encountered:");
            for (String message : failureMessages) {
                System.err.println(message);
            }
            throw new RuntimeException("Some tests failed. See above for details.");
        }
    }

    @Test
    public void loginAndVerify() {
        try {
            System.out.println("Navigating to the login page.");
            webPage.findElementById("login_button").click();
            waitForElementVisibility("login-form");

            System.out.println("Entering username and password.");
            webPage.findElementById("username").sendKeys("sandhata_demo");
            webPage.findElementById("password").sendKeys("sandhata");

            System.out.println("Submitting the login form.");
            webPage.findElementByCssSelector(".submit-button").click();

            // Wait for the dashboard page to be reached
            waitForUrlContains("http://10.10.1.135:200/dashboard");

            System.out.println("Login successful. Current URL: " + webPage.getCurrentUrl());
            assertThat(webPage.getCurrentUrl()).isEqualTo("http://10.10.1.135:200/dashboard");
        } catch (Exception e) {
            String message = "Test case 'loginAndVerify' failed: " + e.getMessage();
            System.err.println(message);
            failureMessages.add(message); // Collect failure message
        }
    }

    // Add other test cases here...

    private void waitForElementVisibility(String elementId) throws SeleniumManagerException {
        long startTime = System.currentTimeMillis();
        while (System.currentTimeMillis() - startTime < timeoutMillis) {
            if (webPage.findElementById(elementId).isDisplayed()) {
                return; // Element is visible
            }
            sleep(500); // Sleep before retrying
        }
        throw new RuntimeException("Element with ID '" + elementId + "' not visible after waiting for " + (timeoutMillis / 1000) + " seconds.");
    }

    private void waitForUrlContains(String partialUrl) throws SeleniumManagerException {
        long startTime = System.currentTimeMillis();
        while (System.currentTimeMillis() - startTime < timeoutMillis) {
            if (webPage.getCurrentUrl().contains(partialUrl)) {
                return; // URL contains the expected value
            }
            sleep(500); // Sleep before retrying
        }
    }

    private void sleep(long milliseconds) {
        try {
            Thread.sleep(milliseconds);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt(); // Restore interrupted status
        }
    }
}
