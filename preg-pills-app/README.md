# Pregnant Pills
Pregnant Pills is a web application designed to help pregnant women track and manage medications taken during pregnancy.

The system allows users to register, maintain a personalized list of pills, categorize them, specify pregnancy week, and generate a downloadable PDF report for medical consultations.

This project demonstrates both application development (Flask) and cloud-native deployment strategies (Kubernetes on AWS).

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Technology Stack](#technology-stack)
- [Application Structure](#application-structure)
- [Previews](#previews)
- [Local Setup](#local-setup)
- [Configuration](#configuration)
- [Testing](#testing)
- [Project Status](#project-status)
- [Future Improvements](#future-improvements)
- [License](#license)

---

## Overview

Pregnant Pills enables users to:
- Register and manage an account
- Track medications taken during pregnancy
- Categorize pills (routine / special)
- Store dosage, dates, and pregnancy week
- Generate a PDF report for medical visits

The application was originally built using Flask and SQLite, and later extended to support cloud-native deployment patterns.

---

## Features

### User Management
- User registration
- Login / logout
- User profile management

### Medication Tracking
- Add, edit, delete pills
- Categorize medications
- Track dosage and intake date
- Store pregnancy week information

### PDF Reporting
- Generate downloadable PDF summary
- Structured report suitable for medical consultation

### Error Handling
- Custom error pages (400, 401, 404, 415, 500)
- Centralized error handling via Flask blueprints

---

## Technology Stack

### Backend
- Python 3.11
- Flask 2.2.2
- SQLAlchemy 1.4.45
- WTForms 3.0.1

### Frontend
- Bootstrap 5.2.3
- Jinja2 Templates

### Database
- SQLite (development)
- PostgreSQL (optional / production-ready)

---

## Application Structure
preg-pills-app/
│
├── app_files/
│ ├── models/
│ ├── users/
│ ├── pills/
│ ├── errors/
│ ├── report_pdf/
│ ├── static/
│ └── templates/
│
├── migrations/
├── tests/
├── config.py
├── requirements.txt
└── wsgi.py

The project uses:
- Flask Blueprints for modular separation
- SQLAlchemy models for database abstraction
- Alembic for database migrations
- Pytest for testing

---

## Previews

### Home Page

![Home Page Preview](app_files/static/files/img/previews/preview_pregnant_pills.jpg)

### Register user page
![Register user page](app_files/static/files/img/previews/preview_pregnant_pills_add_user.jpg)

### Admin page - all users

![Admin page - all users](app_files/static/files/img/previews/preview_pregnant_pills_users_list..jpg)

## Local Setup

- Clone This Project git clone
- Enter Project Directory cd Pregnant_Pills
- Create a Virtual Environment (for Windows) py -m venv (name your virtual enviroment :) venv

'EXAMPLE: py -m venv venv'

- Activate Virtual Environment source: venv/Scripts/activate
- Install Requirements Package pip install -r requirements.txt
- Finally Run The Project: python app.py

---

## Configuration

Configuration is handled via `config.py`.

### Key Configuration Areas

- **Database URI**  
  Defines the connection string used by SQLAlchemy  
  (e.g., SQLite for development, PostgreSQL for production).

- **Secret Key**  
  Used for session management and CSRF protection.

- **Debug Mode**  
  Enables development debugging features.

- **Environment Separation**  
  Supports configuration profiles for:
  - Development
  - Testing
  - Production

---

## Testing

### Run Tests

```bash
pytest
```
Test Coverage Includes

- User authentication
- Pill management (CRUD operations)
- Error handling
- PDF generation

---

## Project Status

Project is: _in progress_

---

## Future Improvements

### Application

- Enforce authentication for PDF download
- Improve PDF layout and formatting
- Add role-based access (admin / user)
- Improve validation and error handling

---

## Contact

- Created by [@RockPiryt Github](https://github.com/RockPiryt)
- My Resume [@RockPiryt Resume](https://rockpiryt.github.io/Personal_Site/)

Feel free to contact me!

---

## License

This project is open source and available under the [MIT License]
