package dev.galasa.nextgenbank.uitesting1.e2etesting;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.ArrayList;
import java.util.List;

import org.openqa.selenium.WebElement;

import dev.galasa.AfterClass;
import dev.galasa.BeforeClass;
import dev.galasa.Test;
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
        // Allocate the web page and open the target URL
        webPage = webDriver.allocateWebPage("http://10.10.1.135:200");
        failureMessages = new ArrayList<>(); // Initialize the failure messages list
    }

    @AfterClass
    public void tearDown() {
        try {
            if (webDriver != null && webDriver instanceof org.openqa.selenium.WebDriver) {
                ((org.openqa.selenium.WebDriver) webDriver).quit(); // Cast to Selenium WebDriver and quit
            } else {
                System.err.println("webDriver is not an instance of Selenium WebDriver.");
            }
        } catch (Exception e) {
            System.err.println("Failed to quit the WebDriver: " + e.getMessage());
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

    @Test
    public void verifyBalance() {
        boolean hasErrors = false; // Flag to track if any balances failed validation
        List<String> balanceFailureMessages = new ArrayList<>(); // List to collect balance failure messages

        try {
            System.out.println("Clicking on the current account link.");
            webPage.findElementByCssSelector(".bank").click(); // Click the current account link
            waitForUrlContains("/transaction"); // Ensure we're on the right page

            // Wait for the balance cells container to be present
            WebElement balanceCellsContainer = webPage.findElementByCssSelector(".table-container");
            waitForElementToBePresent(balanceCellsContainer); // Custom method to wait for element presence
            System.out.println("Balance cells container found.");

            // Locate all balance column cells using CSS selector
            List<WebElement> balanceColumnCells = webPage.findElementsByCssSelector(".table-container td:nth-child(6)");
            System.out.println("Number of balance cells found: " + balanceColumnCells.size());

            for (int i = 0; i < balanceColumnCells.size(); i++) {
                String balanceText = balanceColumnCells.get(i).getText().trim();
                System.out.println("Balance for transaction " + (i + 1) + ": " + balanceText);

                try {
                    String cleanedBalanceText = balanceText.replace("USD", "").replace(",", "").trim();
                    float balanceValue = Float.parseFloat(cleanedBalanceText);
                    System.out.println("Parsed Balance for Transaction " + (i + 1) + ": " + balanceValue);

                    // Check if the balance is zero and log a failure without throwing an exception
                    if (balanceValue == 0) {
                        hasErrors = true;
                        String failureMessage = "Balance is displayed as zero for transaction row " + (i + 1);
                        balanceFailureMessages.add(failureMessage);
                        System.err.println(failureMessage); // Log the failure
                    }

                } catch (NumberFormatException e) {
                    String errorMessage = "Error parsing balance for transaction row " + (i + 1) + ": " + e.getMessage();
                    balanceFailureMessages.add(errorMessage);
                    System.err.println(errorMessage); // Log the parsing error
                }
            }

            // Log overall result after processing all balances
            if (hasErrors) {
                System.err.println("Test case 'verifyBalance' completed with failures: " + balanceFailureMessages.size());
                balanceFailureMessages.forEach(System.err::println); // Print all failure messages
            } else {
                System.out.println("All balances are non-zero. Test passed.");
            }

        } catch (Exception e) {
            System.err.println("Test case 'verifyBalance' encountered an unexpected error: " + e.getMessage());
            hasErrors = true; // Mark as having errors
        } finally {
            if (hasErrors) {
                // Instead of throwing an exception, we log the errors and record the failure
                System.err.println("Balance verification failed with messages: " + balanceFailureMessages);
                // You can choose to use an assertion here if you want to log this as a failure but continue executing tests.
                // Uncomment the line below if you wish to treat this as a test failure.
                 assertThat(balanceFailureMessages).isEmpty();
            }
        }
    }

    @Test
    public void backButtonFunctionality() {
        try {
            System.out.println("Testing back button functionality.");
            webPage.findElementByCssSelector(".back-button").click();
            waitForUrlContains("/dashboard");

            System.out.println("Back button functionality verified. Current URL: " + webPage.getCurrentUrl());
            assertThat(webPage.getCurrentUrl()).contains("/dashboard");
        } catch (Exception e) {
            String message = "Test case 'backButtonFunctionality' failed: " + e.getMessage();
            System.err.println(message);
            failureMessages.add(message); // Collect failure message
        }
    }

    @Test
    public void logoutFunctionality() {
        try {
            System.out.println("Testing logout functionality.");
            webPage.findElementById("logout_button").click();
            waitForUrlContains("/home");

            System.out.println("Logout successful. Current URL: " + webPage.getCurrentUrl());
            assertThat(webPage.getCurrentUrl()).contains("/home");
        } catch (Exception e) {
            String message = "Test case 'logoutFunctionality' failed: " + e.getMessage();
            System.err.println(message);
            failureMessages.add(message); // Collect failure message
        }
    }

    // Custom method to wait for an element to be present
    private void waitForElementToBePresent(WebElement element) {
        int attempts = 0;
        final int maxAttempts = 10; // Maximum number of attempts
        final int waitTime = 1000; // Wait time in milliseconds

        while (attempts < maxAttempts) {
            if (element.isDisplayed()) {
                return; // Element is present and displayed
            }
            attempts++;
            try {
                Thread.sleep(waitTime); // Wait before retrying
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt(); // Restore interrupted status
                throw new RuntimeException("Thread was interrupted during wait.", e);
            }
        }
        System.err.println("Element was not found after waiting: " + element);
    }

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

