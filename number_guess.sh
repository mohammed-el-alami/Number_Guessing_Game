#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo "Enter your username:"
read USERNAME
USERNAME_LENGTH=${#USERNAME}


if [[ $USERNAME_LENGTH -gt 22 || $USERNAME_LENGTH -eq 0 ]]
then
  echo "Invalid username length."
  exit
fi


USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
else
  GAMES_PLAYED=$($PSQL "SELECT frequent_games FROM users WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(best_guess) FROM games WHERE user_id=$USER_ID;")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi


SECRET=$(( RANDOM % 1000 + 1 ))
TRIES=0
echo "Guess the secret number between 1 and 1000:"

while true
do
  read GUESS

  if ! [[ "$GUESS" =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((TRIES++))

  if [[ $GUESS -lt $SECRET ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $GUESS -gt $SECRET ]]
  then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"

    UPDATE_USER=$($PSQL "UPDATE users SET frequent_games = frequent_games + 1 WHERE user_id=$USER_ID;")
   
    INSERT_GAME=$($PSQL "INSERT INTO games(user_id, best_guess) VALUES($USER_ID, $TRIES);")
    break
  fi
done
# chore: updated script for commit requirement


# test: another minor update
# refactor: spacing
