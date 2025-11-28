#!/bin/sh

## Copyright (C) 2025 David Miguel Susano Pinto
##
## Copying and distribution of this file, with or without modification,
## are permitted in any medium without royalty provided the copyright
## notice and this notice are preserved.  This file is offered as-is,
## without any warranty.

## This is a sh "library" to be included in the shell scripts that
## handle our PGP encrypted vault password.  Shared variables and
## functions are declared here.


set -o errexit
set -o nounset
## Use TRACE=1 ./script.sh to enable tracing
if [ "${TRACE-0}" = "1" ]; then
    set -o xtrace
fi


ENCRYPTED_PASSWORD_FPATH="vault-password.gpg"


## This is the whole list of keys that we should use to encrypt the
## password.  Please name the keys after your robots username, in
## binary OpenPGP format, in the pgp-keys directory.
##
## No spaces in the filepaths!!!
PGP_KEYS="
pgp-keys/pinto.gpg
pgp-keys/prasanna.gpg
"


exit_if_no_password_file() {
    if [ ! -f "$ENCRYPTED_PASSWORD_FPATH" ]; then
        echo "Password file '$ENCRYPTED_PASSWORD_FPATH' does not exist" >&2
        exit 1;
    fi
}


construct_gpg_recipient_args() {
    ## Construct space delimited list of arguments for gpg recipients
    ## (we are writing for /bin/sh so we don't have arrays).
    recipient_args=""
    for key_fpath in $PGP_KEYS; do
        if [ ! -f "$key_fpath" ]; then
            echo "File '$key_fpath' does not exist" >&2
            exit 1;
        fi
        recipient_args="$recipient_args --recipient-file $key_fpath"
    done
    printf "%s" "$recipient_args"
}


encrypt_password() {
    ## We want word splitting.  construct_gpg_recipient_args returns a
    ## space delimited list of arguments (we are writing for /bin/sh
    ## so we don't have arrays).
    # shellcheck disable=SC2046
    gpg --encrypt $(construct_gpg_recipient_args)
}


prompt_and_encrypt_password() {
    echo "\
Reading new password from STDIN (ctrl-d to end input, twice if the
password does not end in a newline --- probably shouldn't).
" >&2
    printf "New vault password: " >&2
    encrypt_password
}

## Print password to stdout
decrypt_password() {
    exit_if_no_password_file

    gpg --decrypt \
        --batch --quiet --for-your-eyes-only --no-tty \
        "$ENCRYPTED_PASSWORD_FPATH"
}
