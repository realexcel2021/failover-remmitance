import requests

payload = {
    "senderName": "Another Name",
    "senderBank": "Sample Bank",
    "senderAccount": "1101121",
    "receiverName": "Sample Nmae",
    "receiverBank": "TestBank2",
    "receiverAccount": "112110211",
    "amount": "40000"
}

url = "https://demo.devopslord.com/create-remittance"
bearer = "" # get authentication bearer from cognito


headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {bearer}"
}


for i in range(0, 10000):
    send_data = requests.post(
    url=url,
    json=payload,
    headers=headers
    )   

    print(f"request succeded with status code: {send_data.status_code}")
