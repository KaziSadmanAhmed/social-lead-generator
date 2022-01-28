from typing import Any, Dict

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from .config import settings

connect_args: Dict[str, Any] = {}

if settings.env == "prod":
    db_host = settings.db_host
    db_port = settings.db_port

    if settings.db_host_dns_record_type == "SRV":
        import dns.resolver

        db_host_records = dns.resolver.query(db_host, "SRV")

        if len(db_host_records) > 0:
            db_host = db_host_records[0].target.to_text().rstrip(".")
            db_port = db_host_records[0].port

    SQLALCHEMY_DATABASE_URL = f"postgresql://{settings.db_user}:{settings.db_password}@{db_host}:{db_port}/{settings.db_name}"

else:
    SQLALCHEMY_DATABASE_URL = f"sqlite:///{settings.db_host}"
    connect_args["check_same_thread"] = False

engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args=connect_args
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
