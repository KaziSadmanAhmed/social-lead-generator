import datetime

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy import Boolean, Column, ForeignKey, Integer, String, DateTime
from sqlalchemy.orm import relationship


Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    full_name = Column(String(50))
    hashed_password = Column(String(100))
    is_active = Column(Boolean, default=True)
    joined_at = Column(DateTime, default=datetime.datetime.utcnow)
    twitter_access_token = Column(String(100))
    twitter_access_token_secret = Column(String(100))
