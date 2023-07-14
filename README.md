# Pregnant_Pills


On this website you can create yourown list of pills,which you are taking during your pregnancy. It is very useful for your gynecologist and in case of hospital stay. You can specify if the pill is rutine or special.Rutine pills are vitamins and other complex nutrients, which you should take every day in pregnant. Special pills you use if you have illnessfor example flu, heartburn or gestational diabetes.You can download your pill's list as PDF Report.

## Table of Contents

* [General Info](#general-information)
* [Technologies Used](#technologies-used)
* [Features](#features)
* [Previews](#Previews)
* [Setup](#setup)
* [Project Status](#project-status)
* [Room for Improvement](#room-for-improvement)
* [Contact](#contact)
* [License](#license)

## General Information

This web is for pregnant women to keep information about pills, which they taken during pregnancy. On home page User can register a new account. When user is logged in, she can create a list with pills. She can add a new pill or choose from database. She also add information about time (pregnancy week). After that user get all listed pills with dates and kind of pills. User can download this list as PDF file. 

This application was created using Flask and SQLite database.

## Technologies Used

- Python - version 3.11
- Bootstrap - version 5.2.3
- Flask - version 2.2.2
- SQLAlchemy - version 1.4.45
- WTForms - version  3.0.1
- SQLite database

## Features

List the ready features here:

- Register new user,
- Add pills to list,
- Download list with pills as PDF file,

## Previews

### Home Page

![Home Page Preview](static/previews/preview_pregnant_pills.jpg)

### Register user page

![Register user page](static/previews/preview_pregnant_pills_add_user.jpg)

### Admin page - all users

![Admin page - all users](static/previews/preview_pregnant_pills_users_list..jpg)

## Setup

- Clone This Project git clone
- Enter Project Directory cd Pregnant_Pills
- Create a Virtual Environment (for Windows) py -m venv (name your virtual enviroment :) venv

'EXAMPLE: py -m venv venv'

- Activate Virtual Environment source: venv/Scripts/activate
- Install Requirements Package pip install -r requirements.txt
- Finally Run The Project: python app.py

## Project Status

Project is: _in progress_

## Room for Improvement

Room for improvement:

- Add PostgreSQL database,
- Add feature -  register user,
- Create more attractive PDF file,

To do:
- add a new Database_URI for PostgreSQL database and check models,
- create functionality that only registered user can download a PDF file with list,
- Add more information to PDF about user and about pills,

## Contact

- Created by [@RockPiryt Github](https://github.com/RockPiryt)
- My Resume [@RockPiryt Resume](https://rockpiryt.github.io/Personal_Site/)

Feel free to contact me!

## License

This project is open source and available under the [MIT License]
