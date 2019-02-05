#!/bin/bash -e

# Setup Working Directory ---------------------------------------------------

mkdir -p ${deploy_dir}
tmp_dir=$(mktemp -d)

# Install Required Packages -------------------------------------------------

apt-get update
apt-get install -y supervisor unzip

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"
unzip awscli-bundle.zip
./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

# Download and Unpack Deploy Package ----------------------------------------

package_name=$(basename ${deploy_package_s3_uri})
package_path="$tmp_dir/$package_name"

aws s3 cp ${deploy_package_s3_uri} $package_path

tar xzf $package_path --strip-components=1 -C ${deploy_dir}

# Configure Supervisor Processes --------------------------------------------

uuid=$(cat /proc/sys/kernel/random/uuid)
cat > /etc/supervisor/conf.d/${role}.conf <<EOF
${supervisor_config}
EOF

supervisorctl reload
