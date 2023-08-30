*** Settings ***
Documentation       Opens the website to order robot

Library             Screenshot
Library             RPA.Browser.Selenium
Library             RPA.PDF


*** Keywords ***
Open Website
    [Documentation]    Given the url of website. It opens the website and can be used across robot
    [Arguments]    ${url}

    Open Chrome Browser    ${url}

    Log    Website is opened for processing

Close Annoying Model
    [Documentation]    close the Model

    Click Button When Visible    alias:ModalBtnOK

Select Robot Head
    [Documentation]    Selects the robot head based on order value
    [Arguments]    ${head_value}

    TRY
        IF    ${head_value} < 7
            Select From List By Value    alias:SelectHead    ${head_value}
            Log    Robot head selected: ${head_value}
        ELSE
            Fail    InvalidHeadValue: Robot head cannot be ordered.
        END
    EXCEPT    AS    ${err}
        Log    ${err}
        Fail    ${err}
    END

Select Robot Body
    [Documentation]    Select the robot body based on order value
    [Arguments]    ${body_value}

    TRY
        IF    ${body_value} < 7
            Select Radio Button    body    ${body_value}
        ELSE
            Fail    InvalidBodyValue: Robot body cannot be ordered
        END
    EXCEPT    AS    ${err}
        Log    ${err}
        Fail    ${err}
    END

Select Robot Legs
    [Documentation]    Select legs for robot based on order value
    [Arguments]    ${leg_value}

    TRY
        IF    ${leg_value} < 7
            Input Text When Element Is Visible    alias:TxtLegs    ${leg_value}
        ELSE
            Fail    InvalidLegValue: Robot legs cannot be ordered
        END
    EXCEPT    AS    ${err}
        Log    ${err}
        Fail    ${err}
    END

Update Address
    [Documentation]    Enter the shipping Address
    [Arguments]    ${order_address}

    Input Text When Element Is Visible    alias:Address    ${order_address}

Preview Robot
    [Documentation]    Click the preview button and stores robot image
    TRY
        Click Button    alias:BtnPreview
    EXCEPT    AS    ${err}
        Log    ${err}
    END

Take SnapShot
    [Documentation]    Take robot screenshot
    [Arguments]    ${order_number}    ${img_path}

    ${img_file}    Set Variable    ${img_path}${/}Order_${order_number}.jpeg
    Screenshot    alias:RobotPreview    ${img_file}
    # ${screenshot_html}    Get Element Attribute    alias:RobotPreview    outerHTML
    RETURN    ${img_file}

Order Robot
    [Documentation]    Order Robot

    &{reciept_element}    Create Dictionary    visible=${False}
    WHILE    not ${reciept_element.visible}    limit=5
        Click Button    alias:BtnOrder
        Sleep    3
        &{reciept_element}    Get Element Status    alias:DivReceipt
    END

Save Order Reciept And Embed
    [Documentation]    Store the robot reciept to pdf
    [Arguments]    ${order}    ${pdf_path}    ${screenshot}

    # Create PDF

    ${pdf_file}    Set Variable    ${pdf_path}${/}Order_${order}[Order number].pdf
    ${robot_reciept}    Get Element Attribute    alias:DivReceipt    outerHTML
    Html To Pdf    ${robot_reciept}    ${pdf_file}

    # Embed Screenshot
    Open Pdf    ${pdf_file}
    ${final_reciept}    Create List    ${screenshot}
    ${order_file}    Add Files To Pdf    ${final_reciept}    ${pdf_file}    ${True}

Order Another Robot
    [Documentation]    Order another robot

    Click Element If Visible    alias:btnOrderAgain

Process Order
    [Documentation]    Process individual order
    [Arguments]    ${order}    ${path_img}    ${path_pdf}

    Close Annoying Model
    Select Robot Body    ${order}[Body]
    Select Robot Head    ${order}[Head]
    Select Robot Legs    ${order}[Legs]
    Update Address    ${order}[Address]
    Preview Robot
    ${img}    Take SnapShot    ${order}[Order number]    ${path_img}
    Order Robot
    Save Order Reciept And Embed    ${order}    ${path_pdf}    ${img}
    Order Another Robot
