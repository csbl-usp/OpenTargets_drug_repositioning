def search_disease(x):
	from opentargets import OpenTargetsClient
	from sys import argv

	client = OpenTargetsClient()
	response = client.get_associations_for_disease(x)
	return response.to_dataframe()
