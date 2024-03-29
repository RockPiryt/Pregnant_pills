"""empty message

Revision ID: 852ab7a49236
Revises: 696df4f08854
Create Date: 2023-07-20 13:42:26.347136

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '852ab7a49236'
down_revision = '696df4f08854'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('users', schema=None) as batch_op:
        batch_op.alter_column('surname',
               existing_type=sa.TEXT(),
               nullable=False)
        batch_op.alter_column('email',
               existing_type=sa.TEXT(),
               nullable=False)
        batch_op.create_unique_constraint(None, ['email'])

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('users', schema=None) as batch_op:
        batch_op.drop_constraint(None, type_='unique')
        batch_op.alter_column('email',
               existing_type=sa.TEXT(),
               nullable=True)
        batch_op.alter_column('surname',
               existing_type=sa.TEXT(),
               nullable=True)

    # ### end Alembic commands ###
