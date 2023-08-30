*** Settings ***
Documentation       Orders robot from RobotSpareBin Industries INC.
...                 Saves the order HTML reciept as PDF file
...                 Saves the screeenshot of the ordered robot

Library             RPA.Archive
Resource            browser-actions.robot
Resource            excel-actions.robot


*** Variables ***
${URL}              https://robotsparebinindustries.com/#/robot-order
${DOWNLOAD_URL}     https://robotsparebinindustries.com/orders.csv
${OUTPUT_PATH}      ${CURDIR}${/}reciepts
${IMAGES_PATH}      ${OUTPUT_PATH}${/}images
${PDF_PATH}         ${OUTPUT_PATH}${/}pdf


*** Tasks ***
Open Website & Download CSV
    [Documentation]    Main task

    # Save Html To PDF
    TRY
        # Download orders.csv to temp location and store it in a table
        @{temp_orders}    Download & Read CSV    ${DOWNLOAD_URL}
        Log    Orders csv downloaded.

        Set Global Variable    @{ORDERS}    @{temp_orders}

        # Opens RobotsBinSpareParts website
        Open Website    ${URL}
        Log    Website opened: ${URL}
    EXCEPT    AS    ${err}
        Fail    ${err}
    END

Process All Orders
    [Documentation]    Processing orders

    Log    Process all orders started

    # Loop through each order
    FOR    ${order}    IN    @{ORDERS}
        TRY
            # Process each order and handle exception.
            # Handle exception on error and continue with next order
            Log    ${order}
            Process Order    ${order}    ${IMAGES_PATH}    ${PDF_PATH}
        EXCEPT    AS    ${err}
            Log    Error while processing order ${order}. Error msg: ${err}
        END
    END

    Archive Folder With Zip    ${PDF_PATH}    ${OUTPUT_PATH}${/}reciepts.zip

    Log    All the orders are processed.
