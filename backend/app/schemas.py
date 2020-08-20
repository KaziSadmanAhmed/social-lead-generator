from typing import Optional, List
from datetime import datetime

from pydantic import BaseModel, Field


class UserBase(BaseModel):
    email: str
    full_name: Optional[str] = None


class UserRegisterRequest(UserBase):
    password: str


class UserLoginRequest(UserBase):
    password: str


class User(UserBase):
    id: int = Field(title="ID")
    is_active: bool = Field(title="Active Status")
    joined_at: datetime = Field(title="Joined Date Time")

    class Config:
        orm_mode = True


class BaseResponse(BaseModel):
    success: bool = Field(title="Success Status")


class UserListResponse(BaseResponse):
    users: List[User]


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    username: Optional[str] = None