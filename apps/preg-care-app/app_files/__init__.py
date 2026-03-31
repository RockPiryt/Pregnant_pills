from flask import Flask, render_template


def create_app():
    app = Flask(__name__)

    @app.route("/")
    def index():
        modules = [
            {
                "name": "Preg Baby",
                "path": "/baby",
                "description": "Baby development, fetal movement tracking, and weekly pregnancy insights."
            },
            {
                "name": "Preg Memo",
                "path": "/memo",
                "description": "Pregnancy journal, memory keeping, and personal milestones."
            },
            {
                "name": "Preg Nutri",
                "path": "/nutri",
                "description": "Nutrition support, food safety, and healthy pregnancy diet guidance."
            },
            {
                "name": "Preg Org",
                "path": "/org",
                "description": "Planning tools, checklists, hospital bag, and pregnancy organization."
            },
            {
                "name": "Preg Pills",
                "path": "/pills",
                "description": "Medication tracking, dosage records, and pregnancy health monitoring."
            },
        ]

        return render_template("home.html", modules=modules)

    @app.get("/health")
    def health():
        return {"status": "ok"}, 200

    return app


app = create_app()