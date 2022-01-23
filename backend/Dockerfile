FROM python:3-alpine

ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache make build-base libffi-dev

RUN mkdir /srv/backend
WORKDIR /srv/backend
COPY requirements.txt /srv/backend/
RUN pip install --no-cache-dir -r requirements.txt
COPY . /srv/backend/

EXPOSE 8000

CMD ["uvicorn", "--host", "0.0.0.0", "app:app", "--reload"]
