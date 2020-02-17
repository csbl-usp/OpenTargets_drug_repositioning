def search_new_drugs(x):
	from opentargets import OpenTargetsClient
	from sys import argv

	client = OpenTargetsClient()
	response = client.search(x)
	return response.to_dataframe()
