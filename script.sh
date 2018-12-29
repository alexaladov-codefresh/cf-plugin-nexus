#!/bin/bash

env_check(){
if [[ -z "$REPO_TYPE" ]]; then
    echo "Must provide REPO_TYPE variable" 1>&2
    exit 1
fi
if [[ -z "$REPO_URL" ]]; then
    echo "Must provide REPO_URL variable" 1>&2
    exit 1
fi
if [[ -z "$REPO_USERNAME" ]]; then
    echo "Must provide REPO_USERNAME variable" 1>&2
    exit 1
fi
if [[ -z "$REPO_PASSWORD" ]]; then
    echo "Must provide REPO_PASSWORD variable" 1>&2
    exit 1
fi
if [[ -z "$REPO_ARTIFACT_PATH" ]]; then
    REPO_ARTIFACT_PATH=.
    echo "REPO_ARTIFACT_PATH variable is not provided so empty will be used" 1>&2
fi
}

repo_npm(){
NODE_AUTH=$(echo -n "$REPO_USERNAME:$REPO_PASSWORD" | base64)

cat << EOF > /root/.npmrc
email=you@example.com
always-auth=true
_auth=$NODE_AUTH
EOF

cd "$REPO_ARTIFACT_PATH"
npm publish --registry $REPO_URL
}

repo_ruby(){
if [[ -z "$GEM_FILENAME" ]]; then
    echo "Must provide GEM_FILENAME variable" 1>&2
    exit 1
fi
cd "$REPO_ARTIFACT_PATH"
gem nexus --url $REPO_URL --credential $REPO_USERNAME:$REPO_PASSWORD  $GEM_FILENAME
}

repo_python(){
cd "$REPO_ARTIFACT_PATH"

cat << EOF > /root/.pypirc
[distutils]
index-servers=pypi-repo
[pypi-repo]
repository: $REPO_URL
username: $REPO_USERNAME
password: $REPO_PASSWORD
EOF

python setup.py sdist bdist_wheel
twine upload --repository pypi-repo dist/*
}

repo_raw(){
if [[ -z "$RAW_FILENAME" ]]; then
    echo "Must provide RAW_FILENAME variable" 1>&2
    exit 1
fi
cd "$REPO_ARTIFACT_PATH"

cat << EOF > /root/.nexus-cli 
{"nexus_verify": true, "nexus_pass": "$REPO_PASSWORD", "nexus_url": "$(echo $REPO_URL | cut -d'/' -f 1,2,3)", "nexus_user": "$REPO_USERNAME"}
EOF

nexus3 up $RAW_FILENAME  $(basename $REPO_URL)/$RAW_FILENAME/
}

env_check
case "$REPO_TYPE" in
        RAW)    repo_raw
            ;;
        NODEJS) repo_npm
            ;;
        PYTHON) repo_python
            ;;
        RUBY)   repo_ruby
            ;;
        *)
            echo "Provide : REPO_TYPE {RAW|NODEJS|PYTHON|RUBY}"
            exit 1
esac

