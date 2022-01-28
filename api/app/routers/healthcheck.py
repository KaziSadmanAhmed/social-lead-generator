from fastapi import APIRouter, Depends, status
from fastapi.responses import JSONResponse
from sqlalchemy.orm import Session

from app import crud, schemas
from app.enums import HealthCheckStatus
from app.utils import get_db

router = APIRouter()


@router.get(
    "/status",
    response_model=schemas.HealthCheckRespose,
    status_code=status.HTTP_200_OK
)
def get_health_status(db: Session = Depends(get_db)):
    """
    Get health status
    """
    is_status_healthy = crud.healthcheck.get_status(db)

    if is_status_healthy:
        return {
            "success": True,
            "status": HealthCheckStatus.healthy.value
        }

    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "success": False,
            "status": HealthCheckStatus.unhealthy.value
        }
    )
