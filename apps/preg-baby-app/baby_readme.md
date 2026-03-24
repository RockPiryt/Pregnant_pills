## Baby Development Modules - Pregnant Baby App

### Fetal Movement Tracker  
Track baby activity and movement patterns.

**Features:**
- Kick counter
- Baby activity journal
- Alerts for decreased movement
- What's happening with mom and baby each week
- Baby size comparisons (fruits / objects)
- Developmental milestones

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

## Features

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

## Application Structure
preg-pills-app/
│
├── app_files/
│ ├── models/
│ ├── users/
│ ├── baby/
│ ├── errors/
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

![Home Page Preview](app_files/static/files/img/previews/preview_pregnant_baby.jpg)


## Local Setup

- Clone This Project git clone
- Enter Project Directory cd preg-baby-app
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


## Project Status

Project is: _in progress_

---

## Future Improvements

---

## Contact

- Created by [@RockPiryt Github](https://github.com/RockPiryt)
- My Resume [@RockPiryt Resume](https://resume.paulinakimak.com)

Feel free to contact me!

---

## License

This project is open source and available under the [MIT License]
