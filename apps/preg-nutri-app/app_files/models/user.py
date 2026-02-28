from flask_login import UserMixin
from werkzeug.security import generate_password_hash, check_password_hash

from pregnant_pills_app import db


class User(UserMixin, db.Model):
    __tablename__ = "users"

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.Text, nullable=False)
    surname = db.Column(db.Text, nullable=False)
    preg_week = db.Column(db.Integer)
    email = db.Column(db.Text, nullable=False, unique=True, index=True)
    password_hash = db.Column(db.String(255), nullable=False)

    pills = db.relationship(
        "Pill",
        back_populates="user",
        cascade="all, delete-orphan",
        lazy="selectin",
    )

    def __repr__(self):
        return f"<User id={self.id} email={self.email}>"

    # --- password helpers
    def set_password(self, password: str) -> None:
        self.password_hash = generate_password_hash(password)

    def check_password(self, password: str) -> bool:
        return check_password_hash(self.password_hash, password)

    # --- helpers
    def report_pills(self):
        return list(self.pills)
