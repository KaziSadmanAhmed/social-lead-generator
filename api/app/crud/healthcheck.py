from sqlalchemy.orm import Session


def get_status(db: Session) -> bool:
    try:
        db.execute("SELECT 1;")

    except Exception as e:
        print(e)
        return False

    return True
