# Creating a Cors-Anywhere Server on Google Cloud Run

## Clone cors-anywhere repo

```
git clone https://github.com/Rob--W/cors-anywhere.git
cd cors-anywhere
```

## Testing it locally

```
npm install
export PORT=8080
node server.js
```

So you can make a request through the proxy

```
curl -I -H "Origin: http://example.com" https://cors-anywhere-5avhfedkji-ew.a.run.app/http://google.com/
```

## Create a Dockerfile

FROM node:12.18

ENV PORT=8080

RUN mkdir /app
WORKDIR /app
COPY . .
RUN npm install

EXPOSE 8080

CMD [ "node", "server.js" ]
```

## Build a local container image

```
docker build -t cors-anywhere:0.4.3 .
```

## Test it locally

```
docker run -p 8080:8080 cors-anywhere:0.4.3
```

So you can make a request through the proxy

```
curl -I -H "Origin: http://example.com" https://127.0.0.1:8080/http://google.com/
```

## Build a container image and push it to Cloud Registry

```
docker build . --tag gcr.io/${PROJECT_ID}/cors-anywhere:0.4.3
docker push gcr.io/${PROJECT_ID}/cors-anywhere:0.4.3
```

## Check if Cloud Run API is enabled

```
gcloud services list --enabled --project ${PROJECT_ID} --filter="name:run.googleapis.com"
```

## Case you need to enable Cloud Run API

```
gcloud services enable run.googleapis.com --project ${PROJECT_ID}
```

## Deploy it to Cloud Run

```
gcloud run deploy cors-anywhere --image gcr.io/${PROJECT_ID}/cors-anywhere:0.4.3 --platform managed --allow-unauthenticated --region europe-west1
```

## Get the service URL

```
gcloud run services list --platform managed
```


