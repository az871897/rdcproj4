#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

EXTRACT(){
  EXTRACT_DATA=$($PSQL "SELECT symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius, type FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER;")
  echo "$EXTRACT_DATA" | while IFS="|" read SYMBOL NAME ATOMIC_MASS MELTING_POINT_CELSIUS BOILING_POINT_CELSIUS TYPE
    do echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_CELSIUS celsius and a boiling point of $BOILING_POINT_CELSIUS celsius."
  done
}

FAIL(){
  echo I could not find that element in the database.
}

: '
ISSYMBOL(){
   echo Received.
   SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE symbol='$LOAD'")
   if [[ -z $SYMBOL ]]
   then
   FAIL
   else echo $($PSQL "SELECT name FROM elements where symbol='$SYMBOL'")
   fi
}

ISNUMBER() {
  ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$LOAD")
  if [[ -z $ATOMIC_NUMBER ]]
  then 
  SYMBOL "$LOAD"
  else 
  EXTRACT "$ATOMIC_NUMBER"
  fi
}
'

CHECK() {
  if [[ $1 ]]
  then
  LOAD=$1
    if [[ $LOAD =~ ^([1-9]|10)$ ]]
    then
    ATOMIC_NUMBER=$LOAD
    EXTRACT "$ATOMIC_NUMBER"
    elif [[ $LOAD =~ ^[a-zA-Z]{1,2}$ ]]
    then
      CHECK=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$LOAD'")
      if [[ -z $CHECK ]]
      then 
      FAIL
      else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$LOAD'")
      EXTRACT "$ATOMIC_NUMBER"
      fi
    elif [[ $LOAD =~ ^[a-zA-Z]{3,}$ ]]
      then
      CHECK=$($PSQL "SELECT atomic_number FROM elements WHERE name='$LOAD'")
      if [[ -z $CHECK ]]
      then
      FAIL
      else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$LOAD'")
      EXTRACT "$ATOMIC_NUMBER"
      fi
    else
    FAIL
    fi
  else
  echo "Please provide an element as an argument."
  fi
}


CHECK "$1"
