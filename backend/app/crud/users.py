from sqlalchemy.orm import Session

from app import models, schemas, auth


def get(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()


def get_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()


def all(db: Session):
    return {
        "success": True,
        "users": db.query(models.User).all()
    }


def create(db: Session, user: schemas.UserRegisterRequest):
    hashed_password = auth.get_password_hash(user.password)
    db_user = models.User(email=user.email, hashed_password=hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user