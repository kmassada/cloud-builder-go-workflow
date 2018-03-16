# Cloud Builder Workflow

This workflow uses [Google Cloud Builder](https://cloud.google.com/container-builder/) to build a [go application](./test.go)'s source code that lives in [Google Cloud Registry](https://cloud.google.com/container-registry/) into a docker container.

## The Steps

### Build

The [go application](./test.go)'s source code is built into a binary using [Google Cloud Builder](https://cloud.google.com/container-builder/)'s docker step ([read more](https://github.com/GoogleCloudPlatform/cloud-builders) about steps).

```yaml
- name: 'gcr.io/cloud-builders/docker'
  args: [ 'build', '-t', 'gcr.io/$PROJECT_ID/docker/test-go-build', '.' ]
```

### Code

This Binary is then imported into a container that is built and pushed to Google Container Registry.

```yaml
# Build the image
- name: 'gcr.io/cloud-builders/docker'
  args: [ 'build', '-t', 'gcr.io/$PROJECT_ID/docker/test-go', '.' ]
images:
- 'gcr.io/$PROJECT_ID/docker/test-go'
```

### deploy

That image is then used in a deployment in GKE (Google Kubernetes Engine). The entire workflow relies on Google Cloud Builder

```yaml
steps:
- name: 'gcr.io/cloud-builders/kubectl'
  args:
  - 'set'
  - 'image'
  - 'deployment'
  - 'test-go-cb'
  - 'test-go-cb=gcr.io/$PROJECT_ID/docker/test-go'
```

## Steps

### Setup repo

```shell
gcloud source repos create test-go
gcloud source repos list
git init
git config credential.helper gcloud.sh
git remote add google \
https://source.developers.google.com/p/[PROJECT_ID]/r/[CLOUD_SOURCE_REPOSITORY_NAME]
git push google master
```

### setup artifacts locations

`gsutil mb gs://artifacts-[PROJECT_ID]/`

### allow your cloud builder to push to GKE

```shell
gcloud iam service-accounts describe $PROJECT_ID@cloudbuild.gserviceaccount.com

PROJECT_ID="$(gcloud projects describe \
    $(gcloud config get-value core/project -q) --format='get(projectNumber)')"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$PROJECT_ID@cloudbuild.gserviceaccount.com \
    --role=roles/container.developer
```

### run builds

```shell
alias container-build='gcloud container builds submit --config cloudbuild.yaml .'
export REPO=`pwd`

# build binary
cd $REPO/build
container-build

# build image
cd $REPO/code
container-build

# bootstrap
cd $REPO/bootstrap
container-build

# deploy
cd $REPO/deploy
container-build
```