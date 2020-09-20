import os

from fastapi import APIRouter, Depends, status, HTTPException
import tweepy


from app import schemas, crud, auth
from app.utils import get_db

router = APIRouter()


@router.post("/tweet")
def post_tweet(tweet: schemas.Tweet, user: schemas.User = Depends(auth.get_current_active_user), response_model=schemas.BaseResponse):
    """
    Post tweet to authenticated user's twitter timeline
    """

    try:
        consumer_key = os.getenv("TWITTER_CONSUMER_KEY")
        consumer_secret = os.getenv("TWITTER_CONSUMER_SECRET")

        auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
        auth.set_access_token(user.twitter_access_token,
                              user.twitter_access_token_secret)

        api = tweepy.API(auth)

        api.update_status(tweet.text)

        return {
            "success": True,
        }

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Cannot post tweet")


@router.get("/tweet/list")
def list_tweet(user: schemas.User = Depends(auth.get_current_active_user), response_model=schemas.TweetListResponse):
    """
    List tweets from the authenticated user's twitter timeline
    """

    try:
        consumer_key = os.getenv("TWITTER_CONSUMER_KEY")
        consumer_secret = os.getenv("TWITTER_CONSUMER_SECRET")

        auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
        auth.set_access_token(user.twitter_access_token,
                              user.twitter_access_token_secret)

        api = tweepy.API(auth)

        tweet_list = [{
            "id": tweet.id,
            "text": tweet.text,
            "favorite_count": tweet.favorite_count,
            "retweet_count": tweet.retweet_count,
            "created_at": tweet.created_at,
            "user": {
                "name": tweet.user.name,
                "screen_name": tweet.user.screen_name,
                "profile_image_url": tweet.user.profile_image_url
            }
        } for tweet in api.user_timeline()]

        return {
            "success": True,
            "tweet_list": tweet_list
        }

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Cannot post tweet")
