from pregnant_pills_app.report_pdf.views import PDF_report

def test_pdf_generation(tmp_path, new_user):
    file_path = tmp_path / "test.pdf"
    pdf = PDF_report(filename=str(file_path))
    pdf.generate_list(new_user)
    assert file_path.exists()
    assert file_path.stat().st_size > 0  # plik PDF nie jest pusty

    #Używamy fixture tmp_path z pytest do tworzenia tymczasowego pliku.