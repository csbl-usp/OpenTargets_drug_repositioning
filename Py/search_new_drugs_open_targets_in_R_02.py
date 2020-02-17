def search_drug(x):
	import requests
	import pandas as pd
	from opentargets import OpenTargetsClient

	drug = x
	symbol_array = []
	score_array = []
	drug_array = []
	r = requests.get('https://platform-api.opentargets.io/v3/platform/public/search',
	params={"q":drug})

	for i in range(0,len(r.json()['data'])):
		gene_id = r.json()['data'][i]['id']
		if "ENSG" in gene_id:
			symbol = r.json()['data'][i]['data']['approved_symbol']
			score = r.json()['data'][i]['score']
			symbol_array.append(symbol)
			score_array.append(score)
			drug_array.append(drug)
	
	dataframe_to_return = pd.DataFrame({'drug':drug_array, 'symbol':symbol_array,'score':score_array})
	return(dataframe_to_return)


	
	
