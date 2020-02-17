def search_known_drugs(x):
	from opentargets import OpenTargetsClient
	from sys import argv

	client = OpenTargetsClient()
	response = client.get_evidence_for_disease(x)
	return response.to_dataframe()
