*** Settings ***
Documentation    Suite description
Library  Selenium2Library
Library  String
Library  DateTime
Library  scripts_for_initial_test.py


*** Variables ***

${host}=  https://dp.gov.auction/


*** Test Cases ***

Auctions view test

    Prepare environment
    Test tubs auctions
    Test elastic auction_id search
    Test elastic auction_name search
    Test elastic auction_company_name search
    Test view registration and authorization

Documents view test

    Test tubs documents
    Test view participant agreement


Privatization view test

    Test tubs privatization
    Test assets search
    Test contracting search
    Test lots search


*** Keywords ***

Prepare environment
    ${chromeOptions}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
#    Call Method    ${chromeOptions}    add_argument    --headless
    Create Webdriver  Chrome  chrome_options=${chromeOptions}
    Set Window Size  1024  10000
    Go To  ${host}


#------------------------------------Auctions view test---------------------------------------------------------

Test tubs auctions
    Go To  ${host}tenders/index
    Click Element	xpath=(//a[@class="dropdown-toggle"])[1]
    ${type_index}=  Get Element Count  xpath=//ul[@id="w2"]/descendant::*[contains(@href,"${host}tenders/")]
    ${type_index}=  Convert To Integer   ${type_index}
    :FOR  ${t_index}  IN RANGE  ${type_index}
    \    Wait and Click  xpath=//ul[@id="w2"]/descendant::*[contains(@href,"${host}tenders/")][${t_index + 1}]
    \    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=(//div[@class="search-result_t"])[1]
    \    Test auction view
    \    Go To  ${host}/tenders/index
    \    Click Element	xpath=(//a[@class="dropdown-toggle"])[1]


Test auction view
    Go To  ${host}tenders/index
    Wait Until Element Is Visible  xpath=//a[@class="mk-btn mk-btn_default"]
    ${auction_index}=  Get Element Count  xpath=//a[@class="mk-btn mk-btn_default"]
    ${auction_index}=  Convert To Integer   ${auction_index}
    :FOR  ${a_index}  IN RANGE  ${auction_index}
    \    Scroll To Element  xpath=(//a[@class="mk-btn mk-btn_default"])[${a_index + 1}]
    \    Wait and Click  xpath=(//a[@class="mk-btn mk-btn_default"])[${a_index + 1}]
    \    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//a[@data-test-id="sidebar.questions"]
    \    Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
         ...  Wait and Click  xpath=//a[@data-test-id="sidebar.questions"]
         ...  AND  Wait Until Keyword Succeeds  5 x  1 s  Element Should Be Visible  xpath=//a[@data-test-id="sidebar.info"]
    \    Go To  ${host}/tenders/index


Test elastic auction_id search
    Go To  ${host}/tenders/index
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=(//div[@class="search-result_t"])[1]
    ${auction_id}=  Get Text  xpath=(//div[@class="search-result_t"])[1]
    Wait and Click  xpath=//span[@id="more-filter"]
    Select From List By Value  xpath=//select[@id="attribute-select"]  tender_cbd_id
    Wait Until Element Is Visible  xpath=//input[@id="attribute-input"]
    Input Text  xpath=//input[@id="attribute-input"]  ${auction_id}
    Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
    ...  Click Element  xpath=//a[@id="search"]
    ...  AND  Wait and Click  xpath=//a[@class="mk-btn mk-btn_default"]
    ...  AND  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//a[@data-test-id="sidebar.questions"]


Test elastic auction_name search
    Go To  ${host}/tenders/index
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=(//div[@class="search-result_article"])[1]
    ${auction_name}=  Get Text  xpath=(//div[@class="search-result_article"])[1]
    Wait and Click  xpath=//span[@id="more-filter"]
    Select From List By Value  xpath=//select[@id="attribute-select"]  titleFuzzy
    Wait Until Element Is Visible  xpath=//input[@id="attribute-input"]
    Select From List By Value  xpath=//select[@id="attribute-select"]  title
    Input Text  xpath=//input[@id="attribute-input"]  ${auction_name}
    Click Element  xpath=//a[@id="search"]
    Wait and Click  xpath=//a[@class="mk-btn mk-btn_default"]
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//a[@data-test-id="sidebar.questions"]


Test elastic auction_company_name search
    Go To  ${host}/tenders/index
    Wait Until Element Is Visible  xpath=(//div[@class="search-result_bank"])[1]
    ${auction_company_name}=  Get Text  xpath=(//div[@class="search-result_bank"])[1]
    ${auction_company_name}=  adapt_company_name  ${auction_company_name}
    Wait and Click  xpath=//span[@id="more-filter"]
    Wait Until Element Is Visible  xpath=//input[@id="company_name"]
    Input Text  xpath=//input[@id="company_name"]  ${auction_company_name}
    Click Element  xpath=//a[@id="search"]
    Wait and Click  xpath=//a[@class="mk-btn mk-btn_default"]
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//a[@data-test-id="sidebar.questions"]


#--------------------------------------Documents view test-------------------------------------------------------------


Test tubs documents
    Go To  ${host}
    Click Element	xpath=(//a[@class="dropdown-toggle"])[2]
    Wait Until Element Is Visible  xpath=//ul[@id="w5"]/descendant::*[contains(@href,"${host}pages/customer")]
    ${doc_index}=  Get Element Count  xpath=//ul[@id="w5"]/descendant::*[contains(@href,"${host}pages/customer")]
    ${doc_index}=  Convert To Integer   ${doc_index}
    :FOR  ${d_index}  IN RANGE  ${doc_index}
    \    ${doc_type}=  Get Element Attribute  xpath=(//ul[@id="w5"]/descendant::*[contains(@href,"${host}pages/customer")])[${d_index + 1}]  href
    \    Run Keyword If  'rates' in '${doc_type}'  Test view participant rates  ${d_index}
         ...  ELSE IF  'claims' in '${doc_type}'   Test view claims  ${d_index}
         ...  ELSE IF  'customers/customers' in '${doc_type}'   Test view sales instruction  ${d_index}
         ...  ELSE IF  'contacts' in '${doc_type}'    Test view contacts  ${d_index}
    \    Go To  ${host}
    \    Click Element	xpath=(//a[@class="dropdown-toggle"])[2]


Test view participant rates
    [Arguments]  ${d_index}
    Go To  ${host}
    Wait and Click  xpath=(//a[@class="dropdown-toggle"])[2]
    Wait and Click  xpath=//ul[@id="w5"]/descendant::*[contains(@href,"${host}pages/customer")][${d_index+ 1}]
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[@class="page-header"]//*[contains(text(),"Тарифи")]


Test view claims
    [Arguments]  ${d_index}
    Go To  ${host}
    Wait and Click  xpath=(//a[@class="dropdown-toggle"])[2]
    Wait and Click  xpath=//ul[@id="w5"]/descendant::*[contains(@href,"${host}pages/customer")][${d_index+ 1}]
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[@class="page-header"]//*[contains(text(),"Зразки заяв")]
#    """"will be done later""""
#    ${file_index}=  Get Element Count  xpath=//*[contains(@href,"/uploads/pages/files")]
#    ${file_index}=  Convert To Integer  ${file_index}
#    :FOR  ${f_index}  IN RANGE  ${file_index}
#    \    Wait and Click  xpath=(//*[contains(@href,"/uploads/pages/files")])[${f_index + 2}]
#    \    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//embed[@type="application/pdf"] """"will be done later""""
#    \    Go TO  ${host}pages/customers/regulation


Test view sales instruction
    [Arguments]  ${d_index}
    Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
    ...  Wait and Click  xpath=(//a[@class="dropdown-toggle"])[2]
    ...  AND  Wait and Click  xpath=//ul[@id="w5"]/descendant::*[contains(@href,"${host}pages/customer")][${d_index+ 1}]
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[@class="page-header"]//*[contains(text(),"Інструкція")]
    ${location}=  Get Location
    ${file_index}=  Get Element Count  xpath=//*[contains(@href,"/uploads/pages/files")]
    ${file_index}=  Convert To Integer  ${file_index}
    :FOR  ${f_index}  IN RANGE  ${file_index}
    \    Wait and Click  xpath=(//*[contains(@href,"/uploads/pages/files")])[${f_index + 1}]
    \    Run Keyword If  '${location}' == '${host}pages/customers/customers'  Wait Until Keyword Succeeds  5 x  1 s  Element Should Be Visible  xpath=//embed[@type="application/pdf"]
    \    Go TO  ${host}pages/customers/customers


Test view guidelines
    [Arguments]  ${d_index}
    Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
    ...  Wait and Click  xpath=(//a[@class="dropdown-toggle"])[2]
    ...  AND  Wait and Click  xpath=//ul[@id="w5"]/descendant::*[contains(@href,"${host}pages/customer")][${d_index+ 1}]
    ${file_index}=  Get Element Count  xpath=//*[contains(@href,"/uploads/pages/files")]
    ${file_index}=  Convert To Integer  ${file_index}
    :FOR  ${f_index}  IN RANGE  ${file_index}
    \    Wait and Click  xpath=(//*[contains(@href,"/uploads/pages/files")and contains(text(),"Інструкція")])[${f_index + 1}]
    \    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//embed[@type="application/pdf"]
    \    Go TO  ${host}pages/customers/guidelines


Test view contacts
    [Arguments]  ${d_index}
    Wait Until Keyword Succeeds  10 x  1 s  Run Keywords
    ...  Wait and Click  xpath=(//a[@class="dropdown-toggle"])[2]
    ...  AND  Wait and Click  xpath=//ul[@id="w5"]/descendant::*[contains(@href,"${host}pages/customer")][${d_index+ 1}]
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[@class="page-header"]//*[contains(text(),"Контакти")]


Test view participant agreement
    Go To  ${host}
    Wait and Click  xpath=(//a[@class="dropdown-toggle"])[3]
    ${file_index}=  Get Element Count  xpath=//*[@id="w6"]//*[contains(@href,"/pages/regulations")]
    ${file_index}=  Convert To Integer  ${file_index}
    :FOR  ${f_index}  IN RANGE  ${file_index}
    \    Wait and Click	xpath=(//ul[@id="w6"]/descendant::*[contains(@href,"${host}pages/regulations/")])[${f_index + 1}]
    \    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//div[@class="page-header"]//*[contains(text(),"Договір")]
    \    Go To  ${host}
    \    Wait and Click  xpath=(//a[@class="dropdown-toggle"])[3]


#--------------------------------------Privatization view test---------------------------------------------------


Test tubs privatization
    Go To  ${host}/tenders/index
    Click Element	xpath=(//a[@class="dropdown-toggle"])[4]
    ${tab_index}=  Get Element Count  xpath=//ul[@id="w5"]/descendant::*[contains(@href,"${host}")]
    ${tab_index}=  Convert To Integer   ${tab_index}
    :FOR  ${t_index}  IN RANGE  ${tab_index}
    \    Wait and Click  xpath=(//ul[@id="w5"]/descendant::*[contains(@href,"${host}")])[${t_index + 1}]
    \    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//a[@class="mk-btn mk-btn_default"]
    \    Test privatization view
    \    Go To  ${host}/tenders/index
    \    Click Element	xpath=(//a[@class="dropdown-toggle"])[4]

Test privatization view
    Go To  ${host}/tenders/index
    ${mp_index}=  Get Element Count  xpath=//a[@class="mk-btn mk-btn_default"]
    ${mp_index}=  Convert To Integer   ${mp_index}
    :FOR  ${a_index}  IN RANGE  ${mp_index}
    \    Scroll To Element  xpath=(//a[@class="mk-btn mk-btn_default"])[${a_index + 1}]
    \    Wait and Click  xpath=(//a[@class="mk-btn mk-btn_default"])[${a_index + 1}]
    \    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//*[@data-test-id="title"]
    \    Go To  ${host}/tenders/index


Test assets search
    Go To  ${host}/assets/index
    ${asset_id}=  Get Text  xpath=(//*[@class="search-result_t"])[1]
    Wait and Click  xpath=//*[@id="slide-more-filter"]
    Wait Until Keyword Succeeds  5 x  1 s  Element Should Be Visible  xpath=//*[@id="assetssearch-minamount"]
    Input Text  xpath=//*[@id="assetssearch-asset_cbd_id"]  ${asset_id}
    Click Element  xpath=//*[@data-test-id="search"]
    Wait Until Keyword Succeeds  10 x  3 s  Run Keywords
    ...  Wait Until Keyword Succeeds  5x  1s   Page Should Contain Element  xpath=//a[@class="mk-btn mk-btn_default"]
    ...  AND  Wait and Click  xpath=//a[@class="mk-btn mk-btn_default"]
    ...  AND  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//*[@data-test-id="title"]
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//*[@data-test-id="title"]


Test contracting search
    Go To  ${host}/contracting
    ${contract_id}=  Get Text  xpath=(//*[@class="search-result_article"])[1]
    Input Text  xpath=//*[@id="contractingsearch-contract_cbd_id"]  ${contract_id}
    Click Element  xpath=//*[@data-test-id="search"]
    Wait Until Keyword Succeeds  10 x  3 s  Run Keywords
    ...  Wait Until Keyword Succeeds  5x  1s   Page Should Contain Element  xpath=//a[@class="mk-btn mk-btn_default"]
    ...  AND  Wait and Click  xpath=//a[@class="mk-btn mk-btn_default"]
    ...  AND  Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  xpath=//*[@data-test-id="title"]
    Wait Until Keyword Succeeds  5 x  1 s  Element Should Be Visible  xpath=//*[@data-test-id="title"]


Test lots search
    Go To  ${host}/lots/index
    ${lot_id}=  Get Text  xpath=(//*[@class="search-result_article"])[1]
    Input Text  xpath=//*[@id="lotssearch-lot_cbd_id"]  ${lot_id}
    Click Element  xpath=//*[@data-test-id="search"]
    Wait and Click  xpath=//a[@class="mk-btn mk-btn_default"]
    Wait Until Keyword Succeeds  5 x  1 s  Element Should Be Visible  xpath=//*[@data-test-id="lotID"]


Test view registration and authorization
    Go To  ${host}/register
    Element Should Be Visible  xpath=//button[@id="btn-submitform"]
    Go To  ${host}/login
    Element Should Be Visible  xpath=//button[@name="login-button"]


Wait and Click
    [Arguments]  ${locator}
    Wait Until Element Is Visible  ${locator}
    Scroll To Element  ${locator}
    Click Element  ${locator}


Scroll To Element
    [Arguments]  ${locator}
    Wait Until Page Contains Element  ${locator}  10
    Wait Until Keyword Succeeds  10 x  1 s  Element Should Be Visible  ${locator}
    ${elem_vert_pos}=  Get Vertical Position  ${locator}
    ${elem_gor_pos}=  Get Horizontal Position  ${locator}
    Execute Javascript  window.scrollTo(0,${elem_vert_pos - 300});
