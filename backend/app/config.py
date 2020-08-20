import os

from pydantic import BaseSettings


class Settings(BaseSettings):
    app_name: str = "Social Lead Generator"
    admin_email: str = "hello@sadman.xyz"
    secret_key: str = os.getenv("SECRET_KEY")
    hash_algo: str = os.getenv("HASH_ALGO", "HS256")
    access_token_expiration: int = os.getenv("ACCESS_TOKEN_EXPIRATION", 86400)


settings = Settings()
