"""Create an admin user. Administrative role cannot be self-assigned via the API."""

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from app.core.security import hash_password
from app.db.session import SessionLocal
from app.models.user import User, UserRole
from app.repositories.user_repository import UserRepository


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--email", required=True)
    parser.add_argument("--password", required=True)
    parser.add_argument("--full-name", default="MemoryGuide Admin")
    args = parser.parse_args()

    db = SessionLocal()
    try:
        repo = UserRepository(db)
        email = args.email.lower()
        if repo.get_by_email(email):
            raise SystemExit(f"User already exists: {email}")
        user = User(
            email=email,
            password_hash=hash_password(args.password),
            role=UserRole.ADMIN,
            full_name=args.full_name,
            is_active=True,
        )
        repo.add(user)
        db.commit()
        print(f"Created admin {email} id={user.id}")
    finally:
        db.close()


if __name__ == "__main__":
    main()
