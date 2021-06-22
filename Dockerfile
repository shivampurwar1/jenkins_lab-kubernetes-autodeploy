FROM python:3.7-alpine
RUN mkdir /app
WORKDIR /app
COPY requirements.txt requirements.txt
RUN pip install -r requirements.txt
COPY . .
CMD gunicorn -w 4 -b 0.0.0.0:8080 hello_world:APP
