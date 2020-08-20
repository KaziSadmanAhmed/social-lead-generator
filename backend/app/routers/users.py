from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app import schemas, crud, auth
from app.utils import get_db

router = APIRouter()


@router.get("/", response_model=schemas.UserListResponse)
def list_users(db: Session = Depends(get_db), token: str = Depends(auth.get_current_active_user)):
    """
    List all the users
    """
    users = crud.users.all(db)
    return users
