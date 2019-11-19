#!/bin/sh

# check if the .bash_profile exists - if so, source it and apply the Marvel Keys
# the Marvel keys should be defined by MARVEL_PUBLIC_KEY and MARVEL_PRIVATE_KEY in ~/.bash_profile
# If storying the keys in a different file, please update `source ~/.bash_profile` to the file containing the 
# keys.

if [ -f ~/.bash_profile ]; then
	source ~/.bash_profile

	/usr/libexec/PlistBuddy -c "Set :MarvelPrivateKey ${MARVEL_PRIVATE_KEY}" "${PROJECT_DIR}/${INFOPLIST_FILE}"
	/usr/libexec/PlistBuddy -c "Set :MarvelPublicKey ${MARVEL_PUBLIC_KEY}" "${PROJECT_DIR}/${INFOPLIST_FILE}"
fi

