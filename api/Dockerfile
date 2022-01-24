FROM python:3-alpine

ENV PYTHONUNBUFFERED 1

RUN apk add --no-cache make build-base libffi-dev

RUN mkdir /srv/api
WORKDIR /srv/api
COPY requirements.txt /srv/api/
RUN pip install --no-cache-dir -r requirements.txt
COPY . /srv/api/

EXPOSE 8000

CMD ["uvicorn", "--host", "0.0.0.0", "app:app", "--reload"]
