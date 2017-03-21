#! /bin/bash -e

TMP_SSH_DIRECTORY="/tmp/.ssh/"
if [ -d "$TMP_SSH_DIRECTORY" ]; then

	mkdir -p /home/$1/.ssh

	# Copy ssh data to user home
	cp -R "$TMP_SSH_DIRECTORY" /home/$1/

	chmod -Rc 700 /home/$1/.ssh
	ls -lia /home/$1/.ssh

	# Create known_hosts
	touch /home/$1/.ssh/known_hosts

	# Add SaibGit key
	ssh-keyscan SaibGit >> /home/$1/.ssh/known_hosts

	# Remove temporal ssh data
	rm -rf "$TMP_SSH_DIRECTORY"
fi

/opt/sts-bundle/sts-3.8.2.RELEASE/STS
