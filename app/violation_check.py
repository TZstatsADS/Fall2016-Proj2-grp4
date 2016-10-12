import selenium
from selenium import webdriver
import pandas as pd

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
    driver.find_element_by_id('search_next').click()
    try:
        summary = driver.find_element_by_class_name('results-summary-label').text
#         money_owned = driver.find_element_by_class_name('total-amount-owed-value').text
#         print summary,money_owned
        col_length = len(driver.find_elements_by_class_name('expander-icon'))
        for i in range(col_length):
            driver.find_elements_by_class_name('expander-icon')[i].click()
        item_length = len(driver.find_elements_by_class_name('violation-title'))
        violation_df = pd.DataFrame(columns = ['Summon_Number','Description','Penalty','Issue_time'])
        for i in range(item_length):
            violation_number = dict()
            violation_number['Summon_Number'] = driver.find_elements_by_xpath('//div/ul/li/span[contains(text(),"Violation #: ")]/following-sibling::span[@class="violation-details-single-value1"]')[i].text
            violation_number['Description'] = driver.find_elements_by_class_name('violation-title')[i].text.split(':')[0]
            violation_number['Penalty'] = driver.find_elements_by_class_name('violation-value')[i].text
            violation_number['Issue_time'] = driver.find_elements_by_xpath('//div/ul/li/span[contains(text(),"/")]')[i].text
            violation_df = violation_df.append(violation_number,ignore_index=True)
        driver.close()
        return(violation_df.to_dict(orient = "list"))
    
    except:
        driver.close()
        return("The plate number was not found. Please verify the plate number, state and type values and search again. Please note if your ticket was recently issued or if you have no outstanding violations, your plate information will not be found. If you wish to pay a ticket you just received, search by the ticket number to ensure it has not been entered into the system. ")
    