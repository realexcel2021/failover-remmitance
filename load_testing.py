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
bearer = "eyJraWQiOiJ1XC9JY0xoU2FSeFVDS0wrdk1GaHh2djIyUDVOclpjXC9vcmp1YVo2eFlpTXM9IiwiYWxnIjoiUlMyNTYifQ.eyJzdWIiOiIxNDg4YTRlOC1jMDExLTcwM2UtZWRkZi01N2U1YWM1ZTJlOTMiLCJpc3MiOiJodHRwczpcL1wvY29nbml0by1pZHAudXMtZWFzdC0xLmFtYXpvbmF3cy5jb21cL3VzLWVhc3QtMV9LTlhFQ215ZnEiLCJjb2duaXRvOnVzZXJuYW1lIjoiMTQ4OGE0ZTgtYzAxMS03MDNlLWVkZGYtNTdlNWFjNWUyZTkzIiwib3JpZ2luX2p0aSI6IjgwYTFkYTM4LWJmOWMtNDE3NS1hNTI1LTNjNDE4ZTM0YWNkNyIsImF1ZCI6IjFpaWh0ZHZvMzdjcGpqcTNlNmRncThwMXU4IiwiZXZlbnRfaWQiOiJmYmIwM2UxNi0xYmRmLTRiNzEtOTY3OC1lYTRiNTQ1YzI2OGQiLCJ0b2tlbl91c2UiOiJpZCIsImF1dGhfdGltZSI6MTcxOTY4NDM1NiwiZXhwIjoxNzE5Njg3OTU2LCJpYXQiOjE3MTk2ODQzNTYsImp0aSI6ImQ0MTEyOGVmLTFhOTgtNDhmNi1iNDVkLWZhOWY0ODA0MmQ1NyIsImVtYWlsIjoiYWRtaW5AZGVtby5kZXZvcHNsb3JkLmNvbSJ9.RoI-pXJ8bQsHdEj9mUbTJ-k0TYz3HqAPwcH2l32gNPF3geKZbSLVfc15WOWuPrec-LPDGrduw4FA6ggq-0zN3lXKqNfVcXN30MO38uEZrlVsPFlB97_LznfsMpmJ8ENhFywwUWD-FbOFeFROamG5xY8otuQJ4dZLcPnRbwAApAhZ4cxHvXhLYbn4Iong9HtvEi7Aa8mMvx30ougU6pkBhqcGWRnbvmOpBVpfC4cEMMoPZ_BhNW2_HXhYakRM_vFD3Qrdh55yf72YseRevEw1Ma_xpPFeYXo0T_ga_0k7oooAqtV0_OqOYdoL0CBHOkk8bxBRwvVxWeAfZ3kOMw00Mw" # get authentication bearer from cognito


headers = {
    "Content-Type": "application/json",
    "Authorization": f"Bearer {bearer}"
}


for i in range(0, 20):
    send_data = requests.post(
    url=url,
    json=payload,
    headers=headers
    )   

    print(f"request succeded with status code: {send_data.status_code}")
