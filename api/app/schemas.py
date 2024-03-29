from typing import Optional, List, Dict
from datetime import datetime

from pydantic import BaseModel, Field, HttpUrl


class UserBase(BaseModel):
    email: str
    full_name: Optional[str] = None


class User(UserBase):
    id: int = Field(title="ID")
    is_active: bool = Field(title="Active Status")
    joined_at: datetime = Field(title="Joined Date Time")

    class Config:
        orm_mode = True


class UserDetails(User):
    twitter_access_token: Optional[str] = None
    twitter_access_token_secret: Optional[str] = None


class BaseRequest(BaseModel):
    pass


class UserRegisterRequest(BaseRequest, UserBase):
    password: str


class UserLoginRequest(BaseRequest, UserBase):
    password: str


class BaseResponse(BaseModel):
    success: bool = Field(title="Success Status")


class HealthCheckRespose(BaseResponse):
    status: str = Field(title="Health check status")


class UserResponse(BaseResponse):
    user: UserDetails


class Token(BaseModel):
    access_token: str
    token_type: str


class TokenData(BaseModel):
    username: Optional[str] = None


class TwitterAuthorization(BaseModel):
    url: str = Field(title="Authorization URL")


class TwitterConnectResponse(BaseResponse):
    authorization: TwitterAuthorization


class TwitterCallbackRequest(BaseRequest):
    oauth_token: str = Field()
    oauth_verifier: str = Field()


class TwitterUser(BaseModel):
    id: str = Field()
    name: str = Field()
    screen_name: str = Field()
    profile_image_url: str = Field()


class TwitterUserList(BaseModel):
    users: List[TwitterUser]


class TwitterUserListResponse(BaseResponse, TwitterUserList):
    pass


class Tweet(BaseModel):
    id: Optional[int] = Field()
    text: str = Field()
    favorite_count: Optional[int] = Field()
    retweet_count: Optional[int] = Field()
    created_at: Optional[datetime] = Field()
    user: Optional[TwitterUser]


class TweetList(BaseModel):
    tweets: List[Tweet]


class TweetListResponse(BaseResponse, TweetList):
    pass


class TwitterTrendingLocation(BaseModel):
    name: str = Field()
    location_type: str = Field()
    country: Optional[str] = Field()
    country_code: Optional[str] = Field()
    woeid: int = Field(title="WOEID")


class TwitterTrendingLocationList(BaseModel):
    locations: List[TwitterTrendingLocation]


class TwitterTrendingLocationListResponse(BaseResponse, TwitterTrendingLocationList):
    pass


class TwitterTrendingTopicsRequest(BaseRequest):
    woeid: int = Field(title="WOEID")


class TwitterTrendingTopic(BaseModel):
    name: str = Field()
    query: str = Field()
    url: HttpUrl = Field()
    tweets_count: Optional[int] = Field()


class TwitterTrendingTopicList(BaseModel):
    topics: List[TwitterTrendingTopic]


class TwitterTrendingTopicListResponse(BaseResponse, TwitterTrendingTopicList):
    pass
