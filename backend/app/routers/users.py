from fastapi import APIRouter, Depends

from app import schemas, crud, auth
from app.utils import get_db

router = APIRouter()


@router.get("/me", response_model=schemas.UserResponse)
def list_users(user: str = Depends(auth.get_current_active_user)):
    """
    Get details of authenticated user
    """
    return {
        "success": True,
        "user": user
    }
