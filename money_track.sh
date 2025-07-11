#!/bin/bash

# IMPORTANT: Replace 'diksha' with your PostgreSQL username and 'salon' with your database name.
PSQL="psql -X --username=diksha --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Money Track ~~~~~\n"
MAIN_MENU(){
    while true; 
    do
        if [[ $1 ]]
        then
            echo -e "\n$1";
            set -- ""
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
            3) VIEW_TRANSACTION_BY_TYPE ;;
            4) VIEW_MONTHLY_SUMMARY ;; 
            5) VIEW_ALL_TRANSACTIONS ;;
            6) DELETE_TRANSACTION_SUMMARY ;;
            7) ADD_CATEGORY ;;
            8) VIEW_CATEGORY_BY_TYPE ;;
            9) VIEW_ALL_CATEGORY ;;
            10) DELETE_CATEGORY ;;
            11) EXIT ;;
            *) echo -e "\nPlease Enter A Valid Option."
        esac
    done
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

    local AMOUNT
    echo "Enter Amount:"
    read AMOUNT
    if [[ ! $AMOUNT =~ ^[0-9]+(\.[0-9]{1,2})?$ ]] || (( $(echo "$AMOUNT <= 0" | bc -l) ));
    then   
        echo -e "\nInvalid amount. Please enter a positive numeric value\n"
        return 1
    fi

    local DESCRIPTION
    echo "Enter Description (optional)"
    read DESCRIPTION

    local TRANSACTION_DATE
    echo "Enter transaction date (YYYY-MM-DD, Default -> today):"
    read TRANSACTION_DATE

    if [[ -z $TRANSACTION_DATE ]]
    then    
        TRANSACTION_DATE=$(date +%Y-%m-%d)
    else
        if ! date -d "$TRANSACTION_DATE" &>/dev/null;
        then   
            echo -e "\nInvalid Date format. Please use YYYY-MM-DD.\n"
            return 1
        fi
    fi

    VIEW_CATEGORY_BY_TYPE "$TRANSACTION_TYPE";
    local CATEGORY_ID
    echo -e "\n Choose Category ID (enter 0 to add new category)"
    read CATEGORY_ID
    if [[ $CATEGORY_ID -eq 0 ]]
    then 
        
        CATEGORY_ID=$(ADD_CATEGORY "$TRANSACTION_TYPE")
        if [[ -z $CATEGORY_ID ]]
        then
            echo -e "\nFailed to add new category. Transaction not added...\n"
            return 1
        fi
    else  
        CATEGORY_ID=$($PSQL "SELECT category_id FROM categories WHERE category_id = $CATEGORY_ID AND type = '$TRANSACTION_TYPE'")
        if [[ -z $CATEGORY_ID ]]
        then
            echo -e "\nCategory Id not found or does not match transaction type $TRANSACTION_TYPE. Transaction not added...\n"
            return 1
        fi
    fi

    local INSERT_TRANSACTION_RESULT
    INSERT_TRANSACTION_RESULT=$($PSQL "INSERT INTO transactions(amount, description, type, category_id, transaction_date) VALUES($AMOUNT, '$DESCRIPTION', '$TRANSACTION_TYPE', $CATEGORY_ID, '$TRANSACTION_DATE')RETURNING transaction_id")
    
    echo -e "\nTransaction (ID :$INSERT_TRANSACTION_RESULT) Added Successfully!!!\n"
    return 0
}

VIEW_TRANSACTION_BY_CATEGORY() {
    VIEW_ALL_CATEGORY 

    local CATEGORY_ID
    echo -e "\n Choose Category ID"
    read CATEGORY_ID
    if [[ ! $CATEGORY_ID =~ ^[0-9]+$ ]]
    then
        echo -e "INVALID Categort_id"
        return 
    fi

    local TRANSACTION_BY_CATEGORY_RESULT
    TRANSACTION_BY_CATEGORY_RESULT=$($PSQL "SELECT * FROM transactions WHERE category_id = $CATEGORY_ID ORDER BY transaction_id")
    if [[ -z $TRANSACTION_BY_CATEGORY_RESULT ]]
    then
        echo -e "\n No transaction summary exist for this category"
        return
    else
        echo -e "\n~~~Transaction Summary of given Category~~~\n"
        echo "$TRANSACTION_BY_CATEGORY_RESULT" | while read TRANSACTION_ID AMOUNT DESCRIPTION TYPE
        do
            echo "$TRANSACTION_ID) $DESCRIPTION : $AMOUNT -> $TYPE"
        done
        return
    fi

}

