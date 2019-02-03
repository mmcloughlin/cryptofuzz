#!/bin/bash -e

# Setup Working Directory ---------------------------------------------------

mkdir -p ${deploy_dir}
tmp_dir=$(mktemp -d)

# Install Required Packages -------------------------------------------------

apt-get update
apt-get install -y awscli supervisor

# Download and Unpack Deploy Package ----------------------------------------

package_name=$(basename ${deploy_package_s3_uri})
package_path="$tmp_dir/$package_name"

aws s3 cp ${deploy_package_s3_uri} $package_path

tar xzf $package_path --strip-components=1 -C ${deploy_dir}

# Configure Supervisor Processes --------------------------------------------

cat > /etc/supervisor/conf.d/${target}.conf <<EOF
[program:${target}]
command=${deploy_dir}/bin/go-fuzz -bin=${target_dir}/bin.zip -workdir=${target_dir}
process_name=${target}
autostart=true
stdout_logfile=${target_dir}/stdout
stdout_logfile_maxbytes=1MB
stdout_logfile_backups=2
stderr_logfile=${target_dir}/stderr
stderr_logfile_maxbytes=1MB
stderr_logfile_backups=2
EOF

supervisorctl reload
