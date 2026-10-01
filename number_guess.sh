#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess_game -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

if [[ -z $USER_ID ]]
then
  # New user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  # Existing user
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id = $USER_ID")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) FROM games WHERE user_id = $USER_ID")
  
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
TRIES=0

echo -e "\nGuess the secret number between 1 and 1000:"

while true
do
  read GUESS

  # Check if input is a valid integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((TRIES++))

  if (( GUESS > SECRET_NUMBER ))
  then
    echo "It's lower than that, guess again:"
  elif (( GUESS < SECRET_NUMBER ))
  then
    echo "It's higher than that, guess again:"
  else
    # Correct guess: record the game in the database and exit
    INSERT_GAME=$($PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $TRIES)")
    echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done