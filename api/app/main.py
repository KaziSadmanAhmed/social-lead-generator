import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from . import database, models, routers

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()

origins = os.getenv("ALLOWED_ORIGINS", "").split(",")


app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(
    routers.healthcheck.router,
    prefix="/api/v1/healthcheck",
    tags=["healthcheck"]
)

app.include_router(
    routers.users.router,
    prefix="/api/v1/users",
    tags=["users"]
)
app.include_router(
    routers.auth.router,
    prefix="/api/v1/auth",
    tags=["auth"]
)
app.include_router(
    routers.twitter.router,
    prefix="/api/v1/twitter",
    tags=["twitter"]
)
