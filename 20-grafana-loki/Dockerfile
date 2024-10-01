FROM python:3.12-alpine

RUN apk update

RUN adduser -D nonroot

USER nonroot

WORKDIR /api

COPY main.py requirements.txt ./

RUN pip install -r requirements.txt

EXPOSE 8000

ENTRYPOINT [ "python", "-m" ]

CMD ["fastapi", "run", "main.py"]