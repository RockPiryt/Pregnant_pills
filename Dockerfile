FROM python:3.11-slim
# Logi od razu w docker logs oraz brak zaśmiecania  plikami .pyc
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
# Instalacja zależności systemowych
RUN apt-get update && apt-get install -y \
    build-essential libpq-dev curl && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt
COPY . .
EXPOSE 8080
# CMD ["python", "pregnant_pills_app/app.py"] #lokalnie
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "wsgi:app"]