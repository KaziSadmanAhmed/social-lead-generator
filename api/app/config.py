import os

from pydantic import BaseSettings


class Settings(BaseSettings):
    env: str = os.getenv("ENV", "dev")
    db_host: str = os.getenv("DB_HOST", "./db.sqlite3")
    db_host_dns_record_type = os.getenv("DB_HOST_DNS_RECORD_TYPE", "A")
    db_port: int = int(os.getenv("DB_PORT", 0))
    db_name: str = os.getenv("DB_NAME", "")
    db_user: str = os.getenv("DB_USER", "")
    db_password: str = os.getenv("DB_PASSWORD", "")
    app_name: str = os.getenv("APP_NAME", "Social Lead Generator")
    admin_email: str = os.getenv("ADMIN_EMAIL", "hello@sadman.xyz")
    secret_key: str = os.getenv("SECRET_KEY", "SECREY KEY")
    hash_algo: str = os.getenv("HASH_ALGO", "HS256")
    access_token_expiration: int = int(
        os.getenv("ACCESS_TOKEN_EXPIRATION", 86400)
    )


settings = Settings()
