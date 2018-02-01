# Kibana and elastic search stack with "get started" data
This Docker build gets you started with Kibana instance running sample data mentioned on https://www.elastic.co/guide/en/kibana/current/getting-started.html

This build will start a Elastic search and Kibana UI stack and then runs a ruby script to make rest calls to create mappings, indexes, visualisations and dashboard based on example data.

Prereq - 2GB RAM free in order to Kibana and Elasticsearch

This docker build can be pulled from https://hub.docker.com/r/anilampops/kibana_devel/ so no need to build from scratch to test

#Deployment instructions

#Method 1 - Deploying from scratch

1. Clone this project
2. Run Docker build command
3. Run the Image
3. Launch HTTP broswer and open localhost:5601

#Method 2 - Deploying from prebuilt image

1. Docker pull docker pull anilampops/kibana_devel:latest
2. Run Image
