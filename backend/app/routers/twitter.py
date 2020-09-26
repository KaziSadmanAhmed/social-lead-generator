import os

from fastapi import APIRouter, Depends, status, HTTPException
import tweepy


from app import schemas, crud, auth
from app.utils import get_db

router = APIRouter()


@router.post("/tweets")
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


@router.get("/tweets")
def list_tweets(user: schemas.User = Depends(auth.get_current_active_user), response_model=schemas.TweetListResponse):
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

        tweets = [
            {
                "id": tweet.id,
                "text": tweet.text,
                "favorite_count": tweet.favorite_count,
                "retweet_count": tweet.retweet_count,
                "created_at": tweet.created_at,
                "user": {
                    "id": tweet.user.id,
                    "name": tweet.user.name,
                    "screen_name": tweet.user.screen_name,
                    "profile_image_url": tweet.user.profile_image_url
                }
            } for tweet in api.user_timeline()
        ]

        return {
            "success": True,
            "tweets": tweets
        }

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Cannot get tweets")


@router.get("/users")
def search_users(q: str, user: schemas.User = Depends(auth.get_current_active_user), response_model=schemas.TwitterUserListResponse):
    """
    Search users from twitter
    """

    try:
        consumer_key = os.getenv("TWITTER_CONSUMER_KEY")
        consumer_secret = os.getenv("TWITTER_CONSUMER_SECRET")

        auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
        auth.set_access_token(user.twitter_access_token,
                              user.twitter_access_token_secret)

        api = tweepy.API(auth)
        users = api.search_users(q)

        return {
            "success": True,
            "users": [
                {
                    "id": user.id,
                    "name": user.name,
                    "screen_name": user.screen_name,
                    "profile_image_url": user.profile_image_url
                } for user in users
            ]
        }

    except Exception:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Cannot search users")


@router.get("/users/{twitter_user_id}/tweets")
def list_tweets_by_user(twitter_user_id: int, user: schemas.User = Depends(auth.get_current_active_user), response_model=schemas.TweetListResponse):
    """
    List tweets by user id
    """

    try:
        consumer_key = os.getenv("TWITTER_CONSUMER_KEY")
        consumer_secret = os.getenv("TWITTER_CONSUMER_SECRET")

        auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
        auth.set_access_token(user.twitter_access_token,
                              user.twitter_access_token_secret)

        api = tweepy.API(auth)

        tweets = [
            {
                "id": tweet.id,
                "text": tweet.text,
                "favorite_count": tweet.favorite_count,
                "retweet_count": tweet.retweet_count,
                "created_at": tweet.created_at,
                "user": {
                    "id": tweet.user.id,
                    "name": tweet.user.name,
                    "screen_name": tweet.user.screen_name,
                    "profile_image_url": tweet.user.profile_image_url
                }
            } for tweet in api.user_timeline(twitter_user_id)
        ]

        return {
            "success": True,
            "tweets": tweets
        }

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Cannot get tweets")


@router.get("/trending/locations", response_model=schemas.TwitterTrendingLocationListResponse)
def list_trending_locations(user: schemas.User = Depends(auth.get_current_active_user)):
    """
    List all available trending locations
    """

    try:
        consumer_key = os.getenv("TWITTER_CONSUMER_KEY")
        consumer_secret = os.getenv("TWITTER_CONSUMER_SECRET")

        auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
        auth.set_access_token(user.twitter_access_token,
                              user.twitter_access_token_secret)

        api = tweepy.API(auth)

        trending_locations = [
            {
                "name": location["name"],
                "location_type": location["placeType"]["name"],
                "country": location["country"],
                "country_code": location["countryCode"],
                "woeid": location["woeid"]
            } for location in api.trends_available()
        ]

        return {
            "success": True,
            "locations": trending_locations
        }

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Cannot get locations")



@router.post("/trending/topics", response_model=schemas.TwitterTrendingTopicListResponse)
def list_trending_topics_by_location(location: schemas.TwitterTrendingTopicsRequest, user: schemas.User = Depends(auth.get_current_active_user)):
    """
    List trending topics by location
    """

    try:
        consumer_key = os.getenv("TWITTER_CONSUMER_KEY")
        consumer_secret = os.getenv("TWITTER_CONSUMER_SECRET")

        auth = tweepy.OAuthHandler(consumer_key, consumer_secret)
        auth.set_access_token(user.twitter_access_token,
                              user.twitter_access_token_secret)

        api = tweepy.API(auth)

        trending_topics = api.trends_place(location.woeid)

        return {
            "success": True,
            "topics": [
                {
                    "name": topic["name"],
                    "query": topic["query"],
                    "url": topic["url"],
                    "tweets_count": topic["tweet_volume"]
                } for topic in trending_topics[0]["trends"]
            ]
        }

    except Exception as e:
        print(e)
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN, detail="Cannot get topics")