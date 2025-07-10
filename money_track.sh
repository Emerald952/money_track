#!/bin/bash

# IMPORTANT: Replace 'diksha' with your PostgreSQL username and 'salon' with your database name.
PSQL="psql -X --username=diksha --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Money Track ~~~~~\n"
MAIN_MENU(){
    if [[ $1 ]]
    then
        echo -e "\n$1";
    fi

    echo "How may I help you?"
    echo -e "\n--- TRANSACTION ---\n"
    echo "1) Add Transaction"
    echo "2) View Transactions By Category"
    echo "3) View Transaction By Type"
    echo "4) View Monthly Summary"
    echo "5) View All Transactions"
    echo "6) Delete Transaction Summary"
    echo -e "\n~~~~~ CATEGORIES ~~~~~\n"
    echo "7) Add Category"
    echo "8) View Category by Type"
    echo "9) View All Category"
    echo "10) Delete Category"
    echo -e "\n11) Exit"
    read MAIN_MENU_SELECTION

    case $MAIN_MENU_SELECTION in
        1) ADD_TRANSACTION ;;
        2) VIEW_TRANSACTION_BY_CATEGORY ;;
        3) VIEW_TRANSACTION_BY TYPE ;;
        4) VIEW_MONTHLY_SUMMARY ;; 
        5) VIEW_ALL_TRANSACTIONS ;;
        6) DELETE_TRANSACTION ;;
        7) ADD_CATEGORY ;;
        8) VIEW_CATEGORY_BY_TYPE ;;
        9) VIEW_ALL_CATEGORY ;;
        10) DELETE_CATEGORY ;;
        11) EXIT ;;
        *) MAIN_MENU "Please Enter A Valid Option."
    esac
}

ADD_TRANSACTION() {
    echo -e "\n~~~Add New Transaction~~~\n"
    local TRANSACTION_TYPE
    while true; 
    do
        echo -e "\nChoose Transaction Type: Income or Expense (I/E)";
        read CHOICE;
        case $CHOICE in
            [Ii]) TRANSACTION_TYPE="Income"; break;;
            [Ee]) TRANSACTION_TYPE="Expense"; break;;
            *) echo "Invalid Choice!!! Please enter I for Income and E for Expense";;
        esac
    done

    echo "Enter Amount:"
    read Amount
    if [[ ! $AMOUNT =~ [0-9]+(\.[0-9]{1,2})?$ ]] || (( $(echo "$AMOUNT <= 0" | bc -l) ));
    then   
        MAIN_MENU "Invalid amount. Please enter a positive numeric value"
        return;
    fi

    echo "Enter Description (optional)"
    read DESCRIPTION

    echo "Enter transaction date (YYYY-MM-DD, Default -> today):"
    read TRANSACTION_DATE

    if [[ -z $TRANSACTION_DATE ]]
    then    
        TRANSACTION_DATE=$(date +%Y-%M-%D)
    else
        if [[ ! date -d $TRANSACTION_DATE ]]
        then   
            MAIN_MENU "Invalid Date format. Please use YYYY-MM-DD."
            return;
        fi
    fi

    VIEW_CATEGORY_BY_TYPE "$TRANSACTION_TYPE";
    echo -e "\n Choose Category ID (enter 0 to add new category)"
    read CATEGORY_ID
    if [[ $CATEGORY_ID -eq 0 ]]
    then 
        ADD_CATEGORY "$TRANSACTION_TYPE"
        CATEGORY_ID=$($PSQL "SELECT category_id FROM categories WHERE name = '$NEW_CATEGORY_NAME' AND type = '$TRANSACTION_TYPE'")
        if [[ -z CATEGORY_ID ]]
        then
            MAIN_MENU "Failed to add new category. Transaction not added..."
            return;
        fi
    else  
        CATEGORY_ID=$($PSQL "SELECT category_id FROM categories WHERE category_id = '$CATEGORY_ID' AND type = '$TRANSACTION_TYPE'")
        if [[ -z CATEGORY_ID ]]
        then
            MAIN_MENU "Category Id not found or does not match transaction type $TRANSACTION_TYPE. Transaction not added..."
            return;
        fi
    fi

    INSERT_TRANSACTION_RESULT=$($PSQL "INSERT INTO transactions(amount, description, type, category_id, transaction_date) VALUES($AMOUNT, '$DESCRIPTION', '$TRANSACTION_TYPE', $CATEGORY_ID, '$TRANSACTION_DATE')RETURNING transaction_id")
    
    MAIN_MENU "Transaction (ID :$INSERT_TRANSACTION_RESULT) Added Successfully!!!"
}

