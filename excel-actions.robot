*** Settings ***
Documentation       Excel Operations

Library             RPA.HTTP
Library             RPA.Tables
Library             RPA.FileSystem


*** Variables ***
${PATH_TO_ORDER_FILE}       temp/orders.csv


*** Keywords ***
Download CSV To Temp
    [Documentation]    download the order.csv to temp file
    [Arguments]    ${url}

    TRY
        Download    ${url}    target_file=${PATH_TO_ORDER_FILE}    overwrite=${True}
    EXCEPT    AS    ${err}
        Fail    ${err}
    END

Read Order File
    [Documentation]    Reads the downloaded csv and returns table

    TRY
        ${order_file_exists}    Does File Exist    ${PATH_TO_ORDER_FILE}

        IF    ${order_file_exists}
            ${orders}    Read Table From CSV    ${path_to_order_file}
            RETURN    ${orders}
        ELSE
            Fail    Order File not found in temp location: ${PATH_TO_ORDER_FILE}
        END
    EXCEPT    AS    ${err}
        Fail    ${err}
    END

Download & Read CSV
    [Documentation]    Download csv and return orders table
    [Arguments]    ${downloadUrl}
    TRY
        Download CSV To Temp    ${downloadUrl}
        @{orders}    Read Order File
        RETURN    @{orders}
    EXCEPT    AS    ${err}
        Fail    ${err}
    END
