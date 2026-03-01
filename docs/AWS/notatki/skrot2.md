
aws ssm start-session \
  --target i-XXXXXXXXXXXX \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["6443"],"localPortNumber":["6443"]}' \
  --region eu-west-1


  W drugim terminalu możesz sprawdzić czy port odpowiada:

curl -k https://127.0.0.1:6443

Jeśli K3s działa, zobaczysz odpowiedź API (może być JSON z błędem auth — to OK).


  