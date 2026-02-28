
from flask import Blueprint, send_file
from io import BytesIO
from fpdf import FPDF
from pregnant_pills_app.models import User, Pill

#------------------------------Register Blueprint
report_pdf_blueprint = Blueprint("report_pdf", __name__, template_folder="templates/report_pdf")


class PDF_report:
    def generate_bytes(self, user):
        pills = Pill.query.filter_by(user_id=user.id).all()

        pdf = FPDF(orientation="P", unit="pt", format="A4")
        pdf.set_auto_page_break(auto=True, margin=40)
        pdf.add_page()

        #-----------------------------------Title
        pdf.set_font(family="Arial", style="B", size=18)
        pdf.cell(0, 30, "List of pills during pregnancy", ln=1, align="C")
        pdf.ln(6)

        #---------------------------------User info
        pdf.set_font(family="Arial", style="B", size=12)
        full_name = f"{user.name} {getattr(user, 'surname', '')}".strip()
        pdf.cell(0, 18, f"User: {full_name}", ln=1)
        pdf.ln(10)

        #-----------------------------------Pills info
        # ---- Table headers
        headers = ["Type", "Name", "Amount", "Reason", "Date start", "Date end"]
        col_w = [70, 110, 55, 150, 75, 75]
        row_h = 18

        # Header row
        pdf.set_font(family="Arial", style="B", size=10)
        for i, h in enumerate(headers):
            pdf.cell(col_w[i], row_h, h, border=1, align="C")
        pdf.ln(row_h)

        # Rows
        pdf.set_font(family="Arial", style="", size=9)

        def fmt_date(d):
            return d.strftime("%Y-%m-%d") if d else ""

        for pill in pills:
            type_str = pill.type_pill.name if hasattr(pill.type_pill, "name") else str(pill.type_pill)
            reason_str = pill.reason or ""

            pdf.cell(col_w[0], row_h, type_str, border=1)
            pdf.cell(col_w[1], row_h, pill.name, border=1)
            pdf.cell(col_w[2], row_h, str(pill.amount), border=1, align="C")

            x_before = pdf.get_x()
            y_before = pdf.get_y()

            pdf.multi_cell(col_w[3], row_h, reason_str, border=1) # Reason as multi_cell

            y_after = pdf.get_y()
            used_h = y_after - y_before
            if used_h < row_h:
                used_h = row_h

            pdf.set_xy(x_before + col_w[3], y_before)

            pdf.cell(col_w[4], used_h, fmt_date(pill.date_start), border=1)  # Date start / end 
            pdf.cell(col_w[5], used_h, fmt_date(pill.date_end), border=1)
            pdf.ln(used_h)

        pdf_bytes = pdf.output(dest="S").encode("latin-1")
        return pdf_bytes

#------------------------------Views
@report_pdf_blueprint.route("/pdf_download/<int:user_primary_key>", methods=["GET"])
def pdf_download(user_primary_key):
    user = User.query.get_or_404(user_primary_key)

    pdf_report = PDF_report()
    pdf_bytes = pdf_report.generate_bytes(user)

    buffer = BytesIO(pdf_bytes)
    buffer.seek(0)

    filename = f"pills_user_{user.id}.pdf"
    return send_file(
        buffer,
        mimetype="application/pdf",
        as_attachment=True,
        download_name=filename
    )

