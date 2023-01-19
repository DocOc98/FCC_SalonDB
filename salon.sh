#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c "

echo -e "\n~~~~~ MY SALON ~~~~~\n"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  LIST_SERVICES=$($PSQL "SELECT * FROM services;")
  echo "$LIST_SERVICES" | while read SERVICE_ID BAR SERVICE
  do
    echo "$SERVICE_ID) $SERVICE"
  done
  read SERVICE_ID_SELECTED

  GET_SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  if [[ -z $GET_SERVICE ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else
    START_SERVICE $SERVICE_ID_SELECTED $GET_SERVICE
  fi
}
START_SERVICE(){
  SERVICE_ID_SELECTED=$1
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';" | sed -r 's/^ *| *$//g')
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | sed -r 's/^ *| *$//g')
  fi
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;" | sed -r 's/^ *| *$//g')
  echo -e "\nWhat time would you like your $2, $CUSTOMER_NAME?"
  read SERVICE_TIME
  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
  if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}
echo -e "\n Welcome to My Salon, how can I help you?"
MAIN_MENU