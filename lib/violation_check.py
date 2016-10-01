import selenium
from selenium import webdriver

def Ticket_check(plate_number):
    driver_path = '/Users/pengfeiwang/Downloads/ots/chromedriver'
    driver = webdriver.Chrome(driver_path)
    url = 'http://www1.nyc.gov/nyc-resources/service/2195/pay-a-parking-ticket'
    driver.get(url)
    try:
        driver.find_element_by_xpath('//div/button[@class="lg-proactive__button lg-proactive__button--deny"]').click()
    except:
        pass
    driver.find_element_by_xpath('//div/p/a[@class="arrow-link small link-bold link-arrow-blue"]').click()
    driver.find_element_by_css_selector('input[name=\"args.PLATE\"]').send_keys(plate_number)
    try:
        driver.find_element_by_id('search_next').click()
        summary = driver.find_element_by_class_name('results-summary-label').text
        money_owned = driver.find_element_by_class_name('total-amount-owed-value').text
        print summary,money_owned
    except:
        print "The plate number was not found. Please verify the plate number, state and type values and search again. Please note if your ticket was recently issued or if you have no outstanding violations, your plate information will not be found. If you wish to pay a ticket you just received, search by the ticket number to ensure it has not been entered into the system. "
    driver.close()
