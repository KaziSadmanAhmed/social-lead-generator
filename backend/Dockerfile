FROM python:3.8.5
ENV PYTHONUNBUFFERED 1
RUN mkdir /srv/backend
WORKDIR /srv/backend
COPY requirements.txt /srv/backend/
RUN pip install --no-cache-dir -r requirements.txt
COPY . /srv/backend/