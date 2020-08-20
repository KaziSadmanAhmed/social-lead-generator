from fastapi import FastAPI

from . import database, models, routers

models.Base.metadata.create_all(bind=database.engine)

app = FastAPI()


app.include_router(routers.users.router, prefix="/api/v1/users", tags=["users"])
app.include_router(routers.auth.router, prefix="/api/v1/auth", tags=["auth"])