import os

from fastapi import Request, APIRouter, Depends, HTTPException, status
from fastapi.responses import RedirectResponse
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
import tweepy

from app import schemas, crud, auth
from app.utils import get_db

from app.config import settings

router = APIRouter()


@router.post("/register", response_model=schemas.UserResponse, status_code=status.HTTP_201_CREATED)
def register(user: schemas.UserRegisterRequest, db: Session = Depends(get_db)):
    db_user = crud.users.get_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT,
                            detail="Email already registered")
    registered_user = crud.users.create(db=db, user=user)

    return {
        "success": True,
        "user": registered_user
    }


def authenticate_user(db, username: str, password: str):
    user = crud.users.get_by_email(db, email=username)
    if not user or not auth.verify_password(password, user.hashed_password):
        return False
    return user


@router.post("/login", response_model=schemas.TokenResponse)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"}
        )
    access_token = auth.create_access_token(data={"sub": user.email})
    return {
        "success": True,
        "token": {
            "access_token": access_token,
            "token_type": "bearer"
        }
    }


@router.get("/twitter/connect")
def twitter_connect(user: str = Depends(auth.get_current_active_user), response_model=schemas.TwitterConnectResponse):
    consumer_key = os.getenv("TWITTER_CONSUMER_KEY")
    consumer_secret = os.getenv("TWITTER_CONSUMER_SECRET")
    callback_url = os.getenv("TWITTER_CALLBACK_URL")
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret, callback_url)

    try:
        authorization_url = auth.get_authorization_url()
        return {
            "success": True,
            "authorization": {
                "url": authorization_url
            }
        }
    except tweepy.TweepError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Error! Failed to get request token."
        )

    
@router.post("/twitter/callback")
def twitter_callback(oauth_data: schemas.TwitterCallbackRequest, db: Session = Depends(get_db), user: str = Depends(auth.get_current_active_user), response_model=schemas.BaseResponse):

    consumer_key = os.getenv("TWITTER_CONSUMER_KEY")
    consumer_secret = os.getenv("TWITTER_CONSUMER_SECRET")
    callback_url = os.getenv("TWITTER_CALLBACK_URL")
    oauth_token = oauth_data.oauth_token
    oauth_verifier = oauth_data.oauth_verifier
    auth = tweepy.OAuthHandler(consumer_key, consumer_secret, callback_url)

    auth.request_token = {
        "oauth_token": oauth_token,
        "oauth_token_secret": oauth_verifier
    }

    try:
        auth.get_access_token(oauth_verifier)

        user.twitter_access_token = auth.access_token
        user.twitter_access_token_secret = auth.access_token_secret

        db.commit()

        return {
            "success": True
        }

    except tweepy.TweepError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Error! Failed to get request token."
        )