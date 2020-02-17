def search_drug(x):
	from opentargets import OpenTargetsClient
	from sys import argv

	client = OpenTargetsClient()
	drug = x
	response = client.search(drug)
	return response.to_dataframe()