VIEW_TRANSACTION_BY_TYPE(){
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

    local TRANSACTION_BY_TYPE_RESULT
    TRANSACTION_BY_TYPE_RESULT=$($PSQL "SELECT * FROM transactions WHERE type = '$TRANSACTION_TYPE' ORDER BY transaction_id")
    if [[ -z $TRANSACTION_BY_TYPE_RESULT ]]
    then
        echo -e "\n No transaction summary exist for type $TRANSACTION_TYPE"
        return
    else
        echo -e "\n~~~Transaction Summary of type $TRANSACTION_TYPE~~~\n"
        echo "$TRANSACTION_BY_TYPE_RESULT" | while read TRANSACTION_ID AMOUNT DESCRIPTION TYPE
        do
            echo "$TRANSACTION_ID) $DESCRIPTION : $AMOUNT -> $TYPE"
        done
        return
    fi
}

VIEW_MONTHLY_SUMMARY() {

}

VIEW_ALL_TRANSACTIONS(){

}

DELETE_TRANSACTION_SUMMARY() {

}

ADD_CATEGORY() {
    local TRANSACTION_TYPE;
    echo -e "\n~~~Add New Category~~~\n" >&2
    if [[ $1 ]]
    then    
        TRANSACTION_TYPE=$1
    else
        while true; 
        do
            echo -e "\nChoose Transaction Type: Income or Expense (I/E)" >&2
            read CHOICE;
            case $CHOICE in
                [Ii]) TRANSACTION_TYPE="Income"; break;;
                [Ee]) TRANSACTION_TYPE="Expense"; break;;
                *) echo "Invalid Choice!!! Please enter I for Income and E for Expense" >&2 ;;
            esac
        done
    fi

    local NEW_CATEGORY_NAME
    echo "Enter New Category Name:" >&2
    read NEW_CATEGORY_NAME
    local CATEGORY_EXIST
    CATEGORY_EXIST=$($PSQL "SELECT name FROM categories WHERE name ILIKE '$NEW_CATEGORY_NAME' AND type = '$TRANSACTION_TYPE'")
    if [[ -z $CATEGORY_EXIST ]]
    then
        local INSERT_CATEGORY_RESULT
        INSERT_CATEGORY_RESULT=$($PSQL "INSERT INTO categories(name, type) VALUES('$NEW_CATEGORY_NAME', '$TRANSACTION_TYPE') RETURNING category_id")
        if [[ $INSERT_CATEGORY_RESULT =~ ^[0-9]+$ ]]
        then 
            echo "Category $NEW_CATEGORY_NAME added successfully !!!" >&2
            echo "$INSERT_CATEGORY_RESULT"
            return 0
        else  
            echo "Failed to add new category :(" >&2
            return 1
        fi
    else
        echo "Category $NEW_CATEGORY_NAME of type $TRANSACTION_TYPE already exists" >&2
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
    local CATEGORY_BY_TYPE
    CATEGORY_BY_TYPE=$($PSQL "SELECT category_id, name FROM categories WHERE type = '$TRANSACTION_TYPE' ORDER BY name")

    if [[ -z $CATEGORY_BY_TYPE ]]
    then 
        echo -e "No categories found for type '$TRANSACTION_TYPE'"
        return 
    else 
        echo -e "\n~~~$TRANSACTION_TYPE~~~\n"
        echo "$CATEGORY_BY_TYPE" | while read CATEGORY_ID CATEGORY_NAME
        do  
            echo "$CATEGORY_ID) $CATEGORY_NAME"
        done
    fi
    return 
}

VIEW_ALL_CATEGORY() {
    local CATEGORIES
    CATEGORIES=$($PSQL "SELECT category_id, name, type FROM categories ORDER BY category_id")

    if [[ -z $CATEGORIES ]]
    then 
        echo "No category in the system"
        return 
    else
        echo -e "\n~~~Categories~~~\n"
        echo "$CATEGORIES" | while read CATEGORY_ID NAME  TYPE
        do 
            echo -e "$CATEGORY_ID) $NAME -> $TYPE"
        done
    fi
    return
}

DELETE_CATEGORY() {

}

EXIT() {
    echo -e "\nThank You For Using Money Track!\n"
}

MAIN_MENU