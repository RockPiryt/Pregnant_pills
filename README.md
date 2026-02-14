# Pregnant_Pills
This app is for pregnant women to keep information about pills, which they took during pregnancy. On home page user can register a new account or continue as guest. When user is logged in, it is possible to create a list with pills. User can add a new pill or choose from database. Pregnancy week is also required. After that user gets a list with pills (with dates and type of pills), which is avaiable to  download this list as PDF file.

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

On this website you can create your list of pills, which you are taking during your pregnancy. It is very useful for your gynecologist or in the event of a hospital stay. You can specify the type of pill (rutine / special). Rutine pills are vitamins and other complex nutrients, which you should take every day in pregnant. Special pills are pills, which you take during disease.You can download your pill's list as PDF Report to show this list your doctor.
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

![Home Page Preview](pregnant_pills_app/static/files/img/previews/preview_pregnant_pills.jpg)

### Register user page
![Register user page](pregnant_pills_app/static/files/img/previews/preview_pregnant_pills_add_user.jpg)

### Admin page - all users

![Admin page - all users](pregnant_pills_app/static/files/img/previews/preview_pregnant_pills_users_list..jpg)

## Setup

- Clone This Project git clone
- Enter Project Directory cd Pregnant_Pills
- Create a Virtual Environment (for Windows) py -m venv (name your virtual enviroment :) venv

'EXAMPLE: py -m venv venv'

- Activate Virtual Environment source: venv/Scripts/activate
- Install Requirements Package pip install -r requirements.txt
- Finally Run The Project: python app.py

## Deployment Strategies

This project includes multiple infrastructure and deployment strategies:

- **EC2 + k3s + Kustomize (Spot instance)** – main branch  
- **EKS + Helm** – eks branch  
- **(Planned) EKS + Fargate** – future extension  

Detailed documentation can be found in the `/docs/deployment` directory.

## Deployment Variants

This project demonstrates multiple Kubernetes deployment approaches:

| Variant | Infrastructure | Deployment Tool | Ingress | DNS | Scaling |
|----------|---------------|----------------|---------|------|---------|
| EC2 + k3s | Terraform | Kustomize | Traefik | Route53 | Manual / HPA |
| EKS | Terraform | Helm | ALB | Route53 | Managed Node Groups |
| Fargate (planned) | Terraform | Helm | ALB | Route53 | Serverless Pods |


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
