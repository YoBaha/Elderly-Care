import requests
import time

url = 'https://sign-language-api-a443.onrender.com'
while True:
    try:
        response = requests.get(url)
        print(f'Pinged {url}: {response.status_code}')
    except Exception as e:
        print(f'Error pinging {url}: {e}')
    time.sleep(600)  # 10 minutes