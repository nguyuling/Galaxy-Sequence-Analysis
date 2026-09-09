from bioblend.galaxy import GalaxyInstance
import os
from dotenv import load_dotenv

# connect to the galaxy server
load_dotenv()
galaxy_url = "https://usegalaxy.org"
api_key = os.getenv("API_KEY")
gi = GalaxyInstance(url=galaxy_url, key=api_key)

# create a new history for the project
new_history = gi.histories.create_history(name="Template")

# search for a specific metagenomics tool
tools = gi.tools.get_tools(name="Kraken2")
if tools:
    print(f"Found tool: {tools[0]['name']} (ID: {tools[0]['id']})")