"""New form AddPillForm

Revision ID: 6021e404aa5b
Revises: fc3e7eeb7e0a
Create Date: 2023-02-05 12:45:07.490318

"""
from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision = '6021e404aa5b'
down_revision = 'fc3e7eeb7e0a'
branch_labels = None
depends_on = None


def upgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('pills', schema=None) as batch_op:
        batch_op.add_column(sa.Column('choose_pill', sa.String(length=100), nullable=True))
        batch_op.add_column(sa.Column('add_date', sa.DateTime(timezone=True), server_default=sa.text('(CURRENT_TIMESTAMP)'), nullable=True))
        batch_op.alter_column('name',
               existing_type=sa.TEXT(),
               type_=sa.String(length=100),
               nullable=True)
        batch_op.alter_column('type_pill',
               existing_type=sa.TEXT(),
               type_=sa.String(length=40),
               existing_nullable=True)
        batch_op.alter_column('week_start',
               existing_type=sa.INTEGER(),
               nullable=True)

    # ### end Alembic commands ###


def downgrade():
    # ### commands auto generated by Alembic - please adjust! ###
    with op.batch_alter_table('pills', schema=None) as batch_op:
        batch_op.alter_column('week_start',
               existing_type=sa.INTEGER(),
               nullable=False)
        batch_op.alter_column('type_pill',
               existing_type=sa.String(length=40),
               type_=sa.TEXT(),
               existing_nullable=True)
        batch_op.alter_column('name',
               existing_type=sa.String(length=100),
               type_=sa.TEXT(),
               nullable=False)
        batch_op.drop_column('add_date')
        batch_op.drop_column('choose_pill')

    # ### end Alembic commands ###
