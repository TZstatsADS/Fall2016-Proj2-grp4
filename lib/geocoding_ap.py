import pandas as pd
import urllib
import json,time

path = '/Users/pengfeiwang/Desktop/prj2/data/sampling_data.csv'
dta = pd.read_csv(path)

dta['Intersecting Street'] = dta['Intersecting Street'].map(lambda x: str(x).replace('nan',''))
dta['House Number'] = dta['House Number'].map(lambda x: str(x).replace('nan',''))
dta['Address'] = dta['House Number']+' '+dta['Street Name']+' '+dta['Intersecting Street']
dta['Address'] = dta['Address'].map(lambda x: str(x).strip())
dta['Address'] = dta['Address'] + ', NY'
dta['Address'] = dta['Address'].map(lambda x: x.replace(' ','+'))

#api_key = 'AIzaSyDtZ57gLs_CRxTD83RMXnzzR1EGEW0_LwA'
#api_key2 = 'AIzaSyBupPonFNOAVk8gDdj37D9ezFVxRpv2wFY'
#api_key3 = 'AIzaSyD04o-Z2gxOBcZo1Sr4ERnsxHf1yqQI9Qo'

out_put_path = '/Users/pengfeiwang/Desktop/'

def Get_Location(start, end, api_key, out_put_path, dta):
    parts_dict = {}
    for user_index in range(start, end):
        address = dta['Address'][user_index]
        url = 'https://maps.googleapis.com/maps/api/geocode/json?address='+address+'&key='+str(api_key)
        html = urllib.urlopen(url).read()
        content = json.loads(html)
        if content['status'] == 'OK':
            lat = content['results'][0]['geometry']['location']['lat']
            lng = content['results'][0]['geometry']['location']['lng']
        else:
            lat = None
            lng = None
            
        parts_dict[user_index] = [lat,lng]
        # time.sleep(0.1)
        print "√ Finished No." + str(user_index)+"-----"
        
    location_df = pd.DataFrame.from_dict(parts_dict,orient = 'index')
    location_df.columns = ['lat','lng']
    location_df.to_csv(out_put_path+str(start)+'_'+str(end)+'.csv')
    # Every 50 runs cost 1.1774000000002616 s

# test
start = 10000
end = 12500
Get_Location(start,end,api_key3,out_put_path, dta)