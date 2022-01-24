import os

from pydantic import BaseSettings


class Settings(BaseSettings):
    env: str = os.getenv("ENV", "dev")
    app_name: str = os.getenv("APP_NAME", "Social Lead Generator")
    admin_email: str = os.getenv("ADMIN_EMAIL", "hello@sadman.xyz")
    secret_key: str = os.getenv("SECRET_KEY", "SECREY KEY")
    hash_algo: str = os.getenv("HASH_ALGO", "HS256")
    access_token_expiration: int = int(
        os.getenv("ACCESS_TOKEN_EXPIRATION", 86400)
    )
