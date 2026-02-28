from pregnant_pills_app import db
from .enums import PillType


class Pill(db.Model):
    __tablename__ = "pills"

    id = db.Column(db.Integer, primary_key=True)
    type_pill = db.Column(db.Enum(PillType, name="pill_type"), nullable=False)
    name = db.Column(db.String(100), nullable=False)
    amount = db.Column(db.Integer, nullable=False)
    reason = db.Column(db.Text)
    date_start = db.Column(db.Date)
    date_end = db.Column(db.Date)
    
    user_id = db.Column(db.Integer, db.ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    user = db.relationship("User", back_populates="pills")

    def __repr__(self):
        return f"<Pill id={self.id} name={self.name} amount={self.amount} user_id={self.user_id}>"
