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
    echo "3) View Monthly Summary"
    echo "4) View All Transactions"
    echo "5) Delete Transaction Summary"
    echo -e "\n~~~~~ CATEGORIES ~~~~~\n"
    echo "6) Add Category"
    echo "7) View All Category"
    echo "8) Delete Category"
    echo -e "\n9) Exit"
    read MAIN_MENU_SELECTION

    case $MAIN_MENU_SELECTION in
        1) ADD_TRANSACTION ;;
        2) VIEW_TRANSACTION_BY_CATEGORY ;;
        3) VIEW_MONTHLY_SUMMARY ;; 
        4) VIEW_ALL_TRANSACTIONS ;;
        5) DELETE_TRANSACTION ;;
        6) ADD_CATEGORY ;;
        7) VIEW_ALL_CATEGORY ;;
        8) DELETE_CATEGORY ;;
        9) EXIT ;;
        *) MAIN_MENU "Please Enter A Valid Option."
    esac
}

ADD_TRANSACTION() {

}

VIEW_TRANSACTION_BY_CATEGORY() {

}

VIEW_MONTHLY_SUMMARY() {

}

DELETE_TRANSACTION() {

}

ADD_CATEGORY() {

}

VIEW_ALL_CATEGORY() {

}

DELETE_CATEGORY() {

}

EXIT() {
    echo -e "\nThank You For Using Money Track!\n"
}

MAIN_MENU