VIEW_TRANSACTION_BY_CATEGORY() {

}

VIEW_TRANSACTION_BY_TYPE(){
    
}

VIEW_MONTHLY_SUMMARY() {

}

VIEW_ALL_TRANSACTIONS(){

}

DELETE_TRANSACTION() {

}

ADD_CATEGORY() {
    local TRANSACTION_TYPE;
    echo -e "\n~~~Add New Category~~~\n"
    if [[ $1 ]]
    then    
        TRANSACTION_TYPE=$1
    else
        while true; 
        do
            echo -e "\nChoose Transaction Type: Income or Expense (I/E)";
            read CHOICE;
            case $CHOICE in
                [Ii]) TRANSACTION_TYPE="Income"; break;;
                [Ee]) TRANSACTION_TYPE="Expense"; break;;
                *) echo "Invalid Choice!!! Please enter I for Income and E for Expense" ;;
            esac
        done
    fi

    echo "Enter New Category Name:"
    read NEW_CATEGORY_NAME
    CATEGORY_EXIST=$($PSQL "SELECT name FROM categories WHERE name ILIKE $NEW_CATEGORY_NAME AND type = $TRANSACTION_TYPE")
    if [[ -z CATEGORY_EXIST ]]
    then
        INSERT_CATEGORY_RESULT=$($PSQL "INSERT INTO categories(name, type) VALUES('$NEW_CATEGORY_NAME', '$TRANSACTION_TYPE') RETURNING category_id")
        if [[ $INSERT_CATEGORY_RESULT =~ ^[0-9]+$ ]]
        then 
            echo "Category $NEW_CATEGORY_NAME (ID:$INSERT_CATEGORY_RESULT) added successfully!!!"
            return 0
        else  
            echo "Failed to add new category :("
            return 1
        fi
    else
        echo "Category $NEW_CATEGORY_NAME of type $TRANSACTION_TYPE already exists"
        return 1
    fi
}

VIEW_CATEGORY_BY_TYPE() {
    local TRANSACTION_TYPE
    if [[ $1 ]]
    then
        TRANSACTION_TYPE=$1;
    else
        while true; 
        do
            echo -e "\nChoose Transaction Type: Income or Expense (I/E)";
            read CHOICE;
            case $CHOICE in
                [Ii]) TRANSACTION_TYPE="Income"; break;;
                [Ee]) TRANSACTION_TYPE="Expense"; break;;
                *) echo "Invalid Choice!!! Please enter I for Income and E for Expense" ;;
            esac
        done
    fi
    CATEGORY_BY_TYPE=$($PSQL "SELECT category_id, name FROM categories WHERE type = '$TRANSACTION_TYPE' ORDER BY name")

    if [[ -z $CATEGORY_BY_TYPE ]]
    then 
        echo -e "No type to filter"
        return 1;
    else 
        echo -e "~~~$TRANSACTION_TYPE~~~"
        echo "$CATEGORY_BY_TYPE" | while read CATEGORY_ID BAR CATEGORY_NAME
        do  
            echo "$CATEGORY_ID) $CATEGORY_NAME"
        done
    fi
}

VIEW_ALL_CATEGORY() {

}

DELETE_CATEGORY() {

}

EXIT() {
    echo -e "\nThank You For Using Money Track!\n"
}

MAIN_MENU