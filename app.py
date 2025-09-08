from pregnant_pills_app import app

if __name__ == "__main__":
    # app.run(debug=True, host="localhost", use_reloader=False)
    app.run(debug=True, host="0.0.0.0", port=8080, use_reloader=False)
    

# localhost tylko lokalnie
# 0.0.0.0 nasłuchiwanie na wszytskich interfejsach

# Flask
# standardowy port to 5000
# use_reloader=true przeładowanie applikacji jeżeli coś się zmieni w plikach