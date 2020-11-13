"""
Connect senior:Mainland
"""
import pandas as pd
import json
import requests
def ssql(sql):
    admin_token = '2cebeb5c7edac5ef0d7c5a640e69fc7d43bf2cd6a24ce43dfee3dd33662c0bab'
    url = 'http://sensor.wb-intra.com/api/sql/query?token=%s&project=production' % admin_token
    data = {'q': sql, 'format': 'json'}
    req = requests.post(url,data)
    req_dec = req.content.decode()
    try:
        req_json = json.loads('[' + req_dec.replace('\n', ',')[:-1] + ']')
        df_d_id = pd.DataFrame(req_json)
        return df_d_id
    except:
        print(req_dec